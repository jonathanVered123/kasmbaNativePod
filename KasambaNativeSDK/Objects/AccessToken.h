//
//  AccessToken.h
//  consumer
//
//  Created by Alexander Forshtat on 1/31/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkObject.h"
@interface AccessToken : NetworkObject

//-(id) initFromPreferences;
//-(void) saveToUserDefaults;
//-(void) removeAccessToken;
//+(void) eraseAccountFromUserDefaults;

-(NSDate*)getExpirationDateOld;
-(long long)getExpirationDate;

@property NSString* access_token;
@property NSNumber* expires;
@property NSString* expires_old;
@property NSString* token_type;
@property NSString* expires_in;
@property NSString* refresh_token;
@property NSString* client_id;
@property NSString* issued;
@property NSString* error_description;

@end
