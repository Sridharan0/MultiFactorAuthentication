//
//  OauthVerificationStatus.swift
//  
//
//  Created by sridharan R on 07/09/22.
//

import Foundation

public struct OauthVerificationStatus : Codable {
    let trackingId : String
    let status : String
    let updatedAt : String
    let maxRetries : Int
    let expiresAt : String
    let timesTried : Int
    
    static func decode(_ data : Data?) -> OauthVerificationStatus? {
        return OauthVerificationStatus.decodeData(data)
    }
    
    enum VerificationStatus: String {
        case Verified
        case Pending
    }
}

struct OauthVerificationError : Codable {
    var code : String
    var developerMessage : String?
    var entity : String?
    var properties : Properties?
    
    struct Properties : Codable {
        var recipient : [String?]?
    }
}
