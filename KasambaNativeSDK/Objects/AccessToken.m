//
//  AccessToken.m
//  consumer
//
//  Created by Alexander Forshtat on 1/31/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "AccessToken.h"

@implementation AccessToken


-(NSDate*)getExpirationDateOld
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EE, d LLLL yyyy HH:mm:ss ZZZ"];
    return [dateFormat dateFromString:self.expires_old];
}


-(long long)getExpirationDate
{
    long long expirationLong = 0;
    
    if (self.expires)
    {
        if ([self.expires longLongValue]/10000000000 > 1) // millis to sec
            expirationLong = [self.expires longLongValue] / 1000.0;
        else
            expirationLong = [self.expires longLongValue];
    }
    else
    {
        expirationLong = (long)(NSTimeInterval)([[self getExpirationDateOld] timeIntervalSince1970]);
    }

    return expirationLong;
}



@end
