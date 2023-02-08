//
//  MFALocation+CoreDataProperties.swift
//  AMD sample
//
//  Created by sridharan R on 26/08/22.
//
//

import Foundation
import CoreData


extension MFALocation {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MFALocation> {
        return NSFetchRequest<MFALocation>(entityName: "MFALocation")
    }

    @NSManaged public var accuracy: Int16
    @NSManaged public var dateTime: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var uploadStatus: Bool
    @NSManaged public var version: String?

}

extension MFALocation : Identifiable {

}
