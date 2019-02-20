//
//  DefaultHelperProtocol.h
//  Kasamba
//
//  Created by Jonathan Vered on 6/19/17.
//  Copyright © 2017 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppParametersProtocol <NSObject>

/**
 Time interval between configuraton fetch requests that are not required
 */
@property (nonatomic, readonly) NSTimeInterval configurationFetchInterval;

/**
 Advisors sort criteria selected by marketing reasons
 */
@property (nonatomic, assign) NSInteger marketingAdvisorSort;

/**
 Reset stored marketing advisor sort value
 */
-(void)resetMarketingAdvisorSort;

/**
 Number of times app was launched
 */
@property (nonatomic, readonly) NSInteger launchCounter;
@property (nonatomic, readonly) BOOL isFirstLaunch;
@property (readonly) BOOL isIpadVersion;

-(void)registerAppLaunch;
-(NSNumber *)siteId;
-(NSURL*)getImageUrlByAdvisorId:(NSInteger)advisorId;

@end
