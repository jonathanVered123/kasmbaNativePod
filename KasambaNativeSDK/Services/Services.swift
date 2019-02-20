//
//  ServiceProvider.swift
//  Kasamba
//
//  Created by Natan Zalkin on 7/16/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

import Foundation

@objc
public class Services: NSObject {
    
    @objc static var session = URLSession(configuration: URLSessionConfiguration.default)
    
//    @objc static let downloader: DownloaderProtocol = Downloader()
    
    @objc static public  let  userAccount: UserAccountServiceProtocol = UserAccountService()
//    @objc static let instantMessages: InstantMessagingServiceProtocol = InstantMessagingService()
//    @objc static let transcripts: TranscriptsServiceProtocol = TranscriptsService()
//    @objc static let funnelEventTracker: FunnelEventTrackerProtocol = FunnelEventTracker()
//    @objc static let categories: CategoryProviderProtocol = CategoryProvider()
//    @objc static let advisors: AdvisorsProviderProtocol = AdvisorsProvider()
//    @objc static let sales: SalesServiceProtocol = SalesService()
    @objc static let configuration: ConfigurationServiceProtocol = ConfigurationService()
//    @objc static let horoscope: HoroscopeProviderProtocol = HoroscopeProvider()
//    @objc static let accountActivity: AccountActivityServiceProtocol = AccountActivityService()

}
