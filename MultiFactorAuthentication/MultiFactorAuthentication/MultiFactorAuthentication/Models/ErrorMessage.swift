//
//  ErrorMessage.swift
//  
//
//  Created by sridharan R on 06/09/22.
//

import Foundation


struct ErrorMessage : Codable {
    var code : String
    var developerMessage : String?
    
    static func decode(_ data : Data?) -> ErrorMessage? {
        return ErrorMessage.decodeData(data)
    }
}
