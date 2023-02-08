//
//  MFALocation+CLLocation+MFALocationModel.swift
//  
//
//  Created by sridharan R on 25/08/22.
//

import CoreLocation

extension MFALocation {
    public func getCLLocation() -> CLLocation {
        return CLLocation(latitude: CLLocationDegrees(self.lat), longitude: CLLocationDegrees(self.long))
    }
    
    func getMFALocationModel() -> MFALocationModel {
        return MFALocationModel(accuracy: self.accuracy, dateTime: self.dateTime, lat: self.lat, long: self.long, version: self.version)
    }
}

extension Array where Element == MFALocation {
    public func getCLLocations() -> [CLLocation] {
        var clLocations : [CLLocation] = []
        if let mfaLocations = self as? [MFALocation] {
            for mfaLocation in mfaLocations {
                clLocations.append(mfaLocation.getCLLocation())
            }
        }
        return clLocations
    }
    
    public func getMFALocationModels() -> [MFALocationModel] {
        var clLocations : [MFALocationModel] = []
        if let mfaLocations = self as? [MFALocation] {
            for mfaLocation in mfaLocations {
                clLocations.append(mfaLocation.getMFALocationModel())
            }
        }
        return clLocations
    }
    
}
