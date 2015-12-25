//
//  FlyingProviderListVC.m
//  FlyingEnglish
//
//  Created by vincent on 1/19/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingProviderListVC.h"
#import "FlyingProvider.h"
#import "FlyingProviderViewCell.h"
#import "NSString+FlyingExtention.h"
#import "FlyingproviderParser.h"
#import "FlyingSoundPlayer.h"
#import "shareDefine.h"
#import "FlyingLoadingView.h"
#import "UIView+Autosizing.h"
#import "iFlyingAppDelegate.h"
#import "SIAlertView.h"
#import <AFNetworking.h>
#import "RESideMenu.h"
#import "SDImageCache.h"
#import "UIImage+localFile.h"
#import "FlyingWebViewController.h"
#import "FlyingScanViewController.h"
#import "FlyingProviderMapVC.h"
#import "INTULocationManager.h"
#include "china_shift.h"
#import "FlyingSetDefault.h"
#import "UICKeyChainStore.h"
#import "UIView+Toast.h"
#import "FlyingHttpTool.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"

#import "FlyingDiscoverContent.h"
#import "FlyingMyGroupsVC.h"

#import "FlyingNavigationController.h"
#import "FlyingGroupVC.h"
#import "FlyingConversationListVC.h"

@interface FlyingProviderListVC ()
{
    FlyingProviderParser  *_parser;
    NSInteger            _maxNumOfproviders;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
    UIRefreshControl    *_refreshControl;
    
    MBProgressHUD* hud;
}

@end

@implementation FlyingProviderListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addBackFunction];
    
    //更新欢迎语言
    self.title=@"请选择服务商";
    
    //顶部导航
    UIButton* mapButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [mapButton setBackgroundImage:[UIImage imageNamed:@"Map"] forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(doMap) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* mapBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:mapButton];
    
    self.navigationItem.rightBarButtonItem = mapBarButtonItem;

    [self loadData];
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

- (void)refreshNow:(UIRefreshControl *)refreshControl
{
    
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        _refresh=YES;
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新中..."];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self loadData];
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
-(void) loadData
{
    if (!self.providerCollectView)
    {
        self.providerCollectView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
        if (INTERFACE_IS_PAD )
        {
            self.providerCollectView.numColsPortrait  = 4;
            self.providerCollectView.numColsLandscape = 6;
            
        } else
        {
            self.providerCollectView.numColsPortrait  = 2;
            self.providerCollectView.numColsLandscape = 4;
        }
        
        //self.providerCollectView.delegate = self; // This is for UIScrollViewDelegate
        self.providerCollectView.collectionViewDelegate = self;
        self.providerCollectView.collectionViewDataSource = self;
        self.providerCollectView.backgroundColor = [UIColor clearColor];
        self.providerCollectView.autoresizingMask = ~UIViewAutoresizingNone;
        
        //Add a Head view
        CGRect headRect  = CGRectMake(0, 0, self.view.frame.size.width, 44);
        FlyingSetDefault* headView = [[FlyingSetDefault alloc] initWithFrame:headRect];
        self.providerCollectView.headerView = headView;
        
        //Add a footer view
        CGRect loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, 40);
        FlyingLoadingView* loadingView = [[FlyingLoadingView alloc] initWithFrame:loadingRect];
        loadingView.loadingViewDelegate=self;
        self.providerCollectView.footerView = loadingView;
        
        [self.view addSubview:self.providerCollectView];
        
        self.currentData = [NSMutableArray new];
        _currentLodingIndex=0;
        _maxNumOfproviders=NSIntegerMax;
        
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshNow:) forControlEvents:UIControlEventValueChanged];
        [self.providerCollectView addSubview:_refreshControl];
    }
    else
    {
        [(FlyingLoadingView*)self.providerCollectView.footerView showTitle:nil];
        
        [self.currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfproviders=NSIntegerMax;
    }
    
    if (!self.myLocation) {
        
        if (!hud) {
            
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"努力定位中...";
        }

        
        [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                                                         timeout:2.0
                                                            delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                                                           block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                                               
                                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                   [hud hide:YES];
                                                                               });

                                                                               
                                                                               if (status == INTULocationStatusSuccess ||
                                                                                   status == INTULocationStatusTimedOut)
                                                                               {
                                                                                   // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                                                   // currentLocation contains the device's current location.
                                                                                   
                                                                                   Location gc={currentLocation.coordinate.longitude,currentLocation.coordinate.latitude};
                                                                                   
                                                                                   Location normal= transformFromWGSToGCJ(gc);
                                                                                   
                                                                                   self.myLocation=[[CLLocation alloc] initWithLatitude:normal.lat longitude:normal.lng];
                                                                                   
                                                                                   [self downloadMore];
                                                                               }
                                                                               else
                                                                               {
                                                                                   // An error occurred, more info is available by looking at the specific status returned.
                                                                                   [self.view makeToast:@"获取地址位置失败"];
                                                                               }
                                                                           }];
    }
    else
    {
        [self downloadMore];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && ([self.view window] == nil) ) {
        self.view = nil;
        [self my_viewDidUnload];
    }
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{
    
    [self setProviderCollectView:nil];
    [self.currentData removeAllObjects];
    self.currentData=nil;
}

//////////////////////////////////////////////////////////////
#pragma mark PSCollection
//////////////////////////////////////////////////////////////

- (void)didSelectFeatureView:(PSCollectionView *)collectionView;
{
    FlyingGroupVC *groupVC = [FlyingGroupVC new];
    //groupVC.groupData=groupData;
    
    [self.navigationController pushViewController:groupVC animated:YES];
}

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return [_currentData count];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    
    if (_currentData.count==0) {
        
        //[self.helpLabel  showTip:@"没有内容" dismissAfterDelay:3];
        return nil;
    }
    
    FlyingProviderViewCell *v = (FlyingProviderViewCell *)[self.providerCollectView dequeueReusableViewForClass:[FlyingProviderViewCell class]];
    if (!v) {
        v = [[FlyingProviderViewCell alloc] initWithFrame:CGRectZero];
    }
    
    [v collectionView:self.providerCollectView fillCellWithObject:[_currentData objectAtIndex:index] atIndex:index];
    
    [v setLittleShadow];
    
    return v;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    FlyingProvider* provider = [_currentData objectAtIndex:index];
    return  [FlyingProviderViewCell  rowHeightForObject:provider inColumnWidth:self.providerCollectView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    if (_currentData.count!=0) {
        
        FlyingProvider* providerData = [_currentData objectAtIndex:index];
        
        if(![providerData.providerType isEqualToString:KLessonOwnerTempKind]){
        
            NSString *title = @"提示信息";
            NSString *message = [NSString stringWithFormat:@"你确认选择%@?",providerData.providerName];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
            [alertView addButtonWithTitle:@"取消"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                  }];
            
            [alertView addButtonWithTitle:@"确认"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      
                                      //[UICKeyChainStore keyChainStore][KLessonOwner] = providerData.providerID;
                                      //[UICKeyChainStore keyChainStore][KLessonOwnerNickname] = providerData.providerName;
                                      
#ifdef __CLIENT__GROUP__VERSION
                                      FlyingMyGroupsVC  * homeVC = [[FlyingMyGroupsVC alloc] init];
#else
                                      FlyingDiscoverContent * homeVC = [[FlyingDiscoverContent alloc] init];
#endif
                                      
                                      //groupVC.groupData=groupData;
                                      
                                      [self.navigationController pushViewController:homeVC animated:YES];
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView show];
        }
        else
        {
            NSString *title = @"提示信息";
            NSString *message = [NSString stringWithFormat:@"%@还没有入驻...",providerData.providerName];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
            [alertView addButtonWithTitle:@"确认"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView show];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////

- (void)downloadMore
{
    if (_currentData.count<_maxNumOfproviders)
    {
        _currentLodingIndex++;
        
        NSNumber *latitude = [NSNumber numberWithDouble:self.myLocation.coordinate.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:self.myLocation.coordinate.longitude];
        
        [FlyingHttpTool getProviderListForlatitude:[latitude stringValue]
                                         longitude:[longitude stringValue]
                                        PageNumber:_currentLodingIndex
                                        Completion:^(NSArray *providerList,NSInteger allRecordCount) {
                                            
                                            _maxNumOfproviders=allRecordCount;

                                            
                                            [self.currentData addObjectsFromArray:providerList];
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
        [self.providerCollectView reloadData];
    }
    else
    {
        [self.view makeToast:@"请联网后再试一下!" duration:3 position:CSToastPositionCenter];
    }
    
    //处理footview
    if (_currentData.count>=_maxNumOfproviders) {
        
        FlyingLoadingView * loadingView= (FlyingLoadingView*)self.providerCollectView.footerView;
        if (loadingView)
        {
            [loadingView showTitle:@"点击右上角搜索更多内容！"];
        }
    }
    else
    {
        FlyingLoadingView * loadingView= (FlyingLoadingView*)self.providerCollectView.footerView;
        if (loadingView)
        {
            [loadingView showTitle:@"加载更多内容"];
        }
    }
}

- (void)handleError:(NSError *)error
{
    
    //[self.helpLabel  showTip:@"不能显示课程目录" dismissAfterDelay:3];
}
//////////////////////////////////////////////////////////////
#pragma only portart events
//////////////////////////////////////////////////////////////
-(void) dismiss
{
    FlyingNavigationController *navigationController =(FlyingNavigationController *)[[self sideMenuViewController] contentViewController];
    
    if (navigationController.viewControllers.count==1) {
        
#ifdef __CLIENT__GROUP__VERSION
        FlyingMyGroupsVC  * homeVC = [[FlyingMyGroupsVC alloc] init];
#else
        FlyingDiscoverContent * homeVC = [[FlyingDiscoverContent alloc] init];
#endif
        
        [[self sideMenuViewController] setContentViewController:[[UINavigationController alloc] initWithRootViewController:homeVC]
                                                       animated:YES];
        [[self sideMenuViewController] hideMenuViewController];
    }
    else
    {
        if ([self.navigationController.viewControllers count]==1) {
            
            [self showMenu];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
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
        [self.view makeToast:@"保存二维码失败，再试试了：）"];
        
        return;
    }

    FlyingConversationListVC  * chatList=[[FlyingConversationListVC alloc] init];
    [self.navigationController pushViewController:chatList animated:YES];
}

- (void) doMap
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingProviderMapVC * map=[storyboard instantiateViewControllerWithIdentifier:@"map"];
    [self presentViewController:map animated:YES completion:nil];
    
    [map returnSelectBlock:^(BOOL reselect) {
        //
        if (reselect) {
            
#ifdef __CLIENT__GROUP__VERSION
            FlyingMyGroupsVC  * homeVC = [[FlyingMyGroupsVC alloc] init];
#else
            FlyingDiscoverContent * homeVC = [[FlyingDiscoverContent alloc] init];
#endif
            
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:homeVC]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
        }
    }];
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
    
    //如果是从地图返回
    if (self.disclosureBlock) self.disclosureBlock();
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
