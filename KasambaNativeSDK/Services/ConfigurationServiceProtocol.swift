//
//  SalesServiceProtocol.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/30/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


@objc
protocol ConfigurationServiceProtocol {
    
    var current: ClientConfiguration? { get }
    
    @discardableResult
    func getConfiguration(completion: ((ClientConfiguration?, Error?) -> Void)?) -> ServiceTaskHandlerProtocol?
    
    @discardableResult
    func getLocalizations(completion: @escaping ([String: LocalizedStrings]?, Error?) -> Void) -> ServiceTaskHandlerProtocol
}
