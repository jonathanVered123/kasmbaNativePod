//
//  LoginSDK.m
//  Login SDK
//
//  Created by Jonathan Vered on 2/10/19.
//  Copyright © 2019 Kato Acqusition Sub, Inc. All rights reserved.
//

#import "LoginSDK.h"
#import "Objects/AccessToken.h"
#import "SigninViewController.h"
#import <Foundation/Foundation.h>
#import <KasambaNativeSDK/KasambaNativeSDK-Swift.h>
#import <FBSDKCoreKit/FBSDKSettings.h>
#import <React/Base/RCTRootView.h>
#import <UIKit/UIKit.h>
#import <React/Base/RCTBridgeModule.h>

@interface LoginSDK ()<RCTBridgeModule>
@property (strong, nonatomic) NSString *facebookAppId ;

@end

@implementation LoginSDK

RCT_EXPORT_MODULE(LoginSDK);

RCT_EXPORT_METHOD(sharedInstance:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], [LoginSDK sharedInstance]]);
}

+ (LoginSDK *)sharedInstance
{
    static LoginSDK *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoginSDK alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}


RCT_EXPORT_METHOD(initWithFaceBookAppId:(NSString*)facebookAppId)
{
    if (facebookAppId != nil) {
        
        self.facebookAppId = facebookAppId;
        [FBSDKSettings setAppID:facebookAppId];
    }
}

//-(void)initWithFaceBookAppId:(NSString*)facebookAppId{
//    if (facebookAppId != nil) {
//
//        self.facebookAppId = facebookAppId;
//        [FBSDKSettings setAppID:facebookAppId];
//    }
//}

RCT_EXPORT_METHOD(openSigninScreen:(UIViewController*)presentationViewController)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle* bundle = [NSBundle bundleForClass:[SigninViewController self]];
        UIStoryboard *mainSroryboard = [UIStoryboard   storyboardWithName:@"MainStory" bundle:bundle];
        SigninViewController *signinScreenViewControllelr = [mainSroryboard instantiateInitialViewController];
        signinScreenViewControllelr.shouldShowFacebook = self.facebookAppId.length > 0;
        [presentationViewController showViewController:signinScreenViewControllelr sender:nil];
    });
}

    
//-(void)openSigninScreen:(UIViewController*)presentationViewController {
//
////    [[AccountManager instance] loadAccountData];
////    [[AccountManager instance] loadUserDetails];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSBundle* bundle = [NSBundle bundleForClass:[SigninViewController self]];
//        UIStoryboard *mainSroryboard = [UIStoryboard   storyboardWithName:@"MainStory" bundle:bundle];
//        SigninViewController *signinScreenViewControllelr = [mainSroryboard instantiateInitialViewController];
//        signinScreenViewControllelr.shouldShowFacebook = self.facebookAppId.length > 0;
//        [presentationViewController showViewController:signinScreenViewControllelr sender:nil];
//    });
//
//}


-(AccessToken *)getToken {
    AccessToken *accessToken;
    
    return accessToken;
    
}
@end
