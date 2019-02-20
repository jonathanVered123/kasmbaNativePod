//
//  AccountManager.h
//  consumer
//
//  Created by Alexander Forshtat on 1/31/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "AccessToken.h"
#import "AccountResponse.h"
#import "UserDetails.h"

static NSString* _Nonnull const DeepLinkActivated= @"DeepLinkActivated";
static NSString* _Nonnull const UserUpdateMenuNotificationName = @"UserUpdateMenu";
static NSString* _Nonnull const UserHasClientNotificationName = @"UserHasClient";
static NSString* _Nonnull const UserLoggedOutNotificationName = @"UserLoggedOut";

static NSString  * _Nonnull const REGISTER_SUCCESS = @"registersuccessful";

static NSString  * _Nonnull const  username_field = @"username";
static NSString  * _Nonnull const  refresh_token_field = @"refresh_token";
static NSString  * _Nonnull const  password_field = @"password";
static NSString  * _Nonnull const  grant_type_field = @"grant_type";
static NSString  * _Nonnull const  client_id_field = @"client_id";
static NSString  * _Nonnull const  client_secret_field = @"client_secret";
static NSString  * _Nonnull const  client_secret = @"ifqAerspCJjSN8dG8Er9nBMms56lvozdbVE3P8QwR4E";

@interface AccountManager : NSObject

//+(AccessToken* _Nullable) currentToken;
//+(void) setAccessToken: (AccessToken* _Nullable) newAccessToken;
+(AccountManager* _Nonnull) instance;

-(BOOL) isUserLogedIn;
-(BOOL) isNewUser;
-(void) setIsNewUser: (BOOL) isANewUser;

- (void)loadAccountData;
- (void) saveAccount: (AccountResponse* _Nonnull) account;
- (AccountResponse* _Nonnull)accountData;

- (void)loadUserDetails;
- (void) saveUserDetails: (UserDetails* _Nonnull) userDetails;
- (UserDetails* _Nonnull)userDetails;

-(BOOL) isFirstActivation;
-(void) setFirstActivation: (BOOL) isAFirst;

-(void) logOutCurrentUser;

-(BOOL) hasBeenLoggedInThePast;

-(void) logInUser: (nonnull NSString*) user withPassword: (nonnull NSString*) password withSuccess:(nullable void (^)(void))success andFailure: (nullable void (^)(NSError* _Nullable))failure;


- (void)signUpUser:(nonnull NSString *)user withPassword:(nonnull NSString *)password withSuccess:(nullable void (^)(BOOL))success andFailure:(nullable void (^)(NSError *_Nullable))failure;

-(void) requestForgotPasswordEmail:(nonnull NSString *)email withSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure;

-(void) performFacebookLoginFromViewController:(UIViewController* _Nonnull) controller withSuccess:(nullable void (^)(BOOL isFbRegistration))success andFailure:(nullable void (^)(NSError *_Nullable))failure;

- (void)attemptSilentLoginWithSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure;

-(NSInteger) unreadMessages;
-(void) refreshUnread;
-(void) resetUnread;
-(BOOL) isUserChatEnabled;
- (void)refreshLogInWithSuccess:(nullable void (^)(void))success andFailure: (nullable void (^)(NSError* _Nullable))failure;
@end
