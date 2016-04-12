//
//  FlyingLoginVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/10/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingLoginVC.h"
#import <RongIMKit/RongIMKit.h>
#import "AFHttpTool.h"
#import "MBProgressHUD.h"
#import "FlyingUnderlineTextField.h"
#import "NSString+FlyingExtention.h"
#import "FlyingHttpTool.h"
#import "AFHttpTool.h"
#import "UITextFiled+Shake.m"
#import "FlyingActiveViewController.h"
#import "FlyingDataManager.h"
#import "iFlyingAppDelegate.h"
#import "UIAlertController+Window.h"

@interface FlyingLoginVC ()<UITextFieldDelegate>

@property (retain, nonatomic)  FlyingAnimatedImagesView* animatedImagesView;

@property (weak, nonatomic)    UITextField* emailTextField;

@property (weak, nonatomic)    UITextField* pwdTextField;

@property (nonatomic, strong) UIView* headBackground;
@property (nonatomic, strong) UIImageView* rongLogo;
@property (nonatomic, strong) UIView* inputBackground;
@property (nonatomic, strong) UIView* statusBarView;
@property (nonatomic, strong) UILabel* errorMsgLb;
@property (nonatomic, strong) UITextField *passwordTextField;

@property (nonatomic, strong) UILabel *appKeyLabel;
@property (nonatomic, strong) UIButton *changeKeyButton;
@property (nonatomic) int loginFailureTimes;

@end


@implementation FlyingLoginVC
#define UserTextFieldTag 1000
#define PassWordFieldTag 1001
@synthesize animatedImagesView = _animatedImagesView;
@synthesize inputBackground = _inputBackground;
MBProgressHUD* hud ;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    //添加动态图
    self.animatedImagesView = [[FlyingAnimatedImagesView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.animatedImagesView];
    self.animatedImagesView.delegate = self;
    
    //添加头部内容
    _headBackground = [[UIView alloc] initWithFrame:CGRectMake(0, -100, self.view.bounds.size.width, 50)];
    _headBackground.userInteractionEnabled = YES;
    _headBackground.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_headBackground];
    
    UIButton* registerHeadButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    [registerHeadButton setTitle:@"返回" forState:UIControlStateNormal];
    [registerHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5] forState:UIControlStateNormal];
    registerHeadButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [registerHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerHeadButton addTarget:self action:@selector(cancelLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [_headBackground addSubview:registerHeadButton];
    
    //添加图标
    UIImage* rongLogoSmallImage = [UIImage imageNamed:@"Icon"];
    UIImageView* rongLogoSmallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 30, 5, 60, 60)];
    [rongLogoSmallImageView setImage:rongLogoSmallImage];
    
    [rongLogoSmallImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    rongLogoSmallImageView.contentMode = UIViewContentModeScaleAspectFit;
    rongLogoSmallImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    rongLogoSmallImageView.clipsToBounds = YES;
    [_headBackground addSubview:rongLogoSmallImageView];
    
    //顶部按钮
    UIButton* forgetPswHeadButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 0, 70, 50)];
    [forgetPswHeadButton setTitle:@"新用户" forState:UIControlStateNormal];
    [forgetPswHeadButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5] forState:UIControlStateNormal];
    [forgetPswHeadButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswHeadButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [_headBackground addSubview:forgetPswHeadButton];
    
    UIImage* rongLogoImage = [UIImage imageNamed:@"Icon"];
    _rongLogo = [[UIImageView alloc] initWithImage:rongLogoImage];
    _rongLogo.contentMode = UIViewContentModeScaleAspectFit;
    _rongLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_rongLogo];
    
    //中部内容输入区
    _inputBackground = [[UIView alloc] initWithFrame:CGRectZero];
    _inputBackground.translatesAutoresizingMaskIntoConstraints = NO;
    _inputBackground.userInteractionEnabled = YES;
    [self.view addSubview:_inputBackground];
    _errorMsgLb = [[UILabel alloc] initWithFrame:CGRectZero];
    _errorMsgLb.text = @"";
    _errorMsgLb.font = [UIFont fontWithName:@"Heiti SC" size:12.0];
    _errorMsgLb.translatesAutoresizingMaskIntoConstraints = NO;
    _errorMsgLb.textColor = [UIColor colorWithRed:204.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1];
    [self.view addSubview:_errorMsgLb];
    
    //用户名
    FlyingUnderlineTextField* userNameTextField = [[FlyingUnderlineTextField alloc] initWithFrame:CGRectZero];
    userNameTextField.backgroundColor = [UIColor clearColor];
    userNameTextField.tag = UserTextFieldTag;
    userNameTextField.delegate=self;
    //_account.placeholder=[NSString stringWithFormat:@"Email"];
    UIColor* color = [UIColor whiteColor];
    userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"手机" attributes:@{ NSForegroundColorAttributeName : color }];
    userNameTextField.textColor = [UIColor whiteColor];
    userNameTextField.text = [self getDefaultUserName];
    if (userNameTextField.text.length > 0) {
        [userNameTextField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
    }
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    userNameTextField.adjustsFontSizeToFitWidth = YES;
    [userNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [_inputBackground addSubview:userNameTextField];
    
    //密码
    FlyingUnderlineTextField* passwordTextField = [[FlyingUnderlineTextField alloc] initWithFrame:CGRectZero];
    passwordTextField.tag = PassWordFieldTag;
    passwordTextField.textColor = [UIColor whiteColor];
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.delegate=self;
    //passwordTextField.delegate = self;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{ NSForegroundColorAttributeName : color }];
    //passwordTextField.text = [self getDefaultUserPwd];
    [_inputBackground addSubview:passwordTextField];
    passwordTextField.text = [self getDefaultUserPwd];
    self.passwordTextField = passwordTextField;
    
    //UIEdgeInsets buttonEdgeInsets = UIEdgeInsetsMake(0, 7.f, 0, 7.f);
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(actionLogin:) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"login_button"] forState:UIControlStateNormal];
    loginButton.imageView.contentMode = UIViewContentModeCenter;
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inputBackground addSubview:loginButton];
    UIButton* userProtocolButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [userProtocolButton setTitle:@"阅读用户协议" forState:UIControlStateNormal];
    [userProtocolButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5] forState:UIControlStateNormal];
    
    [userProtocolButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [userProtocolButton addTarget:self action:@selector(userProtocolEvent) forControlEvents:UIControlEventTouchUpInside];
    userProtocolButton.hidden=YES;
    
    
    [self.view addSubview:userProtocolButton];
    
    //底部按钮区
    UIView* bottomBackground = [[UIView alloc] initWithFrame:CGRectZero];
    UIButton* registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -20, 80, 50)];
    [registerButton setTitle:@"返回" forState:UIControlStateNormal];
    [registerButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5] forState:UIControlStateNormal];
    [registerButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [registerButton addTarget:self action:@selector(cancelLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomBackground addSubview:registerButton];
    
    UIButton* forgetPswButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, -20, 80, 50)];
    [forgetPswButton setTitle:@"新用户" forState:UIControlStateNormal];
    [forgetPswButton setTitleColor:[[UIColor alloc] initWithRed:153 green:153 blue:153 alpha:0.5] forState:UIControlStateNormal];
    [forgetPswButton.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0]];
    [forgetPswButton addTarget:self action:@selector(registerEvent) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackground addSubview:forgetPswButton];
    
    [self.view addSubview:bottomBackground];
    
    bottomBackground.translatesAutoresizingMaskIntoConstraints = NO;
    userProtocolButton.translatesAutoresizingMaskIntoConstraints = NO;
    passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    userNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    //添加约束
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:bottomBackground attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:20]];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(_errorMsgLb, _rongLogo, _inputBackground, userProtocolButton, bottomBackground);
    
    NSArray* viewConstraints = [[[[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-41-[_inputBackground]-41-|" options:0 metrics:nil views:views]
                                    arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[_rongLogo]-60-|" options:0 metrics:nil views:views]]
                                   arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[_rongLogo(==60)]-10-[_errorMsgLb(==10)]-20-[_inputBackground(180)]-20-[userProtocolButton(==20)]" options:0 metrics:nil views:views]]
                                  arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomBackground(==50)]" options:0 metrics:nil views:views]]
                                 arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[bottomBackground]-10-|" options:0 metrics:nil views:views]]
                                arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_errorMsgLb]-10-|" options:0 metrics:nil views:views]];
    
    [self.view addConstraints:viewConstraints];
    
    NSLayoutConstraint* userProtocolLabelConstraint = [NSLayoutConstraint constraintWithItem:userProtocolButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX
                                                                                  multiplier:1.f
                                                                                    constant:0];
    [self.view addConstraint:userProtocolLabelConstraint];
    NSDictionary* inputViews = NSDictionaryOfVariableBindings(userNameTextField, passwordTextField, loginButton);
    
    NSArray* inputViewConstraints = [[[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[userNameTextField]|" options:0 metrics:nil views:inputViews]
                                       arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[passwordTextField]|" options:0 metrics:nil views:inputViews]] arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[userNameTextField(60)]-[passwordTextField(60)]-[loginButton(50)]" options:0 metrics:nil views:inputViews]] arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loginButton]|" options:0 metrics:nil views:inputViews]];
    
    [_inputBackground addConstraints:inputViewConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    _statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    _statusBarView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:_statusBarView];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
}

//用户名输入时改变字体大小
- (void)textFieldDidChange:(UITextField*)textField
{
    if (textField.text.length == 0) {
        [textField setFont:[UIFont fontWithName:@"Heiti SC" size:18.0]];
    }
    else {
        [textField setFont:[UIFont fontWithName:@"Heiti SC" size:25.0]];
    }
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    switch (textField.tag) {
        case UserTextFieldTag:
            [FlyingDataManager setUserName:@""];
            self.passwordTextField.text = nil;
        case PassWordFieldTag:
            [FlyingDataManager setUserPassword:@""];
            break;
        default:
            break;
    }
    return YES;
}

//键盘升起时动画
- (void)keyboardWillShow:(NSNotification*)notif
{
    
    CATransition* animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_rongLogo.layer addAnimation:animation forKey:nil];
    
    _rongLogo.hidden = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.frame = CGRectMake(0.f, -50, self.view.frame.size.width, self.view.frame.size.height);
        _headBackground.frame=CGRectMake(0, 70, self.view.bounds.size.width, 50);
        _statusBarView.frame = CGRectMake(0.f,50, self.view.frame.size.width,20);
    } completion:nil];
}

//键盘关闭时动画
- (void)keyboardWillHide:(NSNotification*)notif
{
    CATransition* animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.25;
    [_rongLogo.layer addAnimation:animation forKey:nil];
    
    _rongLogo.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
        CGRectMake(0, -100, self.view.bounds.size.width, 50);
        _headBackground.frame=CGRectMake(0, -100, self.view.bounds.size.width, 50);
        _statusBarView.frame = CGRectMake(0.f,0, self.view.frame.size.width,20);
    } completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.animatedImagesView startAnimating];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.animatedImagesView stopAnimating];
}

/*阅读用户协议*/
- (void)userProtocolEvent
{
}

/*注册*/
- (void)registerEvent
{
    
    NSString *title = nil;
    NSString *message = [NSString stringWithFormat:@"注册方式：请在电脑上访问%@/login.jsp?f=mx", [FlyingDataManager getServerAddress]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{
        //
    }];
}

/*找回密码*/
- (void)forgetPswEvent
{
    //RCDFindPswViewController* temp = [[RCDFindPswViewController alloc] init];
    //[self.navigationController pushViewController:temp animated:YES];
}

//取消登录
- (void)cancelLogin
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


/**
 *  获取默认用户
 *
 *  @return 是否获取到数据
 */
- (BOOL)getDefaultUser
{
    return [self validateUserName:[FlyingDataManager getUserName] userPwd:[FlyingDataManager getUserPassword]];
}
/*获取用户账号*/
- (NSString*)getDefaultUserName
{
    return [FlyingDataManager getUserName];
}

/*获取用户密码*/
- (NSString*)getDefaultUserPwd
{
    return  [FlyingDataManager getUserPassword];
}

- (IBAction)actionLogin:(id)sender
{
    NSString* userName = [(UITextField*)[self.view viewWithTag:UserTextFieldTag] text];
    NSString* userPwd = [(UITextField*)[self.view viewWithTag:PassWordFieldTag] text];
    [self login:userName password:userPwd];
}

- (void)loginSuccess:(NSString *)userName password:(NSString *)password token:(NSString *)token userId:(NSString *)userId
{
    //保存默认用户
    [FlyingDataManager setUserName:userName];
    [FlyingDataManager setUserPassword:password];
    
    //设置当前的用户信息
    RCUserInfo *_currentUserInfo = [[RCUserInfo alloc]initWithUserId:userId name:userName portrait:nil];
    [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
    
    [FlyingHttpTool getUserInfoByopenID:[FlyingDataManager getOpenUDID] completion:^(FlyingUserData *userData,RCUserInfo *userInfo) {
        
        //
    }];
}

/**
 *  登陆
 */
- (void)login:(NSString *)userName password:(NSString *)password
{
    RCNetworkStatus stauts=[[RCIMClient sharedRCIMClient]getCurrentNetworkStatus];
    
    if (RC_NotReachable == stauts) {
        _errorMsgLb.text=@"当前网络不可用，请检查！";
        return;
    } else {
        _errorMsgLb.text=@"";
    }
    
    if ([self validateUserName:userName userPwd:password]) {
        
        hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"登录中...";
        [hud show:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey :@"UserCookies"];
        
        [FlyingHttpTool updateCurrentID:[FlyingDataManager getOpenUDID]
                           withUserName:userName
                                    pwd:password
                             Completion:^(BOOL result) {
                                
                                 //
                                 if (result) {

                                     [FlyingDataManager setUserName:userName];
                                     [FlyingDataManager setUserPassword:password];
                                     
                                     FlyingActiveViewController *activeVC= [[FlyingActiveViewController alloc] init];
                                     
                                     //切换账户
                                     [self presentViewController:activeVC animated:YES completion:^{
                                         //
                                     }];
                                 }
                                 else
                                 {
                                     //关闭HUD
                                     [hud hide:YES];
                                     _errorMsgLb.text=@"用户名、密码错误或者你已经成功登录！";
                                     [_pwdTextField shake];
                                 }
                             }];
    }
    else {
        _errorMsgLb.text=@"请检查用户名密码";
    }
}

//验证用户信息格式
- (BOOL)validateUserName:(NSString*)userName
                 userPwd:(NSString*)userPwd
{
    NSString* alertMessage = nil;
    if (userName.length == 0) {
        alertMessage = @"用户名不能为空!";
    }
    else if (userPwd.length == 0) {
        alertMessage = @"密码不能为空!";
    }
    
    if (alertMessage) {
        _errorMsgLb.text = alertMessage;
        [_pwdTextField shake];
        return NO;
    }
    
    return [FlyingLoginVC validateMobile:userName]
    && [FlyingLoginVC validatePassword:userPwd];
}

- (NSUInteger)animatedImagesNumberOfImages:(FlyingAnimatedImagesView*)animatedImagesView
{
    return 2;
}

- (UIImage*)animatedImagesView:(FlyingAnimatedImagesView*)animatedImagesView imageAtIndex:(NSUInteger)index
{
    return [UIImage imageNamed:@"Default"];
}

#pragma mark - UI

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidUnload
{
    [self setAnimatedImagesView:nil];
    
    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

//验证手机号码
+ (BOOL) validateMobile:(NSString *)mobile
{
    if (mobile.length == 0) {

        NSString *title = nil;
        NSString *message = @"手机号码不能为空！";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController show];
        
        return NO;
    }
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    if (![phoneTest evaluateWithObject:mobile]) {
        
        NSString *title = nil;
        NSString *message = @"手机号码格式不正确！";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController show];
    }
    return YES;
}


//验证电子邮箱
+ (BOOL) validateEmail:(NSString *)email
{
    if (email.length == 0) {
        //        NSString *message = @"邮箱不能为空！";
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
        //                                                            message:message
        //                                                           delegate:nil
        //                                                  cancelButtonTitle:@"确定"
        //                                                  otherButtonTitles:nil, nil];
        //        [alertView show];
        return NO;
    }
    
    NSString *expression = [NSString stringWithFormat:@"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"];
    NSError *error = NULL;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:expression
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:email
                                                    options:0
                                                      range:NSMakeRange(0,[email length])];
    if (!match) {
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
        //                                                            message:@"邮箱格式错误！"
        //                                                           delegate:nil
        //                                                  cancelButtonTitle:@"确定"
        //                                                  otherButtonTitles:nil, nil];
        //        [alertView show];
        return NO;
    }
    return YES;
}

//验证密码
+(BOOL)validatePassword:(NSString *)password
{
    if (password.length == 0) {
        
        NSString *title = nil;
        NSString *message = @"密码不能为空！";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController show];
    }
    //    if (password.length < 6) {
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
    //                                                            message:@"密码不足六位！"
    //                                                           delegate:nil
    //                                                  cancelButtonTitle:@"确定"
    //                                                  otherButtonTitles:nil, nil];
    //        [alertView show];
    //        return NO;
    //    }
    
    return YES;
}


@end