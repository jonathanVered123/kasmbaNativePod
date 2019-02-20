//
//  NSURLSessionDataTask.m
//  consumer
//
//  Created by Alexander Forshtat on 26.10.2016.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "AccessTokenManager.h"
#import "AccountManager.h"
#import "NetworkManager.h"
#import <KasambaNativeSDK/KasambaNativeSDK-Swift.h>

#define DAYS_BEFORE_EXPIRE 3

static AccessTokenManager* _instance;

typedef void(^RefreshTokenCompletionHandler)(BOOL);

@interface AccessTokenManager ()

@property (atomic, assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, strong) NSMutableArray<NSURLSessionDataTask*> * tasksQueueArray;
@property (nonatomic, strong) NSMutableArray * completionHandlersArray;
@property (nonatomic, strong) NSMutableArray<RefreshTokenCompletionHandler>* refreshCompletionHandlers;

@end

@implementation AccessTokenManager

+(AccessTokenManager*) instance
{
    if (_instance == nil)
    {
        _instance = [[AccessTokenManager alloc]  init];
    }
    return _instance;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tasksQueueArray = [NSMutableArray new];
        _completionHandlersArray = [NSMutableArray new];
        _refreshCompletionHandlers = [NSMutableArray new];
    }
    return self;
}

-(AccessToken*) currentToken
{
    AccessToken* accessToken = [[AccessToken alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    accessToken.access_token = [userDefaults stringForKey:@"access_token"];
    if (accessToken.access_token != nil)
    {
        accessToken.refresh_token = [userDefaults stringForKey:@"refresh_token"];
        accessToken.token_type = [userDefaults stringForKey:@"token_type"];
        accessToken.expires_in = [userDefaults stringForKey:@"expires_in"];
        accessToken.client_id = [userDefaults stringForKey:@"client_id"];
        accessToken.expires = [userDefaults objectForKey:@"expires"];
        accessToken.expires_old = [userDefaults stringForKey:@"expires_old"];
        accessToken.issued = [userDefaults stringForKey:@"issued"];
    }
    else
    {
        return nil;
    }
    return accessToken;
}

-(void) setCurrentToken: (AccessToken*) accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (accessToken == nil )
    {
        [userDefaults removeObjectForKey:@"refresh_token"];
        [userDefaults removeObjectForKey:@"access_token"];
        [userDefaults removeObjectForKey:@"token_type"];
        [userDefaults removeObjectForKey:@"expires_in"];
        [userDefaults removeObjectForKey:@"client_id"];
        [userDefaults removeObjectForKey:@"expires"];
        [userDefaults removeObjectForKey:@"expires_old"];
        [userDefaults removeObjectForKey:@"issued"];
        [userDefaults synchronize];
    }
    else
    {
        [userDefaults setObject:accessToken.refresh_token forKey:@"refresh_token"];
        [userDefaults setObject:accessToken.access_token forKey:@"access_token"];
        [userDefaults setObject:accessToken.token_type forKey:@"token_type"];
        [userDefaults setObject:accessToken.expires_in forKey:@"expires_in"];
        [userDefaults setObject:accessToken.client_id forKey:@"client_id"];
        [userDefaults setObject:accessToken.expires forKey:@"expires"];
        [userDefaults setObject:accessToken.expires_old forKey:@"expires_old"];
        [userDefaults setObject:accessToken.issued forKey:@"issued"];
        [userDefaults synchronize];
    }
}

-(BOOL) getTokenWithDataTask:(NSURLSessionDataTask*) task withCompletionHandler:  (void (^)(NSData * data, NSURLResponse * response, NSError * error)) completionHandler
{
    // Bug reported by Kobi on 26-oct-2016
    // Application left in background over the token expiration date
    if ([[AccessTokenManager instance] currentToken].refresh_token != nil)
    {
        if (self.isRefreshing)
        {
            
            //[RemoteLogger append:@" Attempt to use token while refresh is running..." context:EMPTY_PAGE];
            if (task != nil && completionHandler != nil)
            {
                [self.completionHandlersArray addObject:completionHandler];
                [self.tasksQueueArray addObject:task];
            }
            return NO;
        }
        
        BOOL isAccessTokenValid = [self isAccessTokenValid];
        BOOL isAccessTokenWillExpireSoon = [self isAccessTokenWillExpireSoon];
        // NSDate *date = [self.currentToken getExpirationDate];
        
        if (!isAccessTokenValid || isAccessTokenWillExpireSoon)
        {
            if (task != nil && completionHandler != nil)
            {
                [self.completionHandlersArray addObject:[completionHandler copy]];
                [self.tasksQueueArray addObject:task];
            }
            self.refreshing = YES;
            [self refreshToken];
            return NO;
        }
    }
//    else
//    {
//        isRefreshing = YES;
//        [[AccessTokenManager instance] refreshToken];
//        return NO;
//    }
    
    [task resume];
    return YES;
}

-(void)refreshTokenWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    // Bug reported by Kobi on 26-oct-2016
    // Application left in background over the token expiration date
    if ([[AccessTokenManager instance] currentToken].refresh_token == nil) {
        if (completionHandler) {
            completionHandler(NO);
        }
        return;
    }
    
    if (self.isRefreshing) {
        
        [self.refreshCompletionHandlers addObject:completionHandler];
        
    }
    else {
        
        BOOL isAccessTokenValid = [self isAccessTokenValid];
        BOOL isAccessTokenWillExpireSoon = [self isAccessTokenWillExpireSoon];
        
        if (!isAccessTokenValid || isAccessTokenWillExpireSoon) {
            
            self.refreshing = YES;
            
            [self.refreshCompletionHandlers addObject:completionHandler];
            
            [self refreshTokenUsingModernMethod];
            
        }
        else {
            if (completionHandler) {
                completionHandler(NO);
            }
        }
    }
}

-(BOOL) isAccessTokenValid
{
#ifdef TESTING
#warning TEST CODE!
    if (arc4random_uniform(100) < 30) {
        return NO;
    }
#endif
    
    long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    
    //  if access_token is expired, will be nil...
    // if ([date timeIntervalSinceNow] <= 0)
    return [[[AccessTokenManager instance] currentToken] getExpirationDate] > currentTime;
}

-(BOOL) isAccessTokenWillExpireSoon
{
#ifdef TESTING
#warning TEST CODE!
    if (arc4random_uniform(100) < 30) {
        return YES;
    }
#endif
    
    long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    long deltaDaysUntilExperationDate = (long)(NSTimeInterval)([[self currentToken] getExpirationDate] - (60 * 60 * 24 * DAYS_BEFORE_EXPIRE)); // seconds * minutes * hours * days
    
    return deltaDaysUntilExperationDate <= currentTime ;
}

-(void)performSuccess
{
    NSURLSession *session = [NSURLSession sharedSession];
    for (int i = 0; i < self.tasksQueueArray.count; i++)
    {
        NSURLSessionDataTask* task = [self.tasksQueueArray objectAtIndex:i];
        NSMutableURLRequest* mutableRequest = [[task currentRequest] mutableCopy];
        NSString* token = [[AccessTokenManager instance] currentToken].access_token;
        if (token == nil)
        {
            token = @"";
        }
        else {
            NSString* bearer = [@"Bearer " stringByAppendingString:token];
            [mutableRequest setValue:bearer forHTTPHeaderField:@"Authorization"];
            //        [task cancel];
            NSURLSessionDataTask* newTask = [session dataTaskWithRequest:mutableRequest completionHandler:[self.completionHandlersArray objectAtIndex:i]];
            [newTask resume];
        }
        //        [task resume];
    }
    [self.tasksQueueArray removeAllObjects];
    [self.completionHandlersArray removeAllObjects];
    
    for (RefreshTokenCompletionHandler refreshCompletionHandler in self.refreshCompletionHandlers) {
        refreshCompletionHandler(YES);
    }
    [self.refreshCompletionHandlers removeAllObjects];
    
}

-(void)performFailure
{
    for (NSURLSessionDataTask *task in self.tasksQueueArray)
    {
        [task cancel];
    }
    [self.tasksQueueArray removeAllObjects];
    [self.completionHandlersArray removeAllObjects];
    
    for (RefreshTokenCompletionHandler refreshCompletionHandler in self.refreshCompletionHandlers) {
        refreshCompletionHandler(NO);
    }
    [self.refreshCompletionHandlers removeAllObjects];
    
}

//extern Environment environment;

-(void) refreshTokenIfExpired {
    if ([self isAccessTokenWillExpireSoon] && [[AccountManager instance] isUserLogedIn]) {
        [[AccessTokenManager instance] refreshToken];
    }
}


-(void) refreshToken
{
    NSString* urlString = @"https://native.kasamba.com/oauth/loginfortoken";
    //    switch (environment) {
    //        case QA_ENVIRONMENT:
    //            urlString = @"http://192.168.25.251/oauth/loginfortoken";
    //            break;
    //        case STAGING_ENVIRONMENT:
    //            urlString = @"https://native.kasamba.com/oauth/loginfortoken";
    //            break;
    //        case PRODUCTION_ENVIRONMENT:
    //            urlString = @"https://native.kasamba.com/oauth/loginfortoken";
    //        default:
    //            break;
    //    }
    
    NSDictionary *urlEncoded = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [[AccessTokenManager instance] currentToken].refresh_token, refresh_token_field,
                                @"refresh_token", grant_type_field,
                                @"nativeApp", client_id_field,
                                client_secret, client_secret_field,
                                nil];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *headers = [[NSDictionary alloc]
                             initWithObjects:
                             @[@"kasamba_mobile", appVersion]
                             forKeys:@[@"SiteName", @"versionName"]];
    
    // Create session using config
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Create URL
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Create URL request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    for (id key in headers)
    {
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *post = [[NSMutableString alloc] init];
    for (id key in urlEncoded)
    {
        NSString* value = [NetworkManager URLEncodedString_ch:[NSString stringWithFormat:@"%@", [urlEncoded objectForKey:key]]];
        [post appendFormat:@"%@=%@&", key, value];
    }
    NSData *mPostData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[mPostData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:mPostData];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    // Create data task
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        
        if ([(NSHTTPURLResponse*)response statusCode] == 401) // error response received
        {
            NSString* errorCode = [[(NSHTTPURLResponse*)response allHeaderFields] objectForKey:@"X-ErrorId"];
            if ([errorCode isEqualToString:@"2"]) // bad RefreshToken
            {
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    [[AccessTokenManager instance] wipeLocalData]; // erase local data
                    
                    // logout and show popup alert
                });
            }
        }
        
        
        if (error != nil)
        {
            // failed no token
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[AccessTokenManager instance] performFailure];
            });
        }
        else if (data != nil)
        {
            NSDictionary *tokenFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            AccessToken *token = nil;
            long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
            
            if ([data isKindOfClass:[NSData class]] && data.length == 0 && [[self currentToken] getExpirationDate] > currentTime) {
                token = [self currentToken];
            }
            else {
                token = [[AccessToken alloc] initWithJSONData:tokenFromServer];
            }
            
            NSLog(@"Token refreshed: %@", token.access_token);
            if (token.access_token != nil)
            {
                //success
                if (token.refresh_token == nil)
                {
                    token.refresh_token = [[AccessTokenManager instance] currentToken].refresh_token;
                }
                [[AccessTokenManager instance] setCurrentToken: token];
                [[AccessTokenManager instance] performSuccess];
            }
            else
            {
                // failed protocol error
                NSMutableDictionary *details = [NSMutableDictionary dictionary];
                NSString *errorMessage = token.error_description;
                if (errorMessage == nil)
                {
                    errorMessage = @"Unknown error";
                }
                [details setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[AccessTokenManager instance] performFailure];
                });
            }
        }
        else
        {
            // failed protocol error
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[AccessTokenManager instance] performFailure];
            });
        }
        self.refreshing = NO;
    }];
    
    [getDataTask resume];
}

-(void) refreshTokenUsingModernMethod
{
    
    [Services.userAccount refreshAccessTokenWithCompletion:^(AccessToken * _Nullable newAccessToken, NSError * _Nullable error) {
        
        if (error && [error.domain isEqualToString:UserAccountError.domain] && error.code == UserAccountError.badRefreshToken) {
            
            
            return;
        }
        
        if (newAccessToken) {
            
//            if (newAccessToken.refresh_token == nil) {
//                newAccessToken.refresh_token = weakSelf.currentToken.refresh_token;
//            }
//
//            [weakSelf setCurrentToken: newAccessToken];
//            [weakSelf performSuccess];
            
        }
        else {
            long currentTime = (long)([[NSDate date] timeIntervalSince1970]);
            
//            if (newAccessToken == nil && weakSelf.currentToken && weakSelf.currentToken.getExpirationDate > currentTime) {
//
////                [weakSelf performSuccess];
//
//            }
//            else {
//
////                [weakSelf performFailure];
//            }
        }
        
    }];
}

-(void) removeAccessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"expires"];
    [userDefaults removeObjectForKey:@"expires_old"];
    [userDefaults synchronize];
}

-(void) wipeLocalData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:@"refresh_token"];
    [userDefaults removeObjectForKey:@"access_token"];
    [userDefaults removeObjectForKey:@"token_type"];
    [userDefaults removeObjectForKey:@"expires_in"];
    [userDefaults removeObjectForKey:@"client_id"];
    [userDefaults removeObjectForKey:@"expires"];
    [userDefaults removeObjectForKey:@"issued"];
    [userDefaults synchronize];

}

@end

