//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingContentListVC.h"
#import "FlyingHttpTool.h"
#import "FlyingConversationListVC.h"
#import "FlyingConversationVC.h"
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
#import "FlyingContentCell.h"
#import "FlyingPubLessonData.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FlyingSearchViewController.h"
#import "FlyingWebViewController.h"
#import "FlyingLoadingCell.h"

@interface FlyingContentListVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfContents;
    NSInteger            _currentLodingIndex;
}
@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@property (strong, nonatomic) FlyingLoadingCell *loadingMoreIndicatorCell;

@property (atomic,assign)    BOOL refresh;

@end

@implementation FlyingContentListVC

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (![self.tagString isBlankString])
    {
        [coder encodeObject:self.tagString forKey:@"self.tagString"];
    }
    
    [coder encodeBool:self.NoTagWork forKey:@"self.NoTagWork"];
    
    if (![self.contentType isBlankString])
    {
        [coder encodeObject:self.contentType forKey:@"self.contentType"];
    }

    if (![self.downloadType isBlankString])
    {
        [coder encodeObject:self.downloadType forKey:@"self.downloadType"];
    }
    
    if (![self.recommend isBlankString])
    {
        [coder encodeObject:self.recommend forKey:@"self.recommend"];
    }
    
    if (![self.title isBlankString])
    {
        [coder encodeObject:self.title forKey:@"self.title"];
    }
    
    if (!CGRectEqualToRect(self.contentTableView.frame,CGRectZero))
    {
        [coder encodeCGRect:self.contentTableView.frame forKey:@"self.contentTableView.frame"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    
    NSString * tagString =  [coder decodeObjectForKey:@"self.tagString"];
    if (![tagString isBlankString])
    {
        self.tagString = tagString;
    }
    self.NoTagWork = [coder decodeBoolForKey:@"self.NoTagWork"];
    
    NSString * contentType = [coder decodeObjectForKey:@"self.contentType"];
    if (![contentType isBlankString])
    {
        self.contentType = contentType;
    }
    
    NSString * downloadType = [coder decodeObjectForKey:@"self.downloadType"];
    if (![downloadType isBlankString])
    {
        self.downloadType = downloadType;
    }
    
    NSString *recommend  = [coder decodeObjectForKey:@"self.recommend"];
    if (![recommend isBlankString])
    {
        self.recommend = recommend;
    }
    
    NSString * title = [coder decodeObjectForKey:@"self.title"];
    if (![title isBlankString])
    {
        self.title = title;
    }
    
    CGRect frame = [coder decodeCGRectForKey:@"self.contentTableView.frame"];
    if (!CGRectEqualToRect(frame,CGRectZero))
    {
        self.contentTableView.frame = frame;
    }
    
    if (self.tagString ||
        self.NoTagWork)
    {
        [self reloadAll];
    }
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
    
    //更新欢迎语言
    self.title =@"内容列表";
    
    //顶部右上角导航
    UIButton* searchButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    
    if (!self.contentTableView)
    {
        self.contentTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-64) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        [self.contentTableView registerNib:[UINib nibWithNibName:@"FlyingContentCell" bundle: nil]      forCellReuseIdentifier:@"FlyingContentCell"];
        
        [self.contentTableView registerNib:[UINib nibWithNibName:@"FlyingLoadingCell" bundle: nil]
                    forCellReuseIdentifier:@"FlyingLoadingCell"];
        
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
        self.contentTableView.backgroundColor = [UIColor clearColor];
        
        self.contentTableView.tableFooterView = [UIView new];
        
        self.contentTableView.restorationIdentifier = self.restorationIdentifier;
        
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_1)
        {
            self.contentTableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        
        [self.view addSubview:_contentTableView];
        
        _currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfContents=NSIntegerMax;
    }
    
    [self setupRefreshControl];
    
    if (self.tagString ||
        self.NoTagWork)
    {
        [self reloadAll];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) willDismiss
{
}

//////////////////////////////////////////////////////////////
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) doSearch
{
    FlyingSearchViewController * search=[[FlyingSearchViewController alloc] init];
    
    search.domainID = self.domainID;
    search.domainType = self.domainType;
    
    search.searchType = BC_Search_Lesson;
    
    [self.navigationController pushViewController:search animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (self.tagString) {
        
        self.title=self.tagString;
    }
    
    [_currentData removeAllObjects];
    _currentLodingIndex=0;
    _maxNumOfContents=NSIntegerMax;
    
    [self loadMore];
}

# pragma mark - YALSunyRefreshControl methods

-(void)setupRefreshControl
{
    _refresh = NO;
    
    if (!self.sunnyRefreshControl)
    {
        self.sunnyRefreshControl = [YALSunnyRefreshControl new];
        self.sunnyRefreshControl.delegate = self;
        [self.sunnyRefreshControl attachToScrollView:self.contentTableView];
    }
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
    if (_currentData.count<_maxNumOfContents)
    {
        _currentLodingIndex++;
        
        [FlyingHttpTool getLessonListForDomainID:self.domainID
                                      DomainType:self.domainType
                                      PageNumber:_currentLodingIndex
                               lessonConcentType:self.contentType
                                    DownloadType:self.downloadType
                                             Tag:self.tagString
                                       Recommend:self.recommend
                                      Completion:^(NSArray *lessonList, NSInteger allRecordCount) {
                                          //
                                          if (lessonList) {
                                              [self.currentData addObjectsFromArray:lessonList];
                                          }
                                          
                                          _maxNumOfContents=allRecordCount;
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self finishLoadingData];
                                          });
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
    if (_currentData.count>0)
    {
        [self.contentTableView reloadData];
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
        FlyingContentCell* contentCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentCell"];
        
        if (!contentCell) {
            
            contentCell = [FlyingContentCell contentCell];
        }
        
        [self configureCell:contentCell atIndexPath:indexPath];

        cell = contentCell;
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
        return [tableView fd_heightForCellWithIdentifier:@"FlyingContentCell"
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
        FlyingPubLessonData *contentData = self.currentData[indexPath.row];
        [(FlyingContentCell*)cell settingWithContentData:contentData];
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
            _currentData.count<_maxNumOfContents)
        {
            // 加载更多
            [self.loadingMoreIndicatorCell startAnimating:@"尝试加载更多..."];
            
            // 加载下一页
            [self loadMore];
        }
        else
        {
            [self.loadingMoreIndicatorCell stopAnimating:@"没有更多内容！"];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (_currentData.count!=0) {
            
            FlyingPubLessonData* lessonPubData = [_currentData objectAtIndex:indexPath.row];
            
            if ([lessonPubData.contentType isEqualToString:KContentTypePageWeb] ) {
                
                FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
                [webVC setThePubLesson:lessonPubData];
                [self.navigationController pushViewController:webVC animated:YES];
            }
            else
            {
                FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
                [contentVC setThePubLesson:lessonPubData];
                
                [self.navigationController pushViewController:contentVC animated:YES];
            }
        }
    }
}

@end
