//
//  CreateAccountViewController.h
//  consumer
//
//  Created by Ofer Davidyan on 1/14/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#ifndef CreateAccountViewController_h
#define CreateAccountViewController_h



#import <UIKit/UIKit.h>
#import "SidedMenuRootViewController.h"

@interface CreateAccountViewController : SidedMenuRootViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *networkAvailablePicture;

@end






#endif /* CreateAccountViewController_h */
