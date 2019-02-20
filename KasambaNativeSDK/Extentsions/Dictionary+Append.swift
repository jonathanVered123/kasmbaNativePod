//
//  Dictionary+Opeartors.swift
//  Kasamba
//
//  Created by Natan Zalkin on 19/07/2017.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation


func +<K, V>(lhs: [K:V], rhs: [K:V]) -> [K:V] {
    var lhs: [K:V] = lhs
    for (key, value) in rhs {
        lhs[key] = value
    }
    return lhs
}
