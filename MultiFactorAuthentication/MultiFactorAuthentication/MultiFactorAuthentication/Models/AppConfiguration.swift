//
//  AppConfiguration.swift
//  
//
//  Created by sridharan R on 30/06/22.
//

import Foundation

public struct AppConfiguration : Codable {
    var version : String?
    var applicationName : String?
    var applicationUUID: String?
    var configurationUrl : String?
    var configurationCallRetryDelay : Int?
    var configurationCallRetries : Int?
    var smsOtpType: String?
    var fireBaseUuid :String?
    var fireBaseConsumer:  String?
    var fireBaseConsumerRetryDelay :Int?
    var fireBaseConsumerCallRetries : Int?
    var mainSystem:String?
    var mainSystemRetryDelay :Int?
    var mainSystemCallRetries : Int?
    var hostedSystem : String?
    var hostedMFASystemRetryDelay : Int?
    var hostedMFASystemCallRetries : Int?
    
    public init() {
        
    }
    
    public init(version : String?, applicationName : String?, applicationUUID: String?, configurationUrl : String?, configurationCallRetryDelay : Int?, configurationCallRetries : Int?, smsOtpType: String?, fireBaseUuid :String?, fireBaseConsumer:  String?, fireBaseConsumerRetryDelay :Int?, fireBaseConsumerCallRetries : Int?, mainSystem:String?, mainSystemRetryDelay :Int?, mainSystemCallRetries : Int?, hostedSystem : String?, hostedMFASystemRetryDelay : Int?, hostedMFASystemCallRetries : Int?){

        self.version = version
        self.applicationName = applicationName
        self.applicationUUID =  applicationUUID
        self.configurationUrl =  configurationUrl
        self.configurationCallRetryDelay = configurationCallRetryDelay
        self.configurationCallRetries = configurationCallRetries
        self.smsOtpType = smsOtpType
        self.fireBaseUuid = fireBaseUuid
        self.fireBaseConsumer = fireBaseConsumer
        self.fireBaseConsumerRetryDelay = fireBaseConsumerRetryDelay
        self.fireBaseConsumerCallRetries = fireBaseConsumerCallRetries
        self.mainSystem = mainSystem
        self.mainSystemRetryDelay = mainSystemRetryDelay
        self.mainSystemCallRetries =  mainSystemCallRetries
        self.hostedSystem =  hostedSystem
        self.hostedMFASystemRetryDelay = hostedMFASystemRetryDelay
        self.hostedMFASystemCallRetries =  hostedMFASystemCallRetries
    }
    
    static func decode(data : Data?) -> AppConfiguration? {
        return ApiHelper.decodeData(data)
    }
    
}
