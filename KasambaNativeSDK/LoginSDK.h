//
//  LoginSDK.h
//  Login SDK
//
//  Created by Jonathan Vered on 2/10/19.
//  Copyright © 2019 Kato Acqusition Sub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface LoginSDK : NSObject

+(LoginSDK *)sharedInstance;
-(void)openSigninScreen:(UIViewController*)presentationViewController;
-(void)initWithFaceBookAppId:(NSString*)facebookAppId;

@end

NS_ASSUME_NONNULL_END
