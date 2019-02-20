//
//  LoadingIndicator.m
//  consumer
//
//  Created by Alexander Forshtat on 2/10/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "LoadingIndicator.h"
#import "WCGraintCircleLayer.h"
@interface LoadingIndicator ()

@property (strong) CALayer* maskLayer;

@end

@implementation LoadingIndicator
{
    UIColor* fromColor, *toColor;
    CGFloat width;
}

-(void)set
{
    toColor = [UIColor colorWithRed:137.0f/255 green:39.0f/255 blue:136.0f/255 alpha:1.0f];
    fromColor = [UIColor whiteColor];
    width = 1.0f;
}

-(void)setWithPosition:(CGPoint)position FromColor:(UIColor *)nFromColor ToColor:(UIColor *)nToColor LineWidth:(CGFloat) linewidth{
    fromColor = nFromColor;
    toColor = nToColor;
    width = linewidth;
}

-(void) startAnimating
{
    
    //CAShapeLayer *newPieLayer = [CAShapeLayer layer];
    
    //[newPieLayer setFillColor:[UIColor whiteColor].CGColor];
    CGPoint center = CGPointMake(self.bounds.size.width/ 2, self.bounds.size.height/2);
    //[[self layer] addSublayer:newPieLayer];
    self.maskLayer = [CALayer layer];
    [self.maskLayer setBounds:self.bounds];
    [self.maskLayer setPosition:center];
    
    WCGraintCircleLayer *segment = [[WCGraintCircleLayer alloc]
                                    initGraintCircleWithBounds:self.bounds
                                    Position:center
                                    FromColor:fromColor
                                    ToColor:toColor
                                    LineWidth:width];
    
    
    
    [self.maskLayer addSublayer:segment];
    
    //newPieLayer.mask = self.maskLayer;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.fromValue = [NSNumber numberWithFloat:0];
    anim.toValue = [NSNumber numberWithFloat:M_PI * 2];
    anim.duration = 1;
    anim.repeatCount = INFINITY;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    anim.removedOnCompletion = false;
    [_maskLayer addAnimation:anim forKey:@"kMaskRotationAnimationKey"];
    
    //[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
    [self.layer addSublayer:self.maskLayer];
}

@end
