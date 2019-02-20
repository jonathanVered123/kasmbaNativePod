//
//  Connectivity.m
//  Kasamba
//
//  Created by Kobi Kagan on 7/16/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Connectivity.h"
#import "Reachability.h"
#import "LocalizationHelper.h"


@implementation Connectivity
{
    BOOL didLoseConnection;
    NSMutableDictionary<NSNumber* ,NSNumber* > *noInternetClickedAdvisorsDict;
}

-(BOOL)isConnectionAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if(networkStatus == NotReachable)
    {
        return false;
    }
    else
    {
        return true;
    }
    
}

@end

