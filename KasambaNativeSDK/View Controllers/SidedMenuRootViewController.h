//
//  SidedMenuRootViewController.h
//  consumer
//
//  Created by Ofer Davidyan on 10/01/2016.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#ifndef SidedMenuRootViewController_h
#define SidedMenuRootViewController_h

@import UIKit;
#import "SWRevealViewController.h"

#import "LoadingIndicator.h"

@interface SidedMenuRootViewController : UIViewController
{
    //HAGAI
    //htofix for loading indicator on signUP/signIN views until
    //full implementation in the next iteration
    //we have a fader layer
    BOOL showBlackOverlay;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

// To highlight the open view controller link - search this string in segues array
@property (strong, nonatomic) NSString* indexInMenuIdentifier;

@property  (strong, nonatomic) UIView* indicator;
-(BOOL) presentBackArrow;
@end



#endif /* SidedMenuRootViewController_h */
