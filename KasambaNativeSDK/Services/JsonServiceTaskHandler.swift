//
//  JsonRestServiceTaskHandler.swift
//  Kasamba
//
//  Created by Natan Zalkin on 8/1/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


extension Dictionary where Key == AnyHashable, Value == Any {
    
    func bool(for key: AnyHashable) -> Bool? {
    
        let value = self[key]
        
        if let boolean = value as? Bool {
            return boolean
        }
        else if let integer = value as? Int {
            return integer != 0
        }
        else if let string = value as? String {
            
            guard let firstLetter = string.lowercased().characters.prefix(1).first else {
                return false
            }
            
            switch firstLetter {
            case "t", "y", "1":
                return true
            case "f", "n", "0":
                return false
            default:
                return nil
            }
        }

        return nil
    }
    
    func int(for key: AnyHashable) -> Int? {
        
        let value = self[key]
        
        if let integer = value as? Int {
            return integer
        }
        else if let string = value as? String {
            return Int(string) ?? 0
        }
        
        return nil
    }
    
}


class JsonServiceTaskHandler: RestServiceTaskHandler {
    
    // MARK: - Override point
    
    override init() {
        super.init()
        
        headers { ["Accept": "application/json"] }
    }
    
    override func handleResponseFailure(data: Data?, response: HTTPURLResponse) -> Bool {
        
        if super.handleResponseFailure(data: data, response: response) {
            return true
        }
        
        if let data = data, let contentType = response.mimeType, contentType == "application/json" {
            
            do {
                
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                                
                return handleJsonFailure(json: jsonObject, response: response)
                
            } catch {
                handleResponseError(error)
                return true
            }
        }
        
        return false
    }
    
    override func handleDataResponse(data: Data, response: HTTPURLResponse) -> Bool {
        
        if super.handleDataResponse(data: data, response: response) {
            return true
        }
        
        if let contentType = response.mimeType, contentType == "application/json" {
            do {
                
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                return handleJsonResponse(json: jsonObject, response: response)
                
            } catch let error {
                handleResponseError(error)
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Closures
    
    private var jsonResponseHandler: ((Any) -> Void)? = nil
    private var dictionaryResponseHandler: (([AnyHashable: Any]) -> Void)? = nil
    private var arrayResponseHandler: (([Any]) -> Void)? = nil
    
    private var jsonFailureHandler: ((Any, HTTPURLResponse) -> Void)? = nil
    private var dictionaryFailureHandler: (([AnyHashable: Any], HTTPURLResponse) -> Void)? = nil
    private var arrayFailureHandler: (([Any], HTTPURLResponse) -> Void)? = nil
    
    // MARK: - Responses
    
    /// Handle response with json data
    @discardableResult
    func json(_ handler: @escaping (Any) -> Void) -> Self {
        self.jsonResponseHandler = handler
        return self
    }
    
    /// Handle response with json dictionary
    @discardableResult
    func dictionary(_ handler: @escaping ([AnyHashable: Any]) -> Void) -> Self {
        self.dictionaryResponseHandler = handler
        return self
    }
    
    /// Handle response with json array
    @discardableResult
    func array(_ handler: @escaping ([Any]) -> Void) -> Self {
        self.arrayResponseHandler = handler
        return self
    }
    
    /// Handle failure with json data (any response that is not 200 OK handled as failure)
    @discardableResult
    func failure(json handler: @escaping (Any, HTTPURLResponse) -> Void) -> Self {
        self.jsonFailureHandler = handler
        return self
    }
    
    /// Handle failure with json dictionary (any response that is not 200 OK handled as failure)
    @discardableResult
    func failure(dictionary handler: @escaping ([AnyHashable: Any], HTTPURLResponse) -> Void) -> Self {
        self.dictionaryFailureHandler = handler
        return self
    }
    
    /// Handle failure with json array (any response that is not 200 OK handled as failure)
    @discardableResult
    func failure(array handler: @escaping ([Any], HTTPURLResponse) -> Void) -> Self {
        self.arrayFailureHandler = handler
        return self
    }
    
    // MARK: - Handlers
    
    @discardableResult
    func handleJsonResponse(json: Any, response: HTTPURLResponse) -> Bool {
        
        if let jsonResponseHandler = jsonResponseHandler {
            jsonResponseHandler(json)
            return true
        }
        
        if let dictionary = json as? [AnyHashable: Any], handleDictionaryResponse(dictionary) {
            return true
        }
        
        if let array = json as? [Any], handleArrayResponse(array) {
            return true
        }
        
        return false
    }
    
    // Handle JSON dictionary response
    @discardableResult
    func handleDictionaryResponse(_ dictionary: [AnyHashable: Any]) -> Bool {
        
        if let dictionaryResponseHandler = dictionaryResponseHandler {
            dictionaryResponseHandler(dictionary)
            return true
        }
        
        return false
    }
    
    // Handle JSON arrayResponse
    @discardableResult
    func handleArrayResponse(_ array: [Any]) -> Bool {
        
        if let arrayResponseHandler = arrayResponseHandler {
            arrayResponseHandler(array)
            return true
        }
        
        return false
    }
    
    @discardableResult
    func handleJsonFailure(json: Any, response: HTTPURLResponse) -> Bool {
        
        if let jsonFailureHandler = jsonFailureHandler {
            jsonFailureHandler(json, response)
            return true
        }
        
        if let dictionary = json as? [AnyHashable: Any], handleDictionaryFailure(dictionary, response) {
            return true
        }
        
        if let array = json as? [Any], handleArrayFailure(array, response) {
            return true
        }
        
        return false
    }
    
    // Handle JSON dictionary failure
    @discardableResult
    func handleDictionaryFailure(_ dictionary: [AnyHashable: Any], _ response: HTTPURLResponse) -> Bool {
        
        if let dictionaryFailureHandler = dictionaryFailureHandler {
            dictionaryFailureHandler(dictionary, response)
            return true
        }
        
        return false
    }
    
    // Handle JSON array failure
    @discardableResult
    func handleArrayFailure(_ array: [Any], _ response: HTTPURLResponse) -> Bool {
        
        if let arrayFailureHandler = arrayFailureHandler {
            arrayFailureHandler(array, response)
            return true
        }
        
        return false
    }
}
