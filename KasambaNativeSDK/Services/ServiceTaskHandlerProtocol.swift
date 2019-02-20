//
//  ServiceTaskHandlerProtocol.swift
//  Kasamba
//
//  Created by Natan Zalkin on 8/7/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


@objc
public protocol ServiceTaskHandlerProtocol {
    
    var canceled: Bool { get }
    var executed: Bool { get }
    
    func resume()
    func cancel()
    
}
