//
//  Decodable+Decode.swift
//  
//
//  Created by sridharan R on 07/09/22.
//

import Foundation

extension Decodable {
    
    static func decodeData(_ data: Data?) -> Self? {
        if let data = data, let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String? {
            let decoder = JSONDecoder()
            do{
                return try decoder.decode(Self.self, from: json.data(using: .utf8)!)
            }catch{ }
        }
        return nil
    }
}
