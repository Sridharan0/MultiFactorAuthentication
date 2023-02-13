//
//  File.swift
//  
//
//  Created by sridharan R on 17/05/22.
//

import UIKit

extension UIViewController {
    public func showOKAlert(withTitle title: String, message:String, handler: ( (UIAlertAction) -> ())? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", bundle: bundle, comment: "Ok"), style: .default, handler: handler))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showQuestionAlert(withTitle title:String?, message : String, handler: @escaping (UIAlertAction) -> Void,_ noHandler: ((UIAlertAction) -> Void)? = nil){
        let alert = UIAlertController(title: title ?? NSLocalizedString("Alert", bundle: bundle, comment: "Alert"), message: message , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", bundle: bundle, comment: "Action"), style: .default, handler: handler))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", bundle: bundle, comment: "Default action"), style: .default, handler: noHandler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 16)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @IBAction func onBackAction(_ sender: Any) {
        self.goAMDBack()
    }
    
    func goAMDBack(_ complition :((Bool) -> ())? = nil) {
        DispatchQueue.main.async {
            if let vc = self.navigationController{
                vc.popViewController(animated: true)
            }else{
                self.dismiss(animated: true, completion: {
                    complition?(true)
                })
            }
        }
    }
    
    public func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    public var localized: String {
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func toData() -> Data? { //"name=\(yourName)&firstName=\(firstName)&lastName=\(lastName)"
        return self.data(using: .utf8)
    }
    
    func toInt() -> Int? {
        return Int(self)
    }
}


extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension Date {
    public var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
}

extension Data {
    
    func toString() -> NSString {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? NSString()
    }
    
    func printResponse() {
        print("response \n<<<<<\n\(self.toString())\n>>>>>>\n")
    }
}


//extension UIApplication {
//    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?{
//        if let nav = base as? UINavigationController
//        {
//            let top = topViewController(nav.visibleViewController)
//            return top
//        }
//
//        if let tab = base as? UITabBarController
//        {
//            if let selected = tab.selectedViewController
//            {
//                let top = topViewController(selected)
//                return top
//            }
//        }
//
//        if let presented = base?.presentedViewController
//        {
//            let top = topViewController(presented)
//            return top
//        }
//        return base
//    }
//
//}

extension UIViewController {
    func showMfaLoader(){
        showLoader(self)
    }
    
    func hideMfaLoader(){
        hideLoader(self)
    }
}

func showLoader(_ viewController : UIViewController? = nil){
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 20, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.color = .link
    loadingIndicator.style = UIActivityIndicatorView.Style.medium
    loadingIndicator.startAnimating()
    alert.view.addSubview(loadingIndicator)
    DispatchQueue.main.async {
        if let viewController = viewController {
            viewController.present(alert, animated:true, completion:nil)
        } else {
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?
                .present(alert, animated:true, completion:nil)
        }
    }
}

func hideLoader(_ viewController : UIViewController? = nil) {
    DispatchQueue.main.async {
        if let viewController = viewController {
            viewController.dismiss(animated: false, completion: nil)
        } else {
            UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?
                .dismiss(animated: false, completion: nil)
        }
    }
}
