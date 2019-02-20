//
//  FeatureState.m
//  Kasamba
//
//  Created by Natan Zalkin on 6/8/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

#import "FeatureState.h"
#import <KasambaNativeSDK/KasambaNativeSDK-Swift.h>

@implementation FeatureState
-(BOOL)sortAndFilterEnabled {
    return [self getFlag:@"enableSortingInCategoryIOS" defaultValue:YES];
}

-(BOOL)multiCurrencyEnabled {
    return NO;
}

-(BOOL)threeFreeMinutesFeatureEnabled {
    return [self getFlag:@"enableThreeFMBannerIOS" defaultValue:YES];
}

-(BOOL)pullToRefreshFeatureEnabled {
    return [self getFlag:@"enablePullToRefreshIOS" defaultValue:YES];
}

-(BOOL) logglyEnabled
{
    return [self getFlag:@"logglyEnabledIOS-2315" defaultValue:YES];
}
-(BOOL) connectivityCheckEnabled
{
    return [self getFlag:@"enableConnectivityCheck" defaultValue:NO];
}
-(BOOL) popUpEnabled
{
    return [self getFlag:@"enablePopUpIOS" defaultValue:NO];
}
-(NSInteger)defaultAdvisorSorting {
    return [self getIntegerValue:@"defaultMarketingSortingIOS" defaultValue:0];
}

-(BOOL)funnelEventsEnabled {
    return [self getFlag:@"funnelEventsEnableIOS" defaultValue:YES];
}

-(BOOL)deepLinkRedirectEnabled {
    
    return [self getFlag:@"deepLinkRedirectEnabledIOS" defaultValue:YES];

}

-(BOOL)shouldTestGoogleAd {
    return NO;
}

-(BOOL)transactionEnabled {
#ifdef TESTING
    return YES;
#else
#ifdef DEBUG
    return YES;
#else
    return [self getFeatureFlagByJsonData:@"transactionJsonEnabled" defaultValue:NO];
#endif
#endif
}

-(BOOL)accountActivityEnabled {
    
#ifdef TESTING
    return YES;
#else
    #ifdef DEBUG
        return YES;
    #else
       return [self getFeatureFlagByJsonData:@"accountActivityEnableIOS-Json" defaultValue:NO] ||  [self getFeatureStateWithRemouteConfigByMemberIdWithKey:@"accountActivityMemberList"];
    #endif
#endif

    
}

-(BOOL)popUpEnabledJson {

#ifdef TESTING
    return YES;
#else
#ifdef DEBUG
    return YES;
#else
    return [self getFeatureFlagByJsonData:@"treeFMPopUpEnableIOS-Json" defaultValue:NO];
#endif
#endif
    
    
}

-(BOOL)lpredirectEnabled {
    return [self getFlag:@"enableLpredirectIOS" defaultValue:YES];
}

-(BOOL)sharedSafariCredentialsEnable {
#ifdef TESTING
    return YES;
#else
    return [self getFlag:@"sharedSafariCredentialsEnableIOS" defaultValue:NO];
#endif
}

-(BOOL)horoscopeEnabled {
#ifdef TESTING
    return YES;
#else
    #ifdef DEBUG
        return YES;
    #else
        return [self getFlag:@"IOSHoroscopeFlag" defaultValue:YES];
    #endif
#endif
}

-(BOOL)shouldResetSessionBanID {
    return [self getFlag:@"shouldResetSessionBanID" defaultValue:YES] ;
}

-(BOOL)isNativeChatOpenForIpad {
    return [self getFlag:@"isNativeChatOpenForIpad" defaultValue:YES];
}

-(BOOL)shouldUseIpadSiteId {
    return [self getFlag:@"shouldUseIpadSiteId" defaultValue:NO] ;
}


-(BOOL)nativeChatEnabled {
#ifdef TESTING
    return YES;
#else
    #ifdef DEBUG
        return YES;
    #else
    
        if (Utilities.appParameters.isIpadVersion && [self isNativeChatOpenForIpad]) {
            return YES;
        }
    
        return YES;
//        return ([self getFeatureFlagByJsonData:@"nativeChatEnableIOS-Json" defaultValue:YES] || [self getFlag:@"nativeChatEnableIOS-New" defaultValue:YES]);

    #endif
#endif
}

-(BOOL)isTranscriptChatEnabled {
#ifdef TESTING
    return YES;
#else
#ifdef DEBUG
    return YES;
#else
    if (@available(iOS 11.0, *)) {
        return [self getFeatureFlagByJsonData:@"transcriptChatEnableIOS" defaultValue:NO] ;
    }
    else {
        return NO;
    }

#endif
#endif

}

-(BOOL)isDisconectedTranscriptChatEnabled {
    
#ifdef TESTING
    return YES;
#else
#ifdef DEBUG
    return YES;
#else
    if (@available(iOS 11.0, *)) {
        return [self getFeatureFlagByJsonData:@"disconnectedTranscriptChatEnableIOS" defaultValue:NO] ;
    }
    else {
        return NO;
    }

#endif
#endif
}

-(BOOL)nativeChatRateEnabled {
#ifdef TESTING
    return YES;
#endif
#ifdef DEBUG
    return YES;
#endif
    return [self getFlag:@"nativeChatRateEnableIOS" defaultValue:NO];
}

-(BOOL)memberBalanceEnabeld{
    return YES;
#ifdef TESTING
    return YES;
#endif
#ifdef DEBUG
    return YES;
#endif
    
    BOOL isEnabled = NO;
    
    if (Utilities.featureState.transactionEnabled) {
        isEnabled = [self getFeatureFlagByJsonData:@"memberBalanceJsonEnabeld" defaultValue:NO];
    }

    return isEnabled;
}

-(BOOL)getCategoriesFromCasEnabeld{

#ifdef TESTING
    return YES;
#endif
#ifdef DEBUG
    return YES;
#endif
    return [self getFeatureFlagByJsonData:@"getCategoriesFromCasEnabeldIOS-json" defaultValue:NO];

}

#pragma mark - Private

-(NSInteger)getIntegerValue:(NSString *)featureName defaultValue:(NSInteger)defaultValue {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [defaults objectForKey:featureName];
    if (value == nil)
    {
        return defaultValue;
    }
    else
    {
        return [value integerValue];
    }
}

-(BOOL)getFlag:(NSString *)featureName defaultValue:(BOOL)defaultValue {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* enableState = [defaults objectForKey:featureName];
    if (enableState == nil)
    {
        return defaultValue;
    }
    else
    {
        return [enableState boolValue];
    }
}

-(BOOL)getFeatureFlagByJsonData :(NSString*)featureName defaultValue:(BOOL)defaultValue {
    NSError * error=nil;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* jsonData = [defaults objectForKey:featureName];
    
    if (jsonData == nil) {
        return defaultValue;
    }
        
    NSData * featureFlagValue = [jsonData  dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary * featureFlagValueData = [NSJSONSerialization JSONObjectWithData:featureFlagValue options:NSJSONReadingMutableContainers error:&error];
    NSInteger buildVersionNumber = [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey] integerValue];
    BOOL isFeatureEnabled = [[featureFlagValueData objectForKey:@"State"] boolValue];
    NSInteger featureVersionNumber = [[featureFlagValueData objectForKey:@"MinBuildVersion"]integerValue];
    NSString * featurePercentage = [featureFlagValueData objectForKey:@"Percentage"];
    BOOL isLivePersonOpenFlag= [[featureFlagValueData objectForKey:@"isLivePersonOpenFlag"] boolValue];;
    NSInteger featureMinUserID= [[featureFlagValueData objectForKey:@"MinUserID"] integerValue];
    NSInteger featureMaxUserID= [[featureFlagValueData objectForKey:@"MaxUserID"] integerValue];

    if (isFeatureEnabled &&  ([self getMemberValidByUserIdRange:featureMinUserID featureMaxUserID:featureMaxUserID]) ){
        if (buildVersionNumber >= featureVersionNumber) {
            if ([self getMemberByPercentage:featurePercentage]) {
                return YES;
            }
            else {
                return NO;
            }
        }
        else if (buildVersionNumber < featureVersionNumber){
            return NO;
        }
        return YES;
    }
    else if (isFeatureEnabled && [self getIsLivePersonUser:isLivePersonOpenFlag]){
        return YES;
    }
    else{
      return NO;
    }
    return defaultValue;
}

-(BOOL)getMemberByPercentage :(NSString*)PercentageString {
    NSString * memberIdString = [[[AccountManager instance] accountData].MemberID stringValue];
    NSInteger memberLastDigit = [[memberIdString substringFromIndex: [memberIdString length] - 1] integerValue] ;
    NSInteger percentageAsNumber = [[PercentageString substringToIndex:1] integerValue];
    if ([PercentageString isEqualToString:@"100"] ) {
        return YES;
    }
  

    else {
        if (percentageAsNumber >  memberLastDigit){
            return YES;
        }
        else{
            return NO;
        }
    }
}

-(BOOL)getMemberValidByUserIdRange :(NSInteger)featureMinUserID featureMaxUserID:(NSInteger)featureMaxUserID {
    NSInteger memberID = [[[AccountManager instance] accountData].MemberID integerValue];
    if (memberID >= featureMinUserID && memberID <= featureMaxUserID)
        return YES;
    else if (featureMinUserID == 0 && featureMaxUserID == 0)
        return YES;
    else
        return NO;
}

-(BOOL)getIsLivePersonUser :(BOOL)isLivePersonOpenFlag {
    if ([[[AccountManager instance] userDetails].userEmail containsString:@"liveperson.com"] && isLivePersonOpenFlag)
        return YES;
    else
        return NO;
}

@end
