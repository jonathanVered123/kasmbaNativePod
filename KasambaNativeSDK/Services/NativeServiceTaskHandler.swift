//
//  KasambaNativeTaskHandler.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/18/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class NativeServiceTaskHandler: SecuredServiceTaskHandler {
    
    override init() {
        super.init()
        
        host { "https://native.kasamba.com" }
        
    }

}
