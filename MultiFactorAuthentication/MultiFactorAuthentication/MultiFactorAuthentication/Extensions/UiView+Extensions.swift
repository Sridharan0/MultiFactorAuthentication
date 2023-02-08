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
}
