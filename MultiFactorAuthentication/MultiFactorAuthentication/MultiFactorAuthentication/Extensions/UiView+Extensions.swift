//
//  UiView+Extensions.swift
//  
//
//  Created by sridharan R on 22/11/22.
//

import UIKit

extension UIView {
    func addCornorRadius(_ cornorRadius : Double? = nil ) {
        if let cornorRadius = cornorRadius {
            self.layer.cornerRadius = CGFloat(cornorRadius)
        }else {
            self.layer.cornerRadius = self.frame.size.height / 2
        }
    }
    
    func addStrokedCornorRadius(_ cornorRadius : Double? = nil , _ color : CGColor = UIColor.init(red: 6, green: 83, blue: 154, alpha:0.5).cgColor) {
        
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
        //
    
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowColor = UIColor.gray.cgColor
        layer.masksToBounds = false
     
        
        if let cornorRadius = cornorRadius {
            self.layer.cornerRadius = CGFloat(cornorRadius)
        }else {
            self.layer.cornerRadius = self.frame.size.height / 2
        }
    }
}
