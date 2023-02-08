//
//  CoreLocationHelper.swift
//  
//
//  Created by sridharan R on 15/09/22.
//

import UIKit
import CoreLocation

public class CoreLocationHelper {
    public static let sharedInstance = CoreLocationHelper()
    
    
    /// To get the Current Location
    ///    - Give requestWhenInUseAuthorization()
    ///    - And get the user's Current Location by once Whenever the function gets triggered
    ///
    /// - Parameter completionHandler: This is used to send back the Locations to the callers
    /// - Parameter vc: pass current view controller to handle location permission deny
    public func getCurrentLocation(_ completionHandler: @escaping (CLLocation?)->(), _ vc : UIViewController? = nil) {
        CoreLocationService.sharedInstance.getCurrentLocation(completionHandler, vc)
    }
    
    /// To get the Background Locations
    ///    - Give requestAlwaysAuthorization()
    ///    - To start the Location updates
    ///
    /// - Parameter completionHandler: This is used to send back the Background Locations to the callers
    /// - Parameter vc: pass current view controller to handle location permission deny
    public func getBackgroundLocation(completionHandler: @escaping (CLLocation?)->(), _ vc : UIViewController? = nil){
        CoreLocationService.sharedInstance.getBackgroundLocation(completionHandler: completionHandler, vc)
    }
    
    /// This function is used to stop updating locations
    public func stopLocationService(){
        CoreLocationService.sharedInstance.stopLocationService()
    }
    
}
