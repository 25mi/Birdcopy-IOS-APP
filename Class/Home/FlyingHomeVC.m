//
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
#import "FlyingGroupUpdateData.h"
#import "FlyingWebViewController.h"
#import "FlyingSoundPlayer.h"

@interface FlyingHomeVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfGroups;
    NSInteger            _currentLodingIndex;
}

@end

@implementation FlyingHomeVC

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
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
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    //标题
    self.title = NSLocalizedString(@"Discover",nil);
    
    //顶部导航
    UIButton* chatButton= [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 24, 24)];
    [chatButton setBackgroundImage:[UIImage imageNamed:@"Help"] forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* chatBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
    UIButton* discoverButton= [[UIButton alloc] initWithFrame:CGRectMake(200, 7, 24, 24)];
    [discoverButton setBackgroundImage:[UIImage imageNamed:@"Discover"] forState:UIControlStateNormal];
    [discoverButton addTarget:self action:@selector(doDiscover) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* discoverButtonItem= [[UIBarButtonItem alloc] initWithCustomView:discoverButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:discoverButtonItem,chatBarButtonItem,nil];
    
    //顶部导航
    [self reloadAll];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate refreshTabBadgeValue];
}

- (void) doDiscover
{
    FlyingDiscoverVC *discoverContent = [[FlyingDiscoverVC alloc] init];
    
    discoverContent.domainID = self.domainID;
    discoverContent.domainType = self.domainType;
    
    discoverContent.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:discoverContent animated:YES];
}

- (void) doChat
{
    FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];

    chatService.domainID = self.domainID;
    chatService.domainType = self.domainType;
    
    chatService.targetId = [FlyingDataManager getBusinessID];
    chatService.conversationType = ConversationType_CHATROOM;
    chatService.title = @"客服聊天室";
    chatService.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatService animated:YES];
}

- (void) willDismiss
{
}
//////////////////////////////////////////////////////////////
#pragma FlyingCoverViewDelegate Related
//////////////////////////////////////////////////////////////
- (void) touchCover:(FlyingPubLessonData*)lessonPubData
{
    if ([lessonPubData.contentType isEqualToString:KContentTypePageWeb]&&
        lessonPubData.coinPrice==0)
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"FlyingWebViewController"];

        webpage.domainID = self.domainID;
        webpage.domainType = self.domainType;
        
        webpage.thePubLesson = lessonPubData;
        
        webpage.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:webpage animated:YES];
    }
    else
    {
        FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
        
        contentVC.domainID = self.domainID;
        contentVC.domainType = self.domainType;
        
        [contentVC setThePubLesson:lessonPubData];
        contentVC.hidesBottomBarWhenPushed=YES;
        
        [self.navigationController pushViewController:contentVC animated:YES];
    }
}

- (void) showFeatureContent
{
    FlyingContentListVC *contentList = [[FlyingContentListVC alloc] init];

    contentList.domainID = self.domainID;
    contentList.domainType = self.domainType;

    [contentList setIsOnlyFeatureContent:YES];
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
        
        self.groupTableView.tableFooterView = [UIView new];
        
        //Add cover view
        CGRect  loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*210/320);
        FlyingCoverView* coverFlow = [[FlyingCoverView alloc] initWithFrame:loadingRect];
        [coverFlow setCoverViewDelegate:self];
        [coverFlow setDomainID:[FlyingDataManager getBusinessID]];
        [coverFlow setDomainType:BC_Domain_Business];
        [coverFlow loadData];
        self.groupTableView.tableHeaderView =coverFlow;
        
        self.groupTableView.restorationIdentifier = @"groupTableView";
        
        [self.view addSubview:self.groupTableView];
        
        _currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
    }
    else
    {
        [_currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
    }
    
    [self loadMore];
}

- (void)loadMore
{
    if (_currentData.count<_maxNumOfGroups)
    {
        _currentLodingIndex++;

        [FlyingHttpTool getAllGroupsForDomainID:[FlyingDataManager getBusinessID]
                                     DomainType:BC_Domain_Business
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
    }
}

-(void) finishLoadingData
{
    //更新界面
    if (_currentData.count>0)
    {
        [self.groupTableView reloadData];
    }
    else
    {
        [self.view makeToast:@"请联网后再试一下!"
                    duration:1
                    position:CSToastPositionCenter];
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
        FlyingGroupTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FlyingGroupTableViewCell"];
        
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
        return [tableView fd_heightForCellWithIdentifier:@"FlyingGroupTableViewCell"
                                        cacheByIndexPath:indexPath
                                           configuration:^(id cell) {
    
            [self configureCell:cell atIndexPath:indexPath];
        }];
    
    }
    
    // 加载更多
    return 44;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FlyingGroupUpdateData *groupData = self.currentData[indexPath.row];
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
    
    if ([[self navigationController] topViewController] == self) {

    
        FlyingGroupUpdateData* groupUpdateData = [_currentData objectAtIndex:indexPath.row];
        
        if (groupUpdateData.groupData.is_public_access) {
            
            [self enterGroup:groupUpdateData.groupData];
        }
        else{
            
            [FlyingHttpTool checkGroupMemberInfoForAccount:[FlyingDataManager getOpenUDID]
                                                   GroupID:groupUpdateData.groupData.gp_id Completion:^(FlyingUserRightData *userRightData) {
                                                       
                //
                if ([userRightData checkRightPresent]) {
                    
                    [self enterGroup:groupUpdateData.groupData];
                }
                else if ([userRightData.memberState isEqualToString:BC_Member_Noexisted])
                {
                    NSString *title   = NSLocalizedString(@"Attenion Please", nil);
                    NSString *message = NSLocalizedString(@"I want to become a member!", nil);
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                             message:message
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                                         style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        
                        [FlyingHttpTool joinGroupForAccount:[FlyingDataManager getOpenUDID]
                                                    GroupID:groupUpdateData.groupData.gp_id
                                                 Completion:^(FlyingUserRightData *userRightData) {
                                                     
                                                     [self showMemberInfo:userRightData];
                                                 }];
                    }];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [alertController addAction:doneAction];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:^{
                        //
                    }];
                }
                else
                {
                    [self showMemberInfo:userRightData];
                }
            }];
        }
    }
}


-(void) enterGroup:(FlyingGroupData*)groupData
{
    FlyingGroupVC *groupVC = [[FlyingGroupVC alloc] init];
    
    groupVC.domainID = groupData.gp_id;
    groupVC.domainType = BC_Domain_Group;
    
    groupVC.groupData=groupData;
    groupVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:groupVC animated:YES];
}

-(void) showMemberInfo:(FlyingUserRightData*)userRightData
{
    NSString * infoStr=@"未知错误！";
    
    if([userRightData.memberState  isEqualToString:BC_Member_Noexisted])
    {
        infoStr = @"不存在会员身份！";
    }
    
    else if([userRightData.memberState  isEqualToString:BC_Member_Reviewing])
    {
        infoStr = @"你的成员资格正在审批中...";
    }
    else if ([userRightData.memberState isEqualToString:BC_Member_Verified]) {
        
        infoStr =  @"你已经是正式会员，可以参与互动了!";
    }
    else if ([userRightData.memberState isEqualToString:BC_Member_Refused]) {
        
        infoStr = @"你的成员资格被拒绝!";
    }
    
    [self.view makeToast:infoStr
                duration:2
                position:CSToastPositionCenter];
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
