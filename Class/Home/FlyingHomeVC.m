//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingHomeVC.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"
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
#import "FlyingGroupVC.h"
#import "FlyingIndexedCollectionView.h"
#import "FlyingAuthorCollectionViewCell.h"
#import <CRToastManager.h>

@interface FlyingHomeVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfGroups;
    NSInteger            _currentLodingIndex;
}

@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@property (atomic,assign)    BOOL refresh;

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
        
        self.hidesBottomBarWhenPushed = NO;
        
        self.domainID = [FlyingDataManager getBusinessID];
        self.domainType = BC_Domain_Business;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //标题
    self.title = NSLocalizedString(@"Discover",nil);
    
    //顶部导航
    UIButton* discoverButton= [[UIButton alloc] initWithFrame:CGRectMake(200, 7, 24, 24)];
    [discoverButton setBackgroundImage:[UIImage imageNamed:@"Favorite"] forState:UIControlStateNormal];
    [discoverButton addTarget:self action:@selector(doDiscover) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* discoverButtonItem= [[UIBarButtonItem alloc] initWithCustomView:discoverButton];
    
    self.navigationItem.rightBarButtonItem = discoverButtonItem;
    
    //加载数据
    [self reloadAll];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate refreshTabBadgeValue];
    
    [self setupRefreshControl];
}

- (void) doDiscover
{
    FlyingDiscoverVC *discoverContent = [[FlyingDiscoverVC alloc] init];
    
    discoverContent.domainID = self.domainID;
    discoverContent.domainType = self.domainType;
    
    [self.navigationController pushViewController:discoverContent animated:YES];
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
        FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
        webVC.domainID = self.domainID;
        webVC.domainType = self.domainType;
        
        webVC.thePubLesson = lessonPubData;
        
        [self.navigationController pushViewController:webVC animated:YES];
    }
    else
    {
        FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
        
        contentVC.domainID = self.domainID;
        contentVC.domainType = self.domainType;
        
        [contentVC setThePubLesson:lessonPubData];
        
        [self.navigationController pushViewController:contentVC animated:YES];
    }
}

- (void) showFeatureContent
{
    FlyingContentListVC *contentList = [[FlyingContentListVC alloc] init];

    contentList.domainID = self.domainID;
    contentList.domainType = self.domainType;

    [contentList setIsOnlyFeatureContent:YES];
    [self.navigationController pushViewController:contentList animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (!self.domainID)
    {
        return;
    }
    
    if (!self.groupTableView)
    {
        self.groupTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-64) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        [self.groupTableView registerNib:[UINib nibWithNibName:@"FlyingGroupTableViewCell" bundle: nil]  forCellReuseIdentifier:@"FlyingGroupTableViewCell"];
        
        self.groupTableView.delegate = self;
        self.groupTableView.dataSource = self;
        self.groupTableView.backgroundColor = [UIColor clearColor];
        
        //Add cover view
        CGRect  loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*210/320);
        self.coverFlow = [[FlyingCoverView alloc] initWithFrame:loadingRect];
        [self.coverFlow setCoverViewDelegate:self];
        self.groupTableView.tableHeaderView =self.coverFlow;
        
        self.groupTableView.restorationIdentifier = self.restorationIdentifier;
        
        NSInteger bottom = [[NSUserDefaults standardUserDefaults] integerForKey:KTabBarHeight];
        self.groupTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.groupTableView.frame.size.width, bottom)];
        
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_1)
        {
            self.groupTableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        
        [self.view addSubview:self.groupTableView];
        
        self.currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
    }
    else
    {
        [self.currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
    }
    
    //加载内容推荐区
    [self.coverFlow setDomainID:[FlyingDataManager getBusinessID]];
    [self.coverFlow setDomainType:BC_Domain_Business];
    [self.coverFlow loadData];

    //加载群组推荐区
    [self loadMore];
}

# pragma mark - YALSunyRefreshControl methods

-(void)setupRefreshControl
{
    _refresh = NO;
    self.sunnyRefreshControl = [YALSunnyRefreshControl new];
    self.sunnyRefreshControl.delegate = self;
    [self.sunnyRefreshControl attachToScrollView:self.groupTableView];
}

-(void)beginRefreshing
{
    if (_refresh)
    {
        return;
    }
    
    // start loading something
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        _refresh=YES;
        [self reloadAll];
    }
    else
    {
        [self endAnimationHandle];
    }
}

-(void)endAnimationHandle
{
    [self.sunnyRefreshControl endRefreshing];
    _refresh=NO;
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////

- (void)loadMore
{
    if (self.currentData.count<_maxNumOfGroups)
    {
        _currentLodingIndex++;

        [FlyingHttpTool getAllGroupsForDomainID:[FlyingDataManager getAppData].domainID
                                     DomainType:BC_Domain_Business
                                     PageNumber:_currentLodingIndex
                                     Completion:^(NSArray *groupUpdateList, NSInteger allRecordCount)
        {
            _maxNumOfGroups=allRecordCount;
            
            if (groupUpdateList.count!=0) {
                
                NSArray *tempArray=[self.currentData arrayByAddingObjectsFromArray:groupUpdateList];
                NSArray *sortedArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    
                    NSDate *first = [dateFormatter dateFromString: [(FlyingGroupUpdateData *)a recentLessonData].timeLamp];
                    
                    NSDate *second = [dateFormatter dateFromString: [(FlyingGroupUpdateData *)b recentLessonData].timeLamp];
                    
                    return [second compare:first];
                }];
                
                [self.currentData removeAllObjects];
                [self.currentData addObjectsFromArray:sortedArray];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self finishLoadingData];
                });
            }
        }];
    }
}

-(void) finishLoadingData
{
    //更新下拉刷新
    if(_refresh)
    {
        [self endAnimationHandle];
    }
    
    //更新界面
    if (self.currentData.count>0)
    {
        [self.groupTableView reloadData];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentData.count && self.currentData.count<_maxNumOfGroups)
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
    if (indexPath.row<self.currentData.count)
    {
        FlyingGroupUpdateData *groupData = self.currentData[indexPath.row];
        [(FlyingGroupTableViewCell*)cell settingWithGroupData:groupData];
    }
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
    FlyingGroupUpdateData *groupUpData = self.currentData[indexPath.row];
    FlyingGroupVC *groupVC =  [[FlyingGroupVC alloc] init];
    groupVC.groupData = groupUpData.groupData;
    
    //公开群组直接进入
    if (groupUpData.groupData.is_public_access)
    {
        [self.navigationController pushViewController:groupVC animated:YES];
    }
    else
    {
        [FlyingGroupVC doMemberRightInVC:self
                                 GroupID:groupUpData.groupData.gp_id
                              Completion:^(FlyingUserRightData *userRightData) {
                                  //
                                  [self.navigationController pushViewController:groupVC animated:YES];
                              }];
    }
}

@end
