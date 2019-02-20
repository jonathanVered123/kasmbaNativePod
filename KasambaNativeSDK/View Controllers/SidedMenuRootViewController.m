//
//  SidedMenuRootViewController.m
//  consumer
//
//  Created by Ofer Davidyan on 10/01/2016.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SidedMenuRootViewController.h"
#import "AccountManager.h"
#import "NetworkManager.h"
#import "LoadingIndicator.h"

@interface SidedMenuRootViewController ()
@end

@implementation SidedMenuRootViewController
{
    LoadingIndicator* li;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.indicator.frame = self.view.frame;
    [self.indicator setBackgroundColor: [UIColor.whiteColor colorWithAlphaComponent:0.5]];
    
    
    
    if ([self presentBackArrow])
    {
//        [self.sidebarButton setImage:[UIImage imageNamed:@"arrow_left"]];
        [self.sidebarButton setTarget: self];
        [self.sidebarButton setAction: @selector(onBack:)];
        return;
    }
    
    [self addSearchViewController];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
    
    
}

// This returns current active indicator or creates a new one if there is none
// Also, as we use the returned view to cover the underlying UI (so user cannot click anything)
// It will be used for cover purpose only in login flow (there is a LoadingIndicator view inside a button)
- (UIView *)indicator {
    if (!_indicator) {
        _indicator = [[UIView alloc] init];
        CGRect frame = CGRectMake(self.view.frame.size.width/2 - 32.0f/2,
                                  self.view.frame.size.height/2 - 32.0f/2 - self.navigationController.navigationBar.frame.size.height/2,
                                  32.0f, 32.0f);
            [_indicator setBackgroundColor:[UIColor clearColor]];
            
            //CGFloat yCenterOrigin = (_indicator.frame.size.height- 32.0f) /2;
            //CGFloat xOrigin = ([_indicator frame].size.width - 32.0f) / 2; // 8 px margin
            CGRect frameForLoader = CGRectMake(frame.origin.x, frame.origin.y, 32.0f, 32.0f);
            li = [[LoadingIndicator alloc] initWithFrame:frameForLoader];
            [li set];
            [li startAnimating];
            [_indicator addSubview:li];
    }
    if(showBlackOverlay)
    {
        [_indicator setBackgroundColor:[UIColor clearColor]];
        [li removeFromSuperview];
    }
    return _indicator;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) addSearchViewController
{
}


- (void)onBack:(UIBarButtonItem *)sender
{
    if (self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        UIStoryboard *mainSroryboard;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            mainSroryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        } else {
            mainSroryboard = [UIStoryboard storyboardWithName:@"MainIpad" bundle:nil];
        }

        UIViewController *homeViewController = [mainSroryboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [[self navigationController] pushViewController:homeViewController animated:YES];
    }
}


-(BOOL) presentBackArrow
{
    return NO;
}
@end

