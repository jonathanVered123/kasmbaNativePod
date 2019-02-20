//
//  NetworkObject.m
//  consumer
//
//  Created by Ofer Davidyan on 2/15/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "NetworkObject.h"
#import "NSDictionary+Safe.h"
#import "NSObject_KVCExtensions.h"


@implementation NetworkObject
-(id)initWithJSONData:(NSDictionary*)data{
    self = [super init];
    if(self){
        @try {
            [[data removeNullValues] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
                // There is an  ".expires" value which is not exactly valid JSON...
                if ([[key substringToIndex:1] isEqualToString:@"."])
                {
//                    key = [key substringFromIndex:1];
                    if ([[key substringFromIndex:1] isEqualToString:@"expires"])
                        key = @"expires_old";
                }
                if ([self canSetValueForKey:key]){
                    [self setValue:obj forKey:key];
                }
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"Failed parsing JSON object");
            return nil;
        }
        @finally {
        }
    }
    return self;
}

@end
