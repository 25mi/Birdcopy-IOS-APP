//
//  FlyingProfileViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 8/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingProfileViewController.h"
#import "iFlyingAppDelegate.h"
#import "FlyingStatisticDAO.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "CERoundProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Autosizing.h"
#import "UIImage+localFile.h"
#import "NSString+FlyingExtention.h"
#import "SIAlertView.h"
#import "shareDefine.h"

#import "FlyingTaskWordDAO.h"
#import "CFSharer.h"
#import "RESideMenu.h"

#import "SoundPlayer.h"
#import "FlyingSysWithCenter.h"

#import "FlyingSearchViewController.h"
#import "FlyingScanViewController.h"
#import "OpenUDID.h"
#import "UIView+Toast.h"
#import "RCDChatListViewController.h"

@interface FlyingProfileViewController ()
{
    NSInteger                       _touchWordCount;
    NSInteger                       _buyMoneyCount;
    NSInteger                       _giftCount;
}

@end

@implementation FlyingProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addBackFunction];
        
    self.title=@"我的账户";
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    image= [UIImage imageNamed:@"back"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem,menuBarButtonItem,nil];
    
    image= [UIImage imageNamed:@"scan"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* scanButton= [[UIButton alloc] initWithFrame:frame];
    [scanButton setBackgroundImage:image forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(doScan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* scanBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    
    image= [UIImage imageNamed:@"search"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:scanBarButtonItem, searchBarButtonItem, nil];

    
    [self.coinDataView setLittleShadow];
    
    if (INTERFACE_IS_PAD ) {
        
        //总数
        self.coinTitleLabel.font         = [UIFont systemFontOfSize:20.0];
        
        //金币
        self.coinLabel2.font             = [UIFont systemFontOfSize:16.0];
        self.coinLabel3.font             = [UIFont systemFontOfSize:16.0];
        self.coinLabel4.font             = [UIFont systemFontOfSize:20.0];
        

        self.giftCountNow.font           = [UIFont boldSystemFontOfSize:20.0];
        self.touchCountNow.font          = [UIFont boldSystemFontOfSize:20.0];
        self.totalCoinNow.font           = [UIFont boldSystemFontOfSize:24.0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self loadMyData];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCoinOK)
                                                 name:KBEAccountChange
                                               object:nil];
    
    dispatch_async(dispatch_get_main_queue() , ^{
        [self updateChatIcon];
    });
}

-(void) updateChatIcon
{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_PUBLICSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
    
    UIImage *image;
    if(unreadMsgCount>0)
    {
        image = [UIImage imageNamed:@"chat"];
    }
    else
    {
        image= [UIImage imageNamed:@"chat_b"];
    }
    
    CGRect frame= CGRectMake(0, 0, 24, 24);
    UIButton* chatButton= [[UIButton alloc] initWithFrame:frame];
    [chatButton setBackgroundImage:image forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* chatBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
    image= [UIImage imageNamed:@"search"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:chatBarButtonItem, searchBarButtonItem, nil];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{
    [self setGiftCountNow:nil];
    [self setTouchCountNow:nil];
    [self setTotalCoinNow:nil];
    [self setCoinLabel2:nil];
    [self setCoinLabel3:nil];
    [self setCoinLabel4:nil];
    [self setCoinTitleLabel:nil];
    [self setCoinProgressView:nil];
    
    [self setCoinDataView:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && ([self.view window] == nil) ) {
        self.view = nil;
        [self my_viewDidUnload];
    }
}

- (NSString *) getUserNickName
{

    return [[NSUserDefaults standardUserDefaults] objectForKey:KLoginNickName];
}

-(void)updateCoinOK
{
    [self refreshUI];
}

//////////////////////////////////////////////////////////////
#pragma mark 
//////////////////////////////////////////////////////////////

//LogoDone functions
- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        [self.view makeToast:@"PAD版本暂时不支持聊天功能!！"];
        
        return;
    }
    
    RCDChatListViewController  * chatList=[[RCDChatListViewController alloc] init];
    [self.navigationController pushViewController:chatList animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma plan card
//////////////////////////////////////////////////////////////

- (void) loadMyData
{
    //和服务器同步数据
    [FlyingSysWithCenter sysWithCenter];
    
    [self refreshUI];
}

- (void) refreshUI
{
    //收费相关
    
    NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];
    
    FlyingStatisticDAO * statisticDAO = [[FlyingStatisticDAO alloc] init];
    [statisticDAO initDataForUserID:passport];
    
    _touchWordCount = [statisticDAO touchCountWithUserID:passport];
    _buyMoneyCount     = [statisticDAO totalBuyMoneyWithUserID:passport];
    _giftCount      = [statisticDAO giftCountWithUserID:passport];
    
    self.giftCountNow.text = [@(_giftCount+KBEFreeTouchCount) stringValue];
    self.touchCountNow.text= [@(_touchWordCount) stringValue];
    
    self.totalCoinNow.text=[NSString  stringWithFormat:@"%@",[@([statisticDAO finalMoneyWithUserID:passport]) stringValue]];
    
    self.coinProgressView.tintColor  = [UIColor redColor];
    self.coinProgressView.trackColor = [UIColor  colorWithRed:0 green:156/255.0 blue:12/255.0 alpha:0.3];
    self.coinProgressView.startAngle = (3.0*M_PI)/2.0;
    self.coinProgressView.progress   = _touchWordCount*1.0/(_buyMoneyCount+_giftCount+KBEFreeTouchCount);
}


//////////////////////////////////////////////////////////////
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) doScan
{
    FlyingScanViewController * scanVC=[[FlyingScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
    [self.navigationController pushViewController:search animated:YES];
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shakeNow];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void) addBackFunction
{
    //在一个函数里面（初始化等）里面添加要识别触摸事件的范围
    UISwipeGestureRecognizer *recognizer= [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

-(void) handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if ((recognizer.state ==UIGestureRecognizerStateEnded) || (recognizer.state ==UIGestureRecognizerStateCancelled)) {
        
        [self dismiss];
    }
}

@end
