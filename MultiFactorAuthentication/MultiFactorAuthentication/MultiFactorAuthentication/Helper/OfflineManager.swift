//
//  OfflineManager.swift
//
//  This class is for handling offline data
//
//  Created by sridharan R on 02/09/22.
//

import Foundation

class OfflineManager {
    
    /// Uploads all location data and clear them from core data manager
    class func uploadLocalLocations(_ completionHandler: ((Bool) -> Void)? = nil) {
        let mfalocations = CoreDataManager.shared.fetchLocationData()
        if mfalocations.count > 0 {
            let mfalocationModels = mfalocations.getMFALocationModels()
            NetworkManager.uploadLocation(locations: mfalocationModels, completionHandler: { response, _ in
                if response != nil {
                    for mfalocation in mfalocations {
                        mfalocation.uploadStatus = true
                    }
                    CoreDataManager.shared.save()
                    CoreDataManager.shared.deleteLocationData()
                    completionHandler?(true)
                }else{
                    completionHandler?(false)
                }
            })
        }else{
            //send last location to server
            CoreLocationHelper.sharedInstance.getCurrentLocation({ currentLoc in
                if let currentLoc = currentLoc {
                    UserDefaultsHelper.setData(value: currentLoc.getMFALocation().encode(), key: .lastLocationData)
                }
            })
            completionHandler?(true)
        }
        
    }
}
