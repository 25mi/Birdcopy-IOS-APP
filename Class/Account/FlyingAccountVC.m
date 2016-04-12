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
#import "FlyingProfileVC.h"
#import "FlyingNavigationController.h"
#import "AFHttpTool.h"
#import "UICKeyChainStore.h"
#import "FlyingPickColorVCViewController.h"
#import <RongIMKit/RCIM.h>
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import <UIImageView+AFNetworking.h>
#import "UIView+Toast.h"
#import "AFHttpTool.h"
#import "FlyingNowLessonDAO.h"
#import "FlyingNowLessonData.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "MKStoreKit.h"
#import "FlyingDataManager.h"
#import "FlyingHttpTool.h"
#import "FlyingConversationListVC.h"
#import "FlyingDataManager.h"
#import "FlyingWebViewController.h"
#import "FlyingUserRightData.h"
#import "FlyingReviewVC.h"
#import "FlyingConversationVC.h"
#import "FlyingTaskWordDAO.h"
#import "FlyingBuyVC.h"

@interface FlyingAccountVC ()<UIViewControllerRestoration>
{
    NSInteger _wordCount;
}
@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (strong, nonatomic) IBOutlet UILabel *accountNikename;
@property (strong, nonatomic) IBOutlet UILabel *membership;
@property (strong, nonatomic) IBOutlet UILabel *englishLabel;
@property (strong, nonatomic) IBOutlet UILabel *chatSettinglabel;
@property (strong, nonatomic) IBOutlet UILabel *clearCacheLabel;
@property (strong, nonatomic) IBOutlet UILabel *styleSetting;
@property (strong, nonatomic) IBOutlet UILabel *onlineServiceLable;

@end

@implementation FlyingAccountVC

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    FlyingAccountVC* vc;
    
    UIStoryboard* sb = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    
    if (sb) {
        
        vc = [sb instantiateViewControllerWithIdentifier:@"FlyingAccountVC"];
        vc.restorationIdentifier = [identifierComponents lastObject];
        vc.restorationClass = [FlyingAccountVC class];
    }
    
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    self.restorationIdentifier = NSStringFromClass([self class]);
    self.restorationClass = [self class];

    //标题
    self.title = NSLocalizedString(@"Account",nil);

    //顶部导航
    if(self.navigationController.viewControllers.count>1)
    {
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
    
    //UI相关配置
    //self.tableView.separatorColor = [UIColor grayColor];
    //self.currentUserNameLabel.text = [RCIMClient sharedClient].currentUserInfo.name;
    
    self.membership.text        = NSLocalizedString(@"My Service",nil);
    self.chatSettinglabel.text  = NSLocalizedString(@"Chat Setting",nil);
    self.clearCacheLabel.text   = NSLocalizedString(@"Clear Cache",nil);
    self.styleSetting.text      = NSLocalizedString(@"Style Setting",nil);
    self.onlineServiceLable.text= NSLocalizedString(@"Service Online",nil);
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
                                                      
                                                      [self.view makeToast:NSLocalizedString(@"Cleanning is ok",nil)
                                                                  duration:1
                                                                  position:CSToastPositionCenter];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBEAccountChange    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBELocalCacheClearOK    object:nil];
}

- (void) dismissNavigation
{
    [self willDismiss];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) willDismiss
{
}

- (void) updateAccountState
{
    NSString *nickName=[FlyingDataManager getUserData:nil].name;
    
    self.accountNikename.text=nickName;
    
    [self loadPortrait];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{

        NSArray *wordArray =  [[[FlyingTaskWordDAO alloc] init] selectWithUserID:[FlyingDataManager getOpenUDID]];
        
        _wordCount = wordArray.count;
        if (_wordCount>0) {
            
            self.englishLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Scene Dictionary[%@]", nil) , @(_wordCount)];
        }
        else
        {
            self.englishLabel.text = NSLocalizedString(@"English Tool",nil);
        }

    });

}

-(void) loadPortrait
{
    NSString *portraitUri=[FlyingDataManager getUserData:nil].portraitUri;
    
    if ([NSString isBlankString:portraitUri]) {
        
        if (![FlyingDataManager getOpenUDID]) {
            
            return;
        }
        
        [AFHttpTool getUserInfoWithOpenID:[FlyingDataManager getOpenUDID]
                                  success:^(id response) {
                                      //
                                      if (response) {
                                          NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                          
                                          if ([code isEqualToString:@"1"]) {
                                              
                                              NSString *portraitUri=response[@"portraitUri"];
                                              
                                              if (portraitUri.length==0) {
                                                  
                                                  [_portraitImageView setImage:[UIImage imageNamed:@"Icon"]];
                                                  [self.view makeToast:NSLocalizedString(@"Touch portrait to update it!", nil)
                                                              duration:1
                                                              position:CSToastPositionCenter];

                                              }
                                              else{
                                                  
                                                  RCUserInfo *userInfo = [RCUserInfo new];
                                                  
                                                  userInfo.userId= [[FlyingDataManager getOpenUDID] MD5];
                                                  userInfo.name=response[@"name"];
                                                  userInfo.portraitUri=response[@"portraitUri"];
                                                  
                                                  [_portraitImageView  setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]  placeholderImage:[UIImage imageNamed:@"Icon"]];
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
        [_portraitImageView  setImageWithURL:[NSURL URLWithString:portraitUri]  placeholderImage:[UIImage imageNamed:@"Icon"]];
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
    _portraitImageView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FlyingProfileVC* profileVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyingProfileVC"];
            
            profileVC.openUDID = [FlyingDataManager getOpenUDID];
            profileVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:profileVC animated:YES];

            break;
        }
            
        case 1:
        {
            FlyingBuyVC * buyVC = [[FlyingBuyVC alloc] init];
            
            buyVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:buyVC animated:YES];

            break;
        }
            
        case 2:
        {
            if (_wordCount>0) {
                
                FlyingReviewVC * reviewVC = [[FlyingReviewVC alloc] init];
                reviewVC.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:reviewVC animated:YES];
            }
            else
            {
                [self.view makeToast:NSLocalizedString(@"Touch subtitle and learn there!", nil)
                            duration:3
                            position:CSToastPositionCenter];
            }

            break;
        }
            
        case 3:
        {
            if (indexPath.row == 0)
            {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                id rongCloudSetting = [storyboard instantiateViewControllerWithIdentifier:@"RongCloudSetting"];
                
                [self.navigationController pushViewController:rongCloudSetting animated:YES];
            }
            else if (indexPath.row == 1) {
                
                [self clearCache];
            }
            else if (indexPath.row == 2) {
                
                
                FlyingPickColorVCViewController * vc= [[FlyingPickColorVCViewController alloc] init];
                
                vc.hidesBottomBarWhenPushed = YES;
                //定制导航条背景颜色
                [self.navigationController pushViewController:vc animated:YES];
            }

            break;
        }
            
        case 4:
        {
            FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
            
            chatService.domainID = self.domainID;
            chatService.domainType = self.domainType;
            
            chatService.targetId = self.domainID;
            chatService.conversationType = ConversationType_CHATROOM;
            chatService.title = NSLocalizedString(@"Service Online",nil);
            chatService.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatService animated:YES];

            break;
        }
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
