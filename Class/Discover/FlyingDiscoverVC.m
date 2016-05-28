//
//  FlyingDiscoverContent.m
//  FlyingEnglish
//
//  Created by vincent on 9/5/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//
#import "FlyingDiscoverVC.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "FlyingLessonParser.h"
#import "FlyingContentListVC.h"
#import "FlyingPubLessonData.h"
#import <UIImageView+AFNetworking.h>
#import "FlyingLoadingView.h"
#import "FlyingConversationListVC.h"
#import "FlyingSearchViewController.h"
#import "FlyingContentVC.h"
#import "iFlyingAppDelegate.h"
#import "UIView+Autosizing.h"
#import "FlyingCoverView.h"
#import "FlyingCoverData.h"
#import "FlyingCoverViewCell.h"
#import "UICKeyChainStore.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHttpTool.h"
#import "FlyingHttpTool.h"

#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"
#import "FlyingConversationVC.h"
#import "FlyingSoundPlayer.h"
#import <CRToast.h>


@interface FlyingDiscoverVC ()<UIViewControllerRestoration>

{
    NSInteger            _maxNumOfTags;
    NSInteger            _currentLodingIndex;
}

@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@property (atomic,assign)    BOOL refresh;

@end

@implementation FlyingDiscoverVC

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
    
    if (self.domainID)
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
    
    _refresh=NO;
        
    self.title=@"推荐";
    
    //顶部导航
    UIButton* searchButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    
    if (!self.homeFeatureTagPSColeectionView)
    {
        self.homeFeatureTagPSColeectionView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.homeFeatureTagPSColeectionView.isHomeView=YES;
        
        if (INTERFACE_IS_PAD )
        {
            self.homeFeatureTagPSColeectionView.numColsPortrait  = 4;
            self.homeFeatureTagPSColeectionView.numColsLandscape = 6;
            
        } else
        {
            self.homeFeatureTagPSColeectionView.numColsPortrait  = 2;
            self.homeFeatureTagPSColeectionView.numColsLandscape = 4;
        }
        
        //self.homeFeatureTagPSColeectionView.delegate = self; // This is for UIScrollViewDelegate
        self.homeFeatureTagPSColeectionView.collectionViewDelegate = self;
        self.homeFeatureTagPSColeectionView.collectionViewDataSource = self;
        self.homeFeatureTagPSColeectionView.backgroundColor = [UIColor clearColor];
        self.homeFeatureTagPSColeectionView.autoresizingMask = ~UIViewAutoresizingNone;
        
        //Add cover view
        if(self.shoudLoaingFeature)
        {
            CGRect  featureRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*210/320);
            FlyingCoverView* coverFlow = [[FlyingCoverView alloc] initWithFrame:featureRect];
            [coverFlow setDomainID:self.domainID];
            [coverFlow setDomainType:self.domainType];
            [coverFlow setCoverViewDelegate:self];
            [coverFlow loadData];
            self.homeFeatureTagPSColeectionView.headerView =coverFlow;
        }
        
        //Add a footer view
        CGRect loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*30/320);
        FlyingLoadingView* loadingView = [[FlyingLoadingView alloc] initWithFrame:loadingRect];
        loadingView.loadingViewDelegate=self;
        self.homeFeatureTagPSColeectionView.footerView = loadingView;
        
        [self.view addSubview:self.homeFeatureTagPSColeectionView];
        
        _currentData = [NSMutableArray new];
        _currentLodingIndex=0;
        _maxNumOfTags=NSIntegerMax;
    }
    else
    {
        [(FlyingCoverView*)self.homeFeatureTagPSColeectionView.headerView loadData];
        [(FlyingLoadingView*)self.homeFeatureTagPSColeectionView.footerView showTitle:nil];
    }
    [self setupRefreshControl];
    
    if (self.domainID)
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

- (void) doSearch
{
    FlyingSearchViewController * search=[[FlyingSearchViewController alloc] init];
    
    search.domainID = self.domainID;
    search.domainType = self.domainType;
    
    [search setSearchType:BC_Search_Lesson];
    [self.navigationController pushViewController:search animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma  Data related
//////////////////////////////////////////////////////////////
-(void) reloadAll
{
    [_currentData removeAllObjects];
    _currentLodingIndex=0;
    _maxNumOfTags=NSIntegerMax;
    
    [self downloadMore];
}

# pragma mark - YALSunyRefreshControl methods

-(void)setupRefreshControl
{
    _refresh = NO;
    self.sunnyRefreshControl = [YALSunnyRefreshControl new];
    self.sunnyRefreshControl.delegate = self;
    [self.sunnyRefreshControl attachToScrollView:self.homeFeatureTagPSColeectionView];
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

- (BOOL)downloadMore
{
    if (_currentData.count<_maxNumOfTags)
    {
        _currentLodingIndex++;
                
        [FlyingHttpTool getAlbumListForDomainID:self.domainID
                                     DomainType:self.domainType
                                    ContentType:nil
                                     PageNumber:_currentLodingIndex
                                      Recommend:BC_onlyRecommend
                                     Completion:^(NSArray *albumList,NSInteger allRecordCount) {
                                         [self.currentData addObjectsFromArray:albumList];
                                         
                                         _maxNumOfTags=allRecordCount;
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self finishLoadingData];
                                         });
                                     }];
        
        return true;
    }
    else{
        
        return false;
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
    if (_currentData.count==0)
    {
        //即时反馈
        NSString * message = NSLocalizedString(@"还没有推荐内容哦...", nil);
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeToast:message];
    }
    else
    {
        [self.homeFeatureTagPSColeectionView reloadData];
    }
    
    //处理footview
    if (_currentData.count>=_maxNumOfTags) {
        
        FlyingLoadingView * loadingView= (FlyingLoadingView*)self.homeFeatureTagPSColeectionView.footerView;
        if (loadingView)
        {
            [loadingView showTitle:@"点击右上角搜索更多内容!"];
        }
    }
    else
    {
        FlyingLoadingView * loadingView= (FlyingLoadingView*)self.homeFeatureTagPSColeectionView.footerView;
        
        if(_currentData.count==0)
        {
            if (loadingView)
            {
                [loadingView showTitle:@"没有更多内容！"];
            }
        }
        else
        {
            if (loadingView)
            {
                [loadingView showTitle:@"加载更多内容"];
            }
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark PSCollection
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return [_currentData count];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    if (_currentData.count==0) {
        
        //[self.messegerLabel  setText:@"没有内容"];
        return nil;
    }
    
    FlyingCoverViewCell *v = (FlyingCoverViewCell *)[self.homeFeatureTagPSColeectionView dequeueReusableViewForClass:[FlyingCoverViewCell class]];
    if (!v) {
        v = [[FlyingCoverViewCell alloc] initWithFrame:CGRectZero];
    }
    
    [v collectionView:self.homeFeatureTagPSColeectionView fillCellWithObject:[_currentData objectAtIndex:index] atIndex:index];
    
    [v setMiniShadow];
    
    return v;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    FlyingCoverData* coverData = [_currentData objectAtIndex:index];
    return  [FlyingCoverViewCell  rowHeightForObject:coverData inColumnWidth:self.homeFeatureTagPSColeectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    if (_currentData.count!=0) {
        
        FlyingCoverData* coverData = [_currentData objectAtIndex:index];
        
        FlyingContentListVC * list=[[FlyingContentListVC alloc] init];
        [list setTagString:coverData.tagString];
        [list setContentType:coverData.tagtype];
        
        [list setDomainID:self.domainID];
        [list setDomainType:self.domainType];
        
        [self.navigationController pushViewController:list animated:YES];
    }
}

//////////////////////////////////////////////////////////////
#pragma FlyingCoverViewDelegate Related
//////////////////////////////////////////////////////////////
- (void) touchCover:(FlyingPubLessonData*)lessonPubData
{
    FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
    [contentVC setThePubLesson:lessonPubData];
    
    [self pushViewController:contentVC animated:YES];
}

- (void) showFeatureContent
{
    FlyingContentListVC *contentList = [[FlyingContentListVC alloc] init];
    [contentList setRecommend:BC_onlyRecommend];
    [contentList setNoTagWork:YES];
    
    [contentList setDomainID:self.domainID];
    [contentList setDomainType:self.domainType];
    [self pushViewController:contentList animated:YES];
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL) animated
{
    [self.navigationController pushViewController:viewController animated:animated];
}

@end
