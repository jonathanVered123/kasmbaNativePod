//
//  Utilities.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/21/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation

@objc
public class Utilities: NSObject {
    
    @objc static public let localizations: LocalizationHelper = LocalizationHelper()
    @objc static public let appParameters: AppParametersProtocol = AppParameters()
    @objc static public let featureState: FeatureStateProtocol = FeatureState()
    @objc static public let connectivity: ConnectivityProtocol = Connectivity()
    
}
