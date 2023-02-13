//
//  Constant.swift
//  
//
//  Created by sridharan R on 10/06/22.
//

import Foundation

//MARK: Value constants
let DefaultRetryCount : Int = 1
public let DefaultOtpSize : Int = 4
let RouteeAuthErrorCode = 401

//MARK: NotificationCenter identifiers
let NextQuestionaryIdentifier = "NextQuestionaryIdentifier"
let APNsStatusUpdateIdentifier = "APNsStatusUpdateIdentifier"

//MARK: NotificationCenter userInfo keys
let UserInfoApnsKey = "userInfoApns"

//
let SUCCESS = "SUCCESS"

public let isTesting = true  //Testing popups enable/disable


public var  bundle :Bundle = {
//    let  bundle = Bundle(identifier: "com.programs.MultiFactorAuthentication")
//     return bundle
    let myBundle = Bundle(for: CoreDataManager.self)

    // Get the URL to the resource bundle within the bundle
    // of the current class.
//    guard let resourceBundleURL = myBundle.url(
//        forResource: "MySDK", withExtension: "bundle")
//        else { fatalError("MySDK.bundle not found!") }
    
    return myBundle
    
    
 }()

