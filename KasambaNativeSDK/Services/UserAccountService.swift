//
//  RegistrationService.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/30/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


public class UserAccountService: UserAccountServiceProtocol {
    
    private static let secret = "ifqAerspCJjSN8dG8Er9nBMms56lvozdbVE3P8QwR4E"
    
    public var tracking: [AnyHashable : Any]? = nil
    
    public func register(username: String, password: String, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol {
        
        
        return JsonServiceTaskHandler()
            
            .host { "https://native.kasamba.com" }
            
            .path { "/Account/signup" }
            
            .method { HTTPMethod.POST }
            
            .headers { SecuredServiceTaskHandler.generateDefaultHeaders() }
            
            .body {
                ["username": username,
                 "password": password,
                 "grant_type": "password",
                 "client_id": "nativeApp",
                 "client_secret": UserAccountService.secret,
                 "SiteId": 6]
            }
            
            .body { tracking as? [String : Any] }
            
            .body { nil }
            
            .error {
                performOnMainQueue(work: completion($0))
            }
            
            .failure(dictionary: { (dictionary, response) in
                
                var error: NSError
                
                if let description = dictionary["error_description"] as? String {
                    
                    if description == "Signup_UserNameAlreadyExists" {
                        error = NSError(domain: UserAccountError.domain, code: UserAccountError.userAlreadyExists, userInfo: [NSLocalizedDescriptionKey: "User already exists"])
                    }
                    else {
                        error = self.generateError(response: dictionary)
                    }
                }
                else {
                    error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])
                }
                
                performOnMainQueue { completion(error) }
            })
            
            .dictionary { (dictionary) in
                
                var error: Error? = nil
                
                if dictionary["MemberID"] == nil {
                
                    error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Registration failed"])
                    
                    
                }
                
                performOnMainQueue { completion(error) }
                
            }
            
            .execute()
        
    }
    
    public func login(username: String, password: String, completion: @escaping (AccessToken?, Bool, Error?) -> Void) -> ServiceTaskHandlerProtocol {
        
        return JsonServiceTaskHandler()
            
            .host { "https://native.kasamba.com" }

            .path { "/oauth/loginfortoken" }
            
            .method { HTTPMethod.POST }
            
            .headers { SecuredServiceTaskHandler.generateDefaultHeaders() }
            
            .body {[
                "username": username,
                "password": password,
                "grant_type": "password",
                "client_id": "nativeApp",
                "client_secret": UserAccountService.secret,
                "SiteId": Utilities.appParameters.siteId().intValue,
                ]}
            
            .body { tracking as? [String : Any] }
            
            .body { nil }
            
            .encoder { UrlEncoder.default }
            
            .error {
                performOnMainQueue(work: completion(nil, false, $0))
            }
            
            .failure(dictionary: { (dictionary, response) in
                
                let error = self.generateError(response: dictionary)
                performOnMainQueue(work: completion(nil, false, error))
                
            })
            
            .dictionary { (dictionary) in
                
                guard let token = AccessToken(jsonData: dictionary), token.access_token != nil else {
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
                    performOnMainQueue(work: completion(nil, false, error))
                    return
                }
                
                let isFacebookUser = dictionary.bool(for: "isFbRegistration")
                
                performOnMainQueue(work: completion(token, isFacebookUser ?? false, nil))
                
            }
            
            .execute()
        
    }
    
    public func login(facebookToken: String, completion: @escaping (AccessToken?, Bool, Error?) -> Void) -> ServiceTaskHandlerProtocol {
        
        return JsonServiceTaskHandler()
            
            .host { "https://native.kasamba.com" }

            .path { "/Account/FacebookAuth" }
            
            .method { HTTPMethod.POST }
            
            .headers { SecuredServiceTaskHandler.generateDefaultHeaders() }
            
            .body {[
                "facebookToken": facebookToken,
                "grant_type": "password",
                "client_id": "nativeApp",
                "client_secret": UserAccountService.secret,
                ]}
            
            .body { tracking as? [String : Any] }
                        
            .encoder { UrlEncoder.default }
            
            .error {
                performOnMainQueue(work: completion(nil, false, $0))
            }
            
            .failure(dictionary: { (dictionary, response) in
                
                let error = self.generateError(response: dictionary)
                performOnMainQueue(work: completion(nil, false, error))
                
            })
            
            .dictionary { (dictionary) in
                
                guard let token = AccessToken(jsonData: dictionary), token.access_token != nil else {
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Login failed"])
                    performOnMainQueue { completion(nil, false, error) }
                    return
                }
                
                let isFirstRegistration = dictionary.bool(for: "isFbRegistration")
                
                performOnMainQueue(work: completion(token, isFirstRegistration ?? false, nil))
                
            }
            
            .execute()
    }

    public func getAccountDetails(token: String, completion: @escaping (AccountResponse?, Error?) -> Void) -> ServiceTaskHandlerProtocol {
        
        return JsonServiceTaskHandler()
            
            .host { "https://native.kasamba.com" }
            
            .path { "/Account/Auth" }
            
            .method { HTTPMethod.POST }
            
            .headers { SecuredServiceTaskHandler.generateAuthorizationInfo(token: token) }
            
            .error {
                performOnMainQueue(work: completion(nil, $0))
            }
            
            .failure(dictionary: { (dictionary, response) in
                
                let error = self.generateError(response: dictionary)
                performOnMainQueue(work: completion(nil, error))
                
            })
            
            .dictionary { (dictionary) in
                
                guard let response = AccountResponse(jsonData: dictionary) else {
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Authentication failed"])
                    performOnMainQueue(work: completion(nil, error))
                    return
                }
                
                performOnMainQueue(work: completion(response, nil))
                
            }
            
            .execute()
        
    }
    
    public func getUserDetails(completion: @escaping (UserDetails?, Error?) -> Void) -> ServiceTaskHandlerProtocol? {
        
        return KasambaServiceTaskHandler()
            
            .path { "/Member/Members/GetMemberDetails" }
            
            .method { HTTPMethod.POST }
            
            .error {
                performOnMainQueue(work: completion(nil, $0))
            }
            
            .dictionary { (dictionary) in
                
                let userDetails = UserDetails()
                
                userDetails.didDoChat = (dictionary["didDoChat"] as? Bool) ?? false
                userDetails.isFromFacebook = (dictionary["isFromFacebook"] as? Bool) ?? false
                userDetails.isVip = (dictionary["isVip"] as? Bool) ?? false
                userDetails.didDoVoice = (dictionary["didDoVoice"] as? Bool) ?? false
                userDetails.userCurrencyCode = (dictionary["userCurrencyCode"] as? Int) ?? 0
                userDetails.userRegistrationSiteId = (dictionary["userRegistrationSiteId"] as? Int) ?? Utilities.appParameters.siteId().intValue
                userDetails.userZodiacSign = (dictionary["userZodiacSign"] as? Int) ?? 0
                userDetails.tierId = (dictionary["tierId"] as? Int) ?? 0
                userDetails.userEmail = (dictionary["userEmail"] as? String) ?? ""
                
                performOnMainQueue { completion(userDetails, nil) }
                
            }
            
            .execute()

    }
    
    public func refreshAccessToken(completion: @escaping (AccessToken?, Error?) -> Void) -> ServiceTaskHandlerProtocol? {
        
        guard let refreshToken = AccessTokenManager.instance().currentToken?.refresh_token else {
            let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Refresh token required"])
            completion(nil, error)
            return nil
        }
        
        return JsonServiceTaskHandler()
            
            .absolutePath { "https://native.kasamba.com/oauth/loginfortoken" }
            
            .method { HTTPMethod.POST }
            
            .headers { SecuredServiceTaskHandler.generateDefaultHeaders() }
            
            .body {[
                "refresh_token": refreshToken,
                "grant_type": "refresh_token",
                "client_id": "nativeApp",
                "client_secret": UserAccountService.secret,
                ]}
            
            .encoder { UrlEncoder.default }
            
            .error {
                performOnMainQueue(work: completion(nil, $0))
            }
            
            .failure(dictionary: { (dictionary, response) in
                
                // Bad refresh token
                if response.statusCode == 401 {
                    
                    if let errorId = response.allHeaderFields["X-ErrorId"] as? String, errorId == "2" {
                        
                        let error = NSError(domain: UserAccountError.domain, code: UserAccountError.badRefreshToken, userInfo: [NSLocalizedDescriptionKey: "Got bad refresh token error with status 401"])
                        
                        performOnMainQueue(work: completion(nil, error))
                        
                        return
                    }
                }
                
                let error = self.generateError(response: dictionary)
                performOnMainQueue { completion(nil, error) }
                
            })
            
            .dictionary { (dictionary) in
                
                guard let token = AccessToken(jsonData: dictionary), token.access_token != nil else {
                    
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Failed to deserialize access token"])
                    performOnMainQueue { completion(nil, error) }
                    return
                }
                
                performOnMainQueue { completion(token, nil) }
                
            }
            
            .execute()
        
    }
    
    public func resetPassword(username: String, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol {
        
        return JsonServiceTaskHandler()
            
            .host { "https://native.kasamba.com" }

            .path { "/Account/ResetPassword" }
            
            .method { HTTPMethod.POST }
            
            .query { ["email": username] }
            
            .error { performOnMainQueue(work: completion($0)) }
            
            .failure(dictionary: { (dictionary, response) in
                let error = self.generateError(response: dictionary)
                performOnMainQueue { completion(error) }
            })
            
            .dictionary { (dictionary) in
                performOnMainQueue { completion(nil) }
            }
            
            .execute()
        
    }
    
    public func addChatSessionUserAgentDetails(memberId: Int, version: String, userAgent: String, deviceModel: String, deviceType: String, deviceVendor: String, osVersion: String, osName: String, browserMajorVersion: String, browserName: String, siteId: Int, sessionId: Int, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol {
        
        return KasambaServiceTaskHandler()
            
            .path { "/Member/Tracking/AddSessionUserAgentDetails" }
            
            .method { HTTPMethod.POST }
            
            .body {[
                "memberId"               :memberId,
                "sessionId"              :sessionId,
                "version"                :version,
                "userAgent"              :userAgent,
                "deviceModel"            :deviceModel,
                "deviceType"             :deviceType,
                "deviceVendor"           :deviceVendor,
                "osVersion"              :osVersion,
                "osName"                 :osName,
                "browserMajorVersion"    :browserMajorVersion,
                "browserName"            :browserName,
                "siteId"                 :siteId,
                ]}
            
            .error { (error) in performOnMainQueue { completion(error)} }
            
            .dictionary { (dictionary) in
                
                if let error = StatusError.parseError(jsonDictionary: dictionary) {
                    performOnMainQueue { completion(error) }
                    return
                }
                
                performOnMainQueue { completion(nil) }
            }
            
            .execute()

    }
    
    public func registrationUserAgentDetails(memberId: Int, version: String, userAgent: String, deviceModel: String, deviceType: String, deviceVendor: String, osVersion: String, osName: String, browserMajorVersion: String, browserName: String, siteId: Int, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol {
        
        return KasambaServiceTaskHandler()
            
            .path { "/Member/Tracking/AddRegistrationUserAgentDetails" }
            
            .method { HTTPMethod.POST }
            
            .body {[
                "memberId"               :memberId,
                "version"                :version,
                "userAgent"              :userAgent,
                "deviceModel"            :deviceModel,
                "deviceType"             :deviceType,
                "deviceVendor"           :deviceVendor,
                "osVersion"              :osVersion,
                "osName"                 :osName,
                "browserMajorVersion"    :browserMajorVersion,
                "browserName"            :browserName,
                "siteId"                 :siteId,
                ]}
            
            .error { (error) in performOnMainQueue {
                completion(error)
                
                } }
            
            .dictionary { (dictionary) in
                
                if let error = StatusError.parseError(jsonDictionary: dictionary) {
                    performOnMainQueue { completion(error) }
                    return
                }
                
                performOnMainQueue { completion(nil) }
            }
            
            .execute()

    }
    
    
    public func registrationMetadata(siteId: Int, appsFlyerId: String, advertisingId: String, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol {
        return KasambaServiceTaskHandler()
            
            .path { "/Member/Tracking/AddRegistrationMetadata" }
            
            .method { HTTPMethod.POST }
            
            .body {[
                "siteId"               :siteId,
                "appsFlyerId"          :appsFlyerId,
                "advertisingId"        :advertisingId,
                ]}
            
            .error { (error) in performOnMainQueue {
                completion(error)
                
                } }
            
            .dictionary { (dictionary) in
                
                if let error = StatusError.parseError(jsonDictionary: dictionary) {
                    performOnMainQueue { completion(error) }
                    return
                }
                
                performOnMainQueue { completion(nil) }
            }
            
            .execute()
    }
    
    public func registrationMetadata(sessionId: Int, siteId: Int, appsFlyerId: String, advertisingId: String, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol {
        return KasambaServiceTaskHandler()
            
            .path { "/Member/Tracking/AddSessionMetadata" }
            
            .method { HTTPMethod.POST }
            
            .body {[
                "siteId"               :siteId,
                "sessionId"             :sessionId,
                "appsFlyerId"          :appsFlyerId,
                "advertisingId"        :advertisingId,
                ]}
            
            .error { (error) in performOnMainQueue {
                completion(error)
                
                } }
            
            .dictionary { (dictionary) in
                
                if let error = StatusError.parseError(jsonDictionary: dictionary) {
                    performOnMainQueue { completion(error) }
                    return
                }
                
                performOnMainQueue { completion(nil) }
            }
            
            .execute()
    }
    
    public func logout(token: String, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol? {
        
        guard let refreshToken = AccessTokenManager.instance().currentToken?.refresh_token else {
            let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Refresh token required"])
            completion(error)
            return nil
        }

        return JsonServiceTaskHandler()
            
            .host { "https://native.kasamba.com" }

            .path { "/Account/LogOut" }
            
            .method { HTTPMethod.POST }
            
            .headers { SecuredServiceTaskHandler.generateAuthorizationInfo(token: token) }

            .body {
                return [
                "RefreshTokenId"               :refreshToken,
                ]}
            
            .encoder { UrlEncoder.default }

            .error { (error) in performOnMainQueue {
                completion(error)
                }
                
            }
            
            .dictionary { (dictionary) in
                
                if let error = StatusError.parseError(jsonDictionary: dictionary) {
                    performOnMainQueue { completion(error) }
                    return
                }
                
                performOnMainQueue { completion(nil) }
            }
            
            .execute()
    }
    
    public func registerBanID(banId: Int, completion: @escaping (Error?) -> Void) -> ServiceTaskHandlerProtocol {
        return KasambaServiceTaskHandler()
            
            .path { "/Member/Members/UpdateMemberBanID" }
            
            .method { HTTPMethod.POST }
            
            .body {[
                "banId"               :banId,
                ]}
            
            .error { (error) in performOnMainQueue {
                completion(error)
                
                } }
            
            .dictionary { (dictionary) in
                
                if let error = StatusError.parseError(jsonDictionary: dictionary) {
                    performOnMainQueue { completion(error) }
                    return
                }
                
                performOnMainQueue { completion(nil) }
            }
            
            .execute()

    }

    
    /// MARK: - Helper methods
    
    private func generateError(response: [AnyHashable: Any]) -> NSError {
        
        if let description = response["error_description"] as? String {
            return NSError(domain: StatusError.domain, code: StatusError.general, userInfo: [NSLocalizedDescriptionKey: description, "response": response])
        }
        
        return NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: ["response": response])
    }
    
}
