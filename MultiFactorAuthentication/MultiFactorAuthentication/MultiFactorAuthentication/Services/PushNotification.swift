//
//  PushNotification.swift
//  
//
//  Created by sridharan R on 19/05/22.
//

import UIKit
import CoreLocation

public class PushNotification{
    
    public static let sharedInstance = PushNotification()
    
    var currentUserInfoApns : UserInfoAPNS? = nil
    
    var userInfoApns = [UserInfoAPNS]() //apns payload list
    
    ///  Get notification permission and register push notification
    ///
    ///  Call this function anytime to get notification permission
    ///
    ///      PushNotification.sharedInstance.registerForPushNotifications()
    public func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Permission granted: \(granted)")
                DispatchQueue.main.async {
                    guard granted else {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                        return
                    }
                    self.setActionCategories()
                }
                self.checkAndRegisterNotificationSettings()
            }
    }
    
    /// Register Remote notification to get device token
    ///
    /// Override the below delegate function in appdelegate
    ///
    ///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ///         FirebaseApp.configure()  // if firebase is used for push notification
    ///         PushNotification.sharedInstance.checkAndRegisterNotificationSettings()
    ///         return true
    ///     }
    ///
    public func checkAndRegisterNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                if #available(iOS 15.0, *) {
                    switch settings.scheduledDeliverySetting {
                    case .enabled:
                        MfaHelper.showOkAlert("Scheduled summery is on", message: "Please turn off scheduled summery to get on time notifications", "Settings", { _ in
                            if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        })
                        // Show alert or do something
                        break
                    default:
                        // Do nothing
                        break
                    }
                }
            }
        }
    }
    
    /// Send device token to server
    ///
    /// override the below delegate function in appdelegate
    ///
    ///     func application(_ application: UIApplication,
    ///         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    ///             PushNotification.sharedInstance.sendToken(deviceToken)
    ///     }
    ///
    /// - Parameter deviceToken : `Data` that has device token which needs to be sent to server
    ///
    public func sendToken(_ deviceToken: Data? = nil){
        if let deviceToken = deviceToken{
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            let token = tokenParts.joined()
            //
            print("Device Token: \(token)")
            sendToken(token)
        }
    }
    
    /// Send device token to server
    ///
    /// override the below delegate function in appdelegate
    ///
    ///     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    ///         pushNotification.sendToken(fcmToken)
    ///     }
    ///
    /// - Parameter fcmToken: firebase token
    public func sendToken(_ fcmToken : String){
        InitialConfiguration.sharedInstance.fcmTokenChanged(token: fcmToken, completionHandler: {_, _ in
        })
    }
    
    /// Check notification permission and returns `Bool` result
    /// - Returns: Status of notification permission. `True` for permission granted
    public func checkNotificationStatus(status : @escaping(Bool) -> ()) {//TODO: add for scheduled
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            switch(settings.authorizationStatus){
            case .authorized:
                status(true)
            case .denied, .notDetermined:
                status(false)
            default:
                status(false)
            }
        })
    }
    
    
    
    public func handleDidReciveNotification(userInfo : [AnyHashable : Any], _ completionHandler:@escaping (String?) -> ()){
        let jsonData = try? JSONSerialization.data(withJSONObject: userInfo)
        if var userInfoApns : UserInfoAPNS = ApiHelper.decodeData(jsonData){
            //Send payload to server
            if UIApplication.shared.applicationState != .active { //not in forground
//                completionHandler(nil)
                InitialConfiguration.sharedInstance.sendPayload(userInfo)
            }
            userInfoApns.changeUserInfoApns(userInfo: userInfo)
            guard userInfoApns.checkAuthType(authTypes: [.StatusUpdate]) else {
                let deleteId = userInfo["del-id"] as? String
                completionHandler(deleteId)
                return
            }
            onNotificationAction(userInfo: userInfo, action: nil, userInfoApns){ success in
                if let success = success as? String, success == "return" {
                    return
                }
            }
            completionHandler(userInfoApns.actionToken)
            return
        }
        completionHandler(nil)
        
    }
    
    /// Handles ckick action of notification
    /// - Parameters:
    ///   - userInfo: userInfo from apns payload
    ///   - action: Click action
    ///   - completionHandler: returns Any
    public func onNotificationAction(userInfo : [AnyHashable : Any], action: String? = nil,_ userInfoApns: UserInfoAPNS? = nil,  _ completionHandler:@escaping (Any)-> ()) {
        let action = NotificationAction(rawValue: action ?? "")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: userInfo)
        
        if MfaHelper.isTestPushApp {
            MfaHelper.showCopyAlert("Payload",text: "\(jsonData?.toString() ?? "")")
        }
        
        let userInfoApns : UserInfoAPNS? = userInfoApns ?? ApiHelper.decodeData(jsonData)
        if let userInfoApns : UserInfoAPNS = userInfoApns {
            if let category = userInfoApns.aps?.category {
                switch NotificationCategory(rawValue: category) {
                case .Authenticate:
                    if action != nil {
                        NavigationHelper.shared.showBiometric({ success in
                            completionHandler(success ?? false)
                        })
                    }
                    break
                case .ActionChoice:
                    var openAuthDirectly = false
                    if let authTypes = userInfoApns.aps?.authTypes, authTypes.count == 1 {
                        if authTypes.contains(where: { UserInfoAPNS.APNsType(rawValue: $0.type?.uppercased() ?? "") == .PushOTP }){
                            openAuthDirectly = true
                        }else if authTypes.contains(where: { UserInfoAPNS.APNsType(rawValue: $0.type?.uppercased() ?? "") == .StatusUpdate }){
                            if let currentUserInfo = PushNotification.getCurrentUserInfoApns(), currentUserInfo.actionToken == userInfoApns.actionToken {
                                NotificationCenter.default.post(name: Notification.Name(APNsStatusUpdateIdentifier), object: nil, userInfo: [UserInfoApnsKey : userInfoApns])
                            }
                            completionHandler("return")
                            return
                        }
//                        else if authTypes.contains(where: { UserInfoAPNS.APNsType(rawValue: $0.type ?? "") == .VideoConference }) && UserInfoAPNS.VideoConferenceType.init(rawValue: userInfoApns.aps?.videoConferenceType ?? "") == .requestAuth {
//                            openAuthDirectly = true
//                        }
                    }
                    
                    if action == .ActionChoiceDecline {
                        InitialConfiguration.sharedInstance.sendActionChoice(token: userInfoApns.actionToken ?? "", isAccepted: false) { data, error in
                            completionHandler(data != nil)
                        }
                    }else if action == .ActionChoiceAccept || openAuthDirectly {
                        handleApnsScreens(userInfoApns: userInfoApns , completionHandler)
                    }else{
//                        if let userInfoApns = userInfoApns {
//                            self.userInfoApns.append(userInfoApns)
//                            NotificationCenter.default.addObserver(self, selector: #selector(self.onNextQuestionary(notification:)), name: Notification.Name(NextQuestionaryIdentifier), object: nil)
//                        }
                        NavigationHelper.shared.openQuestionaryScreen(userInfoApns)
                        completionHandler("return")
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    /// Shows screen based on payload
    /// - Parameters:
    ///   - userInfoApns: Payload data
    ///   - completionHandler: returns Any
    func handleApnsScreens(userInfoApns : UserInfoAPNS, _ completionHandler:@escaping (Any)-> ()){
        var userInfoApns = userInfoApns
        
        if let authTypes = userInfoApns.aps?.authTypes {
            DispatchQueue.global(qos: .userInitiated).async {
                let dispatchGroup = DispatchGroup()
                var authSuccess = true
                for (index, authType) in authTypes.enumerated() {
                    var message = ""
                    dispatchGroup.enter()
                    userInfoApns.aps?.currentActiveAuth = authType //
                    PushNotification.setCurrentUserInfoApns(userInfoApns)
                    switch UserInfoAPNS.APNsType(rawValue: authType.type?.uppercased() ?? "") {
                    case .BIOMETRIC:
                        NavigationHelper.shared.showBiometric(message: userInfoApns.aps?.alert?.body){ success in
                            authSuccess = success ?? false
                            if success == nil {
                                sleep(1)
                                message = "Please enroll Biometric first to \n \(userInfoApns.aps?.alert?.title ?? "")"
                            }
                            dispatchGroup.leave()
                        }
                    case .OTP, .PushOTP:
                        var otp : String = ""
                        if let body = userInfoApns.aps?.alert?.body, body.contains("#") {
                            otp = body.components(separatedBy: "#").last ?? ""
                        }
                        NavigationHelper.shared.openOTPScreen(otpStatusDelegate: { otp, error in
                            authSuccess = otp != nil //change this after otp api success
//                            message = error ?? message
                            dispatchGroup.leave()
                        }, otp: otp)
                    case .Location:
                        self.getLocationOnAccept(completionHandler: { success in
                            authSuccess = success
                            dispatchGroup.leave()
                        })
                    case .VideoConference:
                        NavigationHelper.shared.openVideoCallScreen(roomLink: userInfoApns.aps?.roomName ?? "",userInforApns: userInfoApns, completionHandler: { success in
                            authSuccess = success
                            dispatchGroup.leave()
                        })
                    case .RandomNumber:
                        NavigationHelper.shared.openRandomNumberScreen(userInforApns: userInfoApns){ success in
                            authSuccess = success
                            dispatchGroup.leave()
                        }
                    case .NONE:
                        dispatchGroup.leave()
                    default:
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                    if authSuccess == false {
                        PushNotification.setCurrentUserInfoApns(nil)
                        InitialConfiguration.sharedInstance.sendActionChoice(token: userInfoApns.actionToken ?? "", isAccepted: false) { data, error in
                            completionHandler(data != nil)
                            NavigationHelper.shared.openConfirmationScreen(nil, isSuccess: false, message: message)
                        }
                        break
                    }else if index == authTypes.count - 1 {
                        PushNotification.setCurrentUserInfoApns(nil)
                        InitialConfiguration.sharedInstance.sendActionChoice(token: userInfoApns.actionToken ?? "", isAccepted: true) { data, error in
                            completionHandler(data != nil)
                            NavigationHelper.shared.openConfirmationScreen(nil, isSuccess: data != nil,message: message)
                        }
                    }
                }
            }
        }else{
            print("AMD: No Auth type provided")
            completionHandler(false)
        }
    }
    
    func getLocationOnAccept(completionHandler:@escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            CoreLocationHelper.sharedInstance.getCurrentLocation({ currentLoc in
                if let currentLoc = currentLoc {
                    print(currentLoc.coordinate.latitude)
                    print(currentLoc.coordinate.longitude)
                    NetworkManager.sendCurrentLocation(location: currentLoc.getMFALocation(), completionHandler: { data, error in
                        completionHandler(data != nil)
                    })
                }else{
                    completionHandler(false)
                }
            })
        }
    }
    
    /// removes current payload from stack and show the next challenge if any available
    /// - Parameter userInfoApns: Payload data
    func postNextQuestionaryNotification(oldUserInfoApns userInfoApns : UserInfoAPNS? = nil){
        if let userInfoApns = userInfoApns, self.userInfoApns.count > 1, let index = self.userInfoApns.firstIndex(of: userInfoApns){
            self.userInfoApns.remove(at: index)
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(NextQuestionaryIdentifier), object: nil, userInfo: nil)
        }
    }
    
    /// Triggers accept/Deny screen
    /// - Parameter notification: Notification
    @objc func onNextQuestionary(notification: Notification) {
        if userInfoApns.count > 0 {
            NavigationHelper.shared.openQuestionaryScreen(userInfoApns[0])
        }
    }
        
    /// Create actions in push notification
    public func setActionCategories(){
        let AcceptAction = UNNotificationAction(
            identifier: NotificationAction.ActionChoiceAccept.rawValue,
            title: "Accept",
            options: [.foreground])
        let DeclineAction = UNNotificationAction(
            identifier: NotificationAction.ActionChoiceDecline.rawValue,
            title: "Decline",
            options: [])
        let optionCategory = UNNotificationCategory(
            identifier: NotificationCategory.ActionChoice.rawValue,
            actions: [AcceptAction,DeclineAction],
            intentIdentifiers: [],
            options: [])
        UNUserNotificationCenter.current().setNotificationCategories(
            [optionCategory])
    }
    
    static func getCurrentUserInfoApns() -> UserInfoAPNS? {
        return PushNotification.sharedInstance.currentUserInfoApns
    }
    
    static func setCurrentUserInfoApns(_ userInfoApns : UserInfoAPNS?) {
        PushNotification.sharedInstance.currentUserInfoApns = userInfoApns
    }
    
    //Local notification location test purpose
    public func scheduleNotification(data : Any) {
        let content = UNMutableNotificationContent()
        var body = "Location service started!"
        if data is CLLocation {
            body = "Location \((data as! CLLocation).coordinate.latitude) \((data as! CLLocation).coordinate.longitude)"
        }
        
        content.title = "Location started"
        content.body = body
        
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(Int.random(in: 1..<6000000))",
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }

    
}

