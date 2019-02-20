//
//  SalesService.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/30/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation

class ConfigurationService: ConfigurationServiceProtocol {
    
    private(set) var current: ClientConfiguration? = nil
    
    private var lastConfigurationFetched: Date? = nil
    private var configurationFetchHandler: RestServiceTaskHandler? = nil
    
    
    func getConfiguration(completion: ((ClientConfiguration?, Error?) -> Void)?) -> ServiceTaskHandlerProtocol? {
        
        if let configurationFetchHandler = configurationFetchHandler {
            let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Configuration fetch already in progress"])
            performOnMainQueue { completion?(nil, error) }
            return configurationFetchHandler
        }
        
        if let lastConfigurationFetched = lastConfigurationFetched, Date().timeIntervalSince(lastConfigurationFetched) < Utilities.appParameters.configurationFetchInterval {
            let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "To early since last configuration fetch request (\(lastConfigurationFetched))"])
            performOnMainQueue { completion?(nil, error) }
            return configurationFetchHandler
        }
        
        configurationFetchHandler = NativeServiceTaskHandler()
            
            .path {
                "/ClientConfiguration"
            }
            
            .method {
                HTTPMethod.GET
            }
            
            .query {[
                "appVersion": "1.2",
                "resourcesVersion": "1.0.0",
                "clientType": "iPhone"
                ]}
            
            .error { (error) in
                performOnMainQueue {
                    
                    self.configurationFetchHandler = nil
                    
                    completion?(nil, error)
                }
            }
            
            .dictionary { (dictionary) in
                
                guard let data = dictionary["Configuration"] as? [AnyHashable: Any] else {
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Got invalid data from server, expected 'Configuration' field"])
                    performOnMainQueue {
                        
                        self.configurationFetchHandler = nil
                        
                        completion?(nil, error)
                    }
                    return
                }
                
                guard let configuration = ClientConfiguration(jsonData: data) else {
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Got invalid data from server, failed to deserialize configuration object"])
                    performOnMainQueue {
                        
                        self.configurationFetchHandler = nil
                        
                        completion?(nil, error)
                    }
                    return
                }
                
                performOnMainQueue {
                    
                    self.current = configuration
                    self.lastConfigurationFetched = Date()
                    self.configurationFetchHandler = nil
                    
                    completion?(configuration, nil)
                }
            }
        
            .execute()
        
        return configurationFetchHandler
    }
    
    
    func getLocalizations(completion: @escaping ([String: LocalizedStrings]?, Error?) -> Void) -> ServiceTaskHandlerProtocol {
    
        return NativeServiceTaskHandler()
        
            .path {
                "/Resources"
            }
            
            .method {
                HTTPMethod.GET
            }
            
            .query {[
                "appName": "Mobile",
                "resourcesVersion": "1.0.0"
                ]}
            
            .error { (error) in
                performOnMainQueue {
                    completion(nil, error)
                }
            }
            
            .dictionary { (dictionary) in
                
                guard let translations = dictionary["LanguageTranslation"] as? [String: [AnyHashable: Any]] else {
                    let error = NSError(domain: ServiceError.domain, code: ServiceError.general, userInfo: [NSLocalizedDescriptionKey: "Got invalid data from server, expected 'LanguageTranslation' field"])
                    performOnMainQueue { completion(nil, error) }
                    return
                }
                
                var localizations = [String: LocalizedStrings]()
                
                for (identifier, content) in translations {
                    
                    guard let strings = content["Strings"] as? LocalizedStrings else {
                        continue
                    }
                    
                    #if TESTING
                        
                        let teststrings = MutableLocalizedStrings()
                        
                        for element in strings {
                            teststrings[element.key] = "[QA] " + (element.value as! String)
                        }
                    
                        localizations[identifier.lowercased()] = teststrings
                    #else
                        localizations[identifier.lowercased()] = strings
                    #endif
                }
                
                performOnMainQueue { completion(localizations, nil) }
                
            }
            
            .execute()
    }

}
