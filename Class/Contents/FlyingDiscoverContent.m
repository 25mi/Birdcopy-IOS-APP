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
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _refresh=NO;
    
    NSString * lessonOwnerNickname = [UICKeyChainStore keyChainStore][KLessonOwnerNickname];
    
    if(!lessonOwnerNickname)
    {
        lessonOwnerNickname=@"发现";
    }
    
    self.title=lessonOwnerNickname;
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.leftBarButtonItem = menuBarButtonItem;
    
    [self reloadAll];
    
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
        self.homeFeatureTagPSColeectionView.headerView =coverFlow;
        
        //Add a footer view
        loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width*30/320);
        FlyingLoadingView* loadingView = [[FlyingLoadingView alloc] initWithFrame:loadingRect];
        loadingView.loadingViewDelegate=self;
        self.homeFeatureTagPSColeectionView.footerView = loadingView;
        
        [self.view addSubview:self.homeFeatureTagPSColeectionView];
        
        _currentTagData = [NSMutableArray new];
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
        
        [_currentTagData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfTags=NSIntegerMax;
    }
    
    [self downloadMore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//////////////////////////////////////////////////////////////
#pragma cover Related
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

//////////////////////////////////////////////////////////////
#pragma mark PSCollection
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return [_currentTagData count];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    if (_currentTagData.count==0) {
        
        //[self.messegerLabel  setText:@"没有内容"];
        return nil;
    }
    
    FlyingCoverViewCell *v = (FlyingCoverViewCell *)[self.homeFeatureTagPSColeectionView dequeueReusableViewForClass:[FlyingCoverViewCell class]];
    if (!v) {
        v = [[FlyingCoverViewCell alloc] initWithFrame:CGRectZero];
    }
    
    [v collectionView:self.homeFeatureTagPSColeectionView fillCellWithObject:[_currentTagData objectAtIndex:index] atIndex:index];
    
    [v setMiniShadow];
    
    return v;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    FlyingCoverData* coverData = [_currentTagData objectAtIndex:index];
    return  [FlyingCoverViewCell  rowHeightForObject:coverData inColumnWidth:self.homeFeatureTagPSColeectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    if (_currentTagData.count!=0) {
        
        FlyingCoverData* coverData = [_currentTagData objectAtIndex:index];
        
        FlyingLessonListViewController * list=[[FlyingLessonListViewController alloc] init];
        [list setTagString:coverData.tagString];
        [list setContentType:coverData.tagtype];
        
        [self.navigationController pushViewController:list animated:YES];
    }
}
//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////

- (BOOL)downloadMore
{
    if (_currentTagData.count<_maxNumOfTags)
    {
        _currentLodingIndex++;
        
        [FlyingHttpTool getAlbumListForContentType:nil
                                        PageNumber:_currentLodingIndex
                                         Recommend:YES
                                        Completion:^(NSArray *albumList,NSInteger allRecordCount) {
                                            [self.currentTagData addObjectsFromArray:albumList];
                                            
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
    if (_currentTagData.count!=0)
    {
        [self.homeFeatureTagPSColeectionView reloadData];
    }
    else
    {
        [self.view makeToast:@"请联网后再试一下!" duration:3 position:CSToastPositionCenter];
    }
    
    //处理footview
    if (_currentTagData.count>=_maxNumOfTags) {
        
        FlyingLoadingView * loadingView= (FlyingLoadingView*)self.homeFeatureTagPSColeectionView.footerView;
        if (loadingView)
        {
            [loadingView showTitle:@"点击右上角搜索更多内容!"];
        }
    }
    else
    {
        FlyingLoadingView * loadingView= (FlyingLoadingView*)self.homeFeatureTagPSColeectionView.footerView;
        
        if(_currentTagData.count==0)
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
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void) showWebLesson:(NSString*) webURL
{
    if (webURL) {
        
        NSString * lessonID = [NSString getLessonIDFromOfficalURL:webURL];
        
        if (lessonID) {
            
            [self jumptoLessonforID:lessonID];
            
        }
        else{
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
            [webpage setWebURL:webURL];
            
            [self pushViewController:webpage animated:YES];
        }
    }
}

- (BOOL) jumptoLessonforID:(NSString *) lessonID
{
    [FlyingHttpTool getLessonForLessonID:lessonID
                              Completion:^(FlyingPubLessonData *lesson) {
                                  //
                                  if (lesson) {
                                      
                                      FlyingLessonVC * vc= [[FlyingLessonVC alloc] init];
                                      vc.theLesson=lesson;
                                      [self pushViewController:vc animated:YES];
                                  }
                              }];
    
    return YES;
}

- (BOOL) jumptoLessonforISBN:(NSString *) ISBN
{
    [FlyingHttpTool getLessonForISBN:ISBN
                          Completion:^(FlyingPubLessonData *lesson) {
                              //
                              if (lesson) {
                                  
                                  FlyingLessonVC * vc= [[FlyingLessonVC alloc] init];
                                  vc.theLesson=lesson;
                                  [self pushViewController:vc animated:YES];
                              }
                          }];
    
    return YES;
}


- (void) pushViewController:(UIViewController *)viewController animated:(BOOL) animated
{
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void) showCodeLesson:(NSString*) code
{
    if(code){
        
        [self jumptoLessonforISBN:code];
    }
}

@end
