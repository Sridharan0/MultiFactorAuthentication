//
//  SendVerificationRequest.swift
//  
//
//  Created by sridharan R on 07/09/22.
//

import Foundation

struct SendVerificationRequest : Codable {
    let type : String //"code"
    let method : String //"sms", "voice".
    let recipient : String //'+' and country code
}
