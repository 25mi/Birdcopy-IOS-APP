//
//  FlyingDiscoverContent.m
//  FlyingEnglish
//
//  Created by vincent on 9/5/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//
#import "FlyingDiscoverContent.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "FlyingLessonParser.h"
#import "SIAlertView.h"
#import "FlyingLessonListViewController.h"
#import "FlyingPubLessonData.h"
#import "UIImageView+WebCache.h"
#import "FlyingWebViewController.h"
#import "FlyingLoadingView.h"
#import "RCDChatListViewController.h"
#import "FlyingSearchViewController.h"
#import "FlyingLessonVC.h"
#import "iFlyingAppDelegate.h"
#import "UIView+Autosizing.h"
#import "FlyingCoverView.h"
#import "FlyingCoverData.h"
#import "FlyingCoverViewCell.h"
#import "UICKeyChainStore.h"
#import <AFNetworking/AFNetworking.h>
#import "UIView+Toast.h"
#import "AFHttpTool.h"
#import "FlyingHttpTool.h"

#import "UIViewController+RESideMenu.h"


@interface FlyingDiscoverContent ()

{
    NSInteger            _maxNumOfTags;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
    UIRefreshControl    *_refreshControl;
}

@end

@implementation FlyingDiscoverContent

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBackFunction];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    _refresh=NO;
        
    self.title=@"发现";
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
#ifdef __CLIENT__IS__ENGLISH__
    
    image= [UIImage imageNamed:@"back"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem,menuBarButtonItem,nil];
    
#else

    self.navigationItem.leftBarButtonItem = menuBarButtonItem;
    
#endif

    image= [UIImage imageNamed:@"search"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    
    [self reloadAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//////////////////////////////////////////////////////////////
#pragma  Data related
//////////////////////////////////////////////////////////////
-(void) reloadAll
{
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
        CGRect  loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*210/320);
        FlyingCoverView* coverFlow = [[FlyingCoverView alloc] initWithFrame:loadingRect];
        [coverFlow setCoverViewDelegate:self];
        [coverFlow loadData];
        self.homeFeatureTagPSColeectionView.headerView =coverFlow;
        
        //Add a footer view
        loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*30/320);
        FlyingLoadingView* loadingView = [[FlyingLoadingView alloc] initWithFrame:loadingRect];
        loadingView.loadingViewDelegate=self;
        self.homeFeatureTagPSColeectionView.footerView = loadingView;
        
        [self.view addSubview:self.homeFeatureTagPSColeectionView];
        
        _currentData = [NSMutableArray new];
        _currentLodingIndex=0;
        _maxNumOfTags=NSIntegerMax;
        
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshNow:) forControlEvents:UIControlEventValueChanged];
        [self.homeFeatureTagPSColeectionView addSubview:_refreshControl];
    }
    else
    {
        [(FlyingCoverView*)self.homeFeatureTagPSColeectionView.headerView loadData];
        [(FlyingLoadingView*)self.homeFeatureTagPSColeectionView.footerView showTitle:nil];
        
        [_currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfTags=NSIntegerMax;
    }
    
    [self downloadMore];
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

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////

- (BOOL)downloadMore
{
    if (_currentData.count<_maxNumOfTags)
    {
        _currentLodingIndex++;
        
        [FlyingHttpTool getAlbumListForAuthor:self.author
                                  ContentType:nil
                                   PageNumber:_currentLodingIndex
                                    Recommend:YES
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *lastUpdate = [NSString stringWithFormat:@"刷新时间：%@", [formatter stringFromDate:[NSDate date]]];
        
        _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
        
        [_refreshControl endRefreshing];
        _refresh=NO;
    }
    
    //更新界面
    if (_currentData.count!=0)
    {
        [self.homeFeatureTagPSColeectionView reloadData];
    }
    else
    {
        [self.view makeToast:@"请联网后再试一下!" duration:3 position:CSToastPositionCenter];
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
        
        FlyingLessonListViewController * list=[[FlyingLessonListViewController alloc] init];
        [list setTagString:coverData.tagString];
        [list setContentType:coverData.tagtype];
        
        [self.navigationController pushViewController:list animated:YES];
    }
}

//////////////////////////////////////////////////////////////
#pragma FlyingCoverViewDelegate Related
//////////////////////////////////////////////////////////////
- (void) touchCover:(FlyingPubLessonData*)lessonData
{
    FlyingLessonVC *lessonPage = [[FlyingLessonVC alloc] init];
    [lessonPage setTheLesson:lessonData];
    
    [self pushViewController:lessonPage animated:YES];
}

- (void) showFeatureContent
{
    FlyingLessonListViewController *lessonList = [[FlyingLessonListViewController alloc] init];
    [lessonList setSortByTime:YES];
    [lessonList setRecommoned:YES];
    [lessonList setTagString:@"精彩内容推荐"];
    [self pushViewController:lessonList animated:YES];
}

- (NSString*) getAuthor
{
    return self.author;
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL) animated
{
    [self.navigationController pushViewController:viewController animated:animated];
}
//////////////////////////////////////////////////////////////
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

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

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
    [search setSearchType:BEFindLesson];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

@end
