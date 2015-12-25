//
//  FlyingAccountVC.m
//  FlyingEnglish
//
//  Created by vincent on 5/25/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingAccountVC.h"
#import "UIColor+RCColor.h"
#import "iFlyingAppDelegate.h"
#import "FlyingSearchViewController.h"
#import "FlyingProfileVC.h"
#import "FlyingNavigationController.h"
#import "AFHttpTool.h"
#import "UICKeyChainStore.h"
#import "FlyingPickColorVCViewController.h"
#import <RongIMKit/RCIM.h>

#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "UIImageView+WebCache.h"
#import "SIAlertView.h"
#import "UIView+Toast.h"

#import "AFHttpTool.h"
#import "FlyingNowLessonDAO.h"
#import "FlyingNowLessonData.h"

#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"

#import "FlyingDiscoverContent.h"
#import "FlyingMyGroupsVC.h"

#import "FlyingHelpVC.h"
#import "MKStoreKit.h"

#import "FlyingDataManager.h"
#import "FlyingHttpTool.h"

#import "FlyingConversationListVC.h"


@interface FlyingAccountVC ()

@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (strong, nonatomic) IBOutlet UILabel *accountNikename;
@property (strong, nonatomic) IBOutlet UILabel *membership;

@end

@implementation FlyingAccountVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    self.title=@"设置";
    
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
    
    //UI相关配置
    self.tableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    //self.currentUserNameLabel.text = [RCIMClient sharedClient].currentUserInfo.name;
    
    self.tabBarController.navigationItem.title = @"我";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateAccountState];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:KBEAccountChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self updateAccountState];
                                                      //[self.tableView reloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:KBELocalCacheClearOK
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self.view makeToast:@"清理缓存成功！"];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBEAccountChange    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBELocalCacheClearOK    object:nil];
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

- (void) willDismiss
{
}

- (void) updateAccountState
{
    NSString *nickName=[NSString getNickName];
    
    self.accountNikename.text=nickName;
    
    [self loadPortrait];
    
    NSString *endDateStr = [[NSUserDefaults standardUserDefaults] objectForKey:KMembershipEndTime];
    
    if (endDateStr)
    {
        self.membership.text=[NSString stringWithFormat:@"会员至:%@",endDateStr];
    }
    else
    {
        self.membership.text=@"现在购买会员";
    }
}

-(void) loadPortrait
{
    NSString *portraitUri=[NSString getUserPortraitUri];
    
    if (portraitUri.length==0) {
        
        NSString *openID = [NSString getOpenUDID];
        
        if (!openID) {
            
            return;
        }
        
        [AFHttpTool getUserInfoWithOpenID:openID
                                  success:^(id response) {
                                      //
                                      if (response) {
                                          NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                          
                                          if ([code isEqualToString:@"1"]) {
                                              
                                              NSString *portraitUri=response[@"portraitUri"];
                                              
                                              if (portraitUri.length==0) {
                                                  
                                                  [_portraitImageView setImage:[UIImage imageNamed:@"Icon"]];
                                                  [self.view makeToast:@"请点击头像图片更新！"];
                                              }
                                              else{
                                                  
                                                  RCUserInfo *userInfo = [RCUserInfo new];
                                                  
                                                  userInfo.userId= [openID MD5];
                                                  userInfo.name=response[@"name"];
                                                  userInfo.portraitUri=response[@"portraitUri"];
                                                  
                                                  [_portraitImageView  sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]  placeholderImage:[UIImage imageNamed:@"Icon"]];
                                                  self.accountNikename.text=userInfo.name;
                                              }
                                          }
                                          else
                                          {
                                              NSLog(@"getUserInfoWithOpenID:%@",response[@"rm"]);
                                          }
                                      }
                                  } failure:^(NSError *err) {
                                      //
                                      [_portraitImageView setImage:[UIImage imageNamed:@"Icon"]];
                                      NSLog(@"Get rongcloud Toke %@",err.description);
                                      
                                  }];
    }
    else
    {
        [_portraitImageView  sd_setImageWithURL:[NSURL URLWithString:portraitUri]  placeholderImage:[UIImage imageNamed:@"Icon"]];
    }
    
    [_portraitImageView.layer setCornerRadius:(_portraitImageView.frame.size.height/2)];
    [_portraitImageView.layer setMasksToBounds:YES];
    [_portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_portraitImageView setClipsToBounds:YES];
    _portraitImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _portraitImageView.layer.shadowOffset = CGSizeMake(4, 4);
    _portraitImageView.layer.shadowOpacity = 0.5;
    _portraitImageView.layer.shadowRadius = 2.0;
    _portraitImageView.userInteractionEnabled = YES;
    _portraitImageView.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id myProfileVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyingProfileVC"];
        
        [self.navigationController pushViewController:myProfileVC animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate presentStoreView];
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id rongCloudSetting = [storyboard instantiateViewControllerWithIdentifier:@"RongCloudSetting"];
        
        [self.navigationController pushViewController:rongCloudSetting animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 1) {
        
        [self clearCache];
    }
    else if (indexPath.section == 3 && indexPath.row == 0) {
        
        //定制导航条背景颜色
        [self.navigationController pushViewController:[[FlyingPickColorVCViewController alloc] init] animated:YES];

    }
    else if (indexPath.section == 4 && indexPath.row == 0)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate  showWebviewWithURL:[NSString getOfficalURL]];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
        /*
#define SERVICE_ID @"kefu114"
        RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
        chatService.targetName = @"客服";
        chatService.targetId = SERVICE_ID;
        chatService.conversationType = ConversationType_CUSTOMERSERVICE;
        chatService.title = chatService.targetName;
        [self.navigationController pushViewController:chatService animated:YES];
         */
    
}


//清理缓存
-(void) clearCache
{
    [FlyingDataManager clearCache];
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
    [self.view addGestureRecognizer:recognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismissNavigation];
    }
}

@end
