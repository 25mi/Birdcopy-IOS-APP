//
//  FlyingGuideViewController.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/12/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.

#import "FlyingGuideViewController.h"
#import "shareDefine.h"
#import "MBProgressHUD.h"

#import "FlyingHttpTool.h"
#import "iFlyingAppDelegate.h"
#import "NSString+FlyingExtention.h"
#import "FlyingDataManager.h"
#import "iFlyingAppDelegate.h"
#import "FlyingDataManager.h"

@interface FlyingGuideViewController()<UIViewControllerRestoration>
{
    MBProgressHUD* hud;
}

@end

@implementation FlyingGuideViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.view.autoresizesSubviews=UIViewAutoresizingNone;
    
    // 单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleRecognizer];

    [self BeginMagic];

    self.timer=[NSTimer scheduledTimerWithTimeInterval:5
                                                target:self
                                              selector:@selector(timerFired)
                                              userInfo:nil
                                               repeats:NO];
}

-(void)timerFired
{
    [self BeginMagic];
}

- (void)BeginMagic
{
    if (!hud) {

        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"激活设备中...";
    }
    
    [FlyingDataManager clearAllUserDate];
    
    //注册终端设备
    [FlyingHttpTool regOpenUDID:[FlyingDataManager getOpenUDID]
                             Completion:^(BOOL result) {
                                 
                                 //注册成功
                                 if (result) {
                                     
                                     [self accountActive];
                                 }
                             }];
}

- (void)accountActive
{
    //登录融云
    [FlyingHttpTool loginRongCloud];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = [appDelegate getTabBarController];
    [appDelegate.window makeKeyAndVisible];
    
    [self.timer invalidate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:YES];
    });
}

//屏幕单击
- (void)handleSingleTapFrom: (id) sender
{
    [self BeginMagic];
}

@end
