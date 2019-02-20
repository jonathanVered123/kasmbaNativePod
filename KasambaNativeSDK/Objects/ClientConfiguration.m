//
//  ClientConfiguration.m
//  consumer
//
//  Created by Alexander Forshtat on 2/28/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "ClientConfiguration.h"

@implementation ClientConfiguration
-(id)initWithJSONData:(NSDictionary*)data{
    self = [super initWithJSONData: data];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if(self){
        @try {
            [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
                [defaults setObject:obj forKey:key];
            }];
        }
        @catch (NSException *exception) {
            return nil;
        }
        @finally {
        }
    }
    return self;
}

-(NSString*) expertImageUrl
{
    return [self defaultStringByKey:@"expertImageUrl" defaultString:@"https://expertsimages.kassrv.com/experts-pictures/big/pic%ld.jpg"];
}

-(NSString*) WebViewNavigationUrl
{
    return [self defaultStringByKey:@"WebViewNavigationUrl" defaultString:@"https://touch.kasamba.com/authentication/Login-And-Redirect.ashx"];
}

-(NSString*) WebViewNavigationReturnUrl
{
    return [self defaultStringByKey:@"WebViewNavigationReturnUrl" defaultString:@"http://touch.kasamba.com/pages/session-selector.aspx"];
}
-(NSString*) WebViewMessagesInboxUrl
{
    return [self defaultStringByKey:@"WebViewMessagesInboxUrl" defaultString:@"http://touch.kasamba.com/messages/inbox"];
}
-(NSString*) WebViewComposeMessageUrl
{
    return [self defaultStringByKey:@"WebViewComposeMessageUrl" defaultString:@"https://touch.kasamba.com/messages/compose-message/"];
}
-(NSString*) TermsAndConditionsUrl
{
    return [self defaultStringByKey:@"TermsAndConditionsUrl" defaultString:@"http://touch.kasamba.com/pages/landingpages/default.aspx?DlpID=58456"];
}
-(NSString*) WebViewReadMessageUrl
{
    return [self defaultStringByKey:@"WebViewReadMessageUrl" defaultString:@"https://touch.kasamba.com/messages/read-message/"];
}

-(NSString*) IphoneMinVersion
{
    return [self defaultStringByKey:@"IphoneMinVersion" defaultString:@"0.0"];
}

-(NSString*) defaultStringByKey: (NSString*) key defaultString: (NSString*) defaultString
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* webViewNavigationUrl = [defaults stringForKey:key];
    if (webViewNavigationUrl == nil)
    {
        webViewNavigationUrl = defaultString;
    }
    return webViewNavigationUrl;
}

-(BOOL) log
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* log = [defaults objectForKey:@"log"];
    if (log == nil)
    {
        return YES;
    }
    else
    {
        return [log boolValue];
    }
}

-(BOOL) log_all_registrations
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* log_all_registrations = [defaults objectForKey:@"log_all_registrations"];
    if (log_all_registrations == nil)
    {
        return YES;
    }
    else
    {
        return [log_all_registrations boolValue];
    }
}

-(int) autoNotifyMeDurationInSeconds
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* duration = [defaults objectForKey:@"auto_notify_me_in_seconds"];
    if (duration == nil)
    {
        return 10;
    }
    else
    {
        return [duration intValue];
    }
}

-(NSArray*)getSanitizeUrl
{
    @try {
        NSData* bytes = [self.sanitizedUrls dataUsingEncoding:NSUTF8StringEncoding];
        NSArray* array = [NSJSONSerialization JSONObjectWithData: bytes options:0 error:nil];
        return array;
    }
    @catch (NSException * e) {
        return [NSArray init];
    }
}

@end
