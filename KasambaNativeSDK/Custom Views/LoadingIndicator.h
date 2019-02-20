//
//  LoadingIndicator.h
//  consumer
//
//  Created by Alexander Forshtat on 2/10/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LoadingIndicator : UIView
-(void)startAnimating;
-(void)set;
-(void)setWithPosition:(CGPoint)position FromColor:(UIColor *)nFromColor ToColor:(UIColor *)nToColor LineWidth:(CGFloat) linewidth;
@end
