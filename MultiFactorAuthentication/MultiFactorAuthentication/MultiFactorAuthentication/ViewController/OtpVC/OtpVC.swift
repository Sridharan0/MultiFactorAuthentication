//
//  OtpVC.swift
//  
//
//  Created by sridharan R on 16/05/22.
//

import UIKit

/// This class is to show otp screen from client app
/// - Note: Call this screen like
/// ```
/// OtpViewController.showScreen(self, otpStatusDelegate: self)
/// ```
class OtpViewController : UIViewController {
    
    var otpSize : Int = DefaultOtpSize
    var otp = ""
        
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var otpField: UIOtpTextField!
        
    var otpStatusDelegate : ((String?, String?) -> ())? = nil
    
    var verificationStatus : OauthVerificationStatus?
    
    var screenType : ScreenType = .OTP
    
    enum ScreenType : String, CaseIterable {
        case OTP
        case PushOTP
    }
    
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        submitBtn.addCornorRadius()
        cancelBtn?.addCornorRadius()
        otpView.addCornorRadius(25)
        otpField.otpSize = otpSize
        otpField.setOptButton(submitBtn)
        if !otp.isEmpty {
            otpField.otpSize = otp.count
            otpField.setOtp(otp)
        }
        infoLabel?.text = NSLocalizedString("Provide the verification pin you received", bundle: bundle, comment: "")
        submitBtn.setTitle(NSLocalizedString("Submit", bundle: bundle, comment: ""), for: .normal)
        cancelBtn?.setTitle(NSLocalizedString("Cancel", bundle: bundle, comment: ""), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isTesting && screenType == .OTP {
            let ac = UIAlertController(title: "Provide recipient number to send sms", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.textFields?[0].text = "+"
            let submitAction = UIAlertAction(title: "Send", style: .default) { [unowned ac] _ in
                let answer = ac.textFields![0].text
                if answer?.isEmpty == false {
                    self.sendVerificationCode(recipient: answer ?? "")
                }
            }
            ac.addAction(submitAction)
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            present(ac, animated: true)
        }
    }
    
    @IBAction func onBack(_ sender: Any){
        self.goAMDBack({ _ in
            self.otpStatusDelegate?(nil, nil)
        })
    }
    
    @IBAction func onSubmitAction(_ sender: Any) {
        switch screenType {
        case .OTP:
            if let verificationStatus = verificationStatus {
                NetworkManager.sendOathByTrackingID(trackingID: verificationStatus.trackingId, answer: "\(otpField.getOtp())"){ verificationStatus, error in
                    if let verificationStatus = verificationStatus , verificationStatus.status == OauthVerificationStatus.VerificationStatus.Verified.rawValue {
                        self.goAMDBack({ _ in
                            self.otpStatusDelegate?("\(self.otpField.getOtp())", nil)
                        })
                    }else if let error = error {
                        self.goAMDBack({ _ in
                            self.otpStatusDelegate?(nil, error.message)
                        })
                    }else {
                        self.showOKAlert(withTitle: "Alert", message: "Otp failed", handler: nil)
                    }
                }
            }else {
                otpFailed()
            }
        case .PushOTP:
            NetworkManager.sendOtpToMfaVerification(trackingID: "", answer: "\(otpField.getOtp())"){ data, error in
                if data != nil {
                    self.goAMDBack({ _ in
                        self.otpStatusDelegate?("\(self.otpField.getOtp())", nil)
                    })
                }else if let error = error {
                    self.goAMDBack({ _ in
                        self.otpStatusDelegate?(nil, error.message)
                    })
                }else {
                    self.showOKAlert(withTitle: "Alert", message: "Otp failed", handler: nil)
                }
            }
        }
    }
    
    func otpFailed(){
        self.goAMDBack({ _ in
            self.otpStatusDelegate?(nil, "No recipient")
        })
        DispatchQueue.main.async {
            NavigationHelper.shared.openConfirmationScreen(isSuccess: false)
        }
    }
    
    func sendVerificationCode(recipient : String) {
        NetworkManager.sendVerificationCode(recipient: recipient){ verificationStatus , errorMessage in
            if let verificationStatus = verificationStatus {
                self.verificationStatus = verificationStatus
            }else if let error = errorMessage {
                if let ouathError : OauthVerificationError = ApiHelper.decodeData(error.data) , let recipient = ouathError.properties?.recipient {
                    self.showOKAlert(withTitle: "Failed", message: (recipient.first ?? "Something went wrong") ?? "")
                }else{
                    self.showOKAlert(withTitle: "Failed", message: error.message)
                }
            }else {
                self.showOKAlert(withTitle: "Api failed", message: "Something went wrong")
            }
        }
    }
}
