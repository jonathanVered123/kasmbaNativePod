//
//  NSDictionary+Safe.h
//  consumer
//
//  Created by Ofer Davidyan on 2/15/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safe)
-(NSDictionary *)removeNullValues;

@end

