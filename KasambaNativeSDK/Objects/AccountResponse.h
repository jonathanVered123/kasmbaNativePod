//
//  AccountResponse.h
//  consumer
//
//  Created by Alexander Forshtat on 2/1/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkObject.h"
@interface AccountResponse : NetworkObject

@property NSNumber* IsExpert;
@property NSNumber* MemberID;
@property NSString* FirstName;
@property NSString* LastName;
@property NSString* PrimaryEmail;
@property NSString* Guid;
@property NSNumber* IsChatEligible;
@end
