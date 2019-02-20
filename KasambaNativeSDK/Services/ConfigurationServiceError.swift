//
//  ConfigurationServiceError.swift
//  Kasamba
//
//  Created by Natan Zalkin on 9/10/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class ConfigurationServiceError: NSObject {
    
    @objc static public let domain = "ConfigurationServiceError"
    
    @objc static let general: Int = 0
    @objc static let notSubscribedToPush: Int = 3
    
}
