//
//  UrlEncoder.swift
//  Kasamba
//
//  Created by Natan Zalkin on 8/1/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class UrlEncoder: ContentEncoderProtocol {
    
    static let `default` = UrlEncoder()
    
    var encodedContentType: String {
        return "application/x-www-form-urlencoded"
    }
    
    func encode(content: [String : Any]?, error: inout Error?) -> Data? {
     
        var components = URLComponents()
        
        if let body = content, body.count > 0 {
            
            let queryItems = body.reduce([URLQueryItem]()) {
                
                if let value = $1.value as? String {
                    return $0 + URLQueryItem(name: $1.key, value: value)
                }
                
                return $0
            }
            
            components.queryItems = queryItems
        }
        else {
            return Data() // Empty data
        }
        
        guard let content = components.url?.absoluteString else {
            error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare encoded string for request with components \(components)"])
            return nil
        }
        
        let croppedContent = content.suffix(from: content.index(content.startIndex, offsetBy: 1))
        
        guard let data = croppedContent.data(using: .ascii, allowLossyConversion: true) else {
            error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Failed to produce data from URI encoded string"])
            return nil
        }
        
        return data
        
    }
}
