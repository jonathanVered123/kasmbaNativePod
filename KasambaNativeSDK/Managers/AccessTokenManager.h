//
//  NSURLSessionDataTask.h
//  consumer
//
//  Created by Alexander Forshtat on 26.10.2016.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessToken.h"

@interface AccessTokenManager : NSObject

+(AccessTokenManager* _Nonnull) instance;

@property AccessToken* _Nullable currentToken;

-(BOOL)getTokenWithDataTask:(NSURLSessionDataTask* _Nonnull) task withCompletionHandler:  (nonnull void (^)(NSData* _Nullable, NSURLResponse * _Nullable, NSError *_Nullable)) completionHandler;
-(void)refreshTokenWithCompletionHandler:(nonnull void (^)(BOOL succeeded))completionHandler;
-(void)refreshTokenIfExpired;
-(void)refreshToken;
-(void)performSuccess;
-(void)performFailure;
-(BOOL)isAccessTokenValid;
-(BOOL)isAccessTokenWillExpireSoon;
-(void)removeAccessToken;
-(void)wipeLocalData;

@end

