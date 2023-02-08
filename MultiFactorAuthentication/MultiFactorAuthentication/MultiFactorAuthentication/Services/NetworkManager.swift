//
//  NetworkManager.swift
//  
//
//  Created by sridharan R on 26/08/22.
//

import Foundation

public class NetworkManager {
    
    //MARK: Location Api's
    /// Uploads location details to backend
    /// - Parameters:
    ///   - locations: list of location data
    ///   - completionHandler: returns api result
    static  func uploadLocation(locations : [MFALocationModel], completionHandler:@escaping(Data?, AMDError?)->()){
        guard locations.count > 0 && Reachability.isConnectedToNetwork() else {
            completionHandler(nil, AMDError())
            return
        }
        let url = ApiUrls.shared.UPLOAD_LOCATION
        
        let mFALocationDatas = MFALocationDatas(deviceId: InitialConfiguration.sharedInstance.deviceUdid, version: InitialConfiguration.sharedInstance.getInitalConfigData()?.version ?? "", data: locations)
    
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: mFALocationDatas), { success, error in
            completionHandler(success, error)
        }, isShowLoader: false)
    }
    
    /// Uploads location details to backend
    /// - Parameters:
    ///   - locations: list of location data
    ///   - completionHandler: returns api result
    static  func sendCurrentLocation(location : MFALocationModel, completionHandler:@escaping(Data?, AMDError?)->()){
        guard Reachability.isConnectedToNetwork() else {
            completionHandler(nil, AMDError())
            return
        }
        let url = ApiUrls.shared.SEND_CURRENT_LOCATION
        
        let mFALocationData = MFALocationData(deviceId: InitialConfiguration.sharedInstance.deviceUdid, version: InitialConfiguration.sharedInstance.getInitalConfigData()?.version ?? "", data: location)
    
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: mFALocationData), { success, error in
            completionHandler(success, error)
        }, isShowLoader: false, isacceptEmptyResponse: true)
    }
    
    //MARK: OTP APi's
    /// Send One Time Pin to recipient number
    /// - Parameters:
    ///   - recipient: number of recipent with country code ( +1639292... or +1,639292..)
    ///   - type: code
    ///   - method: sms/voice
    ///   - completionHandler: returns OauthVerificationStatus
    static func sendVerificationCode(recipient: String, type: String = "code", method: String = "sms", completionHandler:@escaping(OauthVerificationStatus?, AMDError?)->()){
        let url = String(format: ApiUrls.shared.SEND_VERIFICATION_CODE)
        let param = SendVerificationRequest(type: "code", method: "sms", recipient: recipient)
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: param), header: ApiHelper.shared.aplicationJsonHeader){ success, error in
            completionHandler(OauthVerificationStatus.decode(success), error)
        }
    }
    
    /// Send OTP with trackingID to routee to check pin is valied
    /// - Parameters:
    ///   - trackingID: ID from send verification code
    ///   - answer: OTP
    ///   - completionHandler: returns OauthVerificationStatus
    static func sendOathByTrackingID(trackingID: String, answer: String, completionHandler:@escaping(OauthVerificationStatus?, AMDError?)->()){
        let url = String(format: ApiUrls.shared.OAUTH_BY_TRACKING_ID, trackingID, answer)
        ApiHelper.shared.requestJson(url, .post, parameter: nil){ success, error in
            completionHandler(OauthVerificationStatus.decode(success), error)
        }
    }
    
    /// Send OTP without trackingID - Support Push OTP authentication without sms.
    /// - Parameters:
    ///   - trackingID: ID from send verification code
    ///   - answer: OTP
    ///   - completionHandler: returns OauthVerificationStatus
    static func sendOtpToMfaVerification(trackingID: String, answer: String, completionHandler:@escaping(Data?, AMDError?)->()){
        let url = String(format: ApiUrls.shared.SEND_OTP_TO_MFA_VERIFICATION)
        
        let mfaOtpRequest = MFAOtpRequest(deviceId: InitialConfiguration.sharedInstance.deviceUdid, version: InitialConfiguration.sharedInstance.getInitalConfigData()?.version ?? "", otpPin: answer)
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: mfaOtpRequest), { success, error in
            completionHandler(success, error)
        }, isacceptEmptyResponse: true)
    }
}
