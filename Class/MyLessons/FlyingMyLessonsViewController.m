//
//  FlyingMyLessonsViewController.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/19/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingMyLessonsViewController.h"
#import "FlyingLessonData.h"
#import "FlyingLessonDAO.h"
#import "FlyingPubLessonData.h"

#import "FlyingNowLessonDAO.h"
#import "FlyingNowLessonData.h"

#import "iFlyingAppDelegate.h"

#import "UICKeyChainStore.h"
#import "CERoundProgressView.h"
#import "FlyingLoadingView.h"
#import "FlyingMyLessonCell.h"

#import <QuartzCore/CALayer.h>
#import "AFDownloadRequestOperation.h"
#import "NSData+NSHash.h"
#import "NSString+FlyingExtention.h"

#import "SoundPlayer.h"

#import "FlyingHelpVC.h"
#import "UIView+Autosizing.h"
#import <UIKit/UIActionSheet.h>
#import "SIAlertView.h"
#import "UIImage+localFile.h"

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>

#import "FlyingM3U8Downloader.h"
#import "SSZipArchive.h"
#import "RESideMenu.h"
#import "FlyingItemParser.h"
#import "FlyingItemDao.h"
#import "FlyingLessonVC.h"

#import <ImageIO/ImageIO.h>
#import "CGPDFDocument.h"
#import "FlyingSearchViewController.h"
#import "RCDChatListViewController.h"

#import "FileHash.h"
#import "OpenUDID.h"
#import "UICKeyChainStore.h"
#import "FlyingHome.h"
#import "FlyingNavigationController.h"

#import <AFNetworking.h>
#import "UIView+Toast.h"

#import "AFHttpTool.h"

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController (privates methods)
//////////////////////////////////////////////////////////////

@interface FlyingMyLessonsViewController ()<UIViewControllerRestoration>
{
    NSMutableArray       *_dataSource;
    dispatch_source_t     _UpdateDownlonaSource;

    FlyingLessonDAO      *_lessonDAO;
    FlyingNowLessonDAO   *_nowLessonDAO;
}

@end

//////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewController implementation
//////////////////////////////////////////////////////////////

@implementation FlyingMyLessonsViewController

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *retViewController = [[FlyingMyLessonsViewController alloc] init];
    return retViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = @"FlyingMyLessonsViewController";
    self.restorationClass      = [self class];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addBackFunction];
    
    //更新欢迎语言
    self.title =@"本地内容";
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    image= [UIImage imageNamed:@"back"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem,menuBarButtonItem,nil];
    
    self.lessonsCollectView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];

    if (INTERFACE_IS_PAD ) {

        self.lessonsCollectView.numColsPortrait  = 3;
        self.lessonsCollectView.numColsLandscape = 4;
    } else {
        
        self.lessonsCollectView.numColsPortrait  = 2;
        self.lessonsCollectView.numColsLandscape = 3;
    }
    
    self.lessonsCollectView.delegate = self; // This is for UIScrollViewDelegate
    self.lessonsCollectView.collectionViewDelegate = self;
    self.lessonsCollectView.collectionViewDataSource = self;
    self.lessonsCollectView.backgroundColor = [UIColor clearColor];
    self.lessonsCollectView.autoresizingMask = ~UIViewAutoresizingNone;
    
    //Add a footer view
    CGRect  loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, 44);
    self.lessonsCollectView.footerView = [[FlyingLoadingView alloc] initWithFrame:loadingRect];
    [self.lessonsCollectView setCanBeEdit:YES];
    [self.view addSubview:self.lessonsCollectView];

    _lessonDAO =[[FlyingLessonDAO alloc] init];
    _nowLessonDAO =[[FlyingNowLessonDAO alloc] init];
    
    self.currentData= [NSMutableArray new];

    [self loadDataSource];
    [self importSomeLessons];
    
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
    //释放UI资源    
    self.lessonsCollectView = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //释放大数据资源
    [_currentData removeAllObjects];
    _currentData=nil;
    
    [_dataSource removeAllObjects];
    _dataSource=nil;
    
    _UpdateDownlonaSource=nil;

    //释放数据库资源
    _lessonDAO=nil;
    _nowLessonDAO=nil;
}

//////////////////////////////////////////////////////////////
#pragma mark Update methods
//////////////////////////////////////////////////////////////

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadAllDataNow];
    
    //监控文件夹变化
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAllDataNow)
                                                 name:KDocumentStateChange
                                               object:nil];
    //监控下载更新
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadState)
                                                 name:KlessonStateChange
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //关闭实时监控
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDocumentStateChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KlessonStateChange object:nil];
    
    [super viewWillDisappear:animated];
}

- (void) updateDownloadState
{
    
    if (!_UpdateDownlonaSource) {
        
        _UpdateDownlonaSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_event_handler(_UpdateDownlonaSource, ^{
            
            [self.lessonsCollectView setAnimationEffect:NO];
            [self.lessonsCollectView reloadData];
        });
        dispatch_resume(_UpdateDownlonaSource);
    }
    
    dispatch_source_merge_data(_UpdateDownlonaSource, 1);
}

//////////////////////////////////////////////////////////////
#pragma mark PSCollection
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return [self.currentData count];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    
    FlyingMyLessonCell *v = (FlyingMyLessonCell  *)[self.lessonsCollectView dequeueReusableViewForClass:[FlyingMyLessonCell class]];
    if (!v) {
        v = [[FlyingMyLessonCell alloc] initWithFrame:CGRectZero];
    }
    
    [v collectionView:self.lessonsCollectView fillCellWithObject:[self.currentData objectAtIndex:index] atIndex:index];
    
    [v setLittleShadow];
    
    return v;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    FlyingNowLessonData * lesson = [self.currentData objectAtIndex:index];
    return  [FlyingMyLessonCell  rowHeightForObject:lesson inColumnWidth:self.lessonsCollectView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    FlyingNowLessonData  * nowLessonData = [_currentData objectAtIndex:index];
    
    FlyingLessonData* lesson = [_lessonDAO selectWithLessonID:nowLessonData.BELESSONID];
        
    FlyingLessonVC *lessonPage = [[FlyingLessonVC alloc] init];
    [lessonPage setTheLesson:[[FlyingPubLessonData alloc] initWithLessonData:lesson]];
    
    [self.navigationController pushViewController:lessonPage animated:YES];
}

- (void)collectionView:(PSCollectionView *)collectionView didDeleteCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    FlyingNowLessonData * tobeDelete=self.currentData[index];
    
    NSString *title = @"确认";
    NSString *message = @"你真的要删除课程吗?";
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alertView addButtonWithTitle:@"点错了"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"删除"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              
                              //通知下载中心关闭相关资源，没有下载就是无意义操作
                              [self closeAndReleaseDownloaderForID:tobeDelete.BELESSONID];
                              
                              //删除显示数据
                              [self.currentData removeObjectAtIndex:index];
                              [_dataSource removeObjectAtIndex:index];
                              
                              NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];

                              //删除数据库本地纪录，资源自动释放
                              [_nowLessonDAO deleteWithUserID:passport LessonID:tobeDelete.BELESSONID];
                              
                              [self.lessonsCollectView setAnimationEffect:NO];
                              [collectionView reloadData];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    [alertView show];
}

- (void) closeAndReleaseDownloaderForID:(NSString *) lessonID
{
    iFlyingAppDelegate *delegate = (iFlyingAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate closeAndReleaseDownloaderForID:lessonID];
}
//////////////////////////////////////////////////////////////
#pragma mark - scrollView delegate
//////////////////////////////////////////////////////////////

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    CGFloat currentOffset = offset.y + bounds.size.height -inset.bottom;
    CGFloat maximumOffset = size.height;
    
    if((maximumOffset - currentOffset)<self.view.frame.size.height*2){
        [self  importSomeLessons];
    }
    else if(( currentOffset - maximumOffset)<50.0){
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
    if (sender.contentOffset.y <= 0) {
        return;
    }
    
    if (sender.contentOffset.y >= sender.contentSize.height - sender.frame.size.height) {
        return;
    }
    
    if (self.lastUpDownOffset > sender.contentOffset.y)
    {
        //预留
    }
    else if (self.lastUpDownOffset < sender.contentOffset.y){
        
        //预留
    }
    
    self.lastUpDownOffset = sender.contentOffset.y;
    
    // do whatever you need to with scrollDirection here.
}
//////////////////////////////////////////////////////////////
#pragma mark - Load data related
//////////////////////////////////////////////////////////////

- (void)importSomeLessons
{
    if (_dataSource.count==0) {
        
        self.title=@"没有本地内容";
    }
    else if (self.currentData.count<_dataSource.count) {
        
        NSInteger  loadingDefaultCount =kperpageLessonCount;
        if (INTERFACE_IS_PAD) {
            loadingDefaultCount=kperpageLessonCountPAD;
        }
        
        NSInteger startCount=self.currentData.count;
        
        
        NSInteger loadingCount= (loadingDefaultCount<(_dataSource.count-self.currentData.count))? loadingDefaultCount:(_dataSource.count-self.currentData.count);
        
        
        for (int i=0; i<loadingCount; i++) {
            
            [self.currentData addObject:_dataSource[startCount+i]];
            
        }
        
        [self.lessonsCollectView reloadData];
        
        if (self.currentData.count==_dataSource.count) {
            
            FlyingLoadingView * loadingView= (FlyingLoadingView*)self.lessonsCollectView.footerView;

            if (self.currentData.count>6) {
                
                [loadingView setHidden:NO];
                
                [loadingView showTitle:@"长按课程图标就可以选择删除!"];
            }
            else{
            
                [loadingView setHidden:YES];
            }
        }
    }
    else{
        
        FlyingLoadingView * loadingView= (FlyingLoadingView*)self.lessonsCollectView.footerView;
        
        if (self.currentData.count>6) {
            
            [loadingView setHidden:NO];
            
            [loadingView showTitle:@"长按课程图标就可以选择删除!"];
        }
        else{
            
            [loadingView setHidden:YES];
        }
    }
}

- (void) reloadAllDataNow
{
    @autoreleasepool{
        
        //重新倒入数据
        [self.currentData removeAllObjects];
        
        [self loadDataSource];
        [self importSomeLessons];
    }
}

- (void) loadDataSource
{
    
    NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];

    NSArray * tempArray =  [[_nowLessonDAO selectWithUserID:passport] mutableCopy] ;
    NSArray * sortedArray = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        NSString * fileNameA = [(FlyingLessonData *)[_lessonDAO selectWithLessonID:[(FlyingNowLessonData*)a BELESSONID]] BETITLE];
        NSString * fileNameB = [(FlyingLessonData *)[_lessonDAO selectWithLessonID:[(FlyingNowLessonData*)b BELESSONID]] BETITLE];

        return [fileNameA compare:fileNameB];
    }];
    
    _dataSource=[NSMutableArray arrayWithArray:sortedArray];
}

+ (void) updataDBForLocal
{
    
    FlyingNowLessonDAO * nowLessonDAO =[[FlyingNowLessonDAO alloc] init];
    
    NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];

    [nowLessonDAO updateDBFromLocal:passport];
    
    //得到本地课程详细信息
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    //用户目录包含的可读内容
    
    NSArray* contents = [mgr contentsOfDirectoryAtPath:path error:nil];
    
    FlyingLessonDAO * lessonDAO =[[FlyingLessonDAO alloc] init];
    
    for (NSString *fileName in contents) {
        
        @autoreleasepool {
            
            BOOL isMp3 = [NSString checkMp3URL:fileName];
            BOOL isMp4 = [NSString checkMp4URL:fileName];
            BOOL isdoc = [NSString checkDocumentURL:fileName];
            
            if(isMp4
               || [NSString checkOtherVedioURL:fileName]
               || isdoc
               || isMp3){
                
                NSString* filePath = [path stringByAppendingPathComponent:fileName];
                
                //本地文件统一这么处理，最关键是保持和官方lessonID的唯一性。
                NSString * lessonID= [FileHash md5HashOfFileAtPath:filePath];
                
                FlyingLessonData * pubLessondata =[lessonDAO   selectWithLessonID:lessonID];
                
                //如果没有相关纪录
                if (!pubLessondata)
                {
                    NSString* lessontitle =[[filePath lastPathComponent] stringByDeletingPathExtension];
    
                    NSString * localSrtPath = [lessontitle localSrtURL];
                    NSString * localCoverPath = [lessontitle localCoverURL];
                    
                    UIImage * coverImage=nil;
                    if (isMp3) {
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            coverImage = [FlyingMyLessonsViewController thumbnailImageForMp3:[NSURL fileURLWithPath:filePath]];
                            
                            if (coverImage) {
                                
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    else if(isMp4){
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            coverImage = [FlyingMyLessonsViewController thumbnailImageForVideo:[NSURL fileURLWithPath:filePath] atTime:10];
                            
                            if (coverImage) {
                                
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    else if(isdoc)
                    {
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            NSString *phrase=@"";
                            
                            if ( [NSString checkPDFURL:fileName])
                            {
                                coverImage =[FlyingMyLessonsViewController thumbnailImageForPDF:[NSURL fileURLWithPath:filePath]
                                                                                       passWord:phrase];
                            }
                            if (coverImage)
                            {
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    
                    NSString * contentType = KContentTypeVideo;
                    if(isMp3){
                        
                        contentType = KContentTypeAudio;
                    }
                    else if (isdoc) {
                        
                        contentType = KContentTypeText;
                    }
                    
                    pubLessondata =[[FlyingLessonData alloc] initWithLessonID:lessonID
                                                                   LocalTitle:lessontitle
                                                              LocalContentURL:filePath
                                                                  LocalSubURL:localSrtPath
                                                                LocalCoverURL:localCoverPath
                                                                  ContentType:contentType
                                                                 DownloadType:KDownloadTypeNormal
                                                                          Tag:nil];
                    [lessonDAO insertWithData:pubLessondata];
                    
                }
                
                NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];
                
                if (![nowLessonDAO selectWithUserID:passport LessonID:lessonID]) {
                    
                    FlyingNowLessonData * data = [[FlyingNowLessonData alloc] initWithUserID:passport
                                                                                    LessonID:lessonID
                                                                                   TimeStamp:0
                                                                                  LocalCover:pubLessondata.localURLOfCover];
                    [nowLessonDAO insertWithData:data];
                }
            }
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark 
//////////////////////////////////////////////////////////////

//LogoDone functions
- (void)dismiss
{
    FlyingNavigationController *navigationController =(FlyingNavigationController *)[[self sideMenuViewController] contentViewController];
    
    if (navigationController.viewControllers.count==1) {
        
        FlyingHome* homeVC = [[FlyingHome alloc] init];
        
        [[self sideMenuViewController] setContentViewController:[[UINavigationController alloc] initWithRootViewController:homeVC]
                                                       animated:YES];
        [[self sideMenuViewController] hideMenuViewController];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        [self.view makeToast:@"保存二维码失败，再试试了：）"];
        return;
    }
    
    RCDChatListViewController  * chatList=[[RCDChatListViewController alloc] init];
    [self.navigationController pushViewController:chatList animated:YES];
}

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
    [self.navigationController pushViewController:search animated:YES];
}
//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

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
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

-(void) handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if ((recognizer.state ==UIGestureRecognizerStateEnded) || (recognizer.state ==UIGestureRecognizerStateCancelled)) {
        
        [self dismiss];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark get data from offical website
//////////////////////////////////////////////////////////////
+ (void) getSrtForLessonID: (NSString *) lessonID
                     Title:(NSString *) title
{
    
    [AFHttpTool lessonResourceType:kResource_Sub
                          lessonID:lessonID
                        contentURL:nil
                             isURL:NO
                           success:^(id response) {
                               //
                               NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                               NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
                               
                               if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                                   
                                   FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
                                   [mylessonDAO setUserModle:NO];
                                   
                                   FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
                                   [response writeToFile:lessonData.localURLOfSub atomically:YES];
                               }

                           } failure:^(NSError *err) {
                               //
                           }];
}


+ (void) getDicWithURL: (NSString *) baseURLStr
              LessonID: (NSString *) lessonID
{
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    [mylessonDAO setUserModle:NO];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
    
    if(lessonData.BEPROURL)
    {
        NSString *localURL = lessonData.localURLOfPro;
        NSURL *webURL = [NSURL URLWithString:baseURLStr];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
        AFDownloadRequestOperation * operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:localURL shouldResume:YES];
        [operation setShouldOverwrite:YES];
        [operation setDeleteTempFileOnCancel:YES];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            dispatch_async([appDelegate getBackPubQueue], ^{
                
                NSString * outputDir = [iFlyingAppDelegate getLessonDir:lessonID];
                
                [FlyingMyLessonsViewController expandNormalZipFile:lessonData.localURLOfPro OutputDir:outputDir];
                
                //升级课程补丁
                [FlyingMyLessonsViewController updateBaseDic:lessonID];
                
                [[NSFileManager defaultManager] removeItemAtPath:lessonData.localURLOfPro error:nil];
                [mylessonDAO updateProURL:nil LessonID:lessonID]; //表示已经下载
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [operation start];
    }
}

+ (void) getRelativeWithURL: (NSString *) relativeURLStr
                   LessonID: (NSString *) lessonID
{
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    [mylessonDAO setUserModle:NO];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
    
    if(lessonData.BERELATIVEURL)
    {
        NSString *localURL = lessonData.localURLOfRelative;
        NSURL *webURL = [NSURL URLWithString:relativeURLStr];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
        AFDownloadRequestOperation * operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:localURL shouldResume:YES];
        [operation setShouldOverwrite:YES];
        [operation setDeleteTempFileOnCancel:YES];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            dispatch_async([appDelegate getBackPubQueue], ^{
                
                NSString * outputDir = [iFlyingAppDelegate getLessonDir:lessonID];
                
                [FlyingMyLessonsViewController expandNormalZipFile:lessonData.localURLOfRelative OutputDir:outputDir];
                
                [[NSFileManager defaultManager] removeItemAtPath:lessonData.localURLOfRelative error:nil];
                [mylessonDAO updateRelativeURL:nil LessonID:lessonID]; //表示已经下载
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [operation start];
    }
    
    if ( [lessonData.BECONTENTTYPE isEqualToString:KContentTypeText] &&
        lessonData.BEOFFICIAL)
    {
        NSString *localPath = [iFlyingAppDelegate getLessonDir:lessonID];
        NSString  *fileName =kResource_Background_filenmae;

        NSString *filePath = [localPath stringByAppendingPathComponent:fileName];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if(![fm fileExistsAtPath:filePath])
        {
            [AFHttpTool lessonResourceType:kResource_Background
                                  lessonID:lessonID
                                contentURL:nil
                                     isURL:YES
                                   success:^(id response) {
                                       //
                                       NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                       NSData * audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempStr]];
                                       //将数据保存到本地指定位置
                                       [audioData writeToFile:filePath atomically:YES];

                                   } failure:^(NSError *err) {
                                       //
                                   }];
        }
    }
}

+ (void) updateBaseDic:(NSString *) lessonID
{
    NSString * lessonDir = [iFlyingAppDelegate getLessonDir:lessonID];
    
    NSString * fileName = [lessonDir stringByAppendingPathComponent:KLessonDicName];
    
    FlyingItemParser * parser= [FlyingItemParser alloc];
    [parser SetData:[NSData dataWithContentsOfFile:fileName]];
    
    FlyingItemDao * dao= [[FlyingItemDao alloc] init];
    [dao setUserModle:NO];
    parser.completionBlock = ^(NSArray *itemList, NSInteger allRecordCount)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [itemList enumerateObjectsUsingBlock:^(FlyingItemData  *item, NSUInteger idx, BOOL *stop) {
                
                [dao insertWithData:item];
            }];
        });
    };
    
    parser.failureBlock = ^(NSError *error)
    {
        
        NSLog(@"word xml  失败！");
    };
    
    [parser parse];
}

+ (void) getDicForLessonID: (NSString *) lessonID   Title:(NSString *) title
{
    [AFHttpTool lessonResourceType:kResource_Pro
                          lessonID:lessonID
                        contentURL:nil
                             isURL:YES
                           success:^(id response) {
                               //
                               NSString * baseURLStr=[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                               [FlyingMyLessonsViewController getDicWithURL:baseURLStr LessonID:lessonID];
                               
                           } failure:^(NSError *err) {
                               //
                           }];
}

+ (void)expandNormalZipFile:(NSString *) zipFile  OutputDir:(NSString *) outputDir
{
    // unzip normal zip
    [SSZipArchive unzipFileAtPath:zipFile toDestination:outputDir];
}


+ (UIImage*) thumbnailImageForMp3:(NSURL *)mp3fURL
{

    AVAsset *assest = [AVURLAsset URLAssetWithURL:mp3fURL options:nil];
    
    for (NSString *format in [assest availableMetadataFormats]) {
        
        for (AVMetadataItem *item in [assest metadataForFormat:format]) {
            
            if ([[item commonKey] isEqualToString:@"artwork"]) {
                UIImage *img = nil;
                if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                    img = [UIImage imageWithData:[item.value copyWithZone:nil]];
                }
                else { // if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                    NSData *data = [(NSDictionary *)[item value] objectForKey:@"data"];
                    img = [UIImage imageWithData:data]  ;
                }

                return img;
            }
        }
    }
    
    return nil;
}

+ (UIImage*) thumbnailImageForPDF:(NSURL *)pdfURL  passWord:(NSString*) password
{
    
    CGPDFDocumentRef documentRef = CGPDFDocumentCreateX((__bridge CFURLRef)pdfURL, password);
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPDFDocumentRelease(documentRef), documentRef = NULL;
    
    return finalImage;
}


+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [UIImage imageWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}
                
@end
