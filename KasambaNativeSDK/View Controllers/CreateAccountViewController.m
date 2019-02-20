//
//  CreateAccountViewController.m
//  consumer
//
//  Created by Ofer Davidyan on 1/14/16.
//  Copyright © 2016 Kasamba Inc. All rights reserved.
//

#import "sys/utsname.h"
#import <Foundation/Foundation.h>
#import "AccountManager.h"
#import "NetworkManager.h"
#import "CreateAccountViewController.h"
#import "SigninViewController.h"
#import "LocalizationHelper.h"
#import "SigninViewController.h"
#import "NSString+passwordValidation.h"
#import <AdSupport/ASIdentifierManager.h>
#import <KasambaNativeSDK/KasambaNativeSDK-Swift.h>

//#import "RemoteLogger.h"
static int facebookTopPadding = 65;
static int orMargin = 25;

@interface CreateAccountViewController ()

@property (strong, nonatomic) IBOutlet UIButton *alreadySigned;
@property (strong, nonatomic) IBOutlet UITextField *emailLabel;
@property (strong, nonatomic) IBOutlet UITextField *passwordLabel;
@property (strong, nonatomic) IBOutlet UILabel *willNeverPostYourWallLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *preselectedAdvisorViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIButton *signUpWithFacebookButton;
@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UILabel *registerToKasambaBtn;

@property (strong, nonatomic) IBOutlet UIView *emailUnderline;
@property (strong, nonatomic) IBOutlet UIView *passwordUnderline;
@property (strong, nonatomic) IBOutlet UILabel *invalidEmailLabel;
@property (strong, nonatomic) IBOutlet UILabel *invalidPasswordLabel;


@property (strong, nonatomic) IBOutlet UIView *bigEmailLoginViews;
@property (strong, nonatomic) IBOutlet UIView *emailView;
@property (strong, nonatomic) IBOutlet UIView *bigfacebookLoginViews;
@property (strong, nonatomic) IBOutlet UIView *passwordView;
@property (strong, nonatomic) IBOutlet UIButton *signInWithEmailButton;
//@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bigEmailViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *orLinesSeparatorView;
@property (weak, nonatomic) IBOutlet UILabel *disclaimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *disclaimerLabel2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *orBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookDisclaimerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *withEmailHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *orLabelSeparator;

@end

static NSString* REGISTER_FROM_CHAT = @"UserEnteredRegisterScreen";
static NSString* EMAIL_ENTERED = @"UserTypeEmailAddress";
static NSString* PASSWORD_ENTERED = @"UserTypePassword";
static NSString* USER_REGISTRATION = @"registered";
@implementation CreateAccountViewController
{
    BOOL expandedEmailView;
    NSRange linkRange;
    NSLayoutManager* layoutManager;
    NSTextContainer* textContainer;
    NSTextStorage* textStorage;
    NSLayoutManager* layoutManagerDisclaimer;
    NSTextContainer* textContainerDisclaimer;
    NSTextStorage* textStorageDisclaimer;
    NSString* deviceName;
    LoadingIndicator* li;
}

-(void)viewWillAppear:(BOOL)animated
{
    showBlackOverlay = YES;
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
    self.revealViewController.panGestureRecognizer.enabled=NO;
    [self setAdvisorInfo];

    [self.view layoutIfNeeded];
    
    NSString* labelText = [[LocalizationHelper new] stringForKey:@"RegistrationTitle"];
//    NSString* labelText = @"Sign up to Kasamba";

    if([labelText isEqualToString:@""] == NO)
    {
        [self.registerToKasambaBtn setText:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"LoginView_or"];
    if ([labelText isEqualToString:@""] == NO)
    {
        [self.orLabelSeparator setText:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"EmailPlaceholder"];
    if([labelText isEqualToString:@""] == NO)
    {
        [self.emailLabel setPlaceholder:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"PasswordPlaceholder"];
    if([labelText isEqualToString:@""] == NO)
    {
        [self.passwordLabel setPlaceholder:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"CreateAccountC2A"];
    if([labelText isEqualToString:@""] == NO)
    {
        [self.createAccountButton setTitle:labelText forState:UIControlStateNormal];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"FacebookRegistrationC2A"];
//    labelText = @"Connect With Facebook";
    if([labelText isEqualToString:@""] == NO)
    {
        [self.signUpWithFacebookButton setTitle:labelText forState:UIControlStateNormal];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"FacebookDisclaimer"];
    if([labelText isEqualToString:@""] == NO)
    {
        [self.willNeverPostYourWallLabel setText:labelText];
    }
    labelText = [[LocalizationHelper new] stringForKey:@"RegistrationExistingUserLabel"];
    if([labelText isEqualToString:@""] == NO)
    {
//        [self.alreadySigned setText:labelText];
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

- (void)viewDidAppear:(BOOL)animated
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat spacing = 15; // the amount of spacing to appear between image and title
    self.signUpWithFacebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.signUpWithFacebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:20.5]};
    //    [self.navigationItem setTintColor:[UIColor whiteColor]];
    NSString* labelText = [[LocalizationHelper new] stringForKey:@"RegistrationTitle"];
    if ([labelText isEqualToString:@""] == NO)
    {
        self.navigationItem.title = labelText;
    }
    else{
        self.navigationItem.title = @"Login";
    }


    // draw frame to signInWithEmail button
    [[self.signInWithEmailButton layer] setBorderWidth:1.0f];
    [[self.signInWithEmailButton layer] setBorderColor:[UIColor colorWithRed:191/255.0f green:191/255.0f blue:191/255.0f alpha:1.0f].CGColor];
    [[self.signInWithEmailButton layer] setCornerRadius:5.0f];
    self.signInWithEmailButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.signInWithEmailButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.signInWithEmailButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.signInWithEmailButton.imageEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
    self.signInWithEmailButton.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);

    [self setupLinkedLabel];
    [self setupLinkedLabelDisclaimer:self.disclaimerLabel];
    [self setupLinkedLabelDisclaimer:self.disclaimerLabel2];
    self.indexInMenuIdentifier = @"create_account";
    
    self.invalidPasswordLabel.text = [[LocalizationHelper new] stringForKey:@"Invalid_Password_Message"];
    self.invalidEmailLabel.text = [[LocalizationHelper new] stringForKey:@"invalidEmailLabel"];
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceName containsString: @"iPhone4" ] ||  [deviceName containsString: @"iPod4"] || [deviceName isEqualToString: @"x86_64"])
    {
        facebookTopPadding = 0;
        orMargin = 0;
        self.facebookToTop.constant = facebookTopPadding;
        self.orTopConstraint.constant = -10;
        self.orBottomConstraint.constant = orMargin;
    }
}



- (void)backButtonPressed
{
    [self.view endEditing:YES];
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
        [UIView transitionWithView:[UIApplication sharedApplication].keyWindow
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{ [UIApplication sharedApplication].keyWindow.rootViewController = homeViewController; }
                        completion:nil];
    }
}
- (IBAction)hideKeyboard:(id)sender {
    [_emailLabel resignFirstResponder];
    [_passwordLabel resignFirstResponder];
}

- (IBAction)createAccountButtonClick:(UIButton *)sender
{
    if (![self verifyInputs]) return;
    
    [self.view addSubview:self.indicator];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    CGFloat yCenterOrigin = (self.createAccountButton.frame.size.height- 21.0f) /2;
    CGFloat xOrigin = [self.createAccountButton.titleLabel frame].origin.x - 21.0f - 8.0f; // 8 px margin
    CGRect frameForLoader = CGRectMake(xOrigin, yCenterOrigin, 21.0f, 21.0f);
    li = [[LoadingIndicator alloc] initWithFrame:frameForLoader];
    [li set];
    [li startAnimating];
    [self.createAccountButton.imageView removeFromSuperview];
    [self.createAccountButton addSubview:li];
    
    NSString *email = [self emailLabel].text;
    NSString *pswrd = [self passwordLabel].text;
    self.createAccountButton.enabled = NO;
    
    [self.createAccountButton addSubview:li];
    [[AccountManager instance] signUpUser:email withPassword:pswrd withSuccess:^(BOOL isExistingUser){
        
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        [self.indicator removeFromSuperview];
        [li removeFromSuperview];
        li = nil;
        
        self.createAccountButton.enabled = YES;
        [self continueGuestFlow];
        NSLog(@"LOGIN SUCCESS!");
        [self requestSubscriptionToPushNotification];
        [[AccountManager instance] refreshUnread];
        
        if (!isExistingUser)
        {
            [self registerUserAgent];
            [self registerMetaDataApi];

        }
        
    } andFailure:^(NSError *error) {
        
        //[RemoteLogger sendDirectLog:@"EmailSignUpFailure"];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        self.createAccountButton.enabled = YES;
        [self.indicator removeFromSuperview];
        [li removeFromSuperview];
        li = nil;
        NSString* errorDescription = nil;
        if (error && error.userInfo)
        {
            errorDescription = [NSString stringWithFormat:@"%@", [error.userInfo valueForKey:NSLocalizedDescriptionKey]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[LocalizationHelper new] stringForKey:@"LoginFailMessage"]
                                                                           message:errorDescription
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:[[LocalizationHelper new] stringForKey:@"PushDailougeAllow"] style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action){
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }];
}

- (void)setupLinkedLabel
{
    NSString* stringPartOne = [[LocalizationHelper new] stringForKey:@"LoginView_AlreadyHaveAccounnt"];
    
//    NSString* stringPartTwo = @"Login";
    NSString* stringPartTwo = [[LocalizationHelper new] stringForKey:@"LoginView_Signin"];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[stringPartOne stringByAppendingString:@" "] stringByAppendingString: stringPartTwo] attributes:nil];
    
    NSRange linkNSRange = NSMakeRange(stringPartOne.length + 1, stringPartTwo.length);
    
    NSDictionary *linkAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:17.0] };

    [attributedString setAttributes:linkAttributes range:linkNSRange];

    // Assign attributedText to UILabel
    [_alreadySigned setAttributedTitle:attributedString forState:UIControlStateNormal];
    _alreadySigned.userInteractionEnabled = YES;

    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    layoutManager = [[NSLayoutManager alloc] init];
    textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    textStorage = [[NSTextStorage alloc] initWithAttributedString:attributedString];

    // Configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];

    // save this 3 as properties we will need them in other functions
    textContainer.lineFragmentPadding = 0.0;
    stringPartOne   = [[LocalizationHelper new] stringForKey:@"LoginView_signupWithEmail_key_1"];
    stringPartTwo   = [[LocalizationHelper new] stringForKey:@"LoginView_signupWithEmail_key_2"];
    NSString *stringPartThree = [[LocalizationHelper new] stringForKey:@"LoginView_signupWithEmail_key_3"];
    NSString *combined =[[stringPartTwo stringByAppendingString:@" "] stringByAppendingString:stringPartThree];
//    NSString *combined =[[[[ stringPartOne stringByAppendingString:@" "] stringByAppendingString:stringPartTwo] stringByAppendingString:@" "] stringByAppendingString:stringPartThree];
    NSDictionary *workaroundAttributes = @{
                                           NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                           NSUnderlineColorAttributeName:[UIColor clearColor]};
//    NSDictionary *buttonAttributes = @{
//                                       NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
//                                       NSUnderlineColorAttributeName:[UIColor whiteColor]};
    NSDictionary *buttonColorAttributes = @{
                                            NSForegroundColorAttributeName: [UIColor whiteColor]};
//    NSRange btnLinkRange = NSMakeRange(3,7); // underlined SignUp
    NSMutableAttributedString *attributedButtonString = [[NSMutableAttributedString alloc]
                                                         initWithString:combined attributes:nil];
    [attributedButtonString addAttributes:buttonColorAttributes range:NSMakeRange(0,attributedButtonString.length)];
    [attributedButtonString addAttributes:workaroundAttributes range:NSMakeRange(0,1)];
//    [attributedButtonString addAttributes:buttonAttributes range:btnLinkRange];
    [self.signInWithEmailButton setAttributedTitle:attributedButtonString forState:UIControlStateNormal];
    
}

-(void) setupLinkedLabelDisclaimer :(UILabel*) disclaimerLabel
{
    /******************* Set up Disclaimer title ********************/
    
    NSString* stringPartOne = [[LocalizationHelper new] stringForKey:@"TermsAndConditions1"];
    NSString* stringPartTwo = [[LocalizationHelper new] stringForKey:@"TermsAndConditions2"];
    NSDictionary *workaroundAttributes = @{
                                           NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                           NSUnderlineColorAttributeName:[UIColor clearColor]};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[stringPartOne stringByAppendingString:@" "] stringByAppendingString: stringPartTwo] attributes:nil];
    
    [attributedString addAttributes:workaroundAttributes range:NSMakeRange(0,1)];
    linkRange = NSMakeRange(stringPartOne.length + 1, stringPartTwo.length);
    
    //    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:113/255.0 green:25/255.0 blue:114/255.0 alpha:1.0]};
    
    
        NSDictionary *linkAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        [attributedString setAttributes:linkAttributes range:linkRange];
    //    [attributedString setAttributes:linkAttributes range:linkRange];
    
    // Assign attributedText to UILabel
    disclaimerLabel.attributedText = attributedString;
    disclaimerLabel.userInteractionEnabled = YES;
    [disclaimerLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabelTerms:)]];
    
    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    layoutManagerDisclaimer = [[NSLayoutManager alloc] init];
    textContainerDisclaimer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    textStorageDisclaimer = [[NSTextStorage alloc] initWithAttributedString:attributedString];
    
    // Configure layoutManager and textStorage
    [layoutManagerDisclaimer addTextContainer:textContainerDisclaimer];
    [textStorageDisclaimer addLayoutManager:layoutManagerDisclaimer];
    
    // save this 3 as properties we will need them in other functions
    textContainerDisclaimer.lineFragmentPadding = 0.0;
    textContainerDisclaimer.lineBreakMode = disclaimerLabel.lineBreakMode;
    textContainerDisclaimer.maximumNumberOfLines = disclaimerLabel.numberOfLines;
}

- (IBAction)handleTapOnLabelTerms:(UITapGestureRecognizer*)tapGesture
{
    CGPoint locationOfTouchInLabel = [tapGesture locationInView:tapGesture.view];
    NSInteger indexOfCharacter = [layoutManagerDisclaimer characterIndexForPoint:locationOfTouchInLabel
                                                            inTextContainer:textContainerDisclaimer
                                   fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (NSLocationInRange(indexOfCharacter, linkRange))
    {
        [UIView transitionWithView:self.disclaimerLabel duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            NSMutableAttributedString* attributedString = [self.disclaimerLabel.attributedText mutableCopy];
            [attributedString setAttributes:linkAttributes range:linkRange];
            //    [attributedString setAttributes:linkAttributes range:linkRange];
            
            // Assign attributedText to UILabel
            self.disclaimerLabel.attributedText = attributedString;
            
        } completion:^(BOOL finished)
        {
//            NSURL *url = [NSURL URLWithString:@"http://touch.kasamba.com/pages/help.aspx?ContentId=554&ShowTopHelpBtn=true"];
//            if (![[UIApplication sharedApplication] openURL:url])
//            {
//                NSLog(@"%@%@",@"Failed to open url:",[url description]);
//            }
            [self performSegueWithIdentifier:@"showTermsAndConditions" sender:self];

        }];
//        TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
//        [dataLayer push:@{@"event": @"ContactUsClick"}];
        // Open an URL, or handle the tap on the link in any other way
//        [self performSegueWithIdentifier:@"contactUsFrogotPassInitial" sender:self];
    }
}
- (IBAction)handleTapOnLabel:(id)sender
{
    // Open an URL, or handle the tap on the link in any other way
    [self performSegueWithIdentifier:@"signin" sender:self];
    
}

// Once the button is clicked, show the login dialog
- (IBAction)loginWithFacebookButtonClicked:(id)sender
{
    
    [self.view addSubview:self.indicator];
    CGFloat yCenterOrigin = (self.signUpWithFacebookButton.frame.size.height- 21.0f) /2;
    CGFloat xOrigin = [self.signUpWithFacebookButton.imageView frame].origin.x - 21.0f - 8.0f; // 8 px margin
    CGRect frameForLoader = CGRectMake(xOrigin, yCenterOrigin, 21.0f, 21.0f);
    li = [[LoadingIndicator alloc] initWithFrame:frameForLoader];
    [li set];
    [li startAnimating];
    [self.signUpWithFacebookButton addSubview:li];
    
    [[AccountManager instance] performFacebookLoginFromViewController:self withSuccess:^(BOOL isFbRegistration){
        
        [self goToHomepage];
        
        NSLog(@"LOGIN SUCCESS!");
        
        [self requestSubscriptionToPushNotification];
        
        [[AccountManager instance] refreshUnread];
        
        // TODO: Manage isFbRegistration events
        if(isFbRegistration)
        {
            [self registerUserAgent];
            [self registerMetaDataApi];
        }

    } andFailure:^(NSError * error) {
        

        [self.indicator removeFromSuperview];
        [li removeFromSuperview];
        li = nil;
        NSString * errorDescription = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[LocalizationHelper new] stringForKey:@"LoginFailMessage"]
                                                                       message:errorDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:[[LocalizationHelper new] stringForKey:@"PushDailougeAllow"] style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action){
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backgroundTouch:(id)sender {
    [self.view endEditing:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"signin"])
    {
        
        SigninViewController* destination = [segue destinationViewController];
    }
}

-(void)registerUserAgent {
    
    int memberId = [[AccountManager instance] accountData].MemberID.intValue;
    
    NSString *deviceType = @"ipad";
    NSInteger siteId =  6;
    deviceType = @"iphone";

    NSString *versionName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko) Version/9.1.1 Safari/601.6.17";
    NSString *deviceModel = [UIDevice currentDevice].model;
    NSString *osName = [UIDevice currentDevice].systemName;
    NSString *osVersion = [UIDevice currentDevice].systemVersion;
    NSString *deviceVendor = @"APPLE";
    
    [Services.userAccount registrationUserAgentDetailsWithMemberId:memberId version:versionName userAgent:userAgent deviceModel:deviceModel deviceType:deviceType deviceVendor:deviceVendor osVersion:osVersion osName:osName browserMajorVersion:@"" browserName:@"" siteId:siteId completion:^(NSError * _Nullable error) {
        if (error) {
        }
        
    }];
}

-(void)registerMetaDataApi {
    
    
    int siteId =  6;

    NSString* appsFlyerId = 0;
    NSString* appleAdvertisingId = [self identifierForAdvertising];

    [Services.userAccount registrationMetadataWithSiteId:siteId appsFlyerId:appsFlyerId advertisingId:appleAdvertisingId
                                              completion:^(NSError * _Nullable error) {
                                                  if (error) {
                                                  }
                                              }];
}

- (NSString *)identifierForAdvertising {
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSUUID *IDFA = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        
        return [IDFA UUIDString];
    }
    
    return @"";
}


- (void)setAdvisorInfo
{

}
- (BOOL)verifyInputs
{
    BOOL valid = true;
    enum PasswordErrorState passwordState = [self.passwordLabel.text isValidPassword];
    if (passwordState == WRONG_LENGTH) {
        self.invalidPasswordLabel.hidden = NO;
        [self.passwordUnderline setBackgroundColor:self.invalidPasswordLabel.textColor];
        [self.invalidPasswordLabel setText:[[LocalizationHelper new] stringForKey:@"Invalid_Password_Message"]];
        valid = false;
    }
    if (passwordState == UNSUPPORTED_CHARACTERS) {
        self.invalidPasswordLabel.hidden = NO;
        [self.passwordUnderline setBackgroundColor:self.invalidPasswordLabel.textColor];
        [self.invalidPasswordLabel setText:[[LocalizationHelper new] stringForKey:@"Invalid_Chars_Password_Message"]];
        valid = false;
    }
    if (passwordState == FORBIDDEN_WORDS) {
        self.invalidPasswordLabel.hidden = NO;
        [self.passwordUnderline setBackgroundColor:self.invalidPasswordLabel.textColor];
        [self.invalidPasswordLabel setText:[[LocalizationHelper new] stringForKey:@"Signup_InvalidPasswordBadWord"]];
        valid = false;
    }
    
    if (![[NetworkManager instance] isValidEmailAdress:self.emailLabel.text]){
        self.invalidEmailLabel.hidden = NO;
        [self.emailUnderline setBackgroundColor:self.invalidEmailLabel.textColor];
        valid = false;
    }
    return valid;
}

- (IBAction)editingChanged:(UITextField *)sender {
    [self removeInvalidHighlight:sender];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self removeInvalidHighlight:textField];
    //move the main view, so that the keyboard does not hide it.
//    if  (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:NO];
//    }
}

-(void) removeInvalidHighlight:(UITextField *)textField{
    if ([textField isEqual:self.emailLabel]) {
        self.invalidEmailLabel.hidden = YES;
        [self.emailUnderline setBackgroundColor:[UIColor grayColor]];
        
    }
    if ([textField isEqual:self.passwordLabel]){
        self.invalidPasswordLabel.hidden = YES;
        [self.passwordUnderline setBackgroundColor:[UIColor grayColor]];
        if(self.emailLabel.text.length > 0)
        {
            
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [[self navigationController].navigationBar setHidden:NO];
    [super viewWillDisappear:animated];
    self.revealViewController.panGestureRecognizer.enabled=YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

}

-(NSString*) pageTitle
{
    return @"RegistrationPage";
}

- (IBAction)signUpWithEmailClick:(id)sender
{
    expandedEmailView = YES;
    self.bigEmailLoginViews.alpha = 0;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"arrow_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    [UIView animateWithDuration:0.25 animations:^{
//        self.signInWithEmailButton.alpha = 0;
        self.signInWithEmailButton.layer.borderColor = [[UIColor clearColor] CGColor];
        self.bigEmailLoginViews.hidden = NO;
        self.facebookToTop.constant = 0;
        self.orTopConstraint.constant = 0;
        self.orBottomConstraint.constant = 0;
        self.disclaimerLabel.hidden = YES;
//        self.orLinesSeparatorView.hidden = YES;
        //        self.disclaimerLabel.hidden = YES;
        self.bigEmailLoginViews.alpha = 1;
//        self.bigfacebookLoginViews.alpha = 0;
//        self.bigEmailViewTopConstraint.constant = 0;
        if ([deviceName containsString: @"iPhone4" ] ||  [deviceName containsString: @"iPod4"] || [deviceName isEqualToString: @"x86_64"])
        {
            self.withEmailHeightConstraint.constant = 0;
            self.facebookDisclaimerConstraint.active = YES;
            self.signInWithEmailButton.hidden = YES;
        }
        [self.view layoutIfNeeded];
    }
                     completion:^(BOOL finished) {
//                         self.signInWithEmailButton.hidden = YES;
//                         self.bigfacebookLoginViews.hidden = YES;
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
        self.orTopConstraint.constant = orMargin;
        self.orBottomConstraint.constant = orMargin;
        self.bigfacebookLoginViews.alpha = 1;
        self.orLinesSeparatorView.hidden = NO;
        self.disclaimerLabel.hidden = NO;
        self.facebookToTop.constant = facebookTopPadding;
//        self.facebookDisclaimerConstraint.active = NO;
//        self.bigEmailViewTopConstraint.constant = 125;
        self.signInWithEmailButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.disclaimerLabel.hidden = NO;
        if ([deviceName containsString: @"iPhone4" ] ||  [deviceName containsString: @"iPod4"] || [deviceName isEqualToString: @"x86_64"])
        {
            self.facebookDisclaimerConstraint.active = NO;
            self.signInWithEmailButton.hidden = NO;
            self.withEmailHeightConstraint.constant = 50;
        }
        [self.view layoutIfNeeded];
    }
                     completion:^(BOOL finished) {
                         self.bigEmailLoginViews.hidden = YES;
                         self.signInWithEmailButton.hidden = NO;
                         [self.bigfacebookLoginViews setNeedsDisplay];
                     }];
}

-(void) continueGuestFlow
{
    
    UIStoryboard *mainSroryboard;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        mainSroryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    } else {
        mainSroryboard = [UIStoryboard storyboardWithName:@"MainIpad" bundle:nil];
    }
    UIViewController *homeViewController;
    homeViewController = [mainSroryboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    
    NSMutableArray *allViewControllers = [[NSMutableArray alloc] init];//]arrayWithArray: [self navigationController].viewControllers];
    for (NSObject* object in [self navigationController].viewControllers) {
        if (
            ![object isKindOfClass:[SigninViewController class]]
            && ![object isKindOfClass:[CreateAccountViewController class]])
        {
            [allViewControllers addObject: object];
        }
    }
    [allViewControllers addObject:homeViewController];
    [[self navigationController] setViewControllers:allViewControllers animated:YES];
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

-(void) requestSubscriptionToPushNotification
{
    
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
        [self createAccountButtonClick:nil];
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
    CGPoint windowPoint = [self.createAccountButton convertPoint:self.createAccountButton.bounds.origin toView:nil];
    if (movedUp && [[UIScreen mainScreen] bounds].size.height - windowPoint.y - self.createAccountButton.frame.size.height > 160)
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
