//
//  ContentEncoderProtocol.swift
//  Kasamba
//
//  Created by Natan Zalkin on 8/1/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


protocol ContentEncoderProtocol {
    
    var encodedContentType: String { get }
    
    func encode(content: [String : Any]?, error: inout Error?) -> Data?
    
}
