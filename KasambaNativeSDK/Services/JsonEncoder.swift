//
//  JsonEncoder.swift
//  Kasamba
//
//  Created by Natan Zalkin on 8/1/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class JsonEncoder: ContentEncoderProtocol {
    
    static let `default` = JsonEncoder()
    
    var encodedContentType: String {
        return "application/json"
    }
    
    func encode(content: [String : Any]?, error: inout Error?) -> Data? {
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: content as Any, options: .prettyPrinted)
            return data
            
        }
        catch let serializationError {
            error = serializationError
        }
        
        return nil
    }
    
}
