//
//  ActionChoice.swift
//  
//
//  Created by sridharan R on 19/07/22.
//

import Foundation

struct ActionChoice : Codable {
    var applicationUUID : String?
    var deviceUUID: String?
    var userId :  String?
    var actionToken: String?
    var actionChoice: String?
    var actionValue: String?
    
    enum ActionValues : String {
        case Accept = "1"
        case Decline = "2"
    }
}
