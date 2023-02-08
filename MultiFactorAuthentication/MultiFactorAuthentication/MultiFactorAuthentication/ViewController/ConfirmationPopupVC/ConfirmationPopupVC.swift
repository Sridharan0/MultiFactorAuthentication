//
//  ConfirmationPopupVC.swift
//  
//
//  Created by sridharan R on 06/09/22.
//

import Foundation
import UIKit

class ConfirmationPopupVC : UIViewController {
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var failureImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var okayBtn : UIButton!

    
    var isSuccess : Bool = true
    
    var message = ""
    
    var timer : Timer? = nil
    
    override func viewDidLoad() {
        successView.layer.cornerRadius = 25
        okayBtn.addCornorRadius()
        successView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        successImageView?.isHidden = !isSuccess
        failureImageView?.isHidden = isSuccess
        contentLabel?.text = message.isEmpty ? (isSuccess ? "Successfully verified" : "Verification failed") : message
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(update), userInfo: nil, repeats: false)

    }
    
    @objc func update()  {
        timer?.invalidate()
        timer = nil
        self.goAMDBack()
    }
    
}
