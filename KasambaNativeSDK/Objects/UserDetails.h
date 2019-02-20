//
//  UserDetails.h
//  Kasamba
//
//  Created by Jonathan Vered on 9/26/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserDetails : NSObject

@property BOOL didDoVoice;
@property BOOL didDoChat;
@property BOOL isVip;
@property BOOL isFromFacebook;

@property NSInteger userRegistrationSiteId;
@property NSInteger userZodiacSign;
@property NSInteger userCurrencyCode;
@property NSInteger tierId;
@property NSInteger responseStatus;

@property NSString* userEmail;

@end
