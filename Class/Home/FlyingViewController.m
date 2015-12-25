//
//  FlyingViewController.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/25/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingViewController.h"
#import "shareDefine.h"
#import "RESideMenu.h"
#import "UIViewController+RESideMenu.h"
#import <RongIMLib/RCIMClient.h>


@interface FlyingViewController ()

@end

@implementation FlyingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //顶部导航
    UIButton* menuButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];

    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem,menuBarButtonItem,nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount
{
    
    int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                @(ConversationType_PRIVATE),
                                                                @(ConversationType_DISCUSSION),
                                                                @(ConversationType_APPSERVICE),
                                                                @(ConversationType_PUBLICSERVICE),
                                                                @(ConversationType_GROUP)
                                                                ]];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *backString = nil;
        if (count > 0 && count < 1000) {
            
            backString = [NSString stringWithFormat:@"(%d)", count];
            
        } else if (count >= 1000) {
            
            backString = @"返回(...)";
        } else {
            
            return;
        }
        UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuBtn addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        
        menuBtn.frame = CGRectMake(0, 6, 87, 23);
        
        UIImageView *menuImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu"]];
        menuImg.frame = CGRectMake(-10, 0, 22, 22);
        
        [menuBtn addSubview:menuImg];
        UILabel *menuText = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 85, 22)];
        menuText.text = backString;//NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
        //   backText.font = [UIFont systemFontOfSize:17];
        [menuText setBackgroundColor:[UIColor clearColor]];
        [menuText setTextColor:[UIColor whiteColor]];
        [menuBtn addSubview:menuText];
        UIBarButtonItem *menuBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
        
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem,menuBarButtonItem,nil];
    });
}

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) dismissNavigation
{
    [self willDismiss];
    
    if ([self.navigationController.viewControllers count]==1) {
        
        [self showMenu];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//子类具体实现具体功能
- (void) willDismiss
{
}

@end
