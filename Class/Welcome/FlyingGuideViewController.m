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

@interface FlyingGuideViewController()
{
    MBProgressHUD* hud;
}

@property (strong, nonatomic) NSOperationQueue      *loginQueue;


@end

@implementation FlyingGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginQueue = [NSOperationQueue new];
    [self.loginQueue setMaxConcurrentOperationCount:1];

    
	// Do any additional setup after loading the view.
    self.view.autoresizesSubviews=UIViewAutoresizingNone;
    
    // 单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleRecognizer];

    [self tryLogin];

    self.timer=[NSTimer scheduledTimerWithTimeInterval:5
                                                target:self
                                              selector:@selector(timerFired)
                                              userInfo:nil
                                               repeats:NO];
}

-(void)timerFired
{
    [self tryLogin];
}

-(void) tryLogin
{
    [self.loginQueue cancelAllOperations];
    
    [self.loginQueue addOperationWithBlock:^{
        
        if (!hud) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelColor = self.textColor;
                hud.labelText = @"激活设备准备登陆中...";
            }];
        }
        
        //清理旧数据，如果有
        [FlyingDataManager clearAllUserDate];
        
        //检查APP是否注册
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [FlyingHttpTool getAppDataforBounldeID:bundleIdentifier
                                    Completion:^(FlyingAppData *appData) {
                                        //
                                        if (appData) {
                                            
                                            //保存app数据到本地缓存
                                            [FlyingDataManager saveAppData:appData];
                                            
                                            //用户是否有效登录决定是否注册激活
                                            [self checkUserRight];
                                        }
                                        else
                                        {
                                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                
                                                hud.labelText = @"非授权APP设备...";
                                            }];
                                        }
                                    }];

    }];
}

-(void) checkUserRight
{
    [FlyingHttpTool verifyOpenUDID:[FlyingDataManager getOpenUDID]
                        Completion:^(BOOL result) {
                            //有注册记录
                            if (result) {
                                
                                //从服务器获取新数据
                                [FlyingDataManager creatLocalUSerProfileWithServer];
                                
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                    
                                    [self accountActive];
                                }];
                            }
                            else
                            {
                                //注册终端设备
                                [FlyingHttpTool regOpenUDID:[FlyingDataManager getOpenUDID]
                                                 Completion:^(BOOL result) {
                                                     
                                                     //注册成功
                                                     if (result) {
                                                         
                                                         [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                             
                                                             [self accountActive];
                                                         }];
                                                     }
                                                 }];
                            }
                        }];
}


- (void)accountActive
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = [appDelegate getTabBarController];
    
    [self.timer invalidate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hide:YES];
    });
}

//屏幕单击
- (void)handleSingleTapFrom: (id) sender
{
    [self tryLogin];
}

@end
