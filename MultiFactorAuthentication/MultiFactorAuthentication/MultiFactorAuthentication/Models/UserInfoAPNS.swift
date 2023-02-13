//
//  UserInfoAPNS.swift
//  
//
//  Created by sridharan R on 19/07/22.
//

import Foundation
import SwiftUI

public struct UserInfoAPNS : Codable, Equatable {
    var aps : APS?
    var actionToken: String?
    var verificationNumbers: String?
    var headers:Headers?
        
    enum APNsType : String, CaseIterable {
        case BIOMETRIC = "BIOMETRIC"
        case OTP = "OTP"
        case PushOTP = "PUSHOTP"
        case Location = "LOCATION"
        case VideoConference = "VIDEOCONFERENCE"
        case StatusUpdate = "STATUSUPDATE"
        case RandomNumber = "RANDOMNUMBER"
        case NONE = ""
    }
    
    enum VideoConferenceType: String {
        case requestAuth
        case verifyAuth
    }
    
    public static func == (lhs: UserInfoAPNS, rhs: UserInfoAPNS) -> Bool {
        return lhs.actionToken == rhs.actionToken && lhs.aps?.alert?.body == rhs.aps?.alert?.body
    }
    
    func checkAuthType(authTypes : [APNsType]) -> Bool {
        for authType in authTypes {
            if let auths = self.aps?.authTypes, auths.first(where: { $0.type?.uppercased() ?? "" == authType.rawValue }) != nil {
                return true
            }
        }
        return false
    }
    
    mutating func changeUserInfoApns(userInfo: [AnyHashable : Any]) {
        var userInfoApns = self
        if let type = userInfo["type"] as? String { //Silent status update
            self.aps?.status = userInfo["status"] as? String
            self.aps?.category = userInfo["category"] as? String
            var authType = AuthType()
            authType.type = type
            self.aps?.authTypes = []
            self.aps?.authTypes?.append(authType)
        }
    }
}

struct Headers: Codable {
    var apns_collapse_id : String?
}

struct AuthType : Codable {
    var type : String?
}

struct APS : Codable {
    var category : String?
    var alert : Alert?
    var authTypes: [AuthType]?
    //videoCall
    var roomName: String?
    var videoConferenceType : String? //requestAuth, verifyAuth
    //status from verifier to end the call
    var status: String? //success, fail
    
    var currentActiveAuth : AuthType? //
}

struct Alert : Codable {
    var title : String?
    var body : String?
}
