//
//  ApiHelper.swift
//  
//
//  Created by sridharan R on 20/06/22.
//

import Foundation

class ApiHelper : NSObject {
    
    static let shared = ApiHelper()
        
    var headers = [
        "Accept": "application/json",
        "Content-Type": "Application/json"
    ]
    
    var aplicationJsonHeader = [
        "Accept": "application/json",
        "Content-Type": "Application/json"
    ]
    
    var formUrlEncodedHeader = [
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    func setAccessToken(accessToken : String) {
        ApiHelper.shared.formUrlEncodedHeader["Authorization"] = "Bearer \(accessToken)"
        ApiHelper.shared.headers["Authorization"] = "Bearer \(accessToken )"
        ApiHelper.shared.aplicationJsonHeader["Authorization"] = "Bearer \(accessToken)"
        UserDefaultsHelper.setData(value: accessToken, key: .accessToken) //
    }
    
    /// Common function to call all api's
    /// - Parameters:
    ///   - url: url string
    ///   - method: method type
    ///   - parameter: param
    ///   - header: header
    ///   - timeInterval: request time
    ///   - retryCount: over all retry count
    ///   - currentRetryCount: retry count
    ///   - completionHandler: closure for response
    ///   - isShowLoader: need loaded and alert or not
    ///   - acceptEmptyResponse: send true to accept empty response (does not validate empty response)
    func requestJson(_ url: String,_ method: HTTPMethod = .get , parameter: Data? = nil, header : [String: String]? = nil, timeInterval : Int? = nil, retryCount : Int? = DefaultRetryCount , currentRetryCount : Int? = DefaultRetryCount, _ completionHandler:@escaping (_ result:  Data?,_ error: AMDError?) -> (), isShowLoader : Bool = true, isacceptEmptyResponse : Bool = false) {
        guard Reachability.isConnectedToNetwork() else {
            if isShowLoader {
                MfaHelper.showOkAlert("No network", message: "Try again after connecting to network..", "Retry", { _ in
                    self.requestJson(url, method, parameter: parameter, timeInterval: timeInterval, retryCount: retryCount, currentRetryCount: currentRetryCount, completionHandler, isShowLoader: isShowLoader)
                }, isShowCancel: true)
            }else {
                completionHandler(nil, AMDError(code: 0, message: NSLocalizedString("Invalied Url", bundle:bundle, comment: "Invalied Url")))
//                completionHandler(nil, AMDError(code: 501, message: NSLocalizedString("No Network available", bundle: Bundle.module, comment: "No Network"))))
            }
            return
        }
        if isShowLoader {
//            ACTIVITY.show()
//            showLoader()
        }
        let retryCount = retryCount ?? DefaultRetryCount
        let currentRetryCount = currentRetryCount ?? DefaultRetryCount
        
        guard let Url = URL(string: url) else {
            completionHandler(nil, AMDError(code: 0, message: NSLocalizedString("Invalied Url", bundle: bundle, comment: "Invalied Url")))
            return
        }
        var request = URLRequest(url: Url)
        request.httpMethod = method.rawValue
        request.httpBody = parameter
        request.allHTTPHeaderFields = header ?? headers
        var session = URLSession.shared
        
        if timeInterval != nil {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = TimeInterval(timeInterval! * 60)
            session = URLSession(configuration: sessionConfig)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            print("Request Url: \(url)")
            if isShowLoader {
//                ACTIVITY.remove()
//                hideLoader()
            }
            if let parameters = parameter {
                print("Request Parameters: \(NSString(data: parameters, encoding: String.Encoding.utf8.rawValue) ?? "")")
            }
            print("Request header: \(self.headers)")
            if error != nil {
                print(currentRetryCount)
                if currentRetryCount < retryCount {
                    self.requestJson(url, method, parameter: parameter, timeInterval: timeInterval, retryCount: retryCount, currentRetryCount: currentRetryCount + 1, completionHandler, isShowLoader: isShowLoader)
                }else{
                    print("error >>>>>>> \n \(String(describing: error))")
                    if let error = error as? URLError {
                        switch(error.code){
                        case .timedOut:
                            completionHandler(nil, AMDError(code: error.errorCode, message: NSLocalizedString("Time out error", bundle: bundle, comment: "")))
                            break
                        default:
                            completionHandler(nil, AMDError(code: error.errorCode, message: NSLocalizedString("Something went wrong", bundle: bundle, comment: "")))
                        }
                    }else{
                        completionHandler(nil,  AMDError(code: 500, message: NSLocalizedString("Something went wrong", bundle: bundle, comment: "")))
                    }
                }
            }else if let data = data {
                data.printResponse()
                if let error = ErrorMessage.decode(data) {
                    completionHandler(nil, AMDError(code: error.code.toInt(), message: NSLocalizedString(error.developerMessage ?? "Something went wrong", bundle: bundle, comment: ""), data))
                }else if let error = RouteeErrorMessage.decode(data) {
                    completionHandler(nil, AMDError(code: RouteeAuthErrorCode, message: NSLocalizedString(error.error.replacingOccurrences(of: "_", with: " ") , bundle: bundle, comment: ""), data))
                }else if data.isEmpty && !isacceptEmptyResponse {
                    completionHandler(nil,  AMDError(code: 500, message: NSLocalizedString("Something went wrong", bundle: bundle, comment: "")))
                }else {
                    DispatchQueue.main.async {
                        completionHandler(data, nil)
                    }
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).async {
            task.resume()
        }
    }
    
    static func encodeToData<T: Codable>(data : T?) -> Data? {
        if let data = data {
            do{
                return try JSONEncoder().encode(data)
            }catch { }
        }
        return nil
    }

    static func decodeData<T: Codable>(_ data: Data?) -> T? {
        let decoder = JSONDecoder()
        if let data = data, let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
            do{
                return try decoder.decode(T.self, from: json.data(using: .utf8)!)
            }catch{ }
        }
        return nil
    }
    
}
