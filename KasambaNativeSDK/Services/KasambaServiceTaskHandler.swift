//
//  KasambaApiServiceHandler.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/17/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class KasambaServiceTaskHandler: SecuredServiceTaskHandler {
    
    override init() {
        super.init()

        host { "https://api.kasamba.com" }
        
    }
    
}
