//
//  File.swift
//  
//
//  Created by sridharan R on 03/06/22.
//


import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var image: UIImageView!
    
    var completion:((Bool)->())? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.image.image = UIImage(named: "Touch_ID")
        self.button.setTitle(NSLocalizedString("Need user touch id", bundle: .main, comment: ""), for: .normal)
        faceId()
    }
    
    @IBAction func touchfaceID(_ sender: Any) {
        NavigationHelper.shared.showBiometric({success in
            self.completion?(success ?? false)
        })
    }
    
    /// Description
    /// check the device support
    ///         - To check whether the device supports FaceID or TouchID
    /// - Returns: if it return true means the device support FaceID
    ///            if it return false means the device supports TouchID
    func canAuthenticateByFaceID() -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext.init()
            var error: NSError?
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if (context.biometryType == LABiometryType.faceID) {
                    return true
                }else if(context.biometryType == LABiometryType.touchID){
                    return false
                }
            }
            else {
                self.showOKAlert(withTitle: NSLocalizedString("oops", bundle: .main, comment: ""), message: NSLocalizedString("enrolFirst", bundle: .main, comment: "enroll message"), handler: {_ in
                    if let vc = self.navigationController{
                        vc.popViewController(animated: true)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
        self.image.isHidden = true
        self.button.isHidden = true
        
        return false
    }
    
    /// This function is used to update the button title (TouchID or FaceID) based on the device support
    func faceId(){
        self.image.isHidden = false
        self.button.isHidden = false
        if canAuthenticateByFaceID(){
            self.image.image = UIImage(named:"person")
            self.button.setTitle(NSLocalizedString("Camera", bundle: .main, comment: ""), for: .normal)
        }
    }
}
