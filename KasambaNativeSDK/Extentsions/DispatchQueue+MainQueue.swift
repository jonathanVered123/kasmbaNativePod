//
//  DispatchQueue+Helper.swift
//  Beezee
//
//  Created by Natan Zalkin on 12/05/2017.
//  Copyright © 2017 Natan Zalkin. All rights reserved.
//

import Foundation


func performOnMainQueue(sync: Bool = false, work: @escaping () -> Swift.Void) {
    
    if Thread.isMainThread {
        work()
    }
    else {
        if sync {
            DispatchQueue.main.sync(execute: work)
        }
        else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
}

func performOnMainQueue(sync: Bool = false, work: @escaping @autoclosure () -> Swift.Void) {
    
    if Thread.isMainThread {
        work()
    }
    else {
        if sync {
            DispatchQueue.main.sync(execute: work)
        }
        else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
}


extension DispatchQueue {
    
    
    /// Executes work on Main queue. If already running on main queue will execute block immideately. Will add block to main queue otherwise
    static func executeOnMain(_ work: @escaping () -> Swift.Void) {
        
        if Thread.isMainThread {
            work()
        }
        else {
            DispatchQueue.main.async(execute: work)
        }
        
    }
    
}
