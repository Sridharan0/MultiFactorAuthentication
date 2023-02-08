//
//  CoreLocationService.swift
//
//
//  Created by sridharan R on 10/06/22.
//

import CoreLocation
import UIKit

class CoreLocationService: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = CoreLocationService()
    
    let locationManager = CLLocationManager()
    var completion:((CLLocation?)->())? = nil
    
    var viewController : UIViewController? = nil
    
    var isOneTime = true
    
    var isLocationServiceOn : Bool? = nil
    
    /// To get the Current Location
    ///    - Give requestWhenInUseAuthorization()
    ///    - And get the user's Current Location by once Whenever the function gets triggered
    ///
    /// - Parameter completionHandler: This is used to send back the Locations to the callers
    /// - Parameter vc: pass current view controller to handle location permission deny
    func getCurrentLocation(_ completionHandler: @escaping (CLLocation?)->(), _ vc : UIViewController? = nil) {
        viewController = vc
        self.completion = completionHandler
        isOneTime = true
        if checkPermission() {
            locationManager.startUpdatingLocation()
            if let location = locationManager.location {
                completionHandler(location)
                self.completion = nil
                if UserDefaultsHelper.getData(type: Bool.self, forKey: .isLocationServiceOn) ?? false == false {
                    locationManager.stopUpdatingLocation()
                }
            }
        }
    }
    
    /// To get the Background Locations
    ///    - Give requestAlwaysAuthorization()
    ///    - To start the Location updates
    ///
    /// - Parameter completionHandler: This is used to send back the Background Locations to the callers
    /// - Parameter vc: pass current view controller to handle location permission deny
    func getBackgroundLocation(completionHandler: @escaping (CLLocation?)->(), _ vc : UIViewController? = nil){
        isOneTime = false
        viewController = vc
        self.completion = completionHandler
        if checkPermission(true) {
            startLocationChanges()
        }
    }
    
    /// Initiate the location service
    func startLocationChanges() {
        locationManager.requestAlwaysAuthorization()
        UserDefaultsHelper.setData(value: true, key: .isLocationServiceOn)
        locationManager.distanceFilter = 10 //meters
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer //more accurate
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
    }
    
    /// Initiate the location service with battery efficient in background
    func startSignificantLocationChanges() {
        locationManager.requestAlwaysAuthorization()
        changeLocationService(isOn: true)
        locationManager.distanceFilter = 50 //meters
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers //less accurate
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startUpdatingLocation()
            // The device does not support this service.
            return
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func changeLocationService(isOn : Bool) {
        UserDefaultsHelper.setData(value: isOn, key: .isLocationServiceOn)
        CoreLocationService.sharedInstance.isLocationServiceOn = isOn
    }
    
    /// This function is used to stop updating locations
    func stopLocationService(){
        changeLocationService(isOn: false)
        locationManager.stopUpdatingLocation()
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.completion?(location)
            if isOneTime {
                self.completion = nil
                isOneTime = false
                if !MfaHelper.isLocationPermissionActive() {
                    locationManager.stopUpdatingLocation()
                }
                return
            }
            guard MfaHelper.isLocationPermissionActive() else{
                return
            }
            PushNotification.sharedInstance.scheduleNotification(data: location)
            NetworkManager.uploadLocation(locations: [location.getMFALocation()]){ response , error in
                if error != nil {
                    CoreDataManager.shared.saveLocationData(location.getMFALocation())
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                if let completion = completion {
                    if isOneTime {
                        getCurrentLocation(completion)
                    }else{
                        getBackgroundLocation(completionHandler: completion)
                    }
                }
            case .restricted, .denied:
                if let completion = completion {
                    guard !isOneTime else {
                        if let viewController = viewController {
                            showPermissionDeniedAlert(viewController)
                        }else if let rootVc = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
                            showPermissionDeniedAlert(rootVc)
                        }else {
                            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                        }
                        return
                    }
                    completion(nil)
                }
            case .notDetermined:
                let _ = checkPermission()
            default:
                return
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
        if let error = error as? CLError, error.code == .denied {
            locationManager.stopUpdatingLocation()
            return
        }
    }
    
    /// Check core location permission and request for permission
    /// - Parameter isAlways: request location Always Authorization
    /// - Returns: `Bool` - status of core location permission
    func checkPermission(_ isAlways : Bool = false) -> Bool {
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .denied , .restricted:
            if let viewController = viewController {
                showPermissionDeniedAlert(viewController)
            }else if let rootVc = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
                showPermissionDeniedAlert(rootVc)
            }else {
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
            }
            return false
        case .authorizedWhenInUse:
            if isAlways {
                locationManager.requestAlwaysAuthorization()
            }
            return true
        case .authorizedAlways:
            return true
        default:
            locationManager.requestAlwaysAuthorization()
        }
        return false
    }
    
    func showPermissionDeniedAlert(_ vc : UIViewController) {
        vc.showQuestionAlert(withTitle: NSLocalizedString("Permission denied", bundle: Bundle.main, comment: "Permission denied by user"), message: NSLocalizedString("Need location permission to fetch location. Please click Yes to allow permission.", bundle: Bundle.main, comment: "Location permission description"), handler: { _ in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }, { _ in
            if let completion = self.completion {
                completion(nil)
            }
        })
    }
}

