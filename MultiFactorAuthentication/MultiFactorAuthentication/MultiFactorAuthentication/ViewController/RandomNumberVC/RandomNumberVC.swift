//
//  File.swift
//  
//
//  Created by sridharan R on 30/01/23.
//

import UIKit

class RandomNumberVC : UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var FirstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var fourtButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    
    var userInfoApns : UserInfoAPNS?
    
    var completionHandler: ((Bool) -> ())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirstButton.addStrokedCornorRadius()
        secondButton.addStrokedCornorRadius()
        thirdButton.addStrokedCornorRadius()
        fourtButton.addStrokedCornorRadius()
        
  
    
        
        if let userInfoApns = userInfoApns {
            titleLbl.text = userInfoApns.aps?.alert?.title ?? NSLocalizedString("Verify this is you!", bundle: bundle, comment: "")
            descLbl.text = userInfoApns.aps?.alert?.body ?? NSLocalizedString("Please choose the number sent to you", bundle: bundle, comment: "")
        }
        
        if let verificationNumbers = userInfoApns?.verificationNumbers?.components(separatedBy: ","), verificationNumbers.count > 3 {
            FirstButton.setTitle("\(verificationNumbers[0])", for: .normal)
            secondButton.setTitle("\(verificationNumbers[1])", for: .normal)
            thirdButton.setTitle("\(verificationNumbers[2])", for: .normal)
            fourtButton.setTitle("\(verificationNumbers[3])", for: .normal)
        }
        
    }

    @IBAction func onRandomButtonAction(_ sender: Any) {
        if let sender = sender as? UIButton, let number = sender.titleLabel?.text {
            let randomNumber = RandomNumber(number: number)
            InitialConfiguration.sharedInstance.sendRandomNumberVerification(randomNumber){ success, error in
                
                self.goAMDBack({ _ in
                    self.completionHandler?((success != nil))
                    self.completionHandler = nil
                })
            }
        }
    }
}
