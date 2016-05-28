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
#import "FlyingGroupUpdateCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FlyingGroupUpdateData.h"
#import "FlyingDataManager.h"
#import "YALSunnyRefreshControl.h"
#import "FlyingLoadingCell.h"

@interface FlyingMyGroupsVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfGroups;
    NSInteger            _currentLodingIndex;
}

@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@property (strong, nonatomic) FlyingLoadingCell *loadingMoreIndicatorCell;

@property (atomic,assign)    BOOL refresh;

@end

@implementation FlyingMyGroupsVC

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.myGroupsVC) {
        
        appDelegate.myGroupsVC = [self new];
    }
    
    return appDelegate.myGroupsVC;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (!CGRectEqualToRect(self.groupTableView.frame,CGRectZero))
    {
        [coder encodeCGRect:self.groupTableView.frame forKey:@"self.groupTableView.frame"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    CGRect frame = [coder decodeCGRectForKey:@"self.groupTableView.frame"];
    if (!CGRectEqualToRect(frame,CGRectZero))
    {
        self.groupTableView.frame = frame;
    }
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        self.hidesBottomBarWhenPushed = NO;
        
        self.domainID = [FlyingDataManager getAppData].appID;
        self.domainType = BC_Domain_Business;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //标题
    self.title = NSLocalizedString(@"Group",nil);
    
    if (!self.groupTableView)
    {
        self.groupTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-64) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        UINib *nib = [UINib nibWithNibName:@"FlyingGroupUpdateCell" bundle: nil];
        [self.groupTableView registerNib:nib  forCellReuseIdentifier:@"FlyingGroupUpdateCell"];
        
        [self.groupTableView registerNib:[UINib nibWithNibName:@"FlyingLoadingCell" bundle: nil]
                  forCellReuseIdentifier:@"FlyingLoadingCell"];
        
        self.groupTableView.delegate = self;
        self.groupTableView.dataSource = self;
        self.groupTableView.backgroundColor = [UIColor clearColor];
        
        self.groupTableView.restorationIdentifier = self.restorationIdentifier;
        
        NSInteger bottom = [[NSUserDefaults standardUserDefaults] integerForKey:KTabBarHeight];
        self.groupTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.groupTableView.frame.size.width, bottom)];
        
        [self.view addSubview:self.groupTableView];
        
        _currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
    }
    
    [self setupRefreshControl];
    
    //顶部导航
    if (self.domainID)
    {
        [self reloadAll];
    }
}

- (void) willDismiss
{
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
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    [_currentData removeAllObjects];
    _currentLodingIndex=0;
    _maxNumOfGroups=NSIntegerMax;

    [self loadMore];
}

- (void) loadMore
{
     if (_currentData.count<_maxNumOfGroups)
     {
         _currentLodingIndex++;
         
         [FlyingHttpTool getMyGroupsForPageNumber:_currentLodingIndex
                                       Completion:^(NSArray *groupUpdateList, NSInteger allRecordCount) {
                                           //
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
    [self endAnimationHandle];
    
    //更新界面
    if (_currentData.count>0)
    {
        [self.groupTableView reloadData];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; // 增加一个加载更多
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.currentData count];
    }
    else
    {
        // 加载更多
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;

    if (indexPath.section == 0)
    {
        // 普通Cell
        FlyingGroupUpdateCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FlyingGroupUpdateCell"];
        
        if (!cell) {
            
            cell = [FlyingGroupUpdateCell groupCell];
        }
        
        [self configureCell:cell atIndexPath:indexPath];

        return cell;
    }
    else
    {
        FlyingLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingLoadingCell"];
        
        if(loadingCell == nil)
            loadingCell = [FlyingLoadingCell loadingCell];
        
        cell = loadingCell;
        self.loadingMoreIndicatorCell=loadingCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 普通Cell的高度
        return [tableView fd_heightForCellWithIdentifier:@"FlyingGroupUpdateCell"
                                        cacheByIndexPath:indexPath
                                           configuration:^(id cell) {
    
            [self configureCell:cell atIndexPath:indexPath];
        }];
    
    }
    else
    {
        return [tableView fd_heightForCellWithIdentifier:@"FlyingLoadingCell"
                                        cacheByIndexPath:indexPath
                                           configuration:^(FlyingLoadingCell *cell) {
                                               //[self configureCell:cell atIndexPath:indexPath];
                                           }];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<self.currentData.count)
    {
        FlyingGroupUpdateData *updateData = self.currentData[indexPath.row];
        [(FlyingGroupUpdateCell*)cell settingWithGroupData:updateData];
    }
}
//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (_currentData.count>0&&
            _currentData.count<_maxNumOfGroups)
        {
            // 加载更多
            [self.loadingMoreIndicatorCell startAnimating:@"尝试加载更多..."];
            
            // 加载下一页
            [self loadMore];
        }
        else
        {
            [self.loadingMoreIndicatorCell stopAnimating:@"加入更多群组..."];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
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
    else if (indexPath.section == 1)
    {
        [self.tabBarController setSelectedIndex:0];
    }
}

@end
