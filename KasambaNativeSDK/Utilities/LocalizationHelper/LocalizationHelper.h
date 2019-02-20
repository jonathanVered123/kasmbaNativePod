//
//  LocalizationHelper.h
//  ios.sdk.demo
//
//  Created by Ofer Davidyan on 9/30/15.
//  Copyright (c) 2015 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalizedStrings.h"

@interface LocalizationHelper : NSObject

/**
 Get localized string for key using current device language and available localizations
 */
-(nonnull NSString*) stringForKey:(nonnull NSString*)key;

/**
 Prepare localization data to use
 */
-(void) initialize;
/**
 Download localization files from server
 */
-(void) downloadLocalizations;

@end
