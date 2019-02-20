//
//  FeatureStateProtocol.h
//  Kasamba
//
//  Created by Natan Zalkin on 6/8/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FeatureStateProtocol <NSObject>

@property (readonly) BOOL multiCurrencyEnabled;
@property (readonly) BOOL pullToRefreshFeatureEnabled;
@property (readonly) BOOL threeFreeMinutesFeatureEnabled;
@property (readonly) BOOL logglyEnabled;
@property (readonly) BOOL sortAndFilterEnabled;
@property (readonly) NSInteger defaultAdvisorSorting;
@property (readonly) BOOL lpredirectEnabled;
@property (readonly) BOOL funnelEventsEnabled;
@property (readonly) BOOL deepLinkRedirectEnabled;
@property (readonly) BOOL sharedSafariCredentialsEnable;
@property (readonly) BOOL connectivityCheckEnabled;
@property (readonly) BOOL shouldTestGoogleAd;
@property (readonly) BOOL accountActivityEnabled;
@property (readonly) BOOL horoscopeEnabled;
@property (readonly) BOOL nativeChatEnabled;
@property (readonly) BOOL nativeChatRateEnabled;
@property (readonly) BOOL shouldUseIpadSiteId;
@property (readonly) BOOL shouldResetSessionBanID;
@property (readonly) BOOL popUpEnabled;
@property (readonly) BOOL popUpEnabledJson;
@property (readonly) BOOL isTranscriptChatEnabled;
@property (readonly) BOOL isDisconectedTranscriptChatEnabled;
@property (readonly) BOOL memberBalanceEnabeld;
@property (readonly) BOOL transactionEnabled;
@property (readonly) BOOL getCategoriesFromCasEnabeld;

@end
