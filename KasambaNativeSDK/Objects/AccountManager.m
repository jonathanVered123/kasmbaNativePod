//
//  AccountManager.m
//  consumer
//
//  Created by Alexander Forshtat on 1/31/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "AccountManager.h"
#import "NetworkManager.h"
//#import "RemoteLogger.h"
#import "AccessTokenManager.h"
#import <KasambaNativeSDK/KasambaNativeSDK-Swift.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
static AccountManager* _instance;


@implementation AccountManager



//static AccessToken *accessToken;
static AccountResponse * accountData;
static UserDetails * userDetails;

BOOL loggedInWithFacebook = NO;
BOOL isNewUser = NO;
BOOL isFirstActivation = YES;
static NSString* REGISTER = @"registrationattempt";

+(AccountManager*) instance
{
    if (_instance == nil)
    {
        _instance = [[AccountManager alloc] init];
    }
    return _instance;
}

-(void) setFirstActivation: (BOOL) isAFirst
{
    isFirstActivation = isAFirst;
}

-(BOOL) isFirstActivation
{
    return isFirstActivation;
}

-(BOOL) hasBeenLoggedInThePast
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"hasBeenLoggedInThePast"];
}

-(void) setIsNewUser: (BOOL) isANewUser
{
    // This notification makes MenuViewController to update its lines
    // should be a separeate notification, in fact
    [[NSNotificationCenter defaultCenter]
     postNotificationName:UserUpdateMenuNotificationName
     object:nil];
    isNewUser = isANewUser;
}

- (BOOL)isNewUser
{
    return isNewUser;
}

- (BOOL)isUserLogedIn
{
    return [AccessTokenManager instance].currentToken != nil;
}


- (AccountResponse *)accountData
{
    return accountData;
}

- (UserDetails *)userDetails
{
    return userDetails;
}

- (void)logInUser:(nonnull NSString *)user withPassword:(nonnull NSString *)password withSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:user forKey:@"username_field"];
    NSDictionary *authenticationRequest = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                    user, username_field,
                                                                    password, password_field,
                                                                    @"password", grant_type_field,
                                                                    @"nativeApp", client_id_field,
                                                                    client_secret, client_secret_field,
                                                                    nil];
    [[NetworkManager instance] postAuthenticationDetailsToServer:authenticationRequest forExistingUser:YES fromSignUpWithEmail:YES withSuccess:^(AccessToken *token, BOOL isExistingUser, BOOL isFbRegistration) {
        
        [AccessTokenManager instance].currentToken = token;
        
        // Account details
        [[NetworkManager instance] getAccountDataAfterLoginWithSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^() {
                success();
            });
        } andFailure:failure];
        
        // User detatils
        
        
        
        [Services.userAccount getUserDetails:^(UserDetails * _Nullable userDetails, NSError * _Nullable error) {
            if (userDetails) {
                [[AccountManager instance] saveUserDetails:userDetails];
            }
        }];
        
    } andFailure:failure];
}

- (void)refreshLogInWithSuccess:(nullable void (^)(void))success andFailure: (nullable void (^)(NSError* _Nullable))failure
{
    NSDictionary *authenticationRequest = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                    [AccessTokenManager instance].currentToken.refresh_token, refresh_token_field,
                                                                    @"refresh_token", grant_type_field,
                                                                    @"nativeApp", client_id_field,
                                                                    client_secret, client_secret_field,
                                                                    nil];
    [[NetworkManager instance] postAuthenticationDetailsToServer:authenticationRequest forExistingUser:YES fromSignUpWithEmail:YES withSuccess:^(AccessToken *token, BOOL isExistingUser, BOOL isFbRegistration) {
        [AccessTokenManager instance].currentToken = token;
        [NSNotificationCenter defaultCenter];
        if (success)
        {
            success();
        }
    }
    andFailure:^(NSError *error) {
        if  (failure)
        {
            failure(error);
        }
    }];
}

- (void)attemptSilentLoginWithSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure;
{
    if ([AccessTokenManager instance].currentToken.access_token != nil)
    {
        [[NetworkManager instance] postPerformSilentLoginForToken:[AccessTokenManager instance].currentToken.access_token withSuccess:^(AccountResponse *accountData) {
            if ([AccessTokenManager instance].currentToken)
            {
                [self saveAccount:accountData];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:@"cookies"];
                if (success)
                {
                    success();
                }
                [[AccountManager instance] refreshUnread];
                
                // Fetch user detatils
                [Services.userAccount getUserDetails:^(UserDetails * _Nullable userDetails, NSError * _Nullable error) {
                    if (userDetails) {
                        [[AccountManager instance] saveUserDetails:userDetails];
                    }
                }];
            }
        } andFailure:^(NSError *error) {
            if (failure)
            {
                failure(nil);
            }
        }];
    }
}
-(void) saveAccount: (AccountResponse*) newAccountData
{
    // TODO: save account data to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    accountData = newAccountData;
    [defaults setBool:[accountData.IsChatEligible boolValue] forKey:@"isUserChatEnabled"];
    
    [defaults setObject:accountData.MemberID forKey:@"MemberID"];
    [defaults setObject:accountData.Guid  forKey:@"Guid"];
    
    [defaults setObject:accountData.FirstName forKey:@"FirstName"];
    [defaults setObject:accountData.LastName forKey:@"LastName"];
    [defaults setBool:loggedInWithFacebook forKey:@"loggedInWithFacebook"];
    [defaults setBool:YES forKey:@"hasBeenLoggedInThePast"];
    [defaults setBool:isNewUser forKey:@"isNewUser"];
    
    [defaults synchronize];
        
}

-(void)saveUserDetails:(UserDetails *)userAccountDetails {
    
    userDetails = userAccountDetails;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:userAccountDetails.didDoVoice forKey:@"DidDoVoice"];
    [defaults setBool:userAccountDetails.didDoChat forKey:@"DidDoChat"];
    [defaults setBool:userAccountDetails.isVip forKey:@"IsVip"];
    [defaults setBool:userAccountDetails.isFromFacebook forKey:@"IsFromFacebook"];
    
    [defaults setObject:[NSNumber numberWithInteger:userAccountDetails.userCurrencyCode] forKey:@"UserCurrencyCode"];
    [defaults setObject:[NSNumber numberWithInteger:userAccountDetails.userZodiacSign] forKey:@"UserZodiacSign"];
    [defaults setObject:[NSNumber numberWithInteger:userAccountDetails.userRegistrationSiteId] forKey:@"UserRegistrationSiteId"];
    [defaults setObject:[NSNumber numberWithInteger:userAccountDetails.tierId] forKey:@"tierId"];

    [defaults setObject:userAccountDetails.userEmail forKey:@"UserEmail"];
    
    [defaults synchronize];
    
}

- (void)logOutCurrentUser
{

    [Services.userAccount logoutWithToken:[[AccessTokenManager instance].currentToken access_token]
                                              completion:^(NSError * _Nullable error) {
                                              }];

    
    
    [AccessTokenManager instance].currentToken = nil;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"loggedInWithFacebook"];
    [userDefaults removeObjectForKey:@"isNewUser"];
    ////
    [userDefaults setBool:YES forKey:@"has_ever_signed_out"];

    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[[FBSDKLoginManager alloc] init] logOut];
    loggedInWithFacebook = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:UserLoggedOutNotificationName object:nil];
}


// TODO: read from storage
- (void)loadAccountData
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    accountData = [[AccountResponse alloc] init];
    accountData.MemberID = [userDefaults objectForKey:@"MemberID"];
    accountData.Guid = [userDefaults stringForKey:@"Guid"];
    
    accountData.FirstName  = [userDefaults stringForKey:@"FirstName"];
    accountData.LastName = [userDefaults stringForKey:@"LastName"];
    
    if (accountData.MemberID == nil)
    {
        accountData.MemberID = @0;
    }
    if (accountData.Guid == nil)
    {
        accountData.Guid = @"";
    }
    
    loggedInWithFacebook = [userDefaults boolForKey:@"loggedInWithFacebook"];
    isNewUser = [userDefaults boolForKey:@"isNewUser"];
    
    [self attemptSilentLoginWithSuccess:nil andFailure:nil];
}

- (void)loadUserDetails
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userDetails = [UserDetails new];
    
    userDetails.userEmail = [userDefaults stringForKey:@"UserEmail"];
    
    userDetails.didDoVoice = [[userDefaults objectForKey:@"DidDoVoice"] boolValue] ;
    userDetails.didDoChat = [[userDefaults objectForKey:@"DidDoChat"] boolValue] ;
    userDetails.isVip = [[userDefaults objectForKey:@"IsVip"] boolValue] ;
    userDetails.isFromFacebook = [[userDefaults objectForKey:@"IsFromFacebook"] boolValue] ;
    
    userDetails.userCurrencyCode = [[userDefaults objectForKey:@"UserCurrencyCode"] integerValue] ;
    userDetails.userZodiacSign = [[userDefaults objectForKey:@"UserZodiacSign"] integerValue] ;
    userDetails.userRegistrationSiteId = [[userDefaults objectForKey:@"UserRegistrationSiteId"] integerValue] ;
    userDetails.tierId = [[userDefaults objectForKey:@"tierId"] integerValue] ;

    
    if (userDetails.userZodiacSign < 1 || userDetails.userZodiacSign > 12)
    {
        userDetails.userZodiacSign = 0;
    }
    
    //[self attemptSilentLoginWithSuccess:nil andFailure:nil];
    
}

- (void)signUpUser:(nonnull NSString *)user withPassword:(nonnull NSString *)password withSuccess:(nullable void (^)(BOOL))success andFailure:(nullable void (^)(NSError *_Nullable))failure
{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* trackingDict = [defaults objectForKey:@"trackingDict"];
    [defaults setValue:user forKey:@"username_field"];


//    NSDictionary *authenticationRequest = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                                                    user, username_field,
//                                                                    password, password_field,
//                                                                    @"password", grant_type_field,
//                                                                    @"nativeApp", client_id_field,
//                                                                    client_secret, client_secret_field,
//                                           [[DiscountsManager instance] lastBanID].BanId, @"BanId",
//                                           [[DiscountsManager instance] lastBanID].IRID, @"IrId",
//                                                                    nil];
    
    // ******** If Organic install, trackingDict will be nil and not added to authenticationRequest ******** //
    NSDictionary *authenticationRequest = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           user, username_field,
                                           password, password_field,
                                           @"password", grant_type_field,
                                           @"nativeApp", client_id_field,
                                           client_secret, client_secret_field,
                                           0, @"BanId",
                                           0, @"IrId",
                                           6, @"SiteId",
                                           trackingDict, @"tracking",
                                           nil];

    [[NetworkManager instance] postAuthenticationSignUpToServer:authenticationRequest withSuccess:^(AccessToken *token, BOOL isExistingUser, BOOL isFbRegistration) {
        
        [AccessTokenManager instance].currentToken = token;
        
        // Account details
        [[NetworkManager instance] getAccountDataAfterLoginWithSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^() {
            [NSNotificationCenter defaultCenter];
//                [AccountManager saveAccessToken];
                success(isExistingUser); 
            });
        } andFailure:failure];
        
        // User detatils
        [Services.userAccount getUserDetails:^(UserDetails * _Nullable userDetails, NSError * _Nullable error) {
            if (userDetails) {
                [[AccountManager instance] saveUserDetails:userDetails];
            }
        }];
        
    } andFailure:failure];
}

- (void)requestForgotPasswordEmail:(nonnull NSString *)email withSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure
{
    [[NetworkManager instance] postForgotPassword:email withSuccess:success andFailure:failure];
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

- (void)performFacebookLoginFromViewController:(UIViewController *)controller withSuccess:(nullable void (^)(BOOL isFbRegistration))success andFailure:(nullable void (^)(NSError *_Nullable))failure
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login
        logInWithReadPermissions:@[ @"public_profile", @"email"]
              fromViewController:controller
                         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                           if (error)
                           {
                               if (failure != nil)
                               {
                                   failure(nil);
                               }
                           }
                           else if (result.isCancelled)
                           {
                               if (failure != nil)
                               {
                                   failure([AccountManager errorWithMessage:@"Facebook login cancelled" inDomain: @"facebook"]);
                               }
                           }
                           else
                           {
                               NSString *token = result.token.tokenString;
                               NSString *stringToEncode = [@"access_token:" stringByAppendingString:token];
                               NSLog(@"before base64: %@\n", stringToEncode);
                               NSData *plainData = [stringToEncode dataUsingEncoding:NSUTF8StringEncoding];
                               NSString *base64String = [plainData base64EncodedStringWithOptions:0];
                               NSLog(@"after base64: %@\n", base64String);
                               
                               NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                               NSDictionary* trackingDict = [defaults objectForKey:@"trackingDict"];
                               NSMutableDictionary *authenticationRequest = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                                    base64String, @"facebookToken",
                                                                    @"nativeApp", client_id_field,
                                                                    @"password", grant_type_field,
                                                                    @"6" , @"siteId",
                                                                      0, @"BanId",
                                                                      0, @"IrId",
                                                                    client_secret, client_secret_field,
                                                                                               nil];
                               
                               [authenticationRequest setValue:[trackingDict objectForKey:@"gclid"] forKey:@"gclid"];
                               [authenticationRequest setValue:[trackingDict objectForKey:@"device_params"] forKey:@"device_params"];
                               [authenticationRequest setValue:[trackingDict objectForKey:@"af_keywords"] forKey:@"af_keywords"];
                               [authenticationRequest setValue:[trackingDict objectForKey:@"install_time"] forKey:@"install_time"];
                               [authenticationRequest setValue:[trackingDict objectForKey:@"click_time"] forKey:@"click_time"];
                               [authenticationRequest setValue:[trackingDict objectForKey:@"click_url"] forKey:@"click_url"];
                               [authenticationRequest setValue:[trackingDict objectForKey:@"google_label"] forKey:@"google_label"];
                               [authenticationRequest setValue:[trackingDict objectForKey:@"loc_physical_ms"] forKey:@"loc_physical_ms"];
                               
                               [[NetworkManager instance] postAuthenticationDetailsToServer:authenticationRequest forExistingUser:YES fromSignUpWithEmail:NO withSuccess:
                                ^(AccessToken *newAccessToken, BOOL isExistingUser, BOOL isFbRegistration) {
                                    
                                    [AccessTokenManager instance].currentToken = newAccessToken;
                                    
                                    // Account details
                                    [[NetworkManager instance] getAccountDataAfterLoginWithSuccess:^{
                                        loggedInWithFacebook = YES;
                                        [NSNotificationCenter defaultCenter];
                                        //                                                        [AccountManager saveAccessToken];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            success(isFbRegistration);
                                        });
                                    } andFailure:failure];
                                    
                                    // User detatils
                                    [Services.userAccount getUserDetails:^(UserDetails * _Nullable userDetails, NSError * _Nullable error) {
                                        if (userDetails) {
                                            [[AccountManager instance] saveUserDetails:userDetails];
                                        }
                                    }];
                                    
                                } andFailure:^(NSError *error) {
                                    if (failure != nil)
                                        failure(error);
                                }];
                           }
                         }];
}


-(BOOL)isUserChatEnabled
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"isUserChatEnabled"];
}


@end
