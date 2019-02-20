//
//  UserAccountError.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/31/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


public class UserAccountError: NSObject {
    
    @objc static public let domain = "UserAccountErrorDomain"
    
    @objc static public let general: Int = 0
    @objc static public let userAlreadyExists: Int = 1
    @objc static public let badRefreshToken: Int = 2
    
}
