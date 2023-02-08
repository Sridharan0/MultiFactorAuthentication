//
//  MFAOtpRequest.swift
//  
//
//  Created by sridharan R on 20/10/22.
//

import Foundation

struct MFAOtpRequest : Codable {
    var deviceId : String? // a unique device id
    var version : String? // the version number of the upload service
    var otpPin: String?
}
