//
//  LocalizationHelper.m
//  ios.sdk.demo
//
//  Created by Ofer Davidyan on 9/30/15.
//  Copyright (c) 2015 Kasamba Inc. All rights reserved.
//

#import "LocalizationHelper.h"

#define LOCALIZATION_VERSION_KEY @"LocalizationVersion"
#define LOCALIZATION_TIMESTAMP_KEY @"LocalizationTimestamp"

// One hour
#define NEXT_DOWNLOAD_TIMEOUT (NSTimeInterval)(60.0 * 60.0)

#define DEFAULT_STRINGS_FILENAME @"default-strings"
#define CURRENT_STRINGS_FILENAME @"localized-strings"
#define STRINGS_EXTENSION @"plist"

@interface LocalizationHelper ()

@property (nonatomic, strong) LocalizedStrings predefined;
@property (nonatomic, strong) LocalizedStrings current;

@end

@implementation LocalizationHelper

-(instancetype)init {
    
    [self initialize ];
    return self;
}
-(NSString *)stringForKey:(NSString *)key
{
    
    NSString *stringsFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Strings-US.plist"];
    NSDictionary *stringDictionary = [[NSDictionary alloc] initWithContentsOfFile:@"stringsFile"];
    if (stringDictionary != nil) {
        NSString *text = stringDictionary[@"key"];
        if (text) {
            return text;
        }
    }
    
    return key;
}

//-(BOOL)isLocalizationRequiresUpdate
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"localized-strings.plist"];
//    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
//    NSDate* lastUpdate =  (NSDate*) [dict objectForKey:LAST_UPDATE_TIMESTAMP_KEY];
//    if (lastUpdate != nil && lroundf([lastUpdate timeIntervalSinceNow]) < 3600)
//        return NO;
//    else return YES;
//}

//-(void) putValueToSettings:(id)value forKey:(NSString *)key
//{
//    // get paths from root direcory
//    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
//    // get documents path
//    NSString *documentsPath = [paths objectAtIndex:0];
//    // get the path to our Data/plist file
//    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"settings.plist"];
//
//    // read property list into memory as an NSData object
//    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
//    
//    // convert static property liost into dictionary object
//    NSDictionary *temp;
//    if (plistXML){
//        temp = (NSMutableDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
//        if (temp){
//            [temp setValue:value forKey:key];
//        }
//    }
//    // if there is no settings.plist or read fails - create & override file
//    if (!temp)
//    {
//        temp = [NSDictionary dictionaryWithObjects:
//                [NSArray arrayWithObjects: value, nil] forKeys:[NSArray arrayWithObjects: key, nil]];
//    }
//    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:temp format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
//    [plistData writeToFile:plistPath atomically:YES];
//}

-(void)downloadLocalizations
{
    
    
//    [Service.configuration getLocalizationsWithCompletion:^(NSDictionary<NSString *,LocalizedStrings> * _Nullable availableStrings, NSError * _Nullable error) {
//       
//        if (error == nil) {
//            
//            NSString * bestLanguage = [NSLocale preferredLanguages].firstObject.lowercaseString;
//            
//            LocalizedStrings localizedStrings = availableStrings[bestLanguage];
//            
//            if (localizedStrings == nil) {
//                localizedStrings = availableStrings[@"en-us"];
//            }
//            
//            [self updateCurrentLocalization:localizedStrings updateTimestamp:YES];
//        }
//    }];
}

-(void)initialize
{
    
    NSString *documentsPath = [self getDocumentsPath];
    
    NSString *defaultPlistPath = [[NSBundle mainBundle] pathForResource:DEFAULT_STRINGS_FILENAME ofType:STRINGS_EXTENSION];
    _predefined = [[NSDictionary alloc] initWithContentsOfFile:defaultPlistPath];
    
    NSString *localizedPlistPath = [documentsPath stringByAppendingPathComponent:[CURRENT_STRINGS_FILENAME stringByAppendingPathExtension:STRINGS_EXTENSION]];
    _current = [[NSMutableDictionary alloc] initWithContentsOfFile:localizedPlistPath];
    
    // Localization version must be a number constructed from current app version
    // For example v2.13.114 should be transformed to 213114 value.
    // As so we will be sure the strings will be overwritten if you just place current or next app version
    if (_current == nil || (_current[LOCALIZATION_VERSION_KEY].integerValue < _predefined[LOCALIZATION_VERSION_KEY].integerValue)) {
        
        [self updateCurrentLocalization:_predefined updateTimestamp:NO];
        
    }
    
    NSDate * lastDownloaded = [NSDate dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)(_current[LOCALIZATION_TIMESTAMP_KEY].integerValue / 1000.0f)];
    
    if (ABS(lastDownloaded.timeIntervalSinceNow) > NEXT_DOWNLOAD_TIMEOUT) {
        [self downloadLocalizations];
    }
}

-(void)updateCurrentLocalization:(LocalizedStrings)strings updateTimestamp:(BOOL)shouldUpdateTimestamp
{
    NSString *documentsPath = [self getDocumentsPath];
    NSString *localizedPlistPath = [documentsPath stringByAppendingPathComponent:[CURRENT_STRINGS_FILENAME stringByAppendingPathExtension:STRINGS_EXTENSION]];

    NSMutableDictionary * current = _current ? _current.mutableCopy : [NSMutableDictionary new];

    [strings enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        current[key] = value;
    }];
    
    if (shouldUpdateTimestamp) {
        current[LOCALIZATION_TIMESTAMP_KEY] = [NSString stringWithFormat:@"%ld", (long)([NSDate date].timeIntervalSinceReferenceDate * 1000)];
    }
    
    if (![current writeToFile:localizedPlistPath atomically:YES]) {
        NSLog(@"Failed to save current localization file: %@", localizedPlistPath);
    }
    
    _current = current;
}

-(NSString*)getDocumentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

@end


