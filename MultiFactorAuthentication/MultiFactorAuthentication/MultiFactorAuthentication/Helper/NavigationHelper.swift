//
//  NavigationHelper.swift
//  
//
//  Created by sridharan R on 21/07/22.
//

import Foundation
import UIKit
import LocalAuthentication

public class NavigationHelper {
    public static let shared = NavigationHelper()
    
    var isMfaScreenActive = false //Not used
    
    /// Opens Accept / Deny screen
    /// - Parameter userInfoApns: UserInfoAPNS response from APNS
    func openQuestionaryScreen(_ userInfoApns : UserInfoAPNS?){
        if let controller = UIStoryboard(name: "QuestionaryVC", bundle: bundle).instantiateViewController(withIdentifier: "QuestionaryVC") as? QuestionaryVC {
            controller.userInfoApns = userInfoApns
            if #available(iOS 13.0, *) {
                controller.isModalInPresentation = true
            }
            self.openScreen(currentVc: nil, nextVc: controller, forceShow: true)
        }
    }
    
    /// Register Remote notification to get device token
    ///
    ///     NavigationHelper.shared.openOTPScreen{ otp in   }
    ///
    /// - Parameters:
    ///   - viewController: `self` pass current view controller `optional`
    ///   - otpStatusDelegate: callback with string`(OTP)`
    ///   - otpSize: size of OTP default is 4 `optional`
    public func openOTPScreen(_ viewController: UIViewController? = nil, otpStatusDelegate :@escaping(String?, String?) -> (), _ otpSize : Int = DefaultOtpSize, otp : String = "") {
        DispatchQueue.main.async {
            guard let nextViewController = UIStoryboard(name: "otpVC", bundle: bundle).instantiateViewController(withIdentifier: "OtpViewController") as? OtpViewController else { return        }
            nextViewController.otpStatusDelegate = otpStatusDelegate
            nextViewController.otpSize = otpSize
            nextViewController.otp = otp
            if !otp.isEmpty {
                nextViewController.screenType = .PushOTP
            }
            nextViewController.modalPresentationStyle = .fullScreen
            self.openScreen(currentVc: viewController, nextVc: nextViewController)
        }
    }
    
    /// Biometric authentication
    ///
    ///       NavigationHelper.shared.showBiometric({ success in  })
    /// - Parameter completionHandler: `(Bool?)` returns `true` if success `false` if failed `nil` if not enrolled
    public func showBiometric(message: String? = nil, _ completionHandler :@escaping (Bool?) -> ()){
        let authcontext:LAContext = LAContext()
        var error : NSError?
        if authcontext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error){
            authcontext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: message ?? NSLocalizedString("Need biometric for authentication", bundle: bundle , comment: ""), reply: { (sucess,error) in
                if sucess{
                    completionHandler(true)
                }else{
                    completionHandler(false)
                }
            })
        }else{
            completionHandler(nil)
        }
    }
    
    //MARK: Show video call
    ///  present meet video call screen
    /// - Parameters:
    ///   - roomLink: Link of the meet to load.
    ///   - completionHandler: Returns status of the meet.
    ///
    ///       NavigationHelper.shared.openVideoCallScreen(roomLink: "https://meet.routee.net/"){ _ in
    ///
    ///       }
    func openVideoCallScreen(roomLink: String, userInforApns: UserInfoAPNS?, completionHandler:@escaping (Bool) -> ()){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "VideoCallVC", bundle:bundle)
            let videoCallVC = storyBoard.instantiateViewController(withIdentifier: "VideoCallVC") as! VideoCallVC
            videoCallVC.modalPresentationStyle = .fullScreen
            videoCallVC.roomLink = roomLink
            videoCallVC.userInfoApns = userInforApns
            videoCallVC.completionHandler = completionHandler
            self.openScreen(currentVc: nil, nextVc: videoCallVC, forceShow: true)
        }
    }
    
    ///  Shows authentication screen based on device compatability
    ///
    ///     ```
    ///         NavigationHelper.shared.openAuthenticationScreen({ success in  })
    ///     ```
    ///
    /// - Parameters:
    ///   - viewController: self` contains current view controller
    ///   - completionHandler : success will contain the bool which  we assign the completionHandler here
    public func openAuthenticationScreen(_ viewController: UIViewController? = nil, completionHandler: @escaping (Bool)->Void) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "AuthenticationVC", bundle:bundle)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
        nextViewController.completion = completionHandler
        nextViewController.modalPresentationStyle = .fullScreen
        if let vc = viewController {
            if vc.navigationController == nil {
                vc.present(nextViewController, animated:true, completion:nil)
            } else {
                vc.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }else{
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    /// Shows Success/ Failure bottom sheet
    ///
    ///      NavigationHelper.shared.openConfirmationScreen(isSuccess: true)
    ///
    /// - Parameters:
    ///   - viewController: `self` pass current view controller `optional`
    ///   - isSuccess: Shows success or failure based on this.
    func openConfirmationScreen(_ viewController: UIViewController? = nil, isSuccess : Bool = true, message : String = "") {
        NavigationHelper.shared.isMfaScreenActive = false
        DispatchQueue.main.async {
            
            guard let nextViewController = UIStoryboard(name: "ConfirmationPopupVC", bundle: bundle).instantiateViewController(withIdentifier: "ConfirmationPopupVC") as? ConfirmationPopupVC else { return }
            nextViewController.modalPresentationStyle = .pageSheet
            nextViewController.isSuccess = isSuccess
            nextViewController.message = message
            self.openScreen(currentVc: viewController, nextVc: nextViewController, forceShow: true)
        }
    }
    
    func openRandomNumberScreen(userInforApns: UserInfoAPNS?, completionHandler:@escaping (Bool) -> ()) {
        DispatchQueue.main.async {
            let nextViewController = UIStoryboard(name: "RandomNumberVC", bundle: bundle).instantiateViewController(withIdentifier: "RandomNumberVC") as! RandomNumberVC
            nextViewController.userInfoApns = userInforApns
            nextViewController.completionHandler = completionHandler
            nextViewController.modalPresentationStyle = .fullScreen
            self.openScreen(currentVc: nil, nextVc: nextViewController, forceShow: true)
        }
    }
    
    func openScreen(currentVc : UIViewController?, nextVc : UIViewController, forceShow : Bool = false){
//        if NavigationHelper.shared.isMfaScreenActive && !forceShow {
//            //
//            return
//        }else{
//
//        }
        DispatchQueue.main.async {
            if let vc = currentVc {
                if vc.navigationController == nil {
                    vc.present(nextVc, animated:true, completion:nil)
                } else {
                    vc.navigationController?.pushViewController(nextVc, animated: true)
                }
            }else{
                if #available(iOS 13.0, *), forceShow {
                    if var topController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController  {
                           while let presentedViewController = topController.presentedViewController {
                                 topController = presentedViewController
                                }
//                        topController.dismiss(animated: false, completion: nil)
//                        self.openScreen(currentVc: nil, nextVc: nextVc)
                     topController.present(nextVc, animated: true, completion: nil)
                     }
                } else {
                    //                    UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?
                    //                        .present(nextVc, animated:true, completion:nil)
                    if var topController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController  {
                        if let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        topController.present(nextVc, animated: true, completion: nil)
                    }
                    
                }
            }
        }
    }
    
}
