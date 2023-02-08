//
//  ApiUrls.swift
//  
//
//  Created by sridharan R on 21/07/22.
//

import Foundation

class ApiUrls {
    
    static let shared = ApiUrls()
    
    static let baseUrl = "https://ksms.amdtelecom.net/"
        
    let SEND_ACTION_CHOISE = "\(baseUrl)mfa/userActionConsumer.php"
    
    let SEND_OTP = "\(baseUrl)mfa/optAction.php"
    
    let ROUTEE_AUTH = "https://auth.routee.net/oauth/token?grant_type=client_credentials"
    
    let UPLOAD_LOCATION = "\(baseUrl)aiCloud/loc.php"
    
    let SEND_CURRENT_LOCATION = "\(baseUrl)mfa/locVerify.php"
    
    let OAUTH_BY_TRACKING_ID = "https://connect.routee.net/2step/%@?answer=%@" //trackingId, answer
    
    let SEND_VERIFICATION_CODE = "https://connect.routee.net/2step" //trackingId, answer

    let SEND_OTP_TO_MFA_VERIFICATION = "\(baseUrl)mfa/vVerify.php"
}
