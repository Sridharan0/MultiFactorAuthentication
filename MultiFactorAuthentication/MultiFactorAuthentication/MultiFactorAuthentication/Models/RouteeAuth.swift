//
//  RouteeAuth.swift
//  
//
//  Created by sridharan R on 12/08/22.
//

import Foundation

public struct RouteeAuth: Codable {
    public let accessToken, tokenType: String?
    public let expiresIn: Int?
    public let scope: String?
    public let permissions: [String]?
    
    //error
    public let status: Int?
    public let error: String?
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope, permissions, status, error, message
    }
    
    static func decode(data : Data?) -> RouteeAuth? {
        return RouteeAuth.decodeData(data)
    }
}
