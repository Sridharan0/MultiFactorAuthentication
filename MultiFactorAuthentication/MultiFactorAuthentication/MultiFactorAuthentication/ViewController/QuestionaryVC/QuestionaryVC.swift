//
//  QuestionaryVC.swift
//  
//
//  Created by sridharan R on 19/07/22.
//

import Foundation
import UIKit

class QuestionaryVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var notificationView: UIView!
    
    var userInfoApns : UserInfoAPNS?
    
    override func viewDidLoad() {
        submitBtn.layer.cornerRadius = submitBtn.frame.size.height / 2
        cancelBtn.layer.cornerRadius = submitBtn.frame.size.height / 2
        notificationView.layer.cornerRadius = 25
        titleLabel?.text = NSLocalizedString(userInfoApns?.aps?.alert?.title ?? "title", bundle: .main, comment: "")
        infoLabel?.text = NSLocalizedString(userInfoApns?.aps?.alert?.body ?? "Provide the verification pin you received", bundle: .main, comment: "")
        submitBtn.setTitle(NSLocalizedString("Accept", bundle: .main, comment: ""), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("Deny", bundle: .main, comment: ""), for: .normal)
    }
    
    //MARK: IBActions
    @IBAction func onSubmitAction(_ sender: Any) {
        self.goAMDBack{ _ in
            PushNotification.sharedInstance.handleApnsScreens(userInfoApns: self.userInfoApns!){ success in
                PushNotification.sharedInstance.postNextQuestionaryNotification(oldUserInfoApns: self.userInfoApns)
            }
        }
    }
    
    @IBAction func onCloseAction(_ sender: Any) {
        InitialConfiguration.sharedInstance.sendActionChoice(token: self.userInfoApns?.actionToken ?? "", isAccepted: false) { data, error in
            self.goAMDBack{ _ in
                PushNotification.sharedInstance.postNextQuestionaryNotification(oldUserInfoApns: self.userInfoApns)
            }
        }
    }
}
