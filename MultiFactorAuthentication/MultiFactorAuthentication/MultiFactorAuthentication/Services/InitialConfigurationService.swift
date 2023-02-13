//
//  InitialConfiguration.swift
//  
//
//  Created by sridharan R on 16/06/22.
//

import UIKit

public class InitialConfiguration {
    
    public static let sharedInstance = InitialConfiguration()
    
    let deviceUdid = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    var userId = ""
    
    var fcmToken = ""
            
    /// In this func we store the latest version configuration in userdefaults
    /// - Parameter appConfigration: it contains App Configuration details
    public func sendAppDetails(appConfigration: AppConfiguration, completionHandler :@escaping(Data?, AMDError?)->()) {
        setInitalConfigData(appConfigration: appConfigration)
        
        var parameterDictionary = AMDUserDetails()
        parameterDictionary.applicationUUID = appConfigration.applicationUUID
        
        ApiHelper.shared.requestJson(appConfigration.configurationUrl ?? "", .post, parameter: ApiHelper.encodeToData(data: parameterDictionary), timeInterval: appConfigration.configurationCallRetryDelay , retryCount: appConfigration.configurationCallRetries){ response , error in
            if let response = response {
                self.setInitalConfigData(appConfigration: AppConfiguration.decode(data: response))
                completionHandler(response, nil)
            }else {
                completionHandler(nil, error)
            }
        }
    }
    
    /// This func is used to send the parameters to the fireBaseConsumer url
    ///
    ///      InitialConfiguration.sharedInstance.setUserID(id: "") { data, error in
    ///
    ///      }
    public func setUserID(id : String, completionHandler :@escaping(Data?, AMDError?) ->()) {
        guard let configData = getInitalConfigData() else { return }
        let url = String(format: configData.fireBaseConsumer ?? "")
        InitialConfiguration.sharedInstance.userId = id
        let parameterDictionary = AMDUserDetails(applicationUUID: configData.applicationUUID, deviceUUID: deviceUdid, userId: id, token: nil)
        
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: parameterDictionary), timeInterval: configData.fireBaseConsumerRetryDelay, retryCount: configData.fireBaseConsumerCallRetries){ response , error in
            if response != nil {
                UserDefaultsHelper.setData(value: id, key: .userId)
                let token = InitialConfiguration.sharedInstance.fcmToken
                self.fcmTokenChanged(token: token, completionHandler: {_,_ in })
                completionHandler(response, nil)
            }else {
                completionHandler(nil, error)
            }
        }
    }
    
    /// Send token to Amd server
    /// - Parameters:
    ///   - token: fcm token
    ///   - completionHandler: Callback for api response
    public func fcmTokenChanged(token:String, completionHandler:@escaping(Data?, AMDError?)->()){
        guard let configData = getInitalConfigData() else {return}
        let url = String(format: configData.fireBaseConsumer ?? "")
        guard !token.isEmpty else {
            return
        }
        InitialConfiguration.sharedInstance.fcmToken = token
        let userId = InitialConfiguration.sharedInstance.userId
        if userId.isEmpty {
            completionHandler(nil, AMDError(code: 500, message: NSLocalizedString("Something went wrong", bundle: bundle, comment: "")))
            return
        }
        let parameterDictionary = AMDUserDetails(applicationUUID: configData.applicationUUID, deviceUUID: deviceUdid, userId: userId, token: token)
        
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: parameterDictionary)){ success , error in
            if success != nil {
                completionHandler(success, nil)
            }else {
                completionHandler(nil, error)
            }
        }
    }
    
    /// send Action request to backend
    /// - Parameters:
    ///   - token: action Token
    ///   - isAccepted: Accepted / Denied
    ///   - completionHandler: api callback
    public func sendActionChoice(token: String, isAccepted: Bool, completionHandler:@escaping(Data?, AMDError?)->()){
   
        let url = ApiUrls.shared.SEND_ACTION_CHOISE
        
        guard let configData = getInitalConfigData() else {return}
        let parameterDictionary = ActionChoice(applicationUUID: configData.applicationUUID, deviceUUID: deviceUdid, userId: InitialConfiguration.sharedInstance.userId, actionToken: token, actionChoice: isAccepted ? ActionChoice.ActionValues.Accept.rawValue : ActionChoice.ActionValues.Decline.rawValue)// 1 or 2
    
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: parameterDictionary)){ success , error in
            if success != nil {
                completionHandler(success, nil)
            }else {
                completionHandler(nil, error)
            }
        }
    }
    
    public func sendOTP(otp: String, completionHandler:@escaping(Data?, AMDError?)->()){
        let url = ApiUrls.shared.SEND_OTP
        
        guard let configData = getInitalConfigData() else {return}
        let _ = ActionChoice(applicationUUID: configData.applicationUUID, deviceUUID: deviceUdid, userId: InitialConfiguration.sharedInstance.userId, actionToken: InitialConfiguration.sharedInstance.fcmToken , actionChoice: ActionChoice.ActionValues.Accept.rawValue, actionValue: otp)// 1 or 2
    
        ApiHelper.shared.requestJson(url, .post, parameter: nil){ success , error in
            if success != nil {
                completionHandler(success, nil)
            }else {
                completionHandler(nil, error)
            }
        }
    }
    
    func sendRandomNumberVerification(_ number: RandomNumber,_ completionHandler:@escaping(Data?, AMDError?)->()) {
        let url = ApiUrls.shared.SEND_ACTION_CHOISE
        ApiHelper.shared.requestJson(url, .post, parameter: ApiHelper.encodeToData(data: number)){ success , error in
            if success != nil {
                completionHandler(success, nil)
            }else {
                completionHandler(nil, error)
            }
        }
    }
    
    func sendPayload(_ userInfo: [AnyHashable : Any]) {
        let url = ApiUrls.shared.SEND_ACTION_CHOISE
        if let parameter = try? JSONSerialization.data(withJSONObject: userInfo) {
            ApiHelper.shared.requestJson(url, .post, parameter: parameter){ success , error in
                if success != nil {

                }else {

                }
            }
        }
    }
    
    /// To get Routee auth token
    ///
    /// Call the func as below
    ///
    ///     InitialConfiguration.sharedInstance.getRouteeToken(applicationId, applicationSecret){ token in
    ///        if let token = token?.accessToken {
    ///           //token
    ///        }else if token?.message != nil{
    ///           //show error meesage
    ///        }
    ///     }
    ///
    /// - Parameters:
    ///   - applicationID: String
    ///   - aplicationSecret: String
    ///   - completionHandler: completionHandler(RouteeAuth?)
    public func getRouteeToken(_ applicationID : String, _ applicationSecret : String, completionHandler: @escaping(RouteeAuth?) -> Void ){
        if applicationID.isEmpty || applicationSecret.isEmpty {
            completionHandler(nil)
            return
        }
        let authToken = "\(applicationID):\(applicationSecret)"
        
        ApiHelper.shared.formUrlEncodedHeader["Authorization"] = "Basic \(authToken.toBase64())"
        
        ApiHelper.shared.requestJson(ApiUrls.shared.ROUTEE_AUTH , .post, header: ApiHelper.shared.formUrlEncodedHeader){ success , error in
            if success != nil {
                UserDefaultsHelper.setData(value: applicationID, key: .applicationID) //test
                UserDefaultsHelper.setData(value: applicationSecret, key: .applicationSecret) //
                
                let routeeAuth = RouteeAuth.decode(data: success)
                ApiHelper.shared.setAccessToken(accessToken: routeeAuth?.accessToken ?? "")
                completionHandler(routeeAuth)
            }else {
                completionHandler(nil)
            }
        }
    }
    
    
    private func setInitalConfigData(appConfigration: AppConfiguration?){
        guard let appConfigration = appConfigration else { return  }
        
        let configData = getInitalConfigData()
        if configData != nil {
            if let dataVersion = Int(appConfigration.version ?? "0"), let configDataVersion = Int(configData?.version ?? "0")  {
                if dataVersion > configDataVersion {
                    UserDefaultsHelper.setData(value: encode(data: appConfigration), key: .initalConfiguration)
                }
            }
        }else {
                UserDefaultsHelper.setData(value: encode(data: appConfigration), key: .initalConfiguration)
        }
    }
    
    public func getFCMToken() -> String{
        return fcmToken
    }
    
    func getInitalConfigData() -> AppConfiguration? {
        if let json = UserDefaultsHelper.getData(type: String.self, forKey: .initalConfiguration) {
            return self.decode(json)
        }
        return nil
    }
    
    func encode<T: Codable>(data : T) -> String {
        do{
            let data = try JSONEncoder().encode(data)
            return String(data: data, encoding: .utf8)!
        }catch{
            return ""
        }
    }
    
    func decode<T: Codable>(_ json: String) -> T? {
        let decoder = JSONDecoder()
        do{
            return try decoder.decode(T.self, from: json.data(using: .utf8)!)
        }catch{
            return nil
        }
    }
}
