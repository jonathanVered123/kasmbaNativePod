//
//  Dictionary+KeyPaths.swift
//  Kasamba
//
//  Created by Natan Zalkin on 11/1/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


extension Dictionary {
    
    mutating public func setValue(val: Any, forKeyPath keyPath: String) {
        
        var keys = keyPath.components(separatedBy: ".")
        
        guard let first = keys.first as? Key else {
            print("Unable to use string as key on type: \(Key.self)")
            return
        }
        
        keys.remove(at: 0)
        
        if keys.isEmpty, let settable = val as? Value {
            self[first] = settable
        } else {
            
            let rejoined = keys.joined(separator: ".")
            var subdict: [AnyHashable : Any] = [:]
            if let sub = self[first] as? [AnyHashable : Any] {
                subdict = sub
            }
            
            subdict.setValue(val: val, forKeyPath: rejoined)
            
            if let settable = subdict as? Value {
                self[first] = settable
            } else {
                print("Unable to set value: \(subdict) to dictionary of type: \(type(of: self))")
            }
        }
        
    }
    
    public func valueForKeyPath<T>(keyPath: String) -> T? {
        
        var keys = keyPath.components(separatedBy: ".")
        
        guard let first = keys.first as? Key else {
            print("Unable to use string as key on type: \(type(of: Key.self))")
            return nil
            
        }
        
        guard let value = self[first] else {
            return nil
        }
        
        keys.remove(at: 0)
        
        if !keys.isEmpty, let subDict = value as? [AnyHashable : Any] {
            let rejoined = keys.joined(separator: ".")
            return subDict.valueForKeyPath(keyPath: rejoined)
        }
        
        return value as? T
    }
}
