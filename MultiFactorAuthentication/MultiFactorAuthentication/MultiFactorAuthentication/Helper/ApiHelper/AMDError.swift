//
//  AMDError.swift
//  
//
//  Created by sridharan R on 20/06/22.
//

import UIKit

public class AMDError: NSObject , Error {
    public var message = ""
    public var errorCode: Int?
    
    public var data : Data?
    init(code: Int? = 0, message: String? = "",_ data : Data? = nil) {
        self.message = message ?? ""
        self.errorCode = code
        self.data = data
    }
}
