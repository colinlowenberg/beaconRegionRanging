//
//  LocationManager.swift
//

import Foundation
import CoreLocation
import MulticastDelegateSwift

class LocationManager: NSObject {

    static var shared = LocationManager()

    var manager = CLLocationManager()
    var delegate = MulticastDelegate<LocationManagerDelegate>()

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.allowsBackgroundLocationUpdates = true
        manager.startMonitoringSignificantLocationChanges()
    }
}

// CLLocationManagerDelegate implemantation
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didUpdateLocations: locations)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didUpdateHeading: newHeading)
        }
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didDetermineState: state, for: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didRangeBeacons: beacons, in: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        delegate |> { delegate in
            delegate.locationManager?(manager, rangingBeaconsDidFailFor: region, withError: error)
        }
    }

    /*
    @available(iOS 13.0, *)
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didRange: beacons, satisfying: beaconConstraint)
        }
    }

    @available(iOS 13.0, *)
    func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didFailRangingFor: beaconConstraint, error: error)
        }
    }
     */

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didEnterRegion: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didExitRegion: region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didFailWithError: error)
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        delegate |> { delegate in
            delegate.locationManager?(manager, monitoringDidFailFor: region, withError: error)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didChangeAuthorization: status)
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didStartMonitoringFor: region)
        }
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        delegate |> { delegate in
            delegate.locationManagerDidPauseLocationUpdates?(manager)
        }
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        delegate |> { delegate in
            delegate.locationManagerDidResumeLocationUpdates?(manager)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didFinishDeferredUpdatesWithError: error)
        }
    }

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        delegate |> { delegate in
            delegate.locationManager?(manager, didVisit: visit)
        }
    }
}

// MARK: LocationManagerDelegate protocol
@objc protocol LocationManagerDelegate {


    /*
     *  locationManager:didUpdateLocations:
     *
     *  Discussion:
     *    Invoked when new locations are available.  Required for delivery of
     *    deferred locations.  If implemented, updates will
     *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
     *
     *    locations is an array of CLLocation objects in chronological order.
     */
    @available(iOS 6.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])


    /*
     *  locationManager:didUpdateHeading:
     *
     *  Discussion:
     *    Invoked when a new heading is available.
     */
    @available(iOS 3.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)


    /*
     *  locationManagerShouldDisplayHeadingCalibration:
     *
     *  Discussion:
     *    Invoked when a new heading is available. Return YES to display heading calibration info. The display
     *    will remain until heading is calibrated, unless dismissed early via dismissHeadingCalibrationDisplay.
     */
    // @available(iOS 3.0, *)
    @available(*, unavailable, message: "should be implemented in Location Manager singleton")
    @objc optional func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool


    /*
     *  locationManager:didDetermineState:forRegion:
     *
     *  Discussion:
     *    Invoked when there's a state transition for a monitored region or in response to a request for state via a
     *    a call to requestStateForRegion:.
     */
    @available(iOS 7.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion)


    /*
     *  locationManager:didRangeBeacons:inRegion:
     *
     *  Discussion:
     *    Invoked when a new set of beacons are available in the specified region.
     *    beacons is an array of CLBeacon objects.
     *    If beacons is empty, it may be assumed no beacons that match the specified region are nearby.
     *    Similarly if a specific beacon no longer appears in beacons, it may be assumed the beacon is no longer received
     *    by the device.
     */
    @available(iOS, introduced: 7.0, deprecated: 13.0)
    @objc optional func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)


    /*
     *  locationManager:rangingBeaconsDidFailForRegion:withError:
     *
     *  Discussion:
     *    Invoked when an error has occurred ranging beacons in a region. Error types are defined in "CLError.h".
     */
    @available(iOS, introduced: 7.0, deprecated: 13.0)
    @objc optional func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error)


    /*
    @available(iOS 13.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint)


    @available(iOS 13.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error)
     */


    /*
     *  locationManager:didEnterRegion:
     *
     *  Discussion:
     *    Invoked when the user enters a monitored region.  This callback will be invoked for every allocated
     *    CLLocationManager instance with a non-nil delegate that implements this method.
     */
    @available(iOS 4.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)


    /*
     *  locationManager:didExitRegion:
     *
     *  Discussion:
     *    Invoked when the user exits a monitored region.  This callback will be invoked for every allocated
     *    CLLocationManager instance with a non-nil delegate that implements this method.
     */
    @available(iOS 4.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)


    /*
     *  locationManager:didFailWithError:
     *
     *  Discussion:
     *    Invoked when an error has occurred. Error types are defined in "CLError.h".
     */
    @available(iOS 2.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)


    /*
     *  locationManager:monitoringDidFailForRegion:withError:
     *
     *  Discussion:
     *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
     */
    @available(iOS 4.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)


    /*
     *  locationManager:didChangeAuthorizationStatus:
     *
     *  Discussion:
     *    Invoked when the authorization status changes for this application.
     */
    @available(iOS 4.2, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)


    /*
     *  locationManager:didStartMonitoringForRegion:
     *
     *  Discussion:
     *    Invoked when a monitoring for a region started successfully.
     */
    @available(iOS 5.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion)


    /*
     *  Discussion:
     *    Invoked when location updates are automatically paused.
     */
    @available(iOS 6.0, *)
    @objc optional func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager)


    /*
     *  Discussion:
     *    Invoked when location updates are automatically resumed.
     *
     *    In the event that your application is terminated while suspended, you will
     *    not receive this notification.
     */
    @available(iOS 6.0, *)
    @objc optional func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager)


    /*
     *  locationManager:didFinishDeferredUpdatesWithError:
     *
     *  Discussion:
     *    Invoked when deferred updates will no longer be delivered. Stopping
     *    location, disallowing deferred updates, and meeting a specified criterion
     *    are all possible reasons for finishing deferred updates.
     *
     *    An error will be returned if deferred updates end before the specified
     *    criteria are met (see CLError), otherwise error will be nil.
     */
    @available(iOS 6.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?)


    /*
     *  locationManager:didVisit:
     *
     *  Discussion:
     *    Invoked when the CLLocationManager determines that the device has visited
     *    a location, if visit monitoring is currently started (possibly from a
     *    prior launch).
     */
    @available(iOS 8.0, *)
    @objc optional func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit)
}
