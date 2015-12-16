//
//  FlyingMyGroupsVC.m
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingMyGroupsVC.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"

#import "UIView+Toast.h"

#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"

#import "RCDChatListViewController.h"

#import "FlyingGroupVC.h"

#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "FlyingDiscoverContent.h"

#import <AFNetworking/AFNetworking.h>
#import "iFlyingAppDelegate.h"

#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>

//#import <RCIMClient.h>
#import "RCDChatViewController.h"
#import "RCDataBaseManager.h"

#import "UICKeyChainStore.h"
#import "NSString+FlyingExtention.h"

@interface FlyingMyGroupsVC ()
{
    NSInteger            _maxNumOfGroups;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
    UIRefreshControl    *_refreshControl;
    
    NSInteger           kLoadMoreIndicatorTag;
}
@end

@implementation FlyingMyGroupsVC

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
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    _refresh=NO;
    
    //更新欢迎语言
    self.title =@"我的群组";
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.leftBarButtonItem = menuBarButtonItem;
    
    dispatch_async(dispatch_get_main_queue() , ^{
        [self updateChatIcon];
    });

    [self reloadAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    image= [UIImage imageNamed:@"People"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doGroup) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:chatBarButtonItem, searchBarButtonItem, nil];
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (!self.groupTableView)
    {
        _groupTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _groupTableView.delegate = self;
        _groupTableView.dataSource = self;
        _groupTableView.backgroundColor = [UIColor clearColor];
        _groupTableView.separatorColor = [UIColor clearColor];
        
        [self.view addSubview:_groupTableView];
        
        _currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
        
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshNow:) forControlEvents:UIControlEventValueChanged];
        [self.groupTableView addSubview:_refreshControl];
    }
    else
    {
        [_currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
    }
    
    [self loadMore];
}

- (void)refreshNow:(UIRefreshControl *)refreshControl
{
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        
        _refresh=YES;
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新中..."];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self reloadAll];
        });
    }
    else
    {
        [_refreshControl endRefreshing];
        [self.view makeToast:@"请联网后再试一下!" duration:3 position:CSToastPositionCenter];
    }
}

- (BOOL)loadMore
{
    //test only
    NSString *author = [[NSUserDefaults standardUserDefaults] objectForKey:KAppOwner];

    [FlyingHttpTool getAllGroupsForAPPOwner:author
                                  Recommend:YES
                                 PageNumber:1
                                 Completion:^(NSArray *groupList, NSInteger allRecordCount) {
                                     
                                     if (groupList.count!=0) {
                                         
                                         [self.currentData addObjectsFromArray:groupList];
                                         _maxNumOfGroups=allRecordCount;
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             [self finishLoadingData];
                                         });
                                     }
                                 }];
    
    
    return true;
    
    /*
     if (_currentData.count<_maxNumOfGroups)
     {
     _currentLodingIndex++;
     
     [FlyingHttpTool getMyGroupsForPageNumber:_currentLodingIndex
     Completion:^(NSArray *groupList, NSInteger allRecordCount) {
     //
     [self.currentData addObjectsFromArray:groupList];
     _maxNumOfGroups=allRecordCount;
     
     dispatch_async(dispatch_get_main_queue(), ^{
     [self finishLoadingData];
     });
     }];
     return true;
     }
     else{
     
     return false;
     }
     */
}

-(void) finishLoadingData
{
    //更新下拉刷新
    if(_refresh)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *lastUpdate = [NSString stringWithFormat:@"刷新时间：%@", [formatter stringFromDate:[NSDate date]]];
        
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
        
        [_refreshControl endRefreshing];
        _refresh=NO;
    }
    
    //更新界面
    if (_currentData.count>0)
    {
        [self.groupTableView reloadData];
    }
    else
    {
        [self.view makeToast:@"请联网后再试一下!" duration:3 position:CSToastPositionCenter];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentData.count && _currentData.count<_maxNumOfGroups)
    {
        return 2; // 增加一个加载更多
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.currentData count];
    }
    
    // 加载更多
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 普通Cell
        FlyingMyGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:GROUPCELL_IDENTIFIER];
        
        if (!cell) {
            cell = [[FlyingMyGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GROUPCELL_IDENTIFIER];
        }
        
        FlyingGroupData* groupData = [_currentData objectAtIndex:indexPath.row];
        cell.delegate =self;
        [cell loadingGroupData:groupData];

        return cell;
    }
    
    // 加载更多
    static NSString *CellIdentifierLoadMore = @"CellIdentifierLoadMore";
    
    UITableViewCell *loadCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoadMore];
    if (!loadCell)
    {
        loadCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoadMore];
        loadCell.backgroundColor = [UIColor clearColor];
        loadCell.contentView.backgroundColor = [UIColor clearColor];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.tag = kLoadMoreIndicatorTag;
        indicator.hidesWhenStopped = YES;
        indicator.center =loadCell.center;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|
        UIViewAutoresizingFlexibleRightMargin|
        UIViewAutoresizingFlexibleTopMargin|
        UIViewAutoresizingFlexibleBottomMargin;
        [loadCell.contentView addSubview:indicator];
    }
        
    return loadCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 普通Cell的高度
        return INTERFACE_IS_PAD ? 674 : 337;
    }
    
    // 加载更多
    return 44;
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator startAnimating];
    
    // 加载下一页
    [self loadMore];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator stopAnimating];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlyingGroupData* groupData = [_currentData objectAtIndex:indexPath.row];

    FlyingGroupVC *groupVC = [FlyingGroupVC new];
    groupVC.groupData=groupData;
    
    [self.navigationController pushViewController:groupVC animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma cell related
//////////////////////////////////////////////////////////////

- (void)memberCountButtonPressed:(FlyingGroupData*)groupData
{

}

- (void)lessonCountButtonPressed:(FlyingGroupData*)groupData
{
    FlyingDiscoverContent *discoverContent = [[FlyingDiscoverContent alloc] init];
    discoverContent.author= groupData.gp_author;
    
    [self.navigationController pushViewController:[[FlyingDiscoverContent alloc] init] animated:YES];
}

- (void)profileImageViewPressed:(FlyingGroupData*)groupData
{
    NSString *openID = [NSString getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    if ([openID isEqualToString:groupData.gp_owner])
    {
        //个人档案页
    }
    else
    {
        RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
        
        NSString* userID = groupData.gp_owner;
        
        RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:userID];
        chatService.userName = userInfo.name;
        chatService.targetId = userID;
        chatService.conversationType = ConversationType_PRIVATE;
        chatService.title = chatService.userName;
        [self.navigationController pushViewController:chatService animated:YES];
    }
}

- (void)coverImageViewPressed:(FlyingGroupData*)groupData
{
    FlyingGroupVC *groupVC = [FlyingGroupVC new];
    groupVC.groupData=groupData;
    
    [self.navigationController pushViewController:groupVC animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma menu related
//////////////////////////////////////////////////////////////

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)dismiss
{
#ifdef __CLIENT__IS__ENGLISH__
    [self showMenu];
#else
    if ([self.navigationController.viewControllers count]==1) {
        
        [self showMenu];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
#endif
    
}

- (void) doGroup
{
    
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
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

@end
