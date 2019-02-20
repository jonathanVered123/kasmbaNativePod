//
//  RegistrationServiceProtocol.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/30/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation

@objc
public protocol UserAccountServiceProtocol {
    
    var tracking: [AnyHashable: Any]? { get set }
    
    @discardableResult
    @objc(registerUsername:password:completion:)
    func register(username: String, password: String, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol
    
    @discardableResult
    func login(username: String, password: String, completion: @escaping (_ accessToken: AccessToken?, _ facebookUser: Bool, _ error: Error?) -> Void) -> ServiceTaskHandlerProtocol
    
    @discardableResult
    func login(facebookToken: String, completion: @escaping (_ accessToken: AccessToken?, _ isNewUser: Bool, _ error: Error?) -> Void) -> ServiceTaskHandlerProtocol
    
    @discardableResult
    @objc(logoutWithToken:completion:)
    func logout(token: String, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol?

    @discardableResult
    func getAccountDetails(token: String, completion: @escaping (_ response: AccountResponse?, _ error: Error?) -> Void) -> ServiceTaskHandlerProtocol
    
    @discardableResult
    @objc(getUserDetails:)
    func getUserDetails(completion: @escaping (_ response: UserDetails?, _ error: Error?) -> Void) -> ServiceTaskHandlerProtocol?

    @discardableResult
    @objc(resetPasswordForUsername:completion:)
    func resetPassword(username: String, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol
        
    @discardableResult
    func refreshAccessToken(completion: @escaping (_ accessToken: AccessToken?, _ error: Error?) -> Void) -> ServiceTaskHandlerProtocol?
    
    @discardableResult
    @objc(registrationUserAgentDetailsWithMemberId:version:userAgent:deviceModel:deviceType:deviceVendor:osVersion:osName:browserMajorVersion:browserName:siteId:completion:)
    func registrationUserAgentDetails(memberId: Int, version: String,userAgent: String, deviceModel: String, deviceType: String, deviceVendor: String, osVersion: String, osName: String, browserMajorVersion: String, browserName: String, siteId: Int, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol

    @discardableResult
    @objc(addChatSessionUserAgentDetailsWithMemberId:version:userAgent:deviceModel:deviceType:deviceVendor:osVersion:osName:browserMajorVersion:browserName:siteId:sessionId:completion:)
    func addChatSessionUserAgentDetails(memberId: Int, version: String,userAgent: String, deviceModel: String, deviceType: String, deviceVendor: String, osVersion: String, osName: String, browserMajorVersion: String, browserName: String, siteId: Int, sessionId: Int, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol

    @discardableResult
    @objc(registrationMetadataWithSiteId:appsFlyerId:advertisingId:completion:)
    func registrationMetadata(siteId: Int, appsFlyerId: String,advertisingId: String, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol

    @discardableResult
    @objc(registrationMetadataWithSessionId:siteId:sessionIdappsFlyerId:advertisingId:completion:)
    func registrationMetadata(sessionId: Int, siteId: Int, appsFlyerId: String,advertisingId: String, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol

    @discardableResult
    @objc(registrationBanId:completion:)
    func registerBanID(banId: Int, completion: @escaping (_ error: Error?) -> Void) -> ServiceTaskHandlerProtocol

}
