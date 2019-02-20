//
//  NSString.m
//  consumer
//
//  Created by Alexander Forshtat on 2/18/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "NSString+passwordValidation.h"


@implementation NSString (passwordValidation)
-(enum PasswordErrorState) isValidPassword
{
    NSArray* foriddenWords = @[@"123123",@"123456",@"234567",@"345678",@"456789", @"567890", @"kasamba",@"password", @"qwerty", @"whatever"];
    NSString *forbiddenSymbolsRegex = @"^[^\\<\\>\\&]*";
    NSString *lengthRegex = @"^.{6,32}$";
    NSPredicate *forbiddenSymbolsTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", forbiddenSymbolsRegex];
    BOOL forbiddenSymbols = [forbiddenSymbolsTest evaluateWithObject:self];
    NSPredicate *lengthTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", lengthRegex];
    BOOL length = [lengthTest evaluateWithObject:self];
    BOOL forbiddenWordFound = NO;
    
    for (NSString* foriddenWord in foriddenWords)
    {
        if ([[self lowercaseString] containsString:foriddenWord])
        {
            forbiddenWordFound = YES;
            break;
        }
    }
    
    if (!length)
    {
        return WRONG_LENGTH;
    }
    if (!forbiddenSymbols) {
        return UNSUPPORTED_CHARACTERS;
    }
    if (forbiddenWordFound) {
        return FORBIDDEN_WORDS;
    }
    return GOOD;
}
@end
