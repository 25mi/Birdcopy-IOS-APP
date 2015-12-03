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

#import "UIView+Toast.h"

#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"

#import "RCDChatListViewController.h"

#import "FlyingGroupVC.h"

#import "UICKeyChainStore.h"
#import "shareDefine.h"

#import <AFNetworking/AFNetworking.h>
#import "iFlyingAppDelegate.h"

#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
#import "RCDChatViewController.h"
#import "RCDataBaseManager.h"

#import "NSString+FlyingExtention.h"

#import "StoryBoardUtilities.h"
#import "UIView+Toast.h"
#import "FlyingContentSummaryCell.h"
#import "FlyingTagCell.h"
#import "FlyingCommentCell.h"

#import "FlyingLessonListViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "FlyingLoadingCell.h"

#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"

#import <AFNetworking.h>
#import "AFDownloadRequestOperation.h"
#import "AFHttpTool.h"

#import "FlyingItemParser.h"
#import "FlyingItemDao.h"
#import "SSZipArchive.h"

#import "FlyingWebViewController.h"
#import "ReaderViewController.h"

#import "UIImage+localFile.h"

@interface FlyingContentVC ()
{
    //辅助参数
    float                _ratioHeightToW;
    
    NSInteger            _maxNumOfComments;
    NSInteger            _currentLodingIndex;
}

@property (nonatomic, strong) KMNetworkLoadingViewController* networkLoadingViewController;

@property (strong, nonatomic) UIView            *coverContentView;
@property (strong, nonatomic) UIImageView       *contentCoverImageView;
@property (strong, nonatomic) UIImageView       *contentTypeIcon;

@property (strong, nonatomic) FlyingLoadingCell *loadingCommentIndicatorCell;

@property (strong, nonatomic) UITableView       *tableView;

@property (assign, nonatomic) BOOL              accessRight;

@property (strong, nonatomic) FlyingMediaVC     *mediaVC;

@property (strong, nonatomic) UIActivityIndicatorView  *loadingCoverConntentIndicatorView;

@end

@implementation FlyingContentVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    //更新欢迎语言
    self.title =@"详情";
    
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
    
    image= [UIImage imageNamed:@"share"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* shareButton= [[UIButton alloc] initWithFrame:frame];
    [shareButton setBackgroundImage:image forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* shareBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;
    
    [self commonInit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) commonInit
{
    _ratioHeightToW = 9.0/16.0;
    
    //权限初始化
    self.accessRight=NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString*  endDateStr =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"membershipEndTime"];
    NSDate *endDate = [dateFormatter dateFromString:endDateStr];
    NSDate *nowDate = [NSDate date];
    if ([nowDate compare:endDate] == NSOrderedAscending || self.theLesson.coinPrice==0)
    {
        self.accessRight=YES;
    }
    
    [self prepareCoverView];

    if (!self.tableView)
    {
        self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, CGRectGetHeight(self.coverContentView.frame), CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.coverContentView.frame)-44) style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorColor = [UIColor grayColor];
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingContentTitleAndTypeCell" bundle: nil] forCellReuseIdentifier:@"FlyingContentTitleAndTypeCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingContentSummaryCell" bundle: nil]
             forCellReuseIdentifier:@"FlyingContentSummaryCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingTagCell" bundle: nil]
             forCellReuseIdentifier:@"FlyingTagCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingCommentCell" bundle: nil]
             forCellReuseIdentifier:@"FlyingCommentCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingLoadingCell" bundle: nil]
             forCellReuseIdentifier:@"FlyingLoadingCell"];

        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingCommentHeader" bundle: nil]
             forCellReuseIdentifier:@"FlyingCommentHeader"];
        
        [self.view addSubview:self.tableView];
    }
        
    [self addBackFunction];
    
    [self requestRelatedComments];
    
    //获取权限相关数据
    if(self.accessRight)
    {
        if (![self.theLesson.contentType isEqualToString:KContentTypeText])
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
        KMNetworkLoadingViewController* loadingVC = (KMNetworkLoadingViewController*)[StoryBoardUtilities viewControllerForStoryboardName:@"KMNetworkLoadingViewController" class:[KMNetworkLoadingViewController class]];
        
        self.networkLoadingViewController= loadingVC;
        self.networkLoadingViewController.delegate = self;
    }
        
    [self.navigationController presentViewController:self.networkLoadingViewController animated:YES completion:^{
        
        //获取会员最新权限数据
        NSString *openID = [NSString getOpenUDID];
        
        if(!openID)
        {
            [self hideLoadingView];
            [self showAccessRightInfo];

            return;
        }
        
        //向服务器获取最新会员数据
        [FlyingHttpTool getMembershipForAccount:openID
                                          AppID:[NSString getAppID]
                                     Completion:^(NSDate *startDate, NSDate *endDate) {
                                         //
                                         if(endDate)
                                         {
                                             NSDate *nowDate = [NSDate date];
                                             
                                             if ([nowDate compare:endDate] == NSOrderedAscending)
                                             {
                                                 self.accessRight=YES;
                                                 
                                                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                 
                                                 NSString *startDateStr = [dateFormatter stringFromDate:startDate];
                                                 NSString *endDateStr = [dateFormatter stringFromDate:endDate];
                                                 
                                                 [[NSUserDefaults standardUserDefaults] setObject:startDateStr forKey:@"membershipStartTime"];
                                                 [[NSUserDefaults standardUserDefaults] setObject:endDateStr forKey:@"membershipEndTime"];
                                                 [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sysMembership"];
                                                 
                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                 
                                                 if ([nowDate compare:endDate] == NSOrderedAscending || self.theLesson.coinPrice==0)
                                                 {
                                                     self.accessRight=YES;
                                                     [self showContent:nil];
                                                 }
                                             }
                                         }
                                         
                                         [self hideLoadingView];
                                         [self showAccessRightInfo];
                                     }];
    }];
}

-(void)showAccessRightInfo
{
    NSString * infoStr=@"抱歉，你没有相关权限。请在个人帐户购买会员或者直接点击课程标题的购买图标！";
    
    if(self.accessRight==YES)
    {
        infoStr=@"同步权限成功，请重试！";
    }
    
    [self.view makeToast:infoStr];
}

-(void) prepareCoverView
{
    if (!self.coverContentView) {
        
        float contentWidth=self.view.bounds.size.width;
        float contentHeight=contentWidth*_ratioHeightToW;
        CGRect contentFrame = CGRectMake(0, 0, contentWidth, contentHeight);
        
        self.coverContentView = [[UIView alloc] initWithFrame:contentFrame];
        
        [self.coverContentView setBackgroundColor:[UIColor blackColor]];
        
#ifdef __CLIENT__IS__ENGLISH__
        [self.coverContentView setBackgroundColor:[UIColor redColor]];
#endif

#ifdef __CLIENT__IS__IT__
        [self.coverContentView setBackgroundColor:[UIColor blueColor]];
#endif        
        
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
        
        [self.contentCoverImageView sd_setImageWithURL:[NSURL URLWithString:self.theLesson.imageURL]
                                      placeholderImage:[UIImage imageNamed:@"Default"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             }];

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
    if ([self.theLesson.contentType isEqualToString:KContentTypeText])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayDocIcon]];
    }
    else if ([self.theLesson.contentType isEqualToString:KContentTypeVideo])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayVideoIcon]];
    }
    else  if ([self.theLesson.contentType isEqualToString:KContentTypeAudio])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayAudioIcon]];
    }
    else  if ([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
    {
        [self.contentTypeIcon setImage:[UIImage imageNamed:PlayWebIcon]];
    }
}

//////////////////////////////////////////////////////////////
#pragma 内容呈现相关
//////////////////////////////////////////////////////////////
- (void)showContent:(id)sender
{
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        //获取权限相关数据
        if(!self.accessRight)
        {
            [self checkUserAccessRight];
        }
        else
        {
            //插入公共课程记录
            [[FlyingLessonDAO new] insertWithData:[[FlyingLessonData alloc] initWithPubData:self.theLesson]];
            
            if ([self.theLesson.contentType isEqualToString:KContentTypeText])
            {
                [self showLoadingCoverContentIndicator];
                
                //监控缓存结束
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(updateDownloadOk:)
                                                             name:KlessonFinishTask
                                                           object:nil];

                
                iFlyingAppDelegate *delegate = (iFlyingAppDelegate *)[UIApplication sharedApplication].delegate;
                [delegate startDownloaderForID:self.theLesson.lessonID];
                
                //缓存相关内容
                [FlyingContentVC downloadRelated:self.theLesson];
            }
            else
            {
                [self playLesson:self.theLesson.lessonID];
            }
        }
    }
    else
    {
        [self.view makeToast:@"请联网再试..." duration:3 position:CSToastPositionCenter];
    }
}

- (void) playLesson:(NSString *) lessonID
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    if([self.theLesson.contentType isEqualToString:KContentTypeVideo])
    {
        if([self.theLesson.downloadType isEqualToString:KDownloadTypeM3U8] || [NSString checkMp4URL:self.theLesson.contentURL])
        {
            [self playVedio];
        }
        else
        {
            if(self.theLesson.contentURL!=nil)
            {
                FlyingWebViewController * webVC =[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
                [webVC setWebURL:self.theLesson.contentURL];
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
    }
    else if([self.theLesson.contentType isEqualToString:KContentTypeAudio])
    {
        [self playVedio];
    }
    else if ([self.theLesson.contentType isEqualToString:KContentTypeText])
    {
        NSString *extention = [self.theLesson.contentURL pathExtension];
        
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
    else if ([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
    {
        FlyingWebViewController * webVC =[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
        [webVC setWebURL:self.theLesson.contentURL];
        [self.navigationController pushViewController:webVC animated:NO];
    }
    else if([self.theLesson.downloadType isEqualToString:KDownloadTypeM3U8] || [NSString checkMp4URL:self.theLesson.contentURL])
    {
        [self playVedio];
    }
    else
    {
        [self.view makeToast:@"抱歉：请升级支持新课程类型！" duration:3 position:CSToastPositionCenter];
    }
}

-(void) playVedio
{
    if (!self.mediaVC) {
        
        self.mediaVC = [[FlyingMediaVC alloc] initWithNibName:@"FlyingMediaVC" bundle:nil];
        self.mediaVC.theLesson=self.theLesson;
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
    
    if([lessonID isEqualToString:self.theLesson.lessonID])
    {
        //如果是直接播放的文本
        if([self.theLesson.contentType isEqualToString:KContentTypeText])
        {
            [self hideLoadingCovercontentIndicator];
            [self playLesson:self.theLesson.lessonID];
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

- (BOOL)loadMore
{
    if (_currentData.count<_maxNumOfComments)
    {
        _currentLodingIndex++;
        
        [FlyingHttpTool getCommentListForContentID:self.theLesson.lessonID
                                       ContentType:self.theLesson.contentType
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
        return true;
    }
    else
    {
        
        return false;
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        CGFloat height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingCommentHeader" configuration:^(FlyingCommentHeader *cell) {

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
    if (section == 1)
    {
        FlyingCommentHeader *commentHeader = [tableView dequeueReusableCellWithIdentifier:@"FlyingCommentHeader"];
        
        if(commentHeader == nil)
            commentHeader = [FlyingCommentHeader commentHeaderCell];
        
        [commentHeader setTitle:@"相关评论"];
        commentHeader.delegate=self;
        
        return commentHeader;
    }
    else
    {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_currentData.count && _currentData.count<_maxNumOfComments)
    {
        return 3; // 增加一个加载更多
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }
    else if (section == 1)
    {
        NSInteger actualNumberOfRows = [self.currentData count];
        return (actualNumberOfRows  == 0) ? 1 : actualNumberOfRows;
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
        switch (indexPath.row) {
            case 0:
            {
                FlyingContentTitleAndTypeCell *contentTitleCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentTitleAndTypeCell"];
                
                if(contentTitleCell == nil)
                    contentTitleCell = [FlyingContentTitleAndTypeCell contentTitleAndTypeCell];
                
                contentTitleCell.delegate=self;
                
                [self configureCell:contentTitleCell atIndexPath:indexPath];
                cell = contentTitleCell;
                
                break;
            }
            case 1:
            {
                FlyingContentSummaryCell *contentSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentSummaryCell"];
                
                if(contentSummaryCell == nil)
                    contentSummaryCell = [FlyingContentSummaryCell contentSummaryCell];
                
                [self configureCell:contentSummaryCell atIndexPath:indexPath];
                cell = contentSummaryCell;
            }
                break;
                
            case 2:
            {
                FlyingTagCell *tagCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingTagCell"];
                
                if(tagCell == nil)
                    tagCell = [FlyingTagCell tagCell];
                
                [self configureCell:tagCell atIndexPath:indexPath];
                
                cell = tagCell;
                
                break;
            }
                
            default:
            break;
        }
    }
    else if (indexPath.section == 1)
    {
        NSInteger actualNumberOfRows = [self.currentData count];
        
        if (actualNumberOfRows == 0) {
            // Produce a special cell with the "list is now empty" message
            FlyingContentSummaryCell *contentSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentSummaryCell"];
            
            if(contentSummaryCell == nil)
                contentSummaryCell = [FlyingContentSummaryCell contentSummaryCell];
            
            [self configureCell:contentSummaryCell atIndexPath:indexPath];
            cell = contentSummaryCell;
        }
        else
        {
            FlyingCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingCommentCell"];
            
            if(commentCell == nil)
                commentCell = [FlyingCommentCell commentCell];
            
            [self configureCell:commentCell atIndexPath:indexPath];
            
            cell = commentCell;
        }
    }
    else
    {
        FlyingLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingLoadingCell"];
        
        if(loadingCell == nil)
            loadingCell = [FlyingLoadingCell loadingCell];
        
        cell = loadingCell;
        
        self.loadingCommentIndicatorCell=loadingCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
                
            case 0:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingContentTitleAndTypeCell" configuration:^(FlyingContentTitleAndTypeCell *cell) {
                    [self configureCell:cell atIndexPath:indexPath];
                }];
                break;
            }
            case 1:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingContentSummaryCell" configuration:^(FlyingContentSummaryCell *cell) {
                    [self configureCell:cell atIndexPath:indexPath];
                }];
                
                break;
            }
            case 2:
            {
                if (self.theLesson.tag.length== 0)
                {
                    height = 0;
                }
                else
                {
                    height = 40;
                }

                break;
            }
         }
        
        // 普通Cell的高度
        return height;
    }
    
    else if (indexPath.section == 1)
    {
        NSInteger actualNumberOfRows = [self.currentData count];
        
        if (actualNumberOfRows == 0) {
            return [self.tableView fd_heightForCellWithIdentifier:@"FlyingContentSummaryCell" configuration:^(FlyingContentSummaryCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
        else
        {
            return [self.tableView fd_heightForCellWithIdentifier:@"FlyingCommentCell" configuration:^(FlyingCommentCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
    }
    else
    {
        return [self.tableView fd_heightForCellWithIdentifier:@"FlyingLoadingCell" configuration:^(FlyingLoadingCell *cell) {
            //[self configureCell:cell atIndexPath:indexPath];
        }];
    }
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
            {
                [(FlyingContentTitleAndTypeCell *)cell setTitle:self.theLesson.title];
                [(FlyingContentTitleAndTypeCell *)cell setAccessRight:self.accessRight];
                
                break;
            }
            case 1:
            {
                [(FlyingContentSummaryCell*)cell setSummaryText:self.theLesson.desc];
                break;
            }
            case 2:
            {
                [(FlyingTagCell*)cell setTagList:self.theLesson.tag DataSourceDelegate:self];
                break;
            }
                
            default:
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        NSInteger actualNumberOfRows = [self.currentData count];
        
        if (actualNumberOfRows == 0) {
            
            [(FlyingContentSummaryCell*)cell setSummaryText:@"骄傲的去做第一个评论者吧!"];
            [(FlyingContentSummaryCell*)cell setTextAlignment:NSTextAlignmentCenter];
        }
        else
        {
            FlyingCommentData *commentData = self.currentData[indexPath.row];
            [(FlyingCommentCell*)cell setCommentData:commentData];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        return;
    }
    
    // 加载更多
    [self.loadingCommentIndicatorCell startAnimating:@"尝试加载更多..."];
    
    // 加载下一页
    [self loadMore];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        return;
    }
    
    // 加载更多
    [self.loadingCommentIndicatorCell stopAnimating];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
                
            case 1:
            {
                break;
            }
        }
    }
    else if (indexPath.section == 1)
    {
        
        NSInteger actualNumberOfRows = [self.currentData count];
        
        if (actualNumberOfRows == 0) {
            
            [self commentHeaderPressed];
        }
        else
        {
            FlyingCommentData* commentData = [_currentData objectAtIndex:indexPath.row];
            
            [self profileImageViewPressed:commentData];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma cell related
//////////////////////////////////////////////////////////////

- (void)selectedTag:(NSString *)tagName tagList:(DWTagList *) tagList
{
    if ([tagName isEqualToString:@"没有标签"] || [tagName isEqualToString:@""] || !tagName ) {
        
        return;
    }
    
    FlyingLessonListViewController *lessonList = [[FlyingLessonListViewController alloc] init];
    [lessonList setTagString:tagName];
    [self.navigationController pushViewController:lessonList animated:YES];
}

- (void)profileImageViewPressed:(FlyingCommentData*)commentData
{
    
    if ([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:[commentData.userID MD5]])
    {
    
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id myProfileVC = [storyboard instantiateViewControllerWithIdentifier:@"myAccount"];
        
        [self.navigationController pushViewController:myProfileVC animated:YES];
    }
    else
    {
        if ([NSString getUserPortraitUri].length==0) {
            
            [self.view makeToast:@"请创建自己头像先！左上角->菜单－》账户->修改头像（昵称）噢"];
        }
        else
        {
            RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
            
            NSString* userID = [commentData.userID MD5];
            
            RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:userID];
            chatService.userName = userInfo.name;
            chatService.targetId = userID;
            chatService.conversationType = ConversationType_PRIVATE;
            chatService.title = chatService.userName;
            [self.navigationController pushViewController:chatService animated:YES];
        }
    }

    /*
    NSString *openID = [NSString getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    if ([openID isEqualToString:commentData.userID])
    {
        //个人档案页
    }
    else
    {
    }
     */
}

- (void)accessButtonPressed
{
    if (!self.accessRight) {
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate presentStoreView];
    }
}

- (void)commentHeaderPressed
{
    FlyingCommentVC *commentVC =[[FlyingCommentVC alloc] init];
    
    commentVC.contentID=self.theLesson.lessonID;
    commentVC.contentType=self.theLesson.contentType;
    commentVC.commentTitle=self.theLesson.title;
    
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
    [self checkUserAccessRight];
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
    return [NSURL fileURLWithPath:[(FlyingLessonData*)[[[FlyingLessonDAO alloc] init] selectWithLessonID:self.theLesson.lessonID] localURLOfContent]];
}
//////////////////////////////////////////////////////////////
#pragma mark get data from offical website
//////////////////////////////////////////////////////////////
+(void) downloadRelated:(FlyingPubLessonData *) theLesson
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_queue_t _background_queue = [appDelegate getAIQueue];

    //保存封面图,离线已经不需要保存了
    //[UIImagePNGRepresentation(self.lessonCoverImageView.image) writeToFile:_lessonData.localURLOfCover  atomically:YES];
    
    //缓存字幕
    dispatch_async(_background_queue, ^{
        
        [FlyingContentVC getSrtForLessonID:theLesson.lessonID Title:theLesson.title];
    });
    
    //缓存课程字典
    dispatch_async(_background_queue, ^{
        
        [FlyingContentVC getDicWithURL:theLesson.pronunciationURL LessonID:theLesson.lessonID];
    });
    
    //缓存课程辅助资源
    dispatch_async(_background_queue, ^{
        
        [FlyingContentVC getRelativeWithURL:theLesson.relativeURL LessonID:theLesson.lessonID];
    });
}


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
                
                [SSZipArchive unzipFileAtPath:lessonData.localURLOfPro toDestination:outputDir];
                
                
                //升级课程补丁
                [FlyingContentVC updateBaseDic:lessonID];
                
                [[NSFileManager defaultManager] removeItemAtPath:lessonData.localURLOfPro error:nil];
                [mylessonDAO updateProURL:nil LessonID:lessonID]; //表示已经缓存
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
                
                [SSZipArchive unzipFileAtPath:lessonData.localURLOfRelative toDestination:outputDir];
                
                [[NSFileManager defaultManager] removeItemAtPath:lessonData.localURLOfRelative error:nil];
                [mylessonDAO updateRelativeURL:nil LessonID:lessonID]; //表示已经缓存
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
                               [FlyingContentVC getDicWithURL:baseURLStr LessonID:lessonID];
                               
                           } failure:^(NSError *err) {
                               //
                           }];
}

//////////////////////////////////////////////////////////////
#pragma menu related
//////////////////////////////////////////////////////////////

- (void) showMenu
{
   [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)dismiss
{
    if(self.mediaVC)
    {
        [self.mediaVC dismiss];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doShare
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if (self.theLesson.weburl)
    {
        [appDelegate shareImageURL:self.theLesson.imageURL
                           withURL:self.theLesson.weburl
                             Title:self.theLesson.title
                              Text:self.theLesson.desc
                             Image:[self.contentCoverImageView.image makeThumbnailOfSize:CGSizeMake(90, 120)]];
    }
}

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

@end
