//
//  File.swift
//  
//
//  Created by sridharan R on 02/09/22.
//

import Foundation

public struct MFALocationModel : Codable {
    public var accuracy: Int16?
    public var dateTime: String?
    public var lat: Double?
    public var long: Double?
    public var version: String?
    
    static func decode(data : Data) -> MFALocationModel? {
        return ApiHelper.decodeData(data)
    }
    
    func encode() -> NSString {
        if let data = ApiHelper.encodeToData(data: self), let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as NSString? {
            return json
        }
        return ""
    }
}
