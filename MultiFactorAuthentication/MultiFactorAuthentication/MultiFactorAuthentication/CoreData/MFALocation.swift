//
//  MFALocation.swift
//  AMD sample
//
//  Created by sridharan R on 26/08/22.
//

import Foundation
import CoreData

@objc(MFALocation)
public class MFALocation : NSManagedObject {
    
    static func fetchMfaLocationModel() -> [MFALocationModel] {
        return CoreDataManager.shared.fetchLocationData().getMFALocationModels()
    }
    
}
