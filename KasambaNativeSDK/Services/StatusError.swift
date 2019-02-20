//
//  StatusError.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/29/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class StatusError: NSObject {
    
    @objc static let domain = "StatusErrorDomain"

    @objc static let general: Int = 0
    
    static func parseError(jsonDictionary: [AnyHashable: Any]) -> NSError? {
        
        var status: Int = 0
        
        if let uppercasedStatus = jsonDictionary["Status"] as? Int {
            status = uppercasedStatus
        }
        else if let lowercasedStatus = jsonDictionary["status"] as? Int {
            status = lowercasedStatus
        }
        else if let lowercasedStatus = jsonDictionary["responseStatus"] as? Int {
            status = lowercasedStatus
        }
        else {
            return NSError(domain: StatusError.domain, code: StatusError.general, userInfo: [NSLocalizedDescriptionKey: "Server does not returned status"])
        }
        
        if status == 0 {
            return nil
        }
        
        if let description = jsonDictionary["error_description"] as? String {
            return NSError(domain: StatusError.domain, code: StatusError.general, userInfo: [NSLocalizedDescriptionKey: description, "response": jsonDictionary])
        }
        
        var errors: Any
        
        if let uppercasedErrors = jsonDictionary["Errors"] {
            errors = uppercasedErrors
        }
        if let lowercasedErrors = jsonDictionary["errors"] {
            errors = lowercasedErrors
        }
        else {
            return NSError(domain: StatusError.domain, code: status, userInfo: [NSLocalizedDescriptionKey: "Server returned failure response with status: \(status)"])
        }
        
        return NSError(domain: StatusError.domain, code: status, userInfo: [NSLocalizedDescriptionKey: "Server returned failure response with status: \(status)", "errors": errors])
    }
}
