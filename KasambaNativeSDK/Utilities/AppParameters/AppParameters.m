//
//  AppParameters.m
//  Kasamba
//
//  Created by Jonathan Vered on 6/19/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

#import "AppParameters.h"
#import "AccountManager.h"

#define IMAGE_URL_PATH @"https://expertsimages.kassrv.com/experts-pictures/big/pic%ld.jpg"

@implementation AppParameters

-(NSTimeInterval)configurationFetchInterval {
    return 60.0 * 60.0 * 4.0; // Every 4 hours, NSTimeInterval is in seconds
}


-(void)resetMarketingAdvisorSort {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MarketingAdvisorSort"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(NSInteger)launchCounter {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"AppLaunchCounter"];
}

-(BOOL)isFirstLaunch {
    return self.launchCounter > 1;
}

-(void)registerAppLaunch {
    
    NSInteger newNumber = self.launchCounter + 1;
    
    [[NSUserDefaults standardUserDefaults] setInteger:newNumber forKey:@"AppLaunchCounter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSNumber *)siteId {
    NSNumber *siteId;
    siteId = @10;

    return siteId;
}

@end
