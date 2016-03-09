//
//  FlyingMyGroupsVC.m
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingHomeVC.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"

#import "UIView+Toast.h"

#import "FlyingConversationListVC.h"
#import "FlyingConversationVC.h"

#import "FlyingGroupVC.h"

#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "FlyingDiscoverVC.h"

#import <AFNetworking/AFNetworking.h>
#import "iFlyingAppDelegate.h"

#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>

#import "RCDataBaseManager.h"

#import "UICKeyChainStore.h"
#import "NSString+FlyingExtention.h"

#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"

#import "FlyingContentVC.h"
#import "FlyingContentListVC.h"
#import "FlyingGroupTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "shareDefine.h"

#import "FlyingAddressBookViewController.h"
#import "SIAlertView.h"

@interface FlyingHomeVC ()
{
    NSInteger            _maxNumOfGroups;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
    UIRefreshControl    *_refreshControl;
}

@end

@implementation FlyingHomeVC

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
    self.title =@"发现";
    
    //顶部导航
    UIButton* chatButton= [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 24, 24)];
    [chatButton setBackgroundImage:[UIImage imageNamed:@"Help"] forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* chatBarButtonItems= [[UIBarButtonItem alloc] initWithCustomView:chatButton];

    self.navigationItem.leftBarButtonItem = chatBarButtonItems;
    
    UIButton* memberButton= [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 24, 24)];
    [memberButton setBackgroundImage:[UIImage imageNamed:@"People"] forState:UIControlStateNormal];
    [memberButton addTarget:self action:@selector(showMember) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* memberBarButtonItems= [[UIBarButtonItem alloc] initWithCustomView:memberButton];
    
    UIButton* discoverButton= [[UIButton alloc] initWithFrame:CGRectMake(200, 7, 24, 24)];
    [discoverButton setBackgroundImage:[UIImage imageNamed:@"Discover"] forState:UIControlStateNormal];
    [discoverButton addTarget:self action:@selector(doDiscover) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* discoverButtonItem= [[UIBarButtonItem alloc] initWithCustomView:discoverButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:discoverButtonItem,memberBarButtonItems,nil];
    
    //顶部导航
    [self reloadAll];
}

- (void) doDiscover
{
    FlyingDiscoverVC *discoverContent = [[FlyingDiscoverVC alloc] init];
    discoverContent.domainID = [FlyingDataManager  getBusinessID];
    discoverContent.domainType = BC_Business_Domain;
    discoverContent.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:discoverContent animated:YES];
}

- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        [self.view makeToast:@"PAD版本暂时不支持聊天功能!！"];
        
        return;
    }
    
    FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
    
    chatService.targetId = [FlyingDataManager getBusinessID];
    chatService.conversationType = ConversationType_CHATROOM;
    chatService.title = @"客服聊天室";
    chatService.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatService animated:YES];
}

-(void) showMember
{
    FlyingAddressBookViewController * membersVC = [[FlyingAddressBookViewController alloc] init];
    
    membersVC.title = @"群成员";
    membersVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:membersVC animated:YES];
}

- (void) willDismiss
{
}
//////////////////////////////////////////////////////////////
#pragma FlyingCoverViewDelegate Related
//////////////////////////////////////////////////////////////
- (void) touchCover:(FlyingPubLessonData*)lessonPubData
{
    FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
    [contentVC setThePubLesson:lessonPubData];
    contentVC.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}

- (void) showFeatureContent
{
    FlyingContentListVC *contentList = [[FlyingContentListVC alloc] init];
    [contentList setIsOnlyFeatureContent:YES];
    [contentList setDomainID:[FlyingDataManager getBusinessID]];
    [contentList setDomainType:BC_Business_Domain];
    contentList.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:contentList animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (!self.groupTableView)
    {
        self.groupTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        UINib *nib = [UINib nibWithNibName:@"FlyingGroupTableViewCell" bundle: nil];
        [self.groupTableView registerNib:nib  forCellReuseIdentifier:@"FlyingGroupTableViewCell"];
        
        self.groupTableView.delegate = self;
        self.groupTableView.dataSource = self;
        self.groupTableView.backgroundColor = [UIColor clearColor];
        
        //Add cover view
        CGRect  loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*210/320);
        FlyingCoverView* coverFlow = [[FlyingCoverView alloc] initWithFrame:loadingRect];
        [coverFlow setCoverViewDelegate:self];
        [coverFlow setDomainID:[FlyingDataManager getBusinessID]];
        [coverFlow setDomainType:BC_Business_Domain];
        [coverFlow loadData];
        self.groupTableView.tableHeaderView =coverFlow;

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
    [FlyingHttpTool getAllGroupsForDomainID:[FlyingDataManager getBusinessID]
                                 DomainType:BC_Business_Domain
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
        FlyingGroupTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:GROUPCELL_IDENTIFIER];
        
        if (!cell) {
            cell = [FlyingGroupTableViewCell groupCell];
        }
        
        [self configureCell:cell atIndexPath:indexPath];

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
        return [tableView fd_heightForCellWithIdentifier:@"FlyingGroupTableViewCell" configuration:^(id cell) {
            
            [self configureCell:cell atIndexPath:indexPath];
        }];
    
    }
    
    // 加载更多
    return 44;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FlyingGroupData *groupData = self.currentData[indexPath.row];
    [(FlyingGroupTableViewCell*)cell settingWithGroupData:groupData];
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
    
    if (groupData.is_public_access) {
        
        [self enterGroup:groupData];
    }
    else{
    
        [FlyingHttpTool checkGroupMemberInfoForAccount:[FlyingDataManager getOpenUDID]
                                                 AppID:[FlyingDataManager getBirdcopyAppID]
                                               GroupID:groupData.gp_id Completion:^(NSString *result) {
                                                   //
                                                   if ([result isEqualToString:KGroupMemberVerified]) {
                                                       
                                                       [self enterGroup:groupData];
                                                   }
                                                   else if ([result isEqualToString:KGroupMemberNoexisted])
                                                   {
                                                       NSString *title = @"友情提醒！";
                                                       NSString *message = @"你不是成员，需要申请加入群组吗？";
                                                       SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
                                                       [alertView addButtonWithTitle:@"取消"
                                                                                type:SIAlertViewButtonTypeCancel
                                                                             handler:^(SIAlertView *alertView) {
                                                                             }];
                                                       
                                                       [alertView addButtonWithTitle:@"确认"
                                                                                type:SIAlertViewButtonTypeDefault
                                                                             handler:^(SIAlertView *alertView) {
                                                                                 
                                                                                 [FlyingHttpTool joinGroupForAccount:[FlyingDataManager getOpenUDID] AppID:[FlyingDataManager getBirdcopyAppID]
                                                                                                             GroupID:groupData.gp_id
                                                                                                          Completion:^(NSString *result) {
                                                                                                              
                                                                                                              if ([result isEqualToString:KGroupMemberVerified]) {
                                                                                                                  [self enterGroup:groupData];
                                                                                                              }
                                                                                                              else {
                                                                                                                  
                                                                                                                  [self showMemberInfo:result];
                                                                                                              }
                                                                                                                                                                                                                        }];
                                                                             }];

                                                       alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                                                       alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
                                                       [alertView show];
                                                   }
                                                   else
                                                   {
                                                       
                                                       [self showMemberInfo:result];
                                                   }
                                               }];
    }
}


-(void) enterGroup:(FlyingGroupData*)groupData

{
    FlyingGroupVC *groupVC = [FlyingGroupVC new];
    groupVC.groupData=groupData;
    groupVC.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:groupVC animated:YES];
}

-(void) showMemberInfo:(NSString*)reslutStr
{
    
    NSString * refuseStr = @"你的成员资格被拒绝!";
    NSString * reviewStr = @"你的成员资格正在审批中...";
    
    NSString * infoStr=@"未知错误！";

    if ([reslutStr isEqualToString:KGroupMemberRefused]) {
        
        infoStr = refuseStr;
    }
    else if([reslutStr isEqualToString:KGroupMemberReviewing])
    {
        infoStr = reviewStr;
        
    }
    
    [self.view makeToast:infoStr duration:2 position:CSToastPositionCenter];
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
