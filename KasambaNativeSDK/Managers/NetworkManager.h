//
//  NetworkManager.h
//  consumer
//
//  Created by Forsh on 18/01/2016.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessToken.h"
#import "LocalizationHelper.h"
#import "AccountManager.h"
#import "AccountResponse.h"
#include "ClientConfiguration.h"

typedef enum 
{
    CHANNEL_TYPE_CHAT = 1,
    CHANNEL_TYPE_VOICE = 5,
    DEFAULT = 0
} ChannelType;

//typedef enum
//{
//    QA_ENVIRONMENT = 1,
//    STAGING_ENVIRONMENT = 2,
//    PRODUCTION_ENVIRONMENT = 3
//} Environment;

enum ErrorCode
{
    ACCESS_TOKEN_EXPIRED = 1,
    REFRESH_TOKEN_EXPIRED
};

// array of string values of enum fields (as ObjC doesn't support enum string value)
extern NSString* _Nonnull const ChannelType_toString[];

//extern Environment environment;

@interface NetworkManager : NSObject


+ (NetworkManager *_Nonnull)instance;

-(BOOL) isValidEmailAdress: (NSString* _Nonnull) candidate;

- (nullable NSURLSessionDataTask *) taskWithMethod:(nullable NSString *)method
                                           headers:(nullable NSDictionary *)headers
                                    urlEncodedDict:(nullable NSDictionary *)urlEncoded
                                 uriParametersDict:(nullable NSDictionary *)uriParams
                                          postData:(nullable NSData *)postData
                                               url:(nullable NSString *)urlString
                                 completionHandler:(nullable void (^)(NSData *__nullable data, NSURLResponse *__nullable response, NSError *__nullable error))completionHandler;

- (void)postAuthenticationSignUpToServer:(NSDictionary *_Nonnull)authDetails
                             withSuccess:( nullable void (^)(AccessToken *_Nullable, BOOL isExistingUser, BOOL isFbRegistration))success
                              andFailure:(nullable void (^)(NSError *_Nullable))failure;

- (void)postAuthenticationDetailsToServer:(NSDictionary *_Nonnull)authDetails forExistingUser:(BOOL)isExisting
                      fromSignUpWithEmail:(BOOL)fromSignUpWithEmail
                              withSuccess:( nullable void (^)(AccessToken *_Nullable, BOOL isExistingUser, BOOL isFbRegistration))success
                               andFailure:(nullable void (^)(NSError *_Nullable))failure;

- (void)postPerformSilentLoginForToken:(nonnull NSString *)tokenString
                           withSuccess:(nullable void (^)(AccountResponse *_Nonnull))success
                            andFailure:(nullable void (^)(NSError *_Nullable))failure;


-(void) postForgotPassword:(nonnull NSString *)email withSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure;
//- (void)updateLocalizationFile;

-(void) getClientConfigurationWithSuccess:(nullable void (^)(ClientConfiguration*_Nullable))success andFailure:(nullable void (^)(NSError *_Nullable))failure;

-(void) getAccountDataAfterLoginWithSuccess:(nullable void (^)(void))success andFailure:(nullable void (^)(NSError *_Nullable))failure;


//- (void) sendAlexfLogsToIgatesServer:(NSDictionary * _Nonnull)authDetails completionHandler:(void (^ _Nullable)(NSData *__nullable data, NSURLResponse *__nullable response, NSError *__nullable error))completionHandler;

+ (NSString * _Nonnull) URLEncodedString_ch:(NSString*_Nonnull)str;

+(NSError* _Nonnull) errorWithMessage: (NSString* _Nullable) message inDomain: (NSString* _Nonnull) domain;
// TODO: transcripts request

- (void) sendTimezoneToServer;

@end

