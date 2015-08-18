//
//  FlyingShareWithFriends.m
//  FlyingEnglish
//
//  Created by vincent on 6/5/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingShareWithFriends.h"
#import "RCDChatViewController.h"
#import "UIColor+RCColor.h"
#import "FlyingHttpTool.h"
#import "UIImageView+WebCache.h"
#import <RongIMKit/RongIMKit.h>
#import "FlyingUserInfo.h"
#import "iFlyingAppDelegate.h"
#import "FlyingNavigationController.h"
#import "FlyingHome.h"
#import "shareDefine.h"
#import "UICKeyChainStore.h"

@interface FlyingShareWithFriends ()<UIViewControllerRestoration>


//@property (nonatomic,strong) NSMutableArray *myDataSource;
@property (nonatomic,strong) RCConversationModel *tempModel;


@end

@implementation FlyingShareWithFriends

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *retViewController = [[FlyingShareWithFriends alloc] init];
    return retViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = @"FlyingShareWithFriends";
    self.restorationClass      = [self class];
    [self addBackFunction];
    
    self.title=@"请选择分享好友";
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"back"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
    //设置要显示的会话类型
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)]];
    
    //设置为不用默认渲染方式
    self.tabBarItem.image = [[UIImage imageNamed:@"icon_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_chat_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    self.conversationListTableView.tableFooterView = [UIView new];
    //    self.conversationListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 12)];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:19];
    titleView.textColor = [UIColor whiteColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.text = @"会话";
    self.tabBarController.navigationItem.titleView = titleView;
    
    //自定义rightBarButtonItem
    /*
     UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
     [rightBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
     [rightBtn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
     [rightBtn setTintColor:[UIColor whiteColor]];
     self.tabBarController.navigationItem.rightBarButtonItem = rightButton;
     */
}

/**
 *  点击进入会话界面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
       
        RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.userName = model.conversationTitle;
        _conversationVC.title = model.conversationTitle;
        
        [_conversationVC sendMessage:self.message pushContent:@""];
        
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }
    
    //聚合会话类型，此处自定设置。
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        
        NSLog(@"不能有聚合类型，如果要支持，要单独实现");

        /*
        RCDChatListViewController *temp = [[RCDChatListViewController alloc] init];
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        [self.navigationController pushViewController:temp animated:YES];
         */
    }
    
    //自定义会话类型
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION)
    {
        RCConversationModel *model = self.conversationListDataSource[indexPath.row];
        RCContactNotificationMessage *_contactNotificationMsg = (RCContactNotificationMessage *)model.lastestMessage;
        FlyingUserInfo *userinfo = [FlyingUserInfo new];
        
        NSDictionary *_cache_userinfo = [[NSUserDefaults standardUserDefaults]objectForKey:_contactNotificationMsg.sourceUserId];
        if (_cache_userinfo) {
            userinfo.userName       = _cache_userinfo[@"username"];
            userinfo.portraitUri    = _cache_userinfo[@"portraitUri"];
            userinfo.userId         = _contactNotificationMsg.sourceUserId;
        }
    }
}


//高度
-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0f;
}

//////////////////////////////////////////////////////////////
#pragma only portart events
//////////////////////////////////////////////////////////////
-(void) dismiss
{
    FlyingNavigationController *navigationController =(FlyingNavigationController *)[[self sideMenuViewController] contentViewController];
    
    if (navigationController.viewControllers.count==1) {
        
        FlyingHome* homeVC = [[FlyingHome alloc] init];
        
        [[self sideMenuViewController] setContentViewController:[[UINavigationController alloc] initWithRootViewController:homeVC]
                                                       animated:YES];
        [[self sideMenuViewController] hideMenuViewController];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
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
