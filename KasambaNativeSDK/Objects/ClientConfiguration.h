//
//  ClientConfiguration.h
//  consumer
//
//  Created by Alexander Forshtat on 2/28/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "NetworkObject.h"
@interface ClientConfiguration : NetworkObject

//@property NSString* AndroidTagManagerContainerId;
//@property NSString* IosTagManagerContainerId;
@property (nonatomic) NSString* WebViewNavigationUrl;
@property (nonatomic) NSString* WebViewNavigationReturnUrl;
@property (nonatomic) NSString* WebViewMessagesInboxUrl;
@property (nonatomic) NSString* WebViewComposeMessageUrl;
@property (nonatomic) NSString* WebViewReadMessageUrl;
@property (nonatomic) NSString* TermsAndConditionsUrl;
@property (nonatomic) NSString* sanitizedUrls;
@property (nonatomic) NSString* expertImageUrl;

//@property NSString* TouchDomainForNativeUsage;
//@property NSString* IphoneRedirection;
//@property NSString* AndroidRedirection;
//@property NSString* TouchErrorPageForNativeUsage;
//@property NSString* TouchOnlineChatPageForNativeUsage;
//@property NSString* KasambaDomainForNativeUsage;
//@property NSString* TouchSupportPageForNativeUsage;
//@property NSString* TouchSupportDomainForNativeUsage;
//@property NSString* RedirectionUrl;
//
//@property NSNumber* IsResoucesCompatible;
//@property NSNumber* AndroidMinVersion;
//@property NSNumber* IsAboveMinimum;
//@property NSNumber* IsAppLatestCompatible;
//@property NSNumber* IphoneNewVersion;
//@property NSNumber* AndroidNewVersion;
//@property NSNumber* MobileResourcesVersion;
@property (nonatomic) NSString* IphoneMinVersion;
-(BOOL) log;
-(BOOL) log_all_registrations;
-(int) autoNotifyMeDurationInSeconds;
-(id)initWithJSONData:(NSDictionary*)data;
-(NSArray*)getSanitizeUrl;
@end
