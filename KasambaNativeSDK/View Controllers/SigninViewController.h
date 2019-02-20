//
//  SigninViewController.h
//  consumer
//
//  Created by Ofer Davidyan on 1/17/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SidedMenuRootViewController.h"

@interface SigninViewController : SidedMenuRootViewController <UITextFieldDelegate>

@property (nonatomic,retain) NSLayoutManager *layoutManager;
@property (nonatomic,retain) NSTextContainer *textContainer;
@property (nonatomic,retain) NSTextStorage *textStorage;
@property (assign, nonatomic) bool shouldShowFacebook;
///
@property (weak, nonatomic) IBOutlet UIView *dskjdskljdsldjs;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *networkAvailablePicture;

//@property (weak, nonatomic) IBOutlet UIButton *notAmember;

//@property (weak, nonatomic) IBOutlet UIButton *forgotPassButton;
//@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
//@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *preselectedAdvisorViewHeightConstraint;
//@property (weak, nonatomic) IBOutlet UILabel *loginToKasambaLabel;
//@property (weak, nonatomic) IBOutlet UILabel *willNeverPostOnYourWallLabel;
//@property (weak, nonatomic) IBOutlet UIButton *signInWithFacebook;
//@property (weak, nonatomic) IBOutlet UIButton *signInButton;
//@property (weak, nonatomic) IBOutlet UIView *emailUnderline;
//@property (weak, nonatomic) IBOutlet UIView *passwordUnderline;
//@property (weak, nonatomic) IBOutlet UILabel *invalidEmailLabel;
//@property (weak, nonatomic) IBOutlet UILabel *invalidPasswordLabel;
//@property (weak, nonatomic) IBOutlet UIView *bigEmailLoginViews;
//@property (weak, nonatomic) IBOutlet UIView *emailView;
//@property (weak, nonatomic) IBOutlet UIView *bigfacebookLoginViews;
//@property (weak, nonatomic) IBOutlet UIView *passwordView;
//@property (weak, nonatomic) IBOutlet UIButton *signInWithEmailButton;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigEmailViewTopConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookToTop;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orTopConstraint;
//@property (weak, nonatomic) IBOutlet UILabel *orLabelSeparator;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orBottomConstraint;


@end

