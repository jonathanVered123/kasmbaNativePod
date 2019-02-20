//
//  NetworkManager.m
//  consumer
//
//  Created by Forsh on 18/01/2016.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//
//#import "RemoteLogger.h"
#import "NetworkManager.h"
#import "AccessTokenManager.h"

#define ADVISORS_PAGE_SIZE 20


@implementation NetworkManager
{
    NSString * server_ip;
    NSString * api_ip;
    NSString *topCategoriesURL;
    NSString *authentcationURL;
    NSString *facebookAuthURL;
    NSString *registrationURL;
    NSString *silentLoginURL;
    NSString *signOutURL;
    NSString *resetPasswordURL;
    NSString *searchAdvisorURL;
    NSString *localizationURL;
    NSString *categoryByNameURL;
    NSString *reviewsURL;
    NSString *advisorPromoURL;
    NSString* clientConfigurationURL;
    NSString* categoryByIdURL;
    NSArray *httpMethods;
    NSString *applicationVisitURL;
    NSString *bannerDataRequestURL;
    NSString *activatePushSubscriptionURL;
    NSString *deActivatePushSubscriptionURL;
    
    NSString *myAdvisorsURL;
    NSString* advisorsSearchURL;
    NSString *advisorsByCategoryURL;
    
    NSString *advisorByNameURL;
    
    NSString *unreadMessagesURL;
    NSString *notifyAdvisorURL;
    NSString *subscribeToNotifyURL;
    NSString *unSubscribeToNotifyURL;

    
    NSString *didHaveSessionURL;
    
    
    /// Tracking requests
    
    NSString *getTranscripts;
    NSString *getTranscriptWithId;
    NSString *getLastTranscript;
    NSString *getExpertsWithTranscripts;
    NSString *getTranscriptsForExpertWithId;
    
    NSString *saveTimezone;
    
    NSString *settingsURL;
    NSString *updateSettingsURL;
}


NSString * const ChannelType_toString[] = {
    [CHANNEL_TYPE_CHAT] = @"CHANNEL_TYPE_CHAT",
    [CHANNEL_TYPE_VOICE] = @"CHANNEL_TYPE_VOICE",
    [DEFAULT] = @"DEFAULT"
};

static NetworkManager *instance = nil;


+ (NetworkManager *)instance {
    if (instance == nil) {
        instance = [[NetworkManager alloc] init];
    }
    return instance;
}


//Environment environment = PRODUCTION_ENVIRONMENT;
- (instancetype)init
{
    self = [super init];
    
//    @"https://208.89.12.40";//Production IP
//    switch (environment) {
//        case QA_ENVIRONMENT:
//            server_ip = @"http://192.168.25.251";//QA IP
//            api_ip = @"http://192.168.25.244";
//            break;
//        case STAGING_ENVIRONMENT:
//            server_ip = @"http://staging.native.kasamba.com"; // Staging IP
//            api_ip = @"http://staging.api.kasamba.com";
//            break;
//        case PRODUCTION_ENVIRONMENT:
//            server_ip = @"https://native.kasamba.com";//Prod Ip
//            api_ip = @"https://api.kasamba.com";
//        default:
//            break;
//    }
    
    
    
//    api_ip = @"http://162.252.79.120";  // Staging IP
//    server_ip = @"http://162.252.79.118";
    
    api_ip = @"https://api.kasamba.com";
    server_ip = @"https://native.kasamba.com";
    
    httpMethods = @[@"OPTIONS", @"GET", @"HEAD", @"POST", @"PUT", @"DELETE", @"TRACE", @"CONNECT"];
    topCategoriesURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Categories/GuestTopCategories"];
    authentcationURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/oauth/loginfortoken"];
    facebookAuthURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Account/FacebookAuth"];
    registrationURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Account/signup"];
    silentLoginURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Account/Auth"];
    signOutURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Account/SignOut"];
    resetPasswordURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Account/ResetPassword?"];
    categoryByNameURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Categories/IdBySeoName?"];
    advisorPromoURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Promotion/FreeMinutes?"];
    categoryByIdURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Categories/NameById?"];
    localizationURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Resources?"];
    clientConfigurationURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/ClientConfiguration?"];
    applicationVisitURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Native/TriggerAppActive"];
    bannerDataRequestURL = [NSString stringWithFormat:@"%@%@", api_ip,@"/Sales/Sales/GetSaleDisplayDataByMemberId"];
    activatePushSubscriptionURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Notification/ActivatePushSubscription"];
    deActivatePushSubscriptionURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Notification/DeactivatePushSubscription"];
    didHaveSessionURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Members/DidClientHaveSession"];
    
    subscribeToNotifyURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Notification/SubscribeToExpertAvailabilityNotificationByPush"];
    unSubscribeToNotifyURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Notification/UnsubscribeToExpertAvailabilityNotificationByPush"];
    
    reviewsURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Expert/Reviews?"];
    
    // EXPERT REQUESTS NEW: !!

    myAdvisorsURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Pages/MyExperts"];

    
    advisorsSearchURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Pages/Search"];
    unreadMessagesURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/InstantMessages/CountUnreadInboxConversations"];
    advisorByNameURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Pages/ExpertProfile"];
    notifyAdvisorURL = [NSString stringWithFormat:@"%@%@", server_ip, @"/Member/Notification/UpdateExpertAvailabilityNotificationByPushSubscription"];
    
    getTranscripts = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Transcript/GetTranscript"];
    getExpertsWithTranscripts = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Transcript/GetExperts"];
    /// TODO: these two end with '/' because parameters will be sent as part of URL string, not query
    getTranscriptWithId = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Transcript/GetTranscript/%d"];
    getLastTranscript = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Transcript/GetLastTranscript"];
    getTranscriptsForExpertWithId = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Transcript/GetExpertSessions/%d"];
    saveTimezone = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/SaveTimeZone"];
    settingsURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Notification/GetSubscriptionSettingsByPush"];
    updateSettingsURL = [NSString stringWithFormat:@"%@%@", api_ip, @"/Member/Notification/UpdateSubscriptionSettingByPush"];
//    settingsURL = @"http://dev2.igates.co.il/cmd/KasambaSettingsTest.ashx";
    return self;
}


-(BOOL) isValidEmailAdress: (NSString*) candidate
{
    // Complete verification of RFC 2822 https://www.ietf.org/rfc/rfc2822.txt
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}



+(NSError*) errorWithMessage: (NSString* _Nullable) message inDomain: (NSString* _Nonnull) domain
{
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    if (message == nil)
    {
        message = @"Unknown error";
    }
    [details setValue:message forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:domain code:400 userInfo:details];
}

-(NSURLSessionDataTask* )
taskWithMethod: (NSString*) method
headers: (NSDictionary*) headers
urlEncodedDict:(NSDictionary*) urlEncoded
uriParametersDict:(NSDictionary*) uriParams
postData: (NSData*) postData
url: (NSString*) urlString
completionHandler: (void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler
{
    if ((([authentcationURL isEqualToString:urlString] || [facebookAuthURL isEqualToString:urlString]) /*&& [RemoteLogger facebookLogIn]*/))
    {
        //[RemoteLogger flushContext:INSTALLATION];
    }
    
    // Create session using config
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableString* urlStringM = [urlString mutableCopy];
    for (id key in uriParams)
    {
        NSString* value = [NetworkManager URLEncodedString_ch:[NSString stringWithFormat:@"%@", [uriParams objectForKey:key]]];
        [urlStringM appendFormat:@"%@=%@&", key, value];
    }
    if ([uriParams count] > 0)
        urlStringM = [[urlStringM substringToIndex:[urlStringM length] - 1] mutableCopy];
    // Create URL
    NSURL *url = [NSURL URLWithString:urlStringM];
    
    // Create URL request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (![httpMethods containsObject:method])
    {
        completionHandler(nil, nil, [NetworkManager errorWithMessage:@"Unknown HTTP method" inDomain:@"network"]);
    }
    request.HTTPMethod = method;
    for (id key in headers)
    {
        [request setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    
    NSData *mPostData = postData;
    ///
    if (mPostData != nil) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    if (urlEncoded && !postData) {
        NSMutableString *post = [[NSMutableString alloc] init];
        for (id key in urlEncoded)
        {
            NSString* value = [NetworkManager URLEncodedString_ch:[NSString stringWithFormat:@"%@", [urlEncoded objectForKey:key]]];
            [post appendFormat:@"%@=%@&", key, value];
        }
        mPostData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[mPostData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:mPostData];
    
    NSLog(@"Sending request %@", request);
//     if (true)
//     {
//         NSLog(@"\e[1;31 URL: %@ \e]\n", url);
//         NSLog(@"METHOD: %@\nHEADERS:\n", method);
//         for (id key in headers.allKeys) {
//             NSLog(@"key: %@, value: %@ \n", key, [headers objectForKey:key]);
//         }
//         NSLog(@"PARAMETERS:\n");
//         for (id key in uriParams.allKeys) {
//             NSLog(@"key: %@, value: %@ \n", key, [uriParams objectForKey:key]);
//         }
//         NSLog(@"WWW-URL-ENCODED:\n");
//         for (id key in urlEncoded.allKeys) {
//             NSLog(@"key: %@, value: %@ \n", key, [urlEncoded objectForKey:key]);
//         }
//     }
    
    
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {}];
    
    void (^completionHandlerWrapper)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) = completionHandler;
    
    completionHandlerWrapper =
        ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
            
//            NSLog(@"Received response %@, data %@, error %@", httpResponse, data, error);
            NSLog(@"Received response %@, error %@", httpResponse, error);
            
            if (error) {
                
                // Connection error
            }
            else if (httpResponse.statusCode != 200 && httpResponse.statusCode != 401) {
                
                // Network error code
            }
            
            if (data == nil)
            {
                completionHandler(data, response, error ?: [NetworkManager errorWithMessage:@"Server response is empty" inDomain:@"networking"]);
                return;
            }
            else if (httpResponse.statusCode == 401) // error response received
            {
                
//                NSError *error = nil;
//                id responseFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                
                NSString* errorCode = [[(NSHTTPURLResponse*)response allHeaderFields] objectForKey:@"X-ErrorId"];
                if ([errorCode isEqualToString:@"1"]) // bad AccesToken
                {
                    //[RemoteLogger append:@"Response: 401 Bad AccessToken" context:EMPTY_PAGE];
                    //NSLog(@"401 Bad AccessToken");
                    if ([[AccessTokenManager instance] currentToken].refresh_token != nil)
                    {
                        [[AccessTokenManager instance] removeAccessToken];
                        [[AccessTokenManager instance] getTokenWithDataTask:getDataTask withCompletionHandler:completionHandlerWrapper];
                    }
                    else
                    {
                        completionHandler(data, response, error);
                    }
                    
                }
                else
                {
                    // Call completion handler also if we failed for reasens, other then @"Response: 401 Bad AccessToken"
                    completionHandler(data, response, error);
                }
                // do not call to completionHandler from error code 401 - we will retry the call with a valid token
                return;
            }
            
//            if (false)
//            {
//                NSDictionary *responseFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                NSLog(@"RESPONSE DATA JSON:\n");
//                if([responseFromServer isKindOfClass:[NSDictionary class]])
//                {
//                    for (id key in responseFromServer) {
//                        NSLog(@"key: %@, value: %@ \n", key, [responseFromServer objectForKey:key]);
//                    }
//                }
//                if ([responseFromServer isKindOfClass:[NSArray class]])
//                {
//                    for (id val in responseFromServer)
//                    {
//                        NSLog(@"value: %@ \n", val);
//                    }
//                }
//            }
//            NSDictionary *responseFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            completionHandler(data, response, error);
    };
    // Create data task
    getDataTask = [session dataTaskWithRequest:request completionHandler:completionHandlerWrapper];
    
    
    if ([[headers allKeys] containsObject:@"Authorization"])
    {
        //[RemoteLogger log:[headers valueForKey:@"Authorization"] key:@"access_token_before_refresh" context:EMPTY_PAGE];
        if(! [[AccessTokenManager instance] getTokenWithDataTask:getDataTask withCompletionHandler:completionHandlerWrapper])
        {
            return nil;
        }
    }
    else
    {
        [getDataTask resume];
    }
    
    return getDataTask;
}

+ (NSString *) URLEncodedString_ch:(NSString*)str {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[str UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

-(NSMutableDictionary*)createPostDataWithDiscountInfo {
    
    NSMutableDictionary * visitData = [NSMutableDictionary new];
    
    return visitData;
}

-(NSDictionary*)createHeadersWithToken: (NSString*)token {
    
    NSString *bearer = [@"Bearer " stringByAppendingString: token ?: @""];
    NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    return @{ @"SiteName": @"kasamba_mobile",
              @"Authorization": bearer,
              @"versionName": version};
    
}

-(NSDictionary*)createHeadersWithCurrentToken {
    
    return [self createHeadersWithToken:[[AccessTokenManager instance] currentToken].access_token];
    
}

-(NSDictionary*)createBasicHeaders {
    
    NSString *version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    return @{ @"SiteName": @"kasamba_mobile",
              @"versionName": version};
}


-(void) postPerformSilentLoginForToken: (NSString *) tokenString  withSuccess:(void (^)(AccountResponse* guidObject))success andFailure:(void (^)(NSError *))failure
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if (tokenString.length == 0) {
        tokenString = @"";
    }
    NSDictionary *headers = [[NSDictionary alloc]
                             initWithObjects:
                             @[[@"Bearer " stringByAppendingString: tokenString], appVersion]
                             forKeys:@[@"Authorization", @"versionName"]];

    
//    [
     [self taskWithMethod:@"POST"
                  headers:headers
           urlEncodedDict:nil
        uriParametersDict:nil
                 postData:nil
                      url:silentLoginURL
        completionHandler:  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil)
                    {
                        failure(error);
                    }
                    else if (data != nil)
                    {
                        NSError *error = nil;
                        if (error)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                failure(error);
                            });
                        }
                        else
                        {
                            NSDictionary *responseFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                            AccountResponse* response = [[AccountResponse alloc] initWithJSONData:responseFromServer];
                            if (response != nil && response.Guid != nil)
                            {
                            }
                            else
                            {
                                    failure(nil);
                            }
                        }
                    }
        }];// resume];
}

-(NSString *) searchTermTrimmer: (NSString *) oldSearchString
{
    NSString* newSearch;
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"([""\\|=;~!@$%^*?{}<>[]]+)"];
    newSearch = [[oldSearchString componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                     (CFStringRef)newSearch,
                                                                     NULL,
                                                                     (CFStringRef)@":/&',#_",
                                                                     kCFStringEncodingUTF8));
}

-(NSDictionary*)cleanUpAuthDetails:(NSDictionary*)authDetails {
    NSMutableDictionary * cleanedDetails = [authDetails mutableCopy];
    
    [cleanedDetails removeObjectForKey:@"password"];
    
    return cleanedDetails;
}

- (void) postAuthenticationDetails:(NSDictionary *)authDetails toStringURL:(NSString *)url completionHandler:(void (^)(NSData *__nullable data, NSURLResponse *__nullable response, NSError *__nullable error))completionHandler
{

    NSDictionary *headers = [self createBasicHeaders];

//    [authDetails enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [RemoteLogger log:obj key:key context:INSTALLATION];
//    }];
//    [
    [self taskWithMethod:@"POST" headers:headers urlEncodedDict:authDetails uriParametersDict:nil postData:nil url:url completionHandler:completionHandler];// resume];

}




//- (void) sendAlexfLogsToIgatesServer:(NSDictionary *)authDetails completionHandler:(void (^)(NSData *__nullable data, NSURLResponse *__nullable response, NSError *__nullable error))completionHandler
//{
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:authDetails
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:nil];
//
////    [
//    [self taskWithMethod:@"POST" headers:nil urlEncodedDict:nil uriParametersDict:nil postData:jsonData url:@"https://kasamba.igates.co.il:4433/logger.ashx" completionHandler:completionHandler];
////    resume];
//}

- (void) postAuthenticationSignUpToServer:(NSDictionary *_Nonnull)authDetails withSuccess:( nullable void (^)(AccessToken *_Nullable, BOOL isExistingUser, BOOL isFbRegistration))success andFailure:(nullable void (^)(NSError *_Nullable))failure
{
    
     NSDictionary *headers = [self createBasicHeaders];

//     [authDetails enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [RemoteLogger log:obj key:key context:INSTALLATION];
//    }];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:authDetails
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:nil];
    
     [self taskWithMethod:@"POST" headers:headers urlEncodedDict:nil uriParametersDict:nil postData:jsonData url:registrationURL completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
              if (error != nil)
              {
                  dispatch_async(dispatch_get_main_queue(), ^(void) {
                      if (failure != nil)
                      {
                          failure(error);
                      }
                  });

              }
              else if (data != nil)
              {
                  NSDictionary *responseFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                  if ([responseFromServer valueForKey:@"MemberID"] != nil)
                  {
                      //[RemoteLogger flushContext:INSTALLATION];
                      // TODO: fix this
                      NSMutableDictionary* tempDict = [authDetails mutableCopy];
                      if ([tempDict objectForKey:@"tracking"])
                      {
                          [tempDict removeObjectForKey:@"tracking"];
                      }
                      
                      [self postAuthenticationDetailsToServer:tempDict forExistingUser:NO fromSignUpWithEmail:YES withSuccess:success andFailure:failure];
                  }
                  // Attempt to log in existing user with provieded pasword
                  else
                  {
                      if ([[responseFromServer valueForKey:@"error_description"] isEqualToString:@"Signup_UserNameAlreadyExists"])
                      {
                          //[RemoteLogger append:[NSString stringWithFormat:@"Fail Signup will attempt login as existing user %s %d", __PRETTY_FUNCTION__, __LINE__] context:INSTALLATION];
                          // TODO: fix this
                          NSMutableDictionary* tempDict = [authDetails mutableCopy];
                          if ([tempDict objectForKey:@"tracking"])
                          {
                              [tempDict removeObjectForKey:@"tracking"];
                          }
                          [self postAuthenticationDetailsToServer:tempDict forExistingUser:YES fromSignUpWithEmail:YES withSuccess:success andFailure:failure];
                      }
                      else
                      {
                          //[RemoteLogger flushContext:INSTALLATION];
                          if ([responseFromServer valueForKey:@"error_description"] != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                                        if (failure != nil)
                                        {
                                            failure([NetworkManager errorWithMessage:
                                                     [[LocalizationHelper new] stringForKey:[responseFromServer valueForKey:@"error_description"]] inDomain:@"Networking"]);
                                        }
                                    });
                                }
                      }
                  }
              }
            }];
}


- (void)postAuthenticationDetailsToServer:(NSDictionary *_Nonnull)authDetails forExistingUser:(BOOL)isExisting fromSignUpWithEmail:(BOOL)fromSignUpWithEmail withSuccess:( nullable void (^)(AccessToken *_Nullable, BOOL isExistingUser, BOOL isFbRegistration))success andFailure:(nullable void (^)(NSError *_Nullable))failure
{
    NSString* postURL;
    
    if(fromSignUpWithEmail)
        postURL = authentcationURL;
    else
        postURL = facebookAuthURL;
    
    [self postAuthenticationDetails:authDetails toStringURL:postURL completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
      if (error != nil)
      {
          dispatch_async(dispatch_get_main_queue(), ^(void) {
              if (failure != nil)
              {
                  failure(error);
              }
          });
      }
      else if (data != nil)
      {
          NSDictionary *tokenFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
          NSString* isFbString = [[tokenFromServer valueForKey:@"isFbRegistration"] lowercaseString];
          BOOL isFbRegistration = [isFbString boolValue];
//          if ([isFbString isEqualToString:@"true"])
//              isFbRegistration = YES;
//          else
//              isFbRegistration = NO;
          
          // TODO: get and handle isFbRegistration for new tracking events
          AccessToken *token = [[AccessToken alloc] initWithJSONData:tokenFromServer];
//           check
//          token.expires = [NSNumber numberWithLong:(long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]) + 30000];
          
//          token.expires_in = [NSString stringWithFormat:@"%d",30*1000];
          if (token.access_token != nil)
          {
              success(token, isExisting, isFbRegistration); // TODO: add isFbRegistration
          }
          else
          {
              NSMutableDictionary *details = [NSMutableDictionary dictionary];
              NSString *errorMessage = token.error_description;
              if (errorMessage == nil)
              {
                  errorMessage = @"Unknown error";
              }
              [details setValue:errorMessage forKey:NSLocalizedDescriptionKey];
              dispatch_async(dispatch_get_main_queue(), ^(void) {
                failure([NSError errorWithDomain:@"login" code:400 userInfo:details]);
              });
          }
      }
      else
      {
          dispatch_async(dispatch_get_main_queue(), ^(void) {
              if (failure != nil)
              {
                  failure(error);
              }
          });
      }
    }];
}

-(void) getAccountDataAfterLoginWithSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure
{
//    [self sendTimezoneToServer];
    [self
     postPerformSilentLoginForToken:[AccessTokenManager instance].currentToken.access_token
     withSuccess:^(AccountResponse * guidObject) {
         [[AccountManager instance] saveAccount: guidObject];
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         [defaults setBool:[guidObject.IsChatEligible boolValue] forKey:@"isUserChatEnabled"];
         success();
                  
     } andFailure:failure];
}

-(void) postForgotPassword:(nonnull NSString *)email withSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure{
    
    NSDictionary* urlArgs = [NSDictionary
                             dictionaryWithObjects:@[email]
                             forKeys:@[@"email"]];
//    [
     [self taskWithMethod:@"POST"
                  headers:nil
           urlEncodedDict:nil
        uriParametersDict:urlArgs
                 postData:nil
                      url:resetPasswordURL
        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (failure != nil)
                {
                    failure(error);
                }
            });

        }
        else if (data != nil)
        {
            NSError *error = nil;
            if (error)
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (failure != nil)
                    {
                        failure(error);
                    }
                });

            }
            else
            {
                NSDictionary *responseFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (responseFromServer)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        success();
                    });
                }
            }
        }
        }];// resume];
}


//-(void) updateLocalizationFile
//{
//    NSDictionary* uriParams = [NSDictionary
//                             dictionaryWithObjects:@[@"Mobile", @"1.0.0"]
//                             forKeys:@[@"appName", @"resourcesVersion"]];
//    
//     [self taskWithMethod:@"GET" headers:nil urlEncodedDict:nil uriParametersDict:uriParams postData:nil url:localizationURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error != nil)
//        {
//        }
//        else if (data != nil)
//        {
//            NSError *error = nil;
//            if (error)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^(void)
//                {
//                });
//            }
//            else
//            {
//                NSDictionary *responseFromServer = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
//                // this behavior should be fixed in server side
//                // current status is that server sends back a string "En-US"
//                // inorder to avoid case senetivity issues all local "language-retion" data should be
//                // propagated as lower/upper cases consistantly for all the key charachters e.g. "en-us"
//                // this will allow android an iOS clients to perform comparison correctly
//                
//                if ([[[responseFromServer valueForKey:@"LanguageTranslation"] valueForKey:language] valueForKey:@"Strings"] != nil)
//                {
//                    [PListHelper overwriteCurrentLocalization:[[[responseFromServer valueForKey:@"LanguageTranslation"] valueForKey:language] valueForKey:@"Strings"]];
//                }
//                else if ([[[responseFromServer valueForKey:@"LanguageTranslation"] valueForKey:@"En-US"] valueForKey:@"Strings"] != nil)
//                {
//                    [PListHelper overwriteCurrentLocalization:[[[responseFromServer valueForKey:@"LanguageTranslation"] valueForKey:@"En-US"] valueForKey:@"Strings"]];
//                }
//            }
//        }
//    }];
////     resume];
//}

-(void) getClientConfigurationWithSuccess:(nullable void (^)(ClientConfiguration*))success andFailure:(nullable void (^)(NSError *_Nullable))failure{
    
    NSDictionary *headers = [self createBasicHeaders];
    
    NSDictionary *uriParams = [[NSDictionary alloc]
                               initWithObjects:
                               @[@"1.2", @"1.0.0", @"iPhone"]
                               forKeys:@[@"appVersion", @"resourcesVersion", @"clientType"]];
    
//    [
     [self taskWithMethod:@"GET" headers:headers urlEncodedDict:nil uriParametersDict:uriParams postData:nil url:clientConfigurationURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (failure != nil)
                {
                    failure(error);
                }
            });
        }
        else if (data != nil)
        {
            NSError *error = nil;
            NSDictionary *clientConfigJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error)
            {
                NSLog(@"error parsing the json data from server with error description - %@", [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if (failure != nil)
                    {
                        failure(error);
                    }
                });
            }
            else
            {
                ClientConfiguration* config = [[ClientConfiguration alloc] initWithJSONData:[clientConfigJSON valueForKey:@"Configuration"]];
                if (config)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        success(config);
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        if (failure != nil)
                        {
                            failure(error);
                        }
                    });
                }
            }
        }
    }];// resume];
}

// TODO: transcripts request
- (void) sendTimezoneToServer
{
    if (![[AccountManager instance] isUserLogedIn]) {
        return;
    }
    
    NSNumber* minutesFromGMT = [NSNumber numberWithLong:[[NSTimeZone localTimeZone] secondsFromGMT] / 60];
    
    NSDictionary* timestamp =[[NSDictionary alloc]
                              initWithObjects:
                              @[minutesFromGMT]
                              forKeys:@[@"GmtOffset"]];
    
    NSDictionary *headers = [self createHeadersWithCurrentToken];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:timestamp
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [self taskWithMethod:@"POST" headers:headers urlEncodedDict:nil uriParametersDict:nil postData:jsonData url:saveTimezone completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //
    }];
}

@end
