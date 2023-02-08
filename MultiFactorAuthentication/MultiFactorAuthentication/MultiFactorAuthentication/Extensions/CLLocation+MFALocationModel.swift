//
//  CLLocation+MFALocationModel.swift
//  
//
//  Created by sridharan R on 25/08/22.
//

import CoreLocation

extension CLLocation{
    public func getMFALocation(_ version: String = "1") -> MFALocationModel {
        var mfaLocation = MFALocationModel()
        mfaLocation.lat = Double(self.coordinate.latitude)
        mfaLocation.long = Double(self.coordinate.longitude)
        mfaLocation.version = version
        mfaLocation.accuracy = Int16(self.horizontalAccuracy) //positional error in meters related to the latitude, longitude coordinate.
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd hh:mm a"
        mfaLocation.dateTime = Date().iso8601withFractionalSeconds //formatter.string(from: Date())
        return mfaLocation
    }
}
