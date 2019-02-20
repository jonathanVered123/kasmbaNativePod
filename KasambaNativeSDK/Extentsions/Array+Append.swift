//
//  Array+Append.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/16/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


func +<T>(lhs: [T], rhs: [T]) -> [T] {
    var lhs: [T] = lhs
    lhs.append(contentsOf: rhs)
    return lhs
}

func +<T>(lhs: [T], rhs: T) -> [T] {
    var lhs: [T] = lhs
    lhs.append(rhs)
    return lhs
}
