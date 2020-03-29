import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var nameLabel: UILabel!
    var locationManager: CLLocationManager?
    var alertShown: Bool?
    var beaconDict: [String: String]?
    var labelName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        alertShown = false

        view.backgroundColor = .gray  // default is in "unknown mode"

    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // Can we monitor beacons or not?
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                //  Can we detect the distance of a beacon?
                if CLLocationManager.isRangingAvailable() {
                    startScanning(uuid: UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!, major: 123, minor: 456, identifier: "Apple Beacon", name: "Apple")
                    startScanning(uuid: UUID(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6")!, major: 123, minor: 456, identifier: "Radius Beacon", name: "Radius")
                    startScanning(uuid: UUID(uuidString: "5AFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!, major: 123, minor: 456, identifier: "Red Bear Beacon", name: "Red Bear")
                    startScanning(uuid: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 123, minor: 456, identifier: "Estimote", name: "Estimote")
                }
            }
        }
    }

    func beaconAlert() {
        alertShown = true
        let ac = UIAlertController(title: "Beacon Detected", message: "A beacon has been detected", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }

    func startScanning(uuid: UUID, major: UInt16, minor: UInt16, identifier: String, name: String) {
        let uuidApple = uuid
        let beaconRegion1 = CLBeaconRegion(proximityUUID: uuidApple, major: major, minor: minor, identifier: identifier)
        locationManager?.startMonitoring(for: beaconRegion1)
        locationManager?.startRangingBeacons(in: beaconRegion1)
        labelName = name
    }

    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)
        if let beacon = beacons.first {
            if !alertShown! { beaconAlert() }
            nameLabel.text = labelName
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
}
