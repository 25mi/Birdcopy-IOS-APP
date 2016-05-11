//
//  FlyingViewController.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/25/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingViewController.h"
#import "shareDefine.h"
#import <RongIMLib/RCIMClient.h>
#import "iFlyingAppDelegate.h"
#import "FlyingNavigationController.h"
#import "FlyingSoundPlayer.h"
#import <CRToast.h>
#import "NSString+FlyingExtention.h"

@interface FlyingViewController ()<UIViewControllerRestoration>

@end

@implementation FlyingViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (![self.domainID isBlankString])
    {
        
        [coder encodeObject:self.domainID forKey:@"self.domainID"];
    }
    
    if (![self.domainType isBlankString])
    {
        
        [coder encodeObject:self.domainType forKey:@"self.domainType"];
    }
    
    [coder encodeBool:self.hidesBottomBarWhenPushed forKey:@"self.hidesBottomBarWhenPushed"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    NSString * domainID = [coder decodeObjectForKey:@"self.domainID"];
    if (![domainID isBlankString])
    {
        self.domainID = domainID;
    }
        
    NSString * domainType =[coder decodeObjectForKey:@"self.domainType"];
    if (![domainType isBlankString])
    {
        self.domainType = domainType;
    }
    
    self.hidesBottomBarWhenPushed = [coder decodeBoolForKey:@"self.hidesBottomBarWhenPushed"];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationClass = [self class];
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self addBackFunction];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController.viewControllers count]>1)
    {
        
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        [self.tabBarController.tabBar setHidden:YES];
    }
    else
    {
        [self.tabBarController.tabBar setHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissNavigation
{
    [self willDismiss];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//子类具体实现具体功能
- (void) willDismiss
{
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shakeNow];
    }
}

- (void) addBackFunction
{
    //在一个函数里面（初始化等）里面添加要识别触摸事件的范围
    UISwipeGestureRecognizer *recognizer= [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    //recognizer.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:recognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismissNavigation];
    }
}


@end
