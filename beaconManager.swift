//
//  beaconManager.swift
//

protocol BeaconErrorDelegate {
    func showError(error: Error)
}

enum BeaconManagerError: Error {
    case unknown(error: Error?)
    case tooManyMonitoredRegions
}

class BeaconManager: NSObject, BeaconErrorDelegate {
    static let shared = BeaconManager()
    private let server: CMEAPIServer = CMELiveServer()

    var beacons = [Beacon]()
    var alertTimer: TimeInterval!

    fileprivate var shouldRangeBeacons = false
    fileprivate var isRequestingBeacons = false
    fileprivate var internalLocationManager: CLLocationManager
    fileprivate var locationAuthorizationRequestCompletion: LocationAuthorizationRequestCompletion?

    fileprivate let maximumMonitoredRegions = 20
    fileprivate let targetBeaconProximity = CLProximity.immediate
    fileprivate let sentaraBeaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!,
                                                         identifier: "HITEC 2018 Beacons")

    typealias LocationAuthorizationRequestCompletion = (_ authorizationStatus: CLAuthorizationStatus) -> Void

    var isRangingBeacons: Bool {
        return internalLocationManager.sentara_isRanging(sentaraBeaconRegion)
    }

    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }

    var inRangeBeacon: Beacon? {
        didSet {
            if inRangeBeacon == nil {
                BeaconAlertManager.shared.shouldIgnoreBeaconDetection = false
            }
        }
    }

    //  - Lifecycle
    override init() {
        internalLocationManager = CLLocationManager()
        super.init()

        internalLocationManager.delegate = self
        loadBeaconData()
        alertTimer = 60
    }

    //  - Beacons

    /**
     Starts looking for beacons.

     - note: Apple's guidance on this is: "The recommended practice is to use the region monitoring
     service to detect the presence of beacons first and to start ranging only after you detect one
     or more beacons." However, this method simplifies the process by combining monitoring for
     beacons with ranging for beacons, automatically starting to range for beacons after they have
     been detected.
     */
    func startRangingBeacons() throws {
        print("Start Ranging Beacons")
        shouldRangeBeacons = true

        internalLocationManager.allowsBackgroundLocationUpdates = true
        internalLocationManager.startUpdatingLocation()

        if internalLocationManager.monitoredRegions.count == (maximumMonitoredRegions - 1) {
            print("Error: Location manager cannot monitor more than \(maximumMonitoredRegions) regions at a time.")
            throw BeaconManagerError.tooManyMonitoredRegions
        }

        internalLocationManager.startMonitoring(for: sentaraBeaconRegion)

        internalLocationManager.requestState(for: sentaraBeaconRegion)
    }

    func stopRangingBeacons() {
        print("Stop Ranging Beacons")
        shouldRangeBeacons = false

        internalLocationManager.allowsBackgroundLocationUpdates = false

        internalLocationManager.stopRangingBeacons(in: sentaraBeaconRegion)
        internalLocationManager.stopMonitoring(for: sentaraBeaconRegion)
        internalLocationManager.stopUpdatingLocation()
    }

    func requestAuthorization(withCompletion completion: LocationAuthorizationRequestCompletion?) {
        locationAuthorizationRequestCompletion = completion
        internalLocationManager.requestAlwaysAuthorization()
    }
}

extension BeaconManager {

    fileprivate func loadBeaconData() {
        CMELiveServer.isTokenValid { (token, valid) in
            if valid == true {
                if let jwtToken = token {
                    self.tokenFetchDidSucceed(jwtToken)
                }
            } else {
                self.server.getToken { [weak self] (result) in

                    switch result {

                    case .failure(error: let error):

                        self?.tokenDidFail(error)

                    case .success(token: let token):

                        self?.tokenFetchDidSucceed(token)
                    }
                }
            }
        }
    }

    fileprivate func tokenDidFail(_ error: Error?) {
        beaconUpdateDidFail(error)
    }

    fileprivate func tokenFetchDidSucceed(_ token: String) {
        server.getBeaconItems(withToken: token) { (result) in
            switch result {
            case .failure(error: let error):

                self.beaconUpdateDidFail(error)

            case .success(items: let items):

                self.beaconItemsUpdateDidSucceed(items)
            }
        }
    }

    fileprivate func beaconUpdateDidFail(_ error: Error?) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.showError(error: error)
            }
        }
    }

    fileprivate func beaconItemsUpdateDidSucceed(_ items: [Beacon]) {
        beacons = items.sorted {
            $0.beaconName < $1.beaconName
        }
        internalLocationManager.startRangingBeacons(in: sentaraBeaconRegion)
    }
}

extension BeaconManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch region {
        case is CLBeaconRegion:
            didDetermineStateForBeaconRegion(state)
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

        if isMonitoring(region: region) == true {
            BeaconAlertManager.shared.exitBeaconRanage()
        }
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        Answers.logCustomEvent(withName: "Beacon Ranging Error", customAttributes: ["error": error.localizedDescription])
        showError(error: error)
    }
}

extension BeaconManager {
    /**
     Makes sure that the region isn't one that the Location Marketing framework is monitoring.
     */
    fileprivate func isMonitoring(region: CLRegion) -> Bool {
        switch region {
        case is CLBeaconRegion:
            return (region.identifier == sentaraBeaconRegion.identifier)
        default:
            return false
        }
    }

    func didDetermineStateForBeaconRegion(_ state: CLRegionState) {
        switch state {
        case .inside:
            print("Inside Range")
            shouldRangeBeacons = true
            if shouldRangeBeacons && (isRangingBeacons == false) {
                internalLocationManager.startRangingBeacons(in: sentaraBeaconRegion)
            }
        case .outside:
            print("Outside Range")
            if isRangingBeacons {
                internalLocationManager.stopRangingBeacons(in: sentaraBeaconRegion)
            }

            inRangeBeacon = nil

        case .unknown:

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in

                guard let strongSelf = self else { return }

                strongSelf.internalLocationManager.requestState(for: strongSelf.sentaraBeaconRegion)
            })
        }
    }
}

private extension CLLocationManager {
    func sentara_isRanging(_ region: CLBeaconRegion) -> Bool {
        return rangedRegions.contains(where: { (candidate) -> Bool in
            region.identifier == candidate.identifier
        })
    }
}

extension BeaconErrorDelegate {
    func showError(error: Error) {
        let alert = PWAlertFactory().alertForBeaconRangingError(error)

        AlertPresenter.shared.enqueue(alert: alert)
    }
}
