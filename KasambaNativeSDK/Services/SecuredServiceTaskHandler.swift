//
//  KasambaServiceHandler.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/26/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


class SecuredServiceTaskHandler: JsonServiceTaskHandler {
    
    static func generateDefaultHeaders() -> [String: String] {
        
        var defaultHeaders = [String: String]()
        
        defaultHeaders["SiteName"] = "kasamba_mobile"
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            defaultHeaders["versionName"] = version
        }
        
        return defaultHeaders
    }
    
    static func generateAuthorizationInfo(token overrideToken: String? = nil) -> [String: String]? {
        
        if let overrideToken = overrideToken {
            return ["Authorization": "Bearer \(overrideToken)"]
        }
        
        if let token = AccessTokenManager.instance().currentToken?.access_token {
            return ["Authorization": "Bearer \(token)"]
        }
        
        return nil
    }
        
    override init() {
        super.init()
        
        headers { SecuredServiceTaskHandler.generateDefaultHeaders() }
        headers { SecuredServiceTaskHandler.generateAuthorizationInfo() }

    }
    
    override func handleResponseFailure(data: Data?, response: HTTPURLResponse) -> Bool {
        
        // Invalid token handling
        if response.statusCode == 401 {
                        
            if let errorId = response.allHeaderFields["X-ErrorId"] as? String, errorId == "1" {
                
                
                if AccessTokenManager.instance().currentToken?.refresh_token != nil {
                    
                    AccessTokenManager.instance().removeAccessToken()
                    
                    AccessTokenManager.instance().refreshToken(completionHandler: { (succeeded) in
                        
                        if succeeded {
                            
                            // Update headers with new access token
                            self.headers { SecuredServiceTaskHandler.generateAuthorizationInfo() }
                            
                            // Retry new task with the same handler
                            self.execute()
                        }
                        else {
                            
                            // Failed
                            let error = NSError(domain: ServiceError.domain, code: ServiceError.refreshAccessTokenFailed, userInfo: [NSLocalizedDescriptionKey: "Refresh access token failed"])
                            super.handleResponseError(error)
                        }
                        
                    })
                    
                    return true
                }
                else {
                    
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.refreshAccessTokenFailed, userInfo: [NSLocalizedDescriptionKey: "Got invalid access token but no refresh token available"])
                    super.handleResponseError(error)
                    return true
                }
                
            }
            else {
                
                let error = NSError(domain: ServiceError.domain, code: ServiceError.refreshAccessTokenFailed, userInfo: [NSLocalizedDescriptionKey: "Got invalid or empty ErrorID for 401 error"])
                super.handleResponseError(error)
                return true
            }
        }
        
        return super.handleResponseFailure(data: data, response: response)
    }

}
