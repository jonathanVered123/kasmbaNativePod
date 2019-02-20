//
//  NSString.h
//  consumer
//
//  Created by Alexander Forshtat on 2/18/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

enum PasswordErrorState
{
    WRONG_LENGTH,
    UNSUPPORTED_CHARACTERS,
    FORBIDDEN_WORDS,
    GOOD
};

@interface NSString (passwordValidation)
-(enum PasswordErrorState)isValidPassword;
@end
