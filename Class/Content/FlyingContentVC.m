//
//  FlyingContentVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingContentVC.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"
#import "FlyingGroupVC.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import <AFNetworking/AFNetworking.h>
#import "iFlyingAppDelegate.h"
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
#import "NSString+FlyingExtention.h"
#import "FlyingContentSummaryCell.h"
#import "FlyingCommentCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "FlyingLoadingCell.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import <AFNetworking.h>
#import "AFHttpTool.h"
#import "FlyingItemParser.h"
#import "FlyingItemDao.h"
#import "SSZipArchive.h"
#import "FlyingWebViewController.h"
#import "ReaderViewController.h"
#import "UIImage+localFile.h"
#import "FlyingDownloadManager.h"
#import "FlyingNavigationController.h"
#import "FlyingConversationVC.h"
#import "FlyingDataManager.h"
#import "KMNetworkLoadingViewController.h"
#import <UIImageView+AFNetworking.h>
#import <UIButton+AFNetworking.h>
#import "FlyingShareData.h"
#import "FlyingProfileVC.h"
#import "FlyingStatisticDAO.h"
#import "FlyingSoundPlayer.h"
#import "FlyingtAuthorCell.h"
#import "FlyingGroupVC.h"
#import "FlyingSummaryheader.h"
#import <CRToastManager.h>
#import "FlyingItemView.h"

@interface FlyingContentVC ()<UIViewControllerRestoration>
{
    //辅助参数
    float                _ratioHeightToW;
    
    NSInteger            _maxNumOfComments;
    NSInteger            _currentLodingIndex;
}

@property (strong, nonatomic) FlyingLoadingCell *loadingMoreIndicatorCell;

@property (nonatomic, strong) KMNetworkLoadingViewController* networkLoadingViewController;

@property (strong, nonatomic) UIView            *coverContentView;
@property (strong, nonatomic) UIImageView       *contentCoverImageView;
@property (strong, nonatomic) UIImageView       *contentTypeIcon;

@property (strong, nonatomic) FlyingContentTitleAndTypeCell *contentTitleAndTypeCell;
@property (strong, nonatomic) FlyingtAuthorCell *authoTablecell;

@property (strong, nonatomic) UITableView       *tableView;

@property (assign, nonatomic) BOOL              accessRight;

@property (strong, nonatomic) FlyingMediaVC     *mediaVC;

@property (strong, nonatomic) UIActivityIndicatorView  *loadingCoverConntentIndicatorView;

@property (strong, nonatomic) UIButton *accessChatbutton;
@property (strong, nonatomic) UIView   *accessChatContainer;

@property (strong, nonatomic) FlyingUserData    *authorUserData;

@end

@implementation FlyingContentVC


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (self.thePubLesson)
    {
        [coder encodeObject:self.thePubLesson forKey:@"self.thePubLesson"];
    }

    if (self.mediaVC)
    {
        [coder encodeObject:self.mediaVC forKey:@"self.mediaVC"];
    }
    
    if (self.authorUserData)
    {
        [coder encodeObject:self.authorUserData forKey:@"self.authorUserData"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    FlyingPubLessonData * thePubLesson =[coder decodeObjectForKey:@"self.thePubLesson"];
    
    if (thePubLesson)
    {
        self.thePubLesson = thePubLesson;
    }
    
    FlyingUserData * authorUserData = [coder decodeObjectForKey:@"self.authorUserData"];

    if (authorUserData)
    {
        self.authorUserData = authorUserData;
    }
    
    FlyingMediaVC * mediaVC = [coder decodeObjectForKey:@"self.mediaVC"];
    
    if (mediaVC)
    {
        self.mediaVC = mediaVC;
        self.mediaVC.restorationIdentifier = self.restorationIdentifier;
    }
    
    if (self.thePubLesson) {

        [self commonInit];
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
    self.title =@"详情";
    
    if (self.thePubLesson) {
        
        [self commonInit];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"%s = %d", __func__, decelerate);
    
    // 1.判断是否有惯性, 如果没有惯性手动调用scrollViewDidEndDecelerating告知已经完全停止滚动
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];

    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath];
    cellRect = CGRectOffset(cellRect, -self.tableView.contentOffset.x, -self.tableView.contentOffset.y);

    if (cellRect.origin.y<5)
    {
        if (self.authorUserData.portraitUri)
        {
            [self setRightNavItem:self.authorUserData.portraitUri];
        }
    }
}

-(void) setRightNavItem:(NSString*) authorIconURL
{
    //顶部右上角导航
    UIButton *askHelpButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [askHelpButton setBackgroundImageForState:UIControlStateNormal
                                      withURL:[NSURL URLWithString:authorIconURL]
                             placeholderImage:[UIImage imageNamed:@"Help"]];
    
    askHelpButton.layer.cornerRadius = askHelpButton.frame.size.width/2;
    askHelpButton.clipsToBounds = YES;
    
    [askHelpButton addTarget:self action:@selector(askHelpNow) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* askHelpBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:askHelpButton];
    
    self.navigationItem.rightBarButtonItem = askHelpBarButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:recognizer.view];
    UIView *viewTouched = [recognizer.view hitTest:point withEvent:nil];
    
    if ([viewTouched isKindOfClass:[FlyingItemView class]])
    {
        // Do nothing;
    }
    else {
        // respond to touch action
        
        if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
            
            [super dismissNavigation];
        }
    }
}

- (void) willDismiss
{
    if(self.mediaVC)
    {
        [self.mediaVC dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil userInfo:nil];
}

-(void)doShare
{
    if (self.thePubLesson.weburl)
    {
        FlyingShareData * shareData = [[FlyingShareData alloc] init];
        
        shareData.webURL  = [NSURL URLWithString:self.thePubLesson.weburl];
        shareData.title   = self.thePubLesson.title;
        shareData.digest  = self.thePubLesson.desc;
        
        shareData.imageURL= self.thePubLesson.imageURL;
        shareData.image   = [self.contentCoverImageView.image makeThumbnailOfSize:CGSizeMake(90, 120)];
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shareContent:shareData fromView:self.contentTitleAndTypeCell];
    }
}

- (void) commonInit
{
    _ratioHeightToW = 9.0/16.0;
    
    //权限初始化
    self.accessRight=NO;
    
    if (self.thePubLesson.coinPrice==0)
    {
        self.accessRight=YES;
    }
    else
    {
        //课程是否有权利
        FlyingUserRightData *userRightdata = [FlyingDataManager getUserRightForDomainID:self.thePubLesson.lessonID
                                                                             domainType:BC_Domain_Content];
        if ([userRightdata checkRightPresent]) {
            
            self.accessRight=YES;
        }
        
        //检查是否年费会员
        if (self.accessRight==NO)
        {
            userRightdata = [FlyingDataManager getUserRightForDomainID:[FlyingDataManager getAppData].appID
                                                                                 domainType:BC_Domain_Business];
            if ([userRightdata checkRightPresent]) {
                
                self.accessRight=YES;
            }
        }
    }
    
    //作者信息获取
    [FlyingHttpTool getOpenIDForUserID:self.thePubLesson.author
                            Completion:^(NSString *openUDID)
     {
         //
         if (openUDID)
         {
             [FlyingHttpTool getUserInfoByopenID:openUDID
                                      completion:^(FlyingUserData *userData, RCUserInfo *userInfo)
              {
                  self.authorUserData = userData;
                  
                  [self.authoTablecell setAuthorIconWithURL:self.authorUserData.portraitUri];
                  [self.authoTablecell setAuthorText:self.authorUserData.name];
              }];
         }
     }];

    [self prepareCoverView];

    if (!self.tableView)
    {
        self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, CGRectGetHeight(self.coverContentView.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.coverContentView.frame)-44) style:UITableViewStyleGrouped];
        
        //必须在设置delegate之前
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingContentTitleAndTypeCell" bundle:nil] forCellReuseIdentifier:@"FlyingContentTitleAndTypeCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingtAuthorCell" bundle:nil] forCellReuseIdentifier:@"FlyingtAuthorCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingSummaryheader" bundle:nil]
             forCellReuseIdentifier:@"FlyingSummaryheader"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingContentSummaryCell" bundle:nil]
             forCellReuseIdentifier:@"FlyingContentSummaryCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingCommentCell" bundle:nil]
             forCellReuseIdentifier:@"FlyingCommentCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingLoadingCell" bundle:nil]
             forCellReuseIdentifier:@"FlyingLoadingCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingCommentHeader" bundle:nil]
             forCellReuseIdentifier:@"FlyingCommentHeader"];
        
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorColor = [UIColor grayColor];
        
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
        self.tableView.restorationIdentifier = self.restorationIdentifier;
        
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_1)
        {
            self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }

        [self.view addSubview:self.tableView];
    }
    
    [self requestRelatedComments];
    
    //获取权限相关数据
    if(self.accessRight)
    {
        if (![self.thePubLesson.contentType isEqualToString:KContentTypeText])
        {
            [self showContent:nil];
        }
    }
    else
    {
        [self checkUserAccessRight];
    }
}

#pragma mark -
#pragma mark Network Request Methods

- (void)checkUserAccessRight
{
    if(!self.networkLoadingViewController)
    {
        KMNetworkLoadingViewController* loadingVC = [[KMNetworkLoadingViewController alloc] initWithNibName:@"KMNetworkLoadingViewController"
                                                                                                     bundle:nil];
        
        self.networkLoadingViewController= loadingVC;
        self.networkLoadingViewController.delegate = self;
    }
        
    [self.navigationController presentViewController:self.networkLoadingViewController animated:YES completion:^{
        
        
        //向服务器获取最新课程权限数据
        
        [FlyingHttpTool getLessonRightForAccount:[FlyingDataManager getOpenUDID]
                                        LessonID:self.thePubLesson.lessonID
                                      Completion:^(FlyingUserRightData *userRightData) {
                                          
                                          //
                                          if ([userRightData checkRightPresent]) {
                                              
                                              self.accessRight=YES;
                                          }
                                          
                                          if (self.accessRight) {
                                              
                                              [self showContent:nil];
                                              [self hideLoadingView];
                                              [self showAccessRightInfo];
                                          }
                                          else
                                          {
                                              //向服务器获取最新会员数据
                                              [FlyingHttpTool getMembershipForAccount:[FlyingDataManager getOpenUDID]
                                                                           Completion:^(FlyingUserRightData *userRightData) {
                                                                               //
                                                                               if ([userRightData checkRightPresent]) {
                                                                                   
                                                                                   self.accessRight=YES;
                                                                                   [self showContent:nil];
                                                                               }
                                                                               
                                                                               [self hideLoadingView];
                                                                               [self showAccessRightInfo];
                                                                           }];
                                          
                                          }
                                      }];
           }];
}

-(void)showAccessRightInfo
{
    NSString * message=NSLocalizedString(@"抱歉，你没有相关权限。请在个人帐户购买会员或者直接点击课程标题的购买图标！",nil);
    
    if(self.accessRight==YES)
    {
        message=NSLocalizedString(@"同步权限成功！",nil);
        [self.contentTitleAndTypeCell setAccessRight:self.accessRight];
    }
    
    //即时反馈
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate makeToast:message];
}

-(void) prepareCoverView
{
    if (!self.coverContentView) {
        
        float contentWidth=self.view.bounds.size.width;
        float contentHeight=contentWidth*_ratioHeightToW;
        CGRect contentFrame = CGRectMake(0, 0, contentWidth, contentHeight);
        
        self.coverContentView = [[UIView alloc] initWithFrame:contentFrame];
        
        [self.coverContentView setBackgroundColor:[UIColor blackColor]];
        
        //[self.coverContentView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.view addSubview:self.coverContentView];
    }
    
    //添加内容封面截图
    if (!self.contentCoverImageView) {
        
        float contentWidth=self.view.bounds.size.width;
        float contentHeight=contentWidth*_ratioHeightToW;
        CGRect contentFrame = CGRectMake(0, 0, contentWidth, contentHeight);
        
        self.contentCoverImageView = [[UIImageView alloc] initWithFrame:contentFrame];
        self.contentCoverImageView.opaque=NO;
        self.contentCoverImageView.contentMode=UIViewContentModeScaleAspectFit;
        self.contentCoverImageView.userInteractionEnabled=YES;
        
        [self.contentCoverImageView setImageWithURL:[NSURL URLWithString:self.thePubLesson.imageURL]
                                   placeholderImage:[UIImage imageNamed:@"Default"]];

        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showContent:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        
        [self.contentCoverImageView addGestureRecognizer:singleRecognizer];
        
        [self.coverContentView addSubview:self.contentCoverImageView];
    }
    
    if (!self.contentTypeIcon) {
        
        float contentHeight =self.coverContentView.bounds.size.height;
        
        float playButtonSide=contentHeight/2.0;
        
        CGRect playbuttonFrame = CGRectMake((self.coverContentView.bounds.size.width-playButtonSide)/2.0, playButtonSide/2.0, playButtonSide, playButtonSide);
        self.contentTypeIcon = [[UIImageView alloc] initWithFrame:playbuttonFrame];
        self.contentTypeIcon.userInteractionEnabled=YES;
        
        [self.contentCoverImageView addSubview:self.contentTypeIcon];
    }
    
    //初始化内容类型
    if ([self.thePubLesson.contentType isEqualToString:KContentTypeText])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayDocIcon]];
    }
    else if ([self.thePubLesson.contentType isEqualToString:KContentTypeVideo])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayVideoIcon]];
    }
    else  if ([self.thePubLesson.contentType isEqualToString:KContentTypeAudio])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayAudioIcon]];
    }
    else  if ([self.thePubLesson.contentType isEqualToString:KContentTypePageWeb])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayWebIcon]];
    }
}

//////////////////////////////////////////////////////////////
#pragma 内容呈现相关
//////////////////////////////////////////////////////////////
- (void)showContent:(id)sender
{
    //获取权限相关数据
    if(!self.accessRight)
    {
        [self checkUserAccessRight];
    }
    else
    {
        FlyingLessonData * lessonData = [[FlyingLessonData alloc] initWithPubData:self.thePubLesson];
        
        //插入公共课程记录
        [[FlyingLessonDAO new] insertWithData:lessonData];
        
        if ([self.thePubLesson.contentType isEqualToString:KContentTypeText])
        {
            [self showLoadingCoverContentIndicator];
            
            //监控下载是否完成
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateDownloadOk:)
                                                         name:KlessonFinishTask
                                                       object:nil];
            
            [[FlyingDownloadManager shareInstance] startDownloaderForID:self.thePubLesson.lessonID];
        }
        else
        {
            [FlyingDownloadManager downloadRelated:lessonData];
            
            [self playLesson:self.thePubLesson.lessonID];
        }
    }
}

- (void) playLesson:(NSString *) lessonID
{
    if([self.thePubLesson.contentType isEqualToString:KContentTypeVideo])
    {
        if([self.thePubLesson.downloadType isEqualToString:KDownloadTypeM3U8] || [NSString checkMp4URL:self.thePubLesson.contentURL])
        {
            [self playVedio];
        }
        else
        {
            if(self.thePubLesson.contentURL!=nil)
            {
                FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
                webVC.domainID = self.domainID;
                webVC.domainType = self.domainType;
                
                [webVC setThePubLesson:self.thePubLesson];
                
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
    }
    else if([self.thePubLesson.contentType isEqualToString:KContentTypeAudio])
    {
        [self playVedio];
    }
    else if ([self.thePubLesson.contentType isEqualToString:KContentTypeText])
    {
        NSString *extention = [self.thePubLesson.contentURL pathExtension];
        
        if ([extention isEqualToString:@"pdf"])
        {
            ReaderViewController *pdfVC= [[ReaderViewController alloc] init];
            [pdfVC setLessonID:lessonID];
            [pdfVC setPlayOnline:YES];
            
            pdfVC.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            [self  presentViewController:pdfVC animated:YES completion:NULL];
        }
        else
        {
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.delegate = self;
            
            // start previewing the document at the current section index
            previewController.currentPreviewItemIndex = 0;
            [[self navigationController] pushViewController:previewController animated:YES];
        }
    }
    else if ([self.thePubLesson.contentType isEqualToString:KContentTypePageWeb])
    {
        FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
        webVC.domainID = self.domainID;
        webVC.domainType= self.domainType;
        
        [webVC setThePubLesson:self.thePubLesson];
        [self.navigationController pushViewController:webVC animated:NO];
    }
    else if([self.thePubLesson.downloadType isEqualToString:KDownloadTypeM3U8] || [NSString checkMp4URL:self.thePubLesson.contentURL])
    {
        [self playVedio];
    }
    else
    {
        //即时反馈
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString * message = NSLocalizedString(@"抱歉：请升级支持新课程类型！", nil);
        [appDelegate makeToast:message];
    }
}

-(void) playVedio
{
    if (!self.mediaVC) {
        
        self.mediaVC = [[FlyingMediaVC alloc] initWithNibName:@"FlyingMediaVC" bundle:nil];
        self.mediaVC.thePubLesson=self.thePubLesson;
        self.mediaVC.restorationIdentifier = self.restorationIdentifier;
    }
    
    self.mediaVC.view.frame=self.coverContentView.bounds;
    
    [self.mediaVC willMoveToParentViewController:nil];
    [self addChildViewController:self.mediaVC];
    self.mediaVC.delegate=self;
    
    [self.coverContentView  addSubview:self.mediaVC.view];
}

- (void) updateDownloadOk:(NSNotification*) aNotification
{
    NSString * lessonID = [[aNotification userInfo] objectForKey:@"lessonID"];
    
    if([lessonID isEqualToString:self.thePubLesson.lessonID])
    {
        //如果是直接播放的文本
        if([self.thePubLesson.contentType isEqualToString:KContentTypeText])
        {
            [self hideLoadingCovercontentIndicator];
            [self playLesson:self.thePubLesson.lessonID];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:KlessonFinishTask    object:nil];
    }
}
//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

-(void)requestRelatedComments
{
    if (!_currentData)
    {
        _currentData = [NSMutableArray new];
    }
    
    [_currentData removeAllObjects];
    _currentLodingIndex=0;
    _maxNumOfComments=NSIntegerMax;
    
    [self loadMore];
}

- (void)loadMore
{
    
    if (self.thePubLesson) {

        if (_currentData.count<_maxNumOfComments)
        {
            _currentLodingIndex++;
            
            [FlyingHttpTool getCommentListForContentID:self.thePubLesson.lessonID
                                           ContentType:self.thePubLesson.contentType
                                            PageNumber:_currentLodingIndex
                                            Completion:^(NSArray *commentList, NSInteger allRecordCount) {
                                                
                                                if (commentList.count!=0) {
                                                    
                                                    [self.currentData addObjectsFromArray:commentList];
                                                    _maxNumOfComments=allRecordCount;
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [self.tableView reloadData];
                                                    });
                                                }
                                            }];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4; // 增加一个加载更多
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 2;
    }
    
    else if (section == 2)
    {
        return [self.currentData count];;
    }
    else
    {
        // 加载更多
        return 1;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        CGFloat height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingCommentHeader" 
                                                          configuration:^(FlyingCommentHeader *cell) {

            [cell setTitle:@"相关评论"];
        }];

        return height;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        FlyingCommentHeader *commentHeader = [tableView dequeueReusableCellWithIdentifier:@"FlyingCommentHeader"];
        
        if(commentHeader == nil)
            commentHeader = [FlyingCommentHeader commentHeaderCell];
        
        [commentHeader setTitle:@"相关评论"];
        [commentHeader setCommentCount:self.thePubLesson.commentCount];
        
        return commentHeader;
    }
    else
    {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                FlyingContentTitleAndTypeCell *contentTitleCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentTitleAndTypeCell"];
                
                if(contentTitleCell == nil)
                    contentTitleCell = [FlyingContentTitleAndTypeCell contentTitleAndTypeCell];
                
                [self configureCell:contentTitleCell atIndexPath:indexPath];
                cell = contentTitleCell;
                
                self.contentTitleAndTypeCell=contentTitleCell;
                break;
            }
            case 1:
            {
                FlyingtAuthorCell *authorCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingtAuthorCell"];
                
                if(authorCell == nil)
                    authorCell = [FlyingtAuthorCell authorCell];
                
                [self configureCell:authorCell atIndexPath:indexPath];
                cell = authorCell;
                
                self.authoTablecell = authorCell;
                break;
            }
                
            default:
            break;
        }
    }
    else if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                FlyingSummaryheader *summayHeader = [tableView dequeueReusableCellWithIdentifier:@"FlyingSummaryheader"];
                
                if(summayHeader == nil)
                    summayHeader = [FlyingSummaryheader summaryHeaderCell];
                
                [self configureCell:summayHeader atIndexPath:indexPath];
                
                cell = summayHeader;
                
                break;
            }
            case 1:
            {
                FlyingContentSummaryCell *contentSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentSummaryCell"];
                
                if(contentSummaryCell == nil)
                    contentSummaryCell = [FlyingContentSummaryCell contentSummaryCell];
                
                [self configureCell:contentSummaryCell atIndexPath:indexPath];
                cell = contentSummaryCell;
                
                break;
            }
                
            default:
                break;
        }
    }
    else if (indexPath.section == 2)
    {
        FlyingCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingCommentCell"];
        
        if(commentCell == nil)
            commentCell = [FlyingCommentCell commentCell];
        
        [self configureCell:commentCell atIndexPath:indexPath];
        
        cell = commentCell;
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
    CGFloat height = 0;
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingContentTitleAndTypeCell"
                                                       cacheByIndexPath:indexPath
                                                          configuration:^(FlyingContentTitleAndTypeCell *cell) {
                                                              [self configureCell:cell atIndexPath:indexPath];
                                                          }];
                break;
            }
            case 1:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingtAuthorCell"
                                                       cacheByIndexPath:indexPath
                                                          configuration:^(FlyingtAuthorCell *cell) {
                                                              [self configureCell:cell atIndexPath:indexPath];
                                                          }];
                
                break;
            }
        }
        
        return height;
    }
    else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
                
            case 0:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingSummaryheader"
                                                       cacheByIndexPath:indexPath
                                                          configuration:^(FlyingSummaryheader *cell) {
                    [self configureCell:cell atIndexPath:indexPath];
                }];
                
                break;
            }
            case 1:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingContentSummaryCell"
                                                       cacheByIndexPath:indexPath
                                                          configuration:^(FlyingSummaryheader *cell) {
                                                              [self configureCell:cell atIndexPath:indexPath];
                                                          }];
                
                break;
            }
         }
        
        // 普通Cell的高度
        return height;
    }
    
    else if (indexPath.section == 2)
    {
        return [self.tableView fd_heightForCellWithIdentifier:@"FlyingCommentCell"
                                             cacheByIndexPath:indexPath
                                                configuration:^(FlyingCommentCell *cell) {
                                                    [self configureCell:cell atIndexPath:indexPath];
                                                }];
    }
    else
    {
        return [self.tableView fd_heightForCellWithIdentifier:@"FlyingLoadingCell"
                                             cacheByIndexPath:indexPath
                                                configuration:^(FlyingLoadingCell *cell) {
            //[self configureCell:cell atIndexPath:indexPath];
        }];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                if (self.thePubLesson)
                {
                    [(FlyingContentTitleAndTypeCell *)cell setTitle:self.thePubLesson.title];
                    [(FlyingContentTitleAndTypeCell *)cell setAccessRight:self.accessRight];
                    [(FlyingContentTitleAndTypeCell *)cell setPrice:@(self.thePubLesson.coinPrice).stringValue];
                }
                
                break;
            }
            case 1:
            {
                if (self.authorUserData )
                {
                    [(FlyingtAuthorCell*)cell setAuthorIconWithURL:self.authorUserData.portraitUri];
                    [(FlyingtAuthorCell*)cell setAuthorText:self.authorUserData.name];
                    [(FlyingtAuthorCell*)cell setHelpText:NSLocalizedString(@"help", nil)];
                }
                
                break;
            }
                
            default:
                break;
        }
    }

    else if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                [(FlyingSummaryheader*)cell setTitle:@"相关简介"];
                break;
            }
            case 1:
            {
                if (![self.thePubLesson.desc isBlankString]) {
                    
                    [(FlyingContentSummaryCell*)cell setSummaryText:self.thePubLesson.desc];
                }

                break;
            }
                
            default:
                break;
        }
    }
    else if (indexPath.section == 2)
    {
        FlyingCommentData *commentData = self.currentData[indexPath.row];
        [(FlyingCommentCell*)cell setCommentData:commentData];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        if (_currentData.count>0&&
            _currentData.count<_maxNumOfComments)
        {
            // 加载更多
            [self.loadingMoreIndicatorCell startAnimating:@"尝试加载更多..."];
            
            // 加载下一页
            [self loadMore];
        }
        else
        {
            [self.loadingMoreIndicatorCell stopAnimating:@"点击这里开始评论..."];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                [self didTouchAccess];
                break;
            }

            case 1:
            {
                [self askHelpNow];
                break;
            }
        }
    }
    else if (indexPath.section == 1)
    {
        switch (indexPath.row) {
                
            case 0:
            {
                //即时反馈
                iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
                NSString * message = NSLocalizedString(@"如果咨询问题，点击“求助”", nil);
                [appDelegate makeToast:message];
                break;
            }
        }
    }
    else if (indexPath.section == 2)
    {
        FlyingCommentData* commentData = [_currentData objectAtIndex:indexPath.row];
        
        [self profileImageViewPressed:commentData];
    }
    else if (indexPath.section == 3)
    {
        [self commentHeaderPressed];
    }
}

//////////////////////////////////////////////////////////////
#pragma cell related
//////////////////////////////////////////////////////////////
- (void)didTouchAccess
{
    if (self.accessRight)
    {
        [self doShare];
    }
    else
    {
        
        NSString * title = NSLocalizedString(@"Attenion Please", nil);
        NSString * message= NSLocalizedString(@"I want to enjoy it!", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                             style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         //
                                         FlyingStatisticDAO * statisticDAO=[[FlyingStatisticDAO alloc] init];
                                         NSInteger touchMoneyCountNow =[statisticDAO touchCountWithUserID:[FlyingDataManager getOpenUDID]];
                                         
                                         if (touchMoneyCountNow<self.thePubLesson.coinPrice)
                                         {
                                             //即时反馈
                                             [FlyingSoundPlayer noticeSound];

                                             iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
                                             NSString * message = NSLocalizedString(@"No enough coins!", nil);
                                             [appDelegate makeToast:message];
                                         }
                                         else
                                         {
                                             touchMoneyCountNow-=self.thePubLesson.coinPrice;
                                             [statisticDAO updateWithUserID:[FlyingDataManager getOpenUDID] TouchCount:touchMoneyCountNow];
                                             
                                             [FlyingHttpTool uploadMoneyDataWithOpenID:[FlyingDataManager getOpenUDID] Completion:^(BOOL result) {
                                                 //
                                                 [FlyingSoundPlayer noticeSound];
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil userInfo:nil];
                                             }];
                                         }
                                         
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
}

-(void) askHelpNow
{
    //没有内容获取权限
    if(!self.accessRight)
    {
        //和APP的客服沟通
        NSString *message = [NSString stringWithFormat:@"我要咨询。可能是:如何获取内容权限， 相关内容:%@",self.thePubLesson.title];
        [FlyingGroupVC contactAppServiceWithMessage:message
                                               inVC:self];
    }
    else
    {
        //群组内
        if ([BC_Domain_Group isEqualToString:self.domainType])
        {
            [FlyingGroupVC doMemberRightInVC:self
                                     GroupID:self.domainID
                                  Completion:^(FlyingUserRightData *userRightData)
            {
                //
                if ([userRightData checkRightPresent])
                {
                    [self contactWithAuhor];
                }
                else
                {
                    //和APP的客服沟通
                    NSString * message = NSLocalizedString(@"已经帮你转接客服人员...", nil);
                    
                    [CRToastManager showNotificationWithMessage:message completionBlock:^{
                        //
                        NSString *message = [NSString stringWithFormat:@"我想咨询，相关内容:%@",self.thePubLesson.title];
                        [FlyingGroupVC contactAppServiceWithMessage:message
                                                               inVC:self];
                    }];
                }
            }];
        }
        else
        {
            //和APP的客服沟通
            NSString * message = NSLocalizedString(@"已经帮你转接客服人员...", nil);
            [CRToastManager showNotificationWithMessage:message completionBlock:^{
                //
                NSString *message = [NSString stringWithFormat:@"我想咨询，相关内容:%@",self.thePubLesson.title];
                [FlyingGroupVC contactAppServiceWithMessage:message
                                                       inVC:self];
            }];
        }
    }
}

-(void) contactWithAuhor
{
    //直接和老师沟通
    if (self.authorUserData.openUDID)
    {
        NSString* targetID = [self.authorUserData.openUDID MD5];
        
        FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
        
        chatService.domainID = self.domainID;
        chatService.domainType = self.domainType;
        
        chatService.targetId = targetID;
        chatService.conversationType = ConversationType_PRIVATE;
        [self.navigationController pushViewController:chatService animated:YES];
    }
}

- (void)profileImageViewPressed:(FlyingCommentData*)commentData
{
    
    FlyingProfileVC  *profileVC = [[FlyingProfileVC alloc] init];
    profileVC.openUDID = commentData.openUDID;
    profileVC.title = commentData.nickName;
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)commentHeaderPressed
{
    FlyingCommentVC *commentVC =[[FlyingCommentVC alloc] init];
    
    commentVC.domainID = self.domainID;
    commentVC.domainType = self.domainType;
    
    commentVC.contentID=self.thePubLesson.lessonID;
    commentVC.contentType=self.thePubLesson.contentType;
    commentVC.commentTitle=self.thePubLesson.title;
    
    commentVC.reloadDatadelegate=self;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma FlyingCommentVCDelegate related
//////////////////////////////////////////////////////////////

-(void)reloadCommentData
{
    [self requestRelatedComments];
}

#pragma mark -
#pragma mark KMNetworkLoadingViewController Methods

- (void)hideLoadingView
{
    [self.networkLoadingViewController dismissViewControllerAnimated:YES completion:^{
        //
        self.networkLoadingViewController = nil;
    }];
}

#pragma 加载内容

-(void) showLoadingCoverContentIndicator
{
    if (self.loadingCoverConntentIndicatorView)
    {
        if(!self.loadingCoverConntentIndicatorView.isAnimating)
        {
            [self.loadingCoverConntentIndicatorView startAnimating];
        }
    }
    else
    {
        //初始化:
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        //设置显示样式,见UIActivityIndicatorViewStyle的定义
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        
        //设置显示位置
        [indicator setCenter:CGPointMake(self.coverContentView.frame.size.width / 2, self.coverContentView.frame.size.height / 2)];
        
        //设置背景色
        indicator.backgroundColor = [UIColor grayColor];
        
        //设置背景透明
        indicator.alpha = 0.5;
        
        //设置背景为圆角矩形
        indicator.layer.cornerRadius = 6;
        indicator.layer.masksToBounds = YES;
        
        //将初始化好的indicator add到view中
        [self.coverContentView addSubview:indicator];
        self.loadingCoverConntentIndicatorView=indicator;
        
        //开始显示Loading动画
        [indicator startAnimating];
        
        [self.coverContentView bringSubviewToFront:indicator];
    }
}

-(void) hideLoadingCovercontentIndicator
{
    if (self.loadingCoverConntentIndicatorView)
    {
        [self.loadingCoverConntentIndicatorView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark KMNetworkLoadingViewDelegate

-(void)retryRequest;
{
    if(self.thePubLesson)
    {
        [self checkUserAccessRight];
    }
}

#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    return 1;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    return [NSURL fileURLWithPath:[(FlyingLessonData*)[[[FlyingLessonDAO alloc] init] selectWithLessonID:self.thePubLesson.lessonID] localURLOfContent]];
}
//////////////////////////////////////////////////////////////
#pragma menu related
//////////////////////////////////////////////////////////////
- (void)doSwitchToFullScreen:(BOOL) toFullScreen;
{
    if (toFullScreen) {
        
        [self.mediaVC pause];
        [self.mediaVC willMoveToParentViewController:nil];
        [self.mediaVC.view removeFromSuperview];
        [self.mediaVC removeFromParentViewController];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // This make it on another run loop
            [self presentViewController:self.mediaVC animated:YES completion:^{
                //
                [self.mediaVC play];
            }];
        });
    }
    else
    {
        [self.mediaVC dismissViewControllerAnimated:YES completion:^{
            
            [self playVedio];
        }];
    }
}

@end
