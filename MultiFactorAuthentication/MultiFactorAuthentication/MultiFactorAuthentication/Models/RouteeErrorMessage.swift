//
//  RouteeErrorMessage.swift
//  
//
//  Created by sridharan R on 15/11/22.
//

import Foundation

struct RouteeErrorMessage : Codable {
    var error : String
    var error_description : String?
    
    static func decode(_ data : Data?) -> RouteeErrorMessage? {
        return RouteeErrorMessage.decodeData(data)
    }
}
