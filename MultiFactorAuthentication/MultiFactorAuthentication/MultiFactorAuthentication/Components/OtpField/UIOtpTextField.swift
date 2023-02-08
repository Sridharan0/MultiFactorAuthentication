//
//  UIOtpTextField.swift
//  
//
//  Created by sridharan R on 16/05/22.
//

import Foundation
import UIKit

/// Otp text filed with button functionality.
///
///  - Note: Set the class in UITextField class in your story board
///
///```
///     otpField.otpSize = 6 //optional by defalut 4
///     otpField.setOptButton(submitBtn)
/// ```
@IBDesignable class UIOtpTextField: UITextField, UITextFieldDelegate {
    
    //MARK: Variables
    ///Maximum size of otp
    var otpSize : Int = DefaultOtpSize
    
    private var otpButton : UIButton? = nil
    
    weak open var delegate1 : UITextFieldDelegate?
    
    private var otp = ""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        self.delegate = self
        otpButton?.isEnabled = false
        self.textContentType = .oneTimeCode
        self.keyboardType = .numberPad
        self.becomeFirstResponder()
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.text = otp
    }
    
    //MARK: Delegate functions
    @objc func textFieldDidChange(_ textField: UITextField) {
        otp = textField.text ?? ""
        checkOtpEligible()
    }
    
    func checkOtpEligible(){
        if !otp.isEmpty, otp.count == otpSize {
            otpButton?.isUserInteractionEnabled = true
            otpButton?.alpha = 1
        }else{
            otpButton?.isUserInteractionEnabled = false
            otpButton?.alpha = 0.8
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    ///  Returns the otp in otp text field
    /// - Returns: otp of type `String`
    public func getOtp() -> String {
        return otp
    }
    
    public func setOtp(_ otp : String) {
        self.text = otp
        self.otp = otp
        checkOtpEligible()
    }
    
    /// Set otp button to enable otp functionality
    /// - Parameter uiButton: otp submit button
    public func setOptButton(_ uiButton : UIButton) {
        otpButton = uiButton
        otpButton?.isUserInteractionEnabled = false
        otpButton?.alpha = 0.8
    }
    
}
