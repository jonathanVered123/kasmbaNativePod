//
//  SigninViewController.m
//  consumer
//
//  Created by Ofer Davidyan on 1/17/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sys/utsname.h"
#import "AccountManager.h"
#import "CreateAccountViewController.h"
#import "NetworkManager.h"
#import "LocalizationHelper.h"
#import "SigninViewController.h"
#import "NSString+passwordValidation.h"

static int facebookTopPadding = 65;
static int orMargin = 25;


@interface SigninViewController ()

@property (weak, nonatomic) IBOutlet UIButton *notAmember;

@property (weak, nonatomic) IBOutlet UIButton *forgotPassButton;
@property (weak, nonatomic) IBOutlet UITextField *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *preselectedAdvisorViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *loginToKasambaLabel;
@property (weak, nonatomic) IBOutlet UILabel *willNeverPostOnYourWallLabel;
@property (weak, nonatomic) IBOutlet UIButton *signInWithFacebook;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIView *emailUnderline;
@property (weak, nonatomic) IBOutlet UIView *passwordUnderline;
@property (weak, nonatomic) IBOutlet UILabel *invalidEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *invalidPasswordLabel;
@property (weak, nonatomic) IBOutlet UIView *bigEmailLoginViews;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *bigfacebookLoginViews;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIButton *signInWithEmailButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigEmailViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *orLabelSeparator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orBottomConstraint;
@end

@implementation SigninViewController
{
    BOOL expandedEmailView;
    LoadingIndicator* li;
}
static NSString* USER_SIGNED_IN = @"UserSignedIn";

-(void)setOutlets {
    self.signInWithFacebook.hidden = !self.shouldShowFacebook;
//    self.forgotPassButton = [self.view viewWithTag:11];
    NSLog(@"dsldskds %@", self.forgotPassButton.titleLabel.text);
//    [self.forgotPassButton setTitle:@"dsds ds ds ds ds" forState:UIControlStateNormal];
}

- (IBAction)hideKeyboard:(id)sender {
    [_emailLabel resignFirstResponder];
    [_passwordLabel resignFirstResponder];
}

- (IBAction)touchBackground:(UIControl *)sender
{
    [self.view endEditing:true];
}

- (IBAction)signInButtonClick:(UIButton *)sender
{
    if ([self verifyInputs])
    {
        NSString *email = [self emailLabel].text;
        NSString *pswrd = [self passwordLabel].text;
        [self.view addSubview:self.indicator];
        
        CGFloat yCenterOrigin = (self.signInButton.frame.size.height- 21.0f) /2;
        CGFloat xOrigin = [self.signInButton.titleLabel frame].origin.x - 21.0f - 8.0f; // 8 px margin
        CGRect frameForLoader = CGRectMake(xOrigin, yCenterOrigin, 21.0f, 21.0f);
        li = [[LoadingIndicator alloc] initWithFrame:frameForLoader];
        [li set];
        [li startAnimating];
        [self.signInButton.imageView removeFromSuperview];
        [self.signInButton addSubview:li];
        
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        
        // Sign in attempt
        
        [[AccountManager instance] logInUser:email withPassword:pswrd withSuccess:^{
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
            
            //login success
            NSLog(@"LOGIN SUCCESS!");
            
            
            
        } andFailure:^(NSError *error) {
            
            [self.navigationItem.leftBarButtonItem setEnabled:YES];
            [self.indicator removeFromSuperview];
            [li removeFromSuperview];
            li = nil;
            NSString* errorMessage = nil;
            if (error && error.userInfo)
            {
                errorMessage = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
                if (errorMessage == nil)
                {
                    errorMessage = [[LocalizationHelper new] stringForKey:@"UnknownErrorMessage"];
                }
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[LocalizationHelper new] stringForKey:@"LoginFailMessage"]
                                                                               message:errorMessage
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:[[LocalizationHelper new] stringForKey:@"PushDailougeAllow"] style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction *action){
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");

//    showBlackOverlay = YES;
    if (!(self.navigationController.viewControllers.count > 1) && [[AccountManager instance] hasBeenLoggedInThePast])
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else
    {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];

//        if (!Utilities.featureState.isIpadVersion) {
//            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
//        }
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                               forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];

    self.revealViewController.panGestureRecognizer.enabled = NO;
    [self.view layoutIfNeeded];
    
    
    NSString *labelText = [[LocalizationHelper new] stringForKey:@"SignInTitle"];
//    if ([labelText isEqualToString:@""] == NO)
//    {
//        [self.loginToKasambaLabel setText:labelText];
//    }
    labelText = [[LocalizationHelper new] stringForKey:@"EmailPlaceholder"];
    if ([labelText isEqualToString:@""] == NO)
    {
        [self.emailLabel setPlaceholder:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"PasswordPlaceholder"];
    if ([labelText isEqualToString:@""] == NO)
    {
        [self.passwordLabel setPlaceholder:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"SignInC2A"];
    if ([labelText isEqualToString:@""] == NO)
    {
        [self.signInButton setTitle:labelText forState:UIControlStateNormal];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"FacebookSignInC2A"];
//    labelText = @"Connect with Facebook";
    if ([labelText isEqualToString:@""] == NO)
    {
        [self.signInWithFacebook setTitle:labelText forState:UIControlStateNormal];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"LoginView_or"];
    if ([labelText isEqualToString:@""] == NO)
    {
        [self.orLabelSeparator setText:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"FacebookDisclaimer"];
    if ([labelText isEqualToString:@""] == NO)
    {
        [self.willNeverPostOnYourWallLabel setText:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"SignInExistingUserLabel"];
    if ([labelText isEqualToString:@""] == NO)
    {

    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

@synthesize layoutManager;
@synthesize textContainer;
@synthesize textStorage;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //colorWithRed:137.0f/255.0f green:39.0f/255.0f blue:136.0f/255.0f alpha:1.0]];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    
    [self setOutlets];
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont fontWithName:@"Roboto-Medium" size:20.5]};
//    [self.navigationItem setTintColor:[UIColor whiteColor]];
    NSString *labelText = [[LocalizationHelper new] stringForKey:@"SignInTitle"];
    if ([labelText isEqualToString:@""] == NO)
    {
        self.navigationItem.title = labelText;
    }
    else{
        self.navigationItem.title = @"Login";
    }
    [self setupLinkedLabel];
    self.title = @"Login";
    CGFloat spacing = 15; // the amount of spacing to appear between image and title
    self.signInWithFacebook.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.signInWithFacebook.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
//    self.indexInMenuIdentifier = @"signin";
    [self.forgotPassButton setTitle:[[LocalizationHelper new] stringForKey:@"ForgotPasswordTitle"] forState:UIControlStateNormal];
    
    self.invalidPasswordLabel.text = [[LocalizationHelper new] stringForKey:@"Invalid_Password_Message"];
    self.invalidEmailLabel.text = [[LocalizationHelper new] stringForKey:@"invalidEmailLabel"];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceName containsString: @"iPhone4" ] ||  [deviceName containsString: @"iPod4"] || [deviceName isEqualToString: @"x86_64"])
    {
        facebookTopPadding = 0;
        orMargin = 0;
        self.facebookToTop.constant = facebookTopPadding;
        self.orTopConstraint.constant = orMargin;
        self.orBottomConstraint.constant = -20;
    }
    NSLog(@"viewDidLoadFinish");

}

- (void)viewDidAppear:(BOOL)animated
{
    
    NSLog(@"viewDidAppear");
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.passwordView.bounds
                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.passwordView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.passwordView.layer.mask = maskLayer;

    UIBezierPath *maskPathTop;
    maskPathTop = [UIBezierPath bezierPathWithRoundedRect:self.emailView.bounds
                                        byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                              cornerRadii:CGSizeMake(5.0, 5.0)];

    CAShapeLayer *maskLayerTop = [[CAShapeLayer alloc] init];
    maskLayerTop.frame = self.emailView.bounds;
    maskLayerTop.path = maskPathTop.CGPath;
    self.emailView.layer.mask = maskLayerTop;
}

- (void)backButtonPressed
{
    [self.view endEditing:true];
    if (expandedEmailView)
    {
        [self reverseAnimation];
        return;
    }
    if (self.navigationController.viewControllers.count > 1)
    {
        long controllersCount = self.navigationController.viewControllers.count;
        NSArray<UIViewController*> *vcs = @[self.navigationController.viewControllers[controllersCount-2]];
        [self.navigationController  setViewControllers:vcs animated: YES];
    }
    else
    {
        UIStoryboard *mainSroryboard;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            mainSroryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        } else {
            mainSroryboard = [UIStoryboard storyboardWithName:@"MainIpad" bundle:nil];
        }

        UIViewController *homeViewController = [mainSroryboard instantiateViewControllerWithIdentifier:@"onBoardingRootViewController"];
        [UIApplication sharedApplication].keyWindow.rootViewController = homeViewController;
    }
}

- (IBAction)onForgotPassClick:(id)sender
{
    [self performSegueWithIdentifier:@"forgotPass" sender:self];
}

- (void)setupLinkedLabel
{
    NSLog(@"setupLinkedLabel");

    NSString *stringPartOne = [[LocalizationHelper new] stringForKey:@"LoginView_No_Account_key_1"];
    NSString *stringPartTwo = [[LocalizationHelper new] stringForKey:@"LoginView_No_Account_key_2"];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[stringPartOne stringByAppendingString:@" "] stringByAppendingString:stringPartTwo] attributes:nil];

    NSRange linkRange = NSMakeRange(stringPartOne.length + 1, stringPartTwo.length);

    NSDictionary *linkAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:17.0] };
    @{ NSForegroundColorAttributeName : [UIColor colorWithRed:137.0/255.0 green:39.0/255.0 blue:137.0/255.0 alpha:1.0]};
    //                                      , NSFontAttributeName :[UIFont fontWithName:@"Roboto-Medium" size:12.0]};
    [attributedString setAttributes:linkAttributes range:linkRange];

    // Assign attributedText to UILabel
    [_notAmember setAttributedTitle:attributedString forState:UIControlStateNormal];
    _notAmember.userInteractionEnabled = YES;
    
    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    layoutManager = [[NSLayoutManager alloc] init];
    textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];

    // Configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];

    // save this 3 as properties we will need them in other functions
    textContainer.lineFragmentPadding = 0.0;
   
    stringPartOne   = [[LocalizationHelper new] stringForKey:@"LoginView_signinWithEmail_key_1"];
    stringPartTwo   = [[LocalizationHelper new] stringForKey:@"LoginView_signinWithEmail_key_2"];
    NSString *stringPartThree = [[LocalizationHelper new] stringForKey:@"LoginView_signinWithEmail_key_3"];
    NSString *combined =[[[[ stringPartOne stringByAppendingString:@" "] stringByAppendingString:stringPartTwo] stringByAppendingString:@" "] stringByAppendingString:stringPartThree];
    NSDictionary *workaroundAttributes = @{
                                       NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                       NSUnderlineColorAttributeName:[UIColor clearColor]};
    NSDictionary *buttonAttributes = @{
                                       NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                       NSUnderlineColorAttributeName:[UIColor whiteColor]};
    NSDictionary *buttonColorAttributes = @{
                                       NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSRange btnLinkRange = NSMakeRange(stringPartOne.length+1,stringPartTwo.length);
    NSMutableAttributedString *attributedButtonString = [[NSMutableAttributedString alloc]
                                                         initWithString:combined attributes:nil];
    [attributedButtonString addAttributes:buttonColorAttributes range:NSMakeRange(0,attributedButtonString.length)];
    [attributedButtonString addAttributes:workaroundAttributes range:NSMakeRange(0,1)];
    [attributedButtonString addAttributes:buttonAttributes range:btnLinkRange];
    [self.signInWithEmailButton setAttributedTitle:attributedButtonString forState:UIControlStateNormal];
}

- (IBAction)handleTapOnLabel:(id) sender
{
    // Open an URL, or handle the tap on the link in any other way
    [self performSegueWithIdentifier:@"register" sender:self];
}

// Once the button is clicked, show the login dialog
- (IBAction)loginWithFacebookButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    [self.view addSubview:self.indicator];

    CGFloat yCenterOrigin = (self.signInWithFacebook.frame.size.height- 21.0f) /2;
    CGFloat xOrigin = [self.signInWithFacebook.imageView frame].origin.x - 21.0f - 8.0f; // 8 px margin
    CGRect frameForLoader = CGRectMake(xOrigin, yCenterOrigin, 21.0f, 21.0f);
    li = [[LoadingIndicator alloc] initWithFrame:frameForLoader];
    [li set];
    [li startAnimating];
    [self.signInWithFacebook addSubview:li];
    
    
    [[AccountManager instance] performFacebookLoginFromViewController:self withSuccess:^(BOOL isFbRegistration){
    
    
        [self goToHomepage];
        
        NSLog(@"LOGIN SUCCESS!");
        
        
        // TODO: Manage isFbRegistration events

        
    } andFailure:^(NSError *error) {
        
//        [self.indicator removeFromSuperview];
        
        [li removeFromSuperview];
        li = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[LocalizationHelper new] stringForKey:@"LoginFailMessage"]
                                                                       message:[error.userInfo valueForKey:NSLocalizedDescriptionKey]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:[[LocalizationHelper new] stringForKey:@"PushDailougeAllow"] style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action){
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        NSString* errorDescription = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"register"])
    {
        CreateAccountViewController *destination = [segue destinationViewController];
    }
}

- (void)setAdvisorInfo
{
    
}

- (BOOL)verifyInputs
{
    return YES;
    
    // not need validation in login , only in create account
    
    
    
//    BOOL valid = true;
//    enum PasswordErrorState passwordState = [self.passwordLabel.text isValidPassword];
//    if (passwordState == WRONG_LENGTH) {
//        self.invalidPasswordLabel.hidden = NO;
//        [self.passwordUnderline setBackgroundColor:self.invalidPasswordLabel.textColor];
//        [self.invalidPasswordLabel setText:[LocalizationHelper stringForKey:@"Invalid_Password_Message"]];
//        valid = false;
//    }
//    if (passwordState == UNSUPPORTED_CHARACTERS) {
//        self.invalidPasswordLabel.hidden = NO;
//        [self.passwordUnderline setBackgroundColor:self.invalidPasswordLabel.textColor];
//        [self.invalidPasswordLabel setText:[LocalizationHelper stringForKey:@"Invalid_Chars_Password_Message"]];
//        valid = false;
//    }
//    if (passwordState == FORBIDDEN_WORDS) {
//        self.invalidPasswordLabel.hidden = NO;
//        [self.passwordUnderline setBackgroundColor:self.invalidPasswordLabel.textColor];
//        [self.invalidPasswordLabel setText:[LocalizationHelper stringForKey:@"Signup_InvalidPasswordBadWord"]];
//        valid = false;
//    }
//    if (![[NetworkManager instance] isValidEmailAdress:self.emailLabel.text])
//    {
//        self.invalidEmailLabel.hidden = NO;
//        valid = false;
//    }
//    return valid;
}

- (IBAction)editingChanged:(UITextField *)sender
{
    [self removeInvalidHighlight:sender];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self removeInvalidHighlight:textField];
}

- (void)removeInvalidHighlight:(UITextField *)textField
{
    if ([textField isEqual:self.emailLabel])
    {
        self.invalidEmailLabel.hidden = YES;
    }
    if ([textField isEqual:self.passwordLabel])
    {
        self.invalidPasswordLabel.hidden = YES;
        [self.passwordUnderline setBackgroundColor:[UIColor grayColor]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[self navigationController].navigationBar setHidden:NO];
    [super viewWillDisappear:animated];
    self.revealViewController.panGestureRecognizer.enabled = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (NSString *)pageTitle
{
    return @"SignInPage";
}

- (IBAction)signUpWithEmailClick:(id)sender
{
    expandedEmailView = YES;
    self.bigEmailLoginViews.alpha = 0;
//    if (!Utilities.featureState.isIpadVersion) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
//    }
    [UIView animateWithDuration:0.25 animations:^{
      self.signInWithEmailButton.alpha = 0;
      self.bigEmailLoginViews.hidden = NO;
      self.bigEmailLoginViews.alpha = 1;
      self.bigfacebookLoginViews.alpha = 0;
      self.bigEmailViewTopConstraint.constant = 0;
      [self.view layoutIfNeeded];
    }
        completion:^(BOOL finished) {
          self.signInWithEmailButton.hidden = YES;
          self.bigfacebookLoginViews.hidden = YES;
        }];
    
}

- (void)reverseAnimation
{
    expandedEmailView = NO;
    self.bigfacebookLoginViews.hidden = NO;
    if (!(self.navigationController.viewControllers.count > 1) && [[AccountManager instance] hasBeenLoggedInThePast])
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    [UIView animateWithDuration:0.25 animations:^{
      self.signInWithEmailButton.alpha = 1;
      self.bigEmailLoginViews.alpha = 0;
      self.bigfacebookLoginViews.alpha = 1;
      self.bigEmailViewTopConstraint.constant = 125;
      [self.view layoutIfNeeded];
    }
        completion:^(BOOL finished) {
          self.bigEmailLoginViews.hidden = YES;
          self.signInWithEmailButton.hidden = NO;
        }];
}

-(void) goToHomepage
{
    
    UIStoryboard *mainSroryboard;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        mainSroryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    } else {
        mainSroryboard = [UIStoryboard storyboardWithName:@"MainIpad" bundle:nil];
    }
    UIViewController *homeViewController;
    if ([[AccountManager instance] isNewUser])
    {
        homeViewController = [mainSroryboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    }
    else
    {
        homeViewController = [mainSroryboard instantiateViewControllerWithIdentifier:@"MyAdvisorsPage"];
    }
    [[self navigationController] pushViewController:homeViewController animated:YES];
}


-(void) continueFromGuestFlow
{
    UIStoryboard *mainSroryboard;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        mainSroryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    } else {
        mainSroryboard = [UIStoryboard storyboardWithName:@"MainIpad" bundle:nil];
    }
    UIViewController *homeViewController;
    homeViewController = [mainSroryboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    
    NSMutableArray *allViewControllers = [[NSMutableArray alloc] init];
    
    for (NSObject *object in [self navigationController].viewControllers)
    {
        if (
            ![object isKindOfClass:[SigninViewController class]] && ![object isKindOfClass:[CreateAccountViewController class]])
        {
            [allViewControllers addObject:object];
        }
    }
    [allViewControllers addObject:homeViewController];
    [[self navigationController] setViewControllers:allViewControllers animated:YES];
}

-(void) requestSubscriptionToPushNotification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pushOkPressed = [defaults objectForKey:@"pushOkPressed"];

    if ( [pushOkPressed isEqualToString:@"YES"] )
    {
        // Registering Push Notifications
        
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    
    if (![defaults objectForKey:@"secondPushResultTracking"])
    {

        [defaults setBool:YES forKey:@"secondPushResultTracking"];
        [defaults synchronize];
    }
    
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [self.view viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [self signInButtonClick:nil];
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}


#define kOFFSET_FOR_KEYBOARD 160.0

-(void)keyboardWillShow {
    
    NSLog(@"%f", self.view.frame.origin.y);
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    //    else if (self.view.frame.origin.y < 0)
    //    {
    //        [self setViewMovedUp:NO];
    //    }
}

-(void)keyboardWillHide {
    //    if (self.view.frame.origin.y >= 0)
    //    {
    //        [self setViewMovedUp:YES];
    //    }
    //    else
    if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    CGPoint windowPoint = [self.signInButton convertPoint:self.signInButton.bounds.origin toView:nil];
    if (movedUp && [[UIScreen mainScreen] bounds].size.height - windowPoint.y - self.signInButton.frame.size.height > 160)
    {
        return;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
        [[self navigationController].navigationBar setHidden:YES];
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y = 0;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        [[self navigationController].navigationBar setHidden:NO];
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
