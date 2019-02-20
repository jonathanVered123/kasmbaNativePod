//
//  NetworkError.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/16/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class ServiceError: NSObject {
    
    @objc static let domain = "ServiceErrorDomain"
    
    @objc static let general: Int = 0
    @objc static let notHandled: Int = 1 // Response not handled
    @objc static let refreshAccessTokenFailed: Int = 2
    @objc static let requestFailed: Int = 3
    
}
