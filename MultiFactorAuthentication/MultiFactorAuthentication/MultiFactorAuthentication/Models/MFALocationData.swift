//
//  MFALocationData.swift
//  
//
//  Created by sridharan R on 26/08/22.
//

import Foundation

struct MFALocationDatas : Codable {
    var deviceId : String? // a unique device id
    var version : String? // the version number of the upload service
    var data : [MFALocationModel]?
}

struct MFALocationData : Codable {
    var deviceId : String? // a unique device id
    var version : String? // the version number of the upload service
    var data : MFALocationModel?
}
