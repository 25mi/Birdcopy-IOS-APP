//
//  FlyingLessonVC.m
//  FlyingEnglish
//
//  Created by vincent on 3/11/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingLessonVC.h"

#import "shareDefine.h"
#import "FlyingPubLessonData.h"
#import "FlyingLessonData.h"
#import "FlyingLessonDAO.h"

#import "FlyingNowLessonData.h"
#import "FlyingNowLessonDAO.h"

#import "UICKeyChainStore.h"

#import "iFlyingAppDelegate.h"

#import "SoundPlayer.h"

#import "NSString+FlyingExtention.h"

#import "FlyingM3U8Downloader.h"
#import "FlyingMyLessonsViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "UIImage+localFile.h"
#import "RESideMenu.h"
#import "FlyingSubTitle.h"
#import "SIAlertView.h"
#import "UIView+Autosizing.h"
#import "UIImageView+WebCache.h"
#import "UIImage+localFile.h"

#import "FlyingWebViewController.h"
#import "FlyingDialogViewController.h"

#import "FlyingLoadingView.h"
#import "FlyingLessonParser.h"
#import "ReaderViewController.h"

#import "FlyingTouchDAO.h"
#import "FlyingTouchRecord.h"
#import "FlyingStatisticDAO.h"
#import "FlyingSysWithCenter.h"
#import "FlyingLessonListViewController.h"

#import <ZXMultiFormatWriter.h>
#import <ZXImage.h>
#import "FlyingSearchViewController.h"

#import "FlyingWordDetailVC.h"
#import "FlyingSeparateView.h"

#import <StoreKit/SKPaymentQueue.h>
#import <Foundation/NSAttributedString.h>
#import <Foundation/NSKeyedArchiver.h>
#import <Foundation/NSLinguisticTagger.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVMediaFormat.h>
#import <QuartzCore/CALayer.h>

#import "FlyingAILearningView.h"
#import "FlyingGestureControlView.h"
#import "FlyingSubtitleTextView.h"
#import "FlyingReference.h"
#import "FlyingWordLinguisticData.h"
#import "FlyingSubRipItem.h"
#import "FlyingSubTitle.h"
#import "ACMagnifyingGlass.h"
#import "FlyingMyLessonsViewController.h"
#import "FlyingLessonData.h"
#import "FlyingLessonDAO.h"
#import "FlyingNowLessonData.h"
#import "FlyingNowLessonDAO.h"
#import "FlyingTaskWordDAO.h"
#import "UICKeyChainStore.h"
#import "FlyingTagTransform.h"
#import "NSString+FlyingExtention.h"
#import "SoundPlayer.h"
#import "iFlyingAppDelegate.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "AFDownloadRequestOperation.h"
#import "FlyingStatisticDAO.h"
#import "FlyingTouchDAO.h"
#import "UIView+Autosizing.h"
#import "SIAlertView.h"
#import "UIImage+localFile.h"
#import "FlyingM3U8Downloader.h"

#import "FlyingPlayerView.h"
#import "FlyingStytleView.h"

#import "NSString+FlyingExtention.h"
#import "FlyingSysWithCenter.h"
#import "FlyingLessonVC.h"

#import "FlyingItemView.h"
#import "FlyingItemData.h"
#import "FlyingScrollView.h"
#import "MotionOrientation.h"

#import <MediaPlayer/MPVolumeView.h>
#import "FlyingTaskWordDAO.h"

#import "UIView+Toast.h"

#import "RCDChatViewController.h"
#import <AFNetworking.h>
#import "UIView+Toast.h"
#import "AFHttpTool.h"

static void *FlyingViewControllerPlayerItemStatusObserverContext = &FlyingViewControllerPlayerItemStatusObserverContext;
static void *FlyingViewControllerSubtitlStatusObserverContext    = &FlyingViewControllerSubtitlStatusObserverContext;
static void *FlyingViewControllerRateObservationContext          = &FlyingViewControllerRateObservationContext;
static void *FlyingViewControllerTrackObservationContext         = &FlyingViewControllerTrackObservationContext;

@interface FlyingLessonVC ()
{
    FlyingLessonDAO     *  _lessonDAO;
    FlyingNowLessonDAO  *  _nowLessonDAO;
    
    FlyingLessonData    *_lessonData;
    FlyingNowLessonData *_nowLessonData;
    
    NSString            * _currentPassport;
    
    //后台处理
    dispatch_queue_t   _background_queue;
    dispatch_source_t  _UpdateDownlonaSource;
    
    BOOL               _hasRight;
    BOOL               _playonline;
    BOOL               _saveToLocal;
    BOOL               _hasHistoryRecord;
    BOOL               _hasCheckedHistoryRecord;
    
    CGFloat            _margin;
    float              _width;
    
    //视频专用
    FlyingSubTitle           *_subtitleFile;
    NSMutableDictionary      *_annotationWordViews;
    
    ACMagnifyingGlass        *_mag;
    FlyingWordLinguisticData *_theOnlyTagWord;
    
    BOOL                     _enableUpdateSub;
    BOOL                     _enableAISub;
    
    NSLinguisticTagger       * _flyingNPL;
    NSMutableArray           * _tagAndTokens;
    
    UIImage                  *_lastScreen;
    
    FlyingTagTransform       *_tagTransform;
    
    //Record NPL managemnet
    dispatch_source_t         _NPLSource;
    
    SoundPlayer              *_speechPlayer;
    NSTimeInterval            _initialPlaybackTime;
    
    NSInteger                 _balanceCoin;
    NSInteger                 _touchWordCount;
    
    FlyingTouchDAO           *_touchDAO;
    
    NSString                 * _movieURLStr;
    BE_Vedio_Type              _contentType;
    NSTimeInterval             _totalDuration;
    
    double                     _startTime;
    double                     _endTime;
    
    //播放控制
    int32_t                   _timeScale;
    BOOL                      _firstPlaying;    //帮助判断是否需要自己播放
    NSTimeInterval            _error;           //字幕播放误差
    BOOL                      _isClosedFlag;    //关闭标志，控制是或否背后播放
    
    //M3U8相关
    UIWebView                * _webView;
    BOOL                       _needShareM3U8URL;
    BOOL                       _parseContentURLOK;
    BOOL                       _needParserContentURL;
    
    BOOL                       _lockScreen;
    
    float                      _ratioHeightToW;
    CGSize                     _standardSize;
    
    UILabel                   *_lessonSumarySep;
    UILabel                   *_relatedContentSep;
    UILabel                   *_lessonTagSep;
    UILabel                   *_keyPointSep;
    UILabel                   *_keyWordSep;
    UILabel                   *_qrcodeSep;
}

@property (strong, nonatomic) UIView              *contentView;
@property (strong, nonatomic) UIImageView         *lessonCoverImageView;
@property (strong, nonatomic) UIImageView         *playImageView;

@property (strong, nonatomic) FlyingScrollView    *otherScroll;

@property (strong, nonatomic) UIView              *buyAndDownloadView;
@property (strong, nonatomic) UILabel             *lessonTitleLabel;
@property (strong, nonatomic) UIButton            *buyButton;

@property (strong, nonatomic) UILabel   *lessonSummaryLabel;
@property (strong, nonatomic) DWTagList *lessonTagView;

@property (strong, nonatomic) UILabel   *keypointLabel;
@property (strong, nonatomic) DWTagList *KeyWordTagView;

@property (strong, nonatomic) UIImageView *QRImageView;


@property (strong, nonatomic) AVPlayer          *player;
@property (strong, nonatomic) AVPlayerItem      *playerItem;
@property (strong, nonatomic) FlyingPlayerView  *playerView;
@property (strong, nonatomic) id                 playerObserver;

@property (strong, nonatomic) FlyingAILearningView     *aiLearningView;
@property (strong, nonatomic) FlyingGestureControlView *gestureControlView;

@property (strong, nonatomic) UIView                  *buttonsView;
@property (strong, nonatomic) UIImageView             *lockImageView;
@property (strong, nonatomic) UISlider                *slider;
@property (strong, nonatomic) UILabel                 *timeLabe;

@property (strong, nonatomic) UIImageView              *magicImageView;
@property (strong, nonatomic) UIImageView              *fullImageView;

@property (strong, nonatomic) FlyingStytleView         *stytleView;
@property (strong, nonatomic) FlyingSubtitleTextView   *subtitleTextView;

@property (strong, nonatomic) UIActivityIndicatorView  *indicatorView;

@property (assign, nonatomic) NSTimeInterval            timestamp;

@property (assign, nonatomic) UIDeviceOrientation       deviceOrientation;


@property (strong, nonatomic) UIButton                 *chatRoomButton;

@end

@implementation FlyingLessonVC

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *retViewController = [[FlyingLessonVC alloc] initWithNibName:nil bundle:nil];
    return retViewController;
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.theLesson forKey:@"theLesson"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.theLesson = [coder decodeObjectForKey:@"theLesson"];
    
    [self commonInit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = @"FlyingLessonVC";
    self.restorationClass      = [self class];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //更新欢迎语言
    self.title =@"课程详情";
    
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
    
    image= [UIImage imageNamed:@"search"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    image= [UIImage imageNamed:@"share"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* shareButton= [[UIButton alloc] initWithFrame:frame];
    [shareButton setBackgroundImage:image forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* shareBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareBarButtonItem,searchBarButtonItem,nil];
    
    [self commonInit];
}

- (void) commonInit
{
    if (INTERFACE_IS_PAD)
    {
        _margin=MARGIN_ipad;
    }
    else{
        _margin=MARGIN_iphone;
    }
    _width=self.view.bounds.size.width-2*_margin;

    [self initData];
    
    _standardSize = [[UIScreen mainScreen] bounds].size;
    
    if (_standardSize.height>_standardSize.width)
    {
        _ratioHeightToW = _standardSize.width/_standardSize.height;
    }
    else
    {
        _ratioHeightToW = _standardSize.height/_standardSize.height;
        
        float temp=_standardSize.height;
        _standardSize.height=_standardSize.width;
        _standardSize.width=temp;
    }
    
    self.deviceOrientation=UIInterfaceOrientationPortrait;
    
    [self initTitle];
    
    [self prepareContentView];
    [self prepareOtherContent];
    
    //监控下载更新
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(godReset)
                                                 name:KGodIsComing
                                               object:nil];
    
    [self addBackFunction];
}

-(void) prepareForChatRoom
{
    if (INTERFACE_IS_PAD) {
        
        return;
    }
    
    if(self.chatRoomButton)
    {
        [self.view  bringSubviewToFront:self.chatRoomButton];
    }
    else
    {
        CGRect chatButtonFrame=self.view.frame;
        
        CGRect frame=self.view.frame;
        
        chatButtonFrame.size.width  = frame.size.width/8;
        chatButtonFrame.size.height = frame.size.width/8;
        chatButtonFrame.origin.x    = frame.size.width*8/10;
        chatButtonFrame.origin.y    = frame.size.height-frame.size.width/5;
        
        self.chatRoomButton = [[UIButton alloc] initWithFrame:chatButtonFrame];
        [self.chatRoomButton setBackgroundImage:[UIImage imageNamed:@"chat"]
                                       forState:UIControlStateNormal];
        [self.chatRoomButton addTarget:self action:@selector(doChatRoom) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.chatRoomButton];
    }
}

-(void) doChatRoom
{
    if (_hasRight) {
        
        RCDChatViewController *chatRoomVC = [[RCDChatViewController alloc]init];
        chatRoomVC.targetId = self.theLesson.lessonID;
        chatRoomVC.conversationType = ConversationType_CHATROOM;
        chatRoomVC.title = self.theLesson.title;
        
        [self.navigationController pushViewController:chatRoomVC animated:YES];
    }
    else
    {
        NSString *title = @"友情提醒";
        NSString *message = @"只有购买内容用户才能才能参与聊天？";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"点错了"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        [alertView addButtonWithTitle:@"确认购买内容"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  
                                  [self buyLessonWithCoin];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
    }
}

-(void) initData
{
    _currentPassport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];

    if(!_background_queue){
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        _background_queue = [appDelegate getAIQueue];
    }
    
    if (!_lessonDAO) {
        
        _lessonDAO = [[FlyingLessonDAO alloc] init];
    }
    
    if (!_nowLessonDAO) {
        
        _nowLessonDAO =[[FlyingNowLessonDAO alloc] init];
    }
    
    _hasRight=NO;
    
    if(self.theLesson.coinPrice==0) _hasRight=YES;
    
    if(!_hasRight){
        
        FlyingTouchRecord * touchData = [[FlyingTouchDAO new] selectWithUserID:_currentPassport
                                                                      LessonID:self.theLesson.lessonID];
        if(touchData.BETOUCHTIMES>0) _hasRight=YES;
    }
    
    _playonline=NO;
    _saveToLocal=NO;
    _hasHistoryRecord=NO;
    _hasCheckedHistoryRecord=NO;
    
    _lockScreen=NO;
    
    _lessonData    = [_lessonDAO selectWithLessonID:self.theLesson.lessonID];
    _nowLessonData = [_nowLessonDAO selectWithUserID:_currentPassport LessonID:self.theLesson.lessonID];
}

-(void) initTitle
{
    //大标题
    if([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
    {
        self.title =@"网页详情";
    }
    else if([self.theLesson.contentType isEqualToString:KContentTypeText])
    {
        self.title =@"文档详情";
    }
    else if ([self.theLesson.contentType isEqualToString:KContentTypeVideo])
    {
        self.title =@"视频详情";
    }
    else if([self.theLesson.contentType isEqualToString:KContentTypeAudio])
    {
        self.title =@"音频详情";
    }
    else
    {
        self.title =@"内容详情";
    }
}

-(void) prepareContentView
{
    if (!self.contentView) {

        float contentWidth=self.view.bounds.size.width;
        float contentHeight=contentWidth*_ratioHeightToW;
        CGRect contentFrame = CGRectMake(0, 0, contentWidth, contentHeight);
        
        self.contentView = [[UIView alloc] initWithFrame:contentFrame];
        [self.contentView setBackgroundColor:[UIColor blackColor]];
        //[self.contentView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.view addSubview:self.contentView];
    }
    
    //添加课程截图
    if (!self.lessonCoverImageView) {

        float contentWidth=self.view.bounds.size.width;
        float contentHeight=contentWidth*_ratioHeightToW;
        CGRect contentFrame = CGRectMake(0, 0, contentWidth, contentHeight);

        self.lessonCoverImageView = [[UIImageView alloc] initWithFrame:contentFrame];
        self.lessonCoverImageView.opaque=NO;
        self.lessonCoverImageView.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.lessonCoverImageView];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_nowLessonData.BELOCALCOVER])
    {
        [self.lessonCoverImageView setImage:[UIImage imageWithContentsOfFile:_nowLessonData.BELOCALCOVER]];
    }
    else
    {
        NSString *localURLOfCover =[(FlyingLessonData*)[_lessonDAO selectWithLessonID:self.theLesson.lessonID] localURLOfCover];
        if ([[NSFileManager defaultManager] fileExistsAtPath:localURLOfCover])
        {
            [self.lessonCoverImageView setImage:[UIImage imageWithContentsOfFile:localURLOfCover]];
        }
        else
        {
            [self.lessonCoverImageView sd_setImageWithURL:[NSURL URLWithString:self.theLesson.imageURL]
                                         placeholderImage:[UIImage imageNamed:@"Deafult"]
                                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                }];
        }
    }
    
    [self initPlayButton];
}

-(void) initPlayButton
{
    if (!self.playImageView) {
        
        float contentHeight =self.contentView.bounds.size.height;
        
        float playButtonSide=contentHeight/2.0;
        
        CGRect playbuttonFrame = CGRectMake((self.contentView.bounds.size.width-playButtonSide)/2.0, playButtonSide/2.0, playButtonSide, playButtonSide);
        self.playImageView = [[UIImageView alloc] initWithFrame:playbuttonFrame];
        self.playImageView.userInteractionEnabled=YES;
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playNow:)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [self.playImageView addGestureRecognizer:singleRecognizer];
        
        [self.contentView addSubview:self.playImageView];
    }
    
    if ([self.theLesson.contentType isEqualToString:KContentTypeText])
    {
        [self.playImageView setImage:[UIImage imageNamed:PlayDocIcon]];
    }
    else if ([self.theLesson.contentType isEqualToString:KContentTypeVideo])
    {
        [self.playImageView setImage:[UIImage imageNamed:PlayVideoIcon]];
    }
    else  if ([self.theLesson.contentType isEqualToString:KContentTypeAudio])
    {
        [self.playImageView setImage:[UIImage imageNamed:PlayAudioIcon]];
    }
    else  if ([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
    {
        [self.playImageView setImage:[UIImage imageNamed:PlayWebIcon]];
    }
}

- (void) prepareOtherContent
{
    if (!self.otherScroll) {
        
        float height=self.view.frame.size.height-self.contentView.frame.size.height;
        CGRect frame = CGRectMake(0, self.contentView.frame.size.height, self.view.bounds.size.width, height);

        self.otherScroll = [[FlyingScrollView alloc] initWithFrame:frame];
        [self.view addSubview:self.otherScroll];
    }
    
    [self prepareBuyAndDownloadView];
    
    [self prepareLessonSummary];
    [self prepareLessonTagCloud];
    
    [self.otherScroll setShowsHorizontalScrollIndicator:NO];
    [self.otherScroll setShowsVerticalScrollIndicator:YES];
    [self.otherScroll setBounces:YES];
    
    self.otherScroll.contentSize =self.view.frame.size;
    
    [self prepareMoreContent];
}

- (void) prepareMoreContent
{
    [AFHttpTool lessonResourceType:kResource_Keypoint
                          lessonID:self.theLesson.lessonID
                        contentURL:nil
                             isURL:NO
                           success:^(id response) {
                               //
                               if (response) {
                                   
                                   NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                   [self prepareKeypoint:tempStr];
                               }
                               else
                               {
                                   [self prepareKeypoint:nil];
                               }
                               
                               [AFHttpTool lessonResourceType:kResource_KeyWord
                                                     lessonID:self.theLesson.lessonID
                                                   contentURL:nil
                                                        isURL:NO
                                                      success:^(id response) {
                                                          //
                                                          if (response) {
                                                              
                                                              NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                                              [self prepareKeyWordTagCloud:tempStr];
                                                          }
                                                          else
                                                          {
                                                              [self prepareKeyWordTagCloud:nil];
                                                          }
                                                          
                                                          [self prepareQRCode];
                                                          
                                                          [self prepareForChatRoom];
                                                          
                                                          float sizeOfContent =self.QRImageView.frame.origin.y+self.QRImageView.frame.size.height;
                                                          self.otherScroll.contentSize =CGSizeMake( self.view.bounds.size.width, sizeOfContent*1.2);

                                                      } failure:^(NSError *err) {
                                                          //
                                                          NSLog(@"lessonResourceType:kResource_KeyWord:%@",err.description);
                                                      }];
                               
                           } failure:^(NSError *err) {
                               //
                               NSLog(@"kResource_Keypoint:%@",err.description);
                           }];
}

-(void) prepareBuyAndDownloadView
{
    if (!self.buyAndDownloadView) {
        
        float buyAndDownloadViewWidth=self.view.bounds.size.width;
        float buyAndDownloadHeight=buyAndDownloadViewWidth*60/320;
        CGRect buyAndDownloadFrame = CGRectMake(0, 0, buyAndDownloadViewWidth, buyAndDownloadHeight);

        self.buyAndDownloadView = [[UIView alloc] initWithFrame:buyAndDownloadFrame];
        [self.otherScroll addSubview:self.buyAndDownloadView];
    }
    
    [self initLessonTitle];
    [self initBuyButton];
}

-(void) initLessonTitle
{
    if (!self.lessonTitleLabel) {
        float titleLableWidth=_width*2/3;
        float titleLableHeight=self.buyAndDownloadView.bounds.size.height;
        CGRect titleLabelFrame = CGRectMake(_margin, 0, titleLableWidth, titleLableHeight);
        self.lessonTitleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        
        [self.buyAndDownloadView addSubview:self.lessonTitleLabel];
    }
    
    //课程标题
    [self.lessonTitleLabel setText:[NSString stringWithFormat:@"《%@》",self.theLesson.title]];
    
    if (INTERFACE_IS_PAD)
    {
        self.lessonTitleLabel.font         = [UIFont systemFontOfSize:font_ipad_size];
    }
    else
    {
        self.lessonTitleLabel.font         = [UIFont systemFontOfSize:font_iphone_size];
    }
    
    self.lessonTitleLabel.numberOfLines = 0;
    self.lessonTitleLabel.textColor=[UIColor blackColor];
    self.lessonTitleLabel.textAlignment=NSTextAlignmentCenter;
}

-(void) initBuyButton
{
    if (!self.buyButton) {
        
        float buyButtonWidth=_width*1/3;
        float buyButtonHeight=self.buyAndDownloadView.bounds.size.height/2;
        CGRect buyButtonFrame = CGRectMake(self.lessonTitleLabel.frame.origin.x+self.lessonTitleLabel.frame.size.width, buyButtonHeight/2, buyButtonWidth, buyButtonHeight);
        self.buyButton = [[UIButton alloc] initWithFrame:buyButtonFrame];
        [self.buyButton setBackgroundImage:[UIImage imageNamed:@"greenbutton"]
                                  forState:UIControlStateNormal];
        [self.buyButton addTarget:self action:@selector(buyOrDownloadNow) forControlEvents:UIControlEventTouchUpInside];
        
        [self.buyAndDownloadView addSubview:self.buyButton];
    }
    
    if (INTERFACE_IS_PAD)
    {
        self.buyButton.titleLabel.font     = [UIFont systemFontOfSize:font_ipad_size];
    }
    else
    {
        self.buyButton.titleLabel.font     = [UIFont systemFontOfSize:font_iphone_size];
    }
    
    //校验是否有内容权限
    if(!_hasRight)
    {
        [self.buyButton setTitle:[NSString stringWithFormat:@"%d金币",self.theLesson.coinPrice] forState:UIControlStateNormal];
        
        [self inquiryRightWithUserID:_currentPassport];
    }
    else
    {
        if (!self.theLesson.canDownloaded) {
        
            [self.buyButton setTitle:@"版权方禁止下载" forState:UIControlStateNormal];
            [self.buyButton setEnabled:NO];
        }
        else
        {
            if([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
            {
                [self.buyButton setTitle:@"马上欣赏" forState:UIControlStateNormal];
                
                return;
            }
            
            if (_lessonData)
            {
                if (_lessonData.BEDLPERCENT==1)
                {
                    [self.buyButton setTitle:@"马上欣赏" forState:UIControlStateNormal];
                }
                else
                {
                    if(_lessonData.BEDLSTATE==YES)
                    {
                        [self.buyButton setTitle:[NSString stringWithFormat:@"下载:%.2f%%",_lessonData.BEDLPERCENT*100] forState:UIControlStateNormal];;
                    }
                    else
                    {
                        [self.buyButton setTitle:@"离线收藏" forState:UIControlStateNormal];
                    }
                }
            }
            else
            {
                if([self.theLesson.downloadType isEqualToString:KDownloadTypeM3U8])
                {
                    //非官方、非大陆
                    if(![NSString isInMainland] && ![NSString checkOfficialURL:self.theLesson.contentURL])
                    {
                        [self.contentView makeToast:@"抱歉：版权原因,非大陆地区可能不能使用此课程!" duration:3 position:CSToastPositionCenter];
                    }
                    else if( ![NSString checkM3U8URL:self.theLesson.contentURL]&& INTERFACE_IS_PAD)
                    {
                        //是平板又不是M3U8直接资源地址
                        
                        [self.buyButton   setEnabled:NO];
                        [self.buyButton setTitle:@"暂时不支持IPAD！" forState:UIControlStateNormal];
                        
                        [self.contentView makeToast:@"抱歉：请使用iPhone终端观看后才能使用IPAD观看!" duration:3 position:CSToastPositionCenter];
                    }
                    else
                    {
                        [self.buyButton setTitle:@"离线收藏" forState:UIControlStateNormal];
                    }
                }
                else
                {
                    [self.buyButton setTitle:@"离线收藏" forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void) prepareLessonSummary
{
    if (!self.lessonSummaryLabel)
    {
        _lessonSumarySep =[[UILabel alloc] initWithFrame:CGRectZero];
        [_lessonSumarySep setText:@"内容概述"];
        
        if (INTERFACE_IS_PAD)
        {
            _lessonSumarySep.font = [UIFont boldSystemFontOfSize:font_ipad_size];
        }
        else
        {
            _lessonSumarySep.font = [UIFont boldSystemFontOfSize:font_iphone_size];
        }
        
        _lessonSumarySep.backgroundColor=[UIColor clearColor];
        _lessonSumarySep.numberOfLines=1;
        _lessonSumarySep.textAlignment=NSTextAlignmentLeft;
        _lessonSumarySep.textColor=[UIColor blackColor];
        
        [self.otherScroll addSubview:_lessonSumarySep];
        
        self.lessonSummaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lessonSummaryLabel.numberOfLines=0;
        self.lessonSummaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.lessonSummaryLabel.textAlignment = NSTextAlignmentLeft;
        
        if (INTERFACE_IS_PAD ) {
            
            self.lessonSummaryLabel.font = [UIFont systemFontOfSize:font_ipad_size];
        }
        else
        {
            self.lessonSummaryLabel.font = [UIFont systemFontOfSize:font_iphone_size];
        }
        
        [self.otherScroll addSubview:self.lessonSummaryLabel];
    }
    
    CGRect frame=CGRectMake(_margin,
                            self.buyAndDownloadView.frame.origin.y+self.buyAndDownloadView.frame.size.height,
                            _width,
                            self.view.frame.size.width*30/320);

    _lessonSumarySep.frame=frame;
    
    if (self.theLesson.desc.length!=0) {
        
        CGSize constraint = CGSizeMake(_width,MAXFLOAT);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = self.lessonSummaryLabel.font;
        gettingSizeLabel.text = self.theLesson.desc;
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        gettingSizeLabel.textAlignment = NSTextAlignmentLeft;
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
        
        [self.lessonSummaryLabel setText:self.theLesson.desc];
        self.lessonSummaryLabel.frame =CGRectMake(_margin,
                                                  _lessonSumarySep.frame.origin.y+_lessonSumarySep.frame.size.height,
                                                  _width,
                                                  expectSize.height);
    }
    else{
        
        self.lessonSummaryLabel.frame =CGRectMake(_margin,
                                                  _lessonSumarySep.frame.origin.y+_lessonSumarySep.frame.size.height,
                                                  _width,
                                                  0);
    }
}

- (void) prepareLessonTagCloud
{
    if(!self.lessonTagView)
    {
        _lessonTagSep =[[UILabel alloc] initWithFrame:CGRectZero];
        [_lessonTagSep setText:@"相关内容"];
        
        if (INTERFACE_IS_PAD)
        {
            _lessonTagSep.font = [UIFont boldSystemFontOfSize:font_ipad_size];
        }
        else
        {
            _lessonTagSep.font = [UIFont boldSystemFontOfSize:font_iphone_size];
        }
        
        _lessonTagSep.backgroundColor=[UIColor clearColor];
        _lessonTagSep.numberOfLines=1;
        _lessonTagSep.textAlignment=NSTextAlignmentLeft;
        _lessonTagSep.textColor=[UIColor blackColor];

        [self.otherScroll addSubview:_lessonTagSep];
        
        CGRect frame=CGRectMake(0,
                                0,
                                _width,
                                0);
        
        self.lessonTagView = [[DWTagList alloc] initWithFrame:frame];
        
        [self.lessonTagView setTagDelegate:self];
        [self.lessonTagView setCornerRadius:3];
        [self.lessonTagView setBorderWidth:0];
        [self.lessonTagView setTagBackgroundColor:[UIColor lightGrayColor]];

        [self.otherScroll addSubview:self.lessonTagView];
    }
    
    //分隔view计算位置
    CGRect frame=CGRectMake(_margin,
                            self.lessonSummaryLabel.frame.origin.y+self.lessonSummaryLabel.frame.size.height,
                            _width,
                            self.view.frame.size.width*30/320);

    _lessonTagSep.frame=frame;
    
    //tagview计算位置和内容
    if(self.theLesson.tag==nil || self.theLesson.tag.length==0)
    {
        [self.lessonTagView setHidden:YES];
        
        CGRect frame=CGRectMake(_margin,
                                _lessonTagSep.frame.origin.y+_lessonTagSep.frame.size.height,
                                _width,
                                0);
        //便于计算
        self.lessonTagView.frame=frame;
    }
    else
    {
        [self.lessonTagView setHidden:NO];
        
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSString *trimmedString = [regex stringByReplacingMatchesInString:self.theLesson.tag options:0 range:NSMakeRange(0, [self.theLesson.tag length]) withTemplate:@" "];
        
        NSArray * tagArray =[trimmedString componentsSeparatedByString:@" "];
        
        [self.lessonTagView setAutomaticResize:YES];
        if (tagArray && tagArray.count>0)
        {
            [self.lessonTagView setTags:tagArray];
        }
        else
        {
            [self.lessonTagView setTags:[NSArray arrayWithObject:@"没有标签"]];
        }
        
        CGRect frame=CGRectMake(_margin,
                                _lessonTagSep.frame.origin.y+_lessonTagSep.frame.size.height,
                                _width,
                                self.lessonTagView.contentSize.height);
        
        self.lessonTagView.frame=frame;
    }
}

- (void) prepareKeypoint:(NSString*) keypoint
{
    if (!self.keypointLabel) {
        
        _keypointLabel =[[UILabel alloc] initWithFrame:CGRectZero];
        [_keypointLabel setText:@"重点提示"];
        
        if (INTERFACE_IS_PAD)
        {
            _keypointLabel.font = [UIFont boldSystemFontOfSize:font_ipad_size];
        }
        else
        {
            _keypointLabel.font = [UIFont boldSystemFontOfSize:font_iphone_size];
        }
        
        _keypointLabel.backgroundColor=[UIColor clearColor];
        _keypointLabel.numberOfLines=1;
        _keypointLabel.textAlignment=NSTextAlignmentLeft;
        _keypointLabel.textColor=[UIColor blackColor];
        
        [self.otherScroll addSubview:_keypointLabel];
        
        
        self.keypointLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.keypointLabel.numberOfLines=0;
        self.keypointLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.keypointLabel.textAlignment = NSTextAlignmentLeft;
        
        if (INTERFACE_IS_PAD ) {
            
            self.keypointLabel.font = [UIFont systemFontOfSize:font_ipad_size];
        }
        else
        {
            self.keypointLabel.font = [UIFont systemFontOfSize:font_iphone_size];
        }
        
        [self.otherScroll addSubview:self.keypointLabel];
    }
    
    //keypoint 分隔计算
    CGRect frame=CGRectMake(_margin,
                            self.lessonTagView.frame.origin.y+self.lessonTagView.frame.size.height,
                            _width,
                            self.view.frame.size.width*30/320);
    
    _keypointLabel.frame=frame;
    
    //计算 keypoint
    if(keypoint!=nil &&keypoint.length!=0)
    {
        CGSize constraint = CGSizeMake(_width,MAXFLOAT);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = self.keypointLabel.font;
        gettingSizeLabel.text = self.theLesson.desc;
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        gettingSizeLabel.textAlignment = NSTextAlignmentLeft;
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
        
        [self.keypointLabel setText:keypoint];
        self.keypointLabel.frame =CGRectMake(_margin,
                                             _keypointLabel.frame.origin.y+_keypointLabel.frame.size.height,
                                             _width,
                                             expectSize.height);
    }
    else
    {
        [self.keypointLabel setHidden:YES];
        self.keypointLabel.frame =CGRectMake(_margin,
                                             _keypointLabel.frame.origin.y+_keypointLabel.frame.size.height,
                                             _width,
                                             0);
    }
}

- (void) prepareKeyWordTagCloud:(NSString*) keyWordString
{
    if (!self.KeyWordTagView) {
        
        _keyWordSep =[[UILabel alloc] initWithFrame:CGRectZero];
        [_keyWordSep setText:@"重点单词"];
        
        if (INTERFACE_IS_PAD)
        {
            _keyWordSep.font = [UIFont boldSystemFontOfSize:font_ipad_size];
        }
        else
        {
            _keyWordSep.font = [UIFont boldSystemFontOfSize:font_iphone_size];
        }
        
        _keyWordSep.backgroundColor=[UIColor clearColor];
        _keyWordSep.numberOfLines=1;
        _keyWordSep.textAlignment=NSTextAlignmentLeft;
        _keyWordSep.textColor=[UIColor blackColor];
        
        [self.otherScroll addSubview:_keyWordSep];
        
        
        CGRect frame=CGRectMake(0,
                                0,
                                _width,
                                0);

        self.KeyWordTagView = [[DWTagList alloc] initWithFrame:frame];
        [self.KeyWordTagView setTagDelegate:self];
        [self.KeyWordTagView setCornerRadius:3];
        [self.KeyWordTagView setBorderWidth:0];
        [self.KeyWordTagView setTagBackgroundColor:[UIColor lightGrayColor]];
        [self.otherScroll addSubview:self.KeyWordTagView];
    }
    
    if(keyWordString.length!=0)
    {
        [_keyWordSep setHidden:NO];

        //计算keyword 分隔
        CGRect frame = CGRectMake(_margin,
                                  self.lessonTagView.frame.origin.y+self.lessonTagView.frame.size.height,
                                  _width,
                                  self.view.frame.size.width*30/320);
        
        _keyWordSep.frame=frame;
    }
    else
    {
        [_keyWordSep setHidden:YES];
        
        //计算方便
        CGRect frame = CGRectMake(_margin,
                                  self.lessonTagView.frame.origin.y+self.lessonTagView.frame.size.height,
                                  _width,
                                  0);
        
        _keyWordSep.frame=frame;
    }
    
    //tagview计算位置和内容
    if(keyWordString==nil || keyWordString.length==0)
    {
        [self.KeyWordTagView setHidden:YES];
        
        CGRect frame=CGRectMake(_margin,
                                _keyWordSep.frame.origin.y+_keyWordSep.frame.size.height,
                                _width,
                                0);
        //便于计算
        self.KeyWordTagView.frame=frame;
    }
    else
    {
        NSError *error = nil;
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSString *trimmedString = [regex stringByReplacingMatchesInString:keyWordString options:0 range:NSMakeRange(0, [keyWordString length]) withTemplate:@" "];
        
        NSArray * tagArray =[trimmedString componentsSeparatedByString:@" "];
        
        [self.KeyWordTagView setAutomaticResize:YES];
        if (tagArray && tagArray.count>0)
        {
            [self.KeyWordTagView setTags:tagArray];
        }
        else
        {
            [self.KeyWordTagView setTags:[NSArray arrayWithObject:@"没有标签"]];
        }
        
        CGRect frame=CGRectMake(_margin,
                                _keyWordSep.frame.origin.y+_keyWordSep.frame.size.height,
                                _width,
                                self.KeyWordTagView.contentSize.height);
        
        self.KeyWordTagView.frame=frame;
    }
}

- (void)selectedTag:(NSString *)tagName tagList:(DWTagList *) tagList
{
    if ([tagName isEqualToString:@"没有标签"] || [tagName isEqualToString:@""] || !tagName ) {
        
        return;
    }
    
    if ([tagList isEqual:self.lessonTagView])
    {
        FlyingLessonListViewController *lessonList = [[FlyingLessonListViewController alloc] init];
        [lessonList setTagString:tagName];
        [self.navigationController pushViewController:lessonList animated:YES];
    }
    else if ([tagList isEqual:self.KeyWordTagView])
    {
        FlyingWordDetailVC * wordDetail = [[FlyingWordDetailVC alloc] init];
        [wordDetail setTheWord:tagName];
        [self.navigationController pushViewController:wordDetail animated:YES];
    }
}

-(void) prepareQRCode
{
    if (!self.QRImageView) {
        
        _qrcodeSep =[[UILabel alloc] initWithFrame:CGRectZero];
        [_qrcodeSep setText:@"请扫描或者长按！"];
        
        if (INTERFACE_IS_PAD)
        {
            _qrcodeSep.font = [UIFont boldSystemFontOfSize:font_ipad_size];
        }
        else
        {
            _qrcodeSep.font = [UIFont boldSystemFontOfSize:font_iphone_size];
        }
        
        _qrcodeSep.backgroundColor=[UIColor clearColor];
        _qrcodeSep.numberOfLines=1;
        _qrcodeSep.textAlignment=NSTextAlignmentLeft;
        _qrcodeSep.textColor=[UIColor blackColor];
        
        [self.otherScroll addSubview:_qrcodeSep];
        
        self.QRImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.QRImageView.userInteractionEnabled = YES;
        [self.otherScroll addSubview:self.QRImageView];
    }
    
    /*
    CGRect frame;
    
    if (self.KeyWordTagView)
    {
        frame=CGRectMake(0,
                         self.KeyWordTagView.frame.origin.y+self.KeyWordTagView.frame.size.height,
                         self.view.frame.size.width,
                         self.view.frame.size.width*30/320);
    }
    else if (self.keypointLabel)
    {
        frame=CGRectMake(0,
                         self.keypointLabel.frame.origin.y+self.keypointLabel.frame.size.height,
                         self.view.frame.size.width,
                         self.view.frame.size.width*30/320);
    }
    else
    {
        frame=CGRectMake(0,
                         self.lessonTagView.frame.origin.y+self.lessonTagView.frame.size.height,
                         self.view.frame.size.width,
                         self.view.frame.size.width*30/320);
    }
    */
    
    
    CGRect frame=CGRectMake(_margin,
                     self.KeyWordTagView.frame.origin.y+self.KeyWordTagView.frame.size.height,
                     _width,
                     self.view.frame.size.width*30/320);
    
    _qrcodeSep.frame=frame;

    self.QRImageView.frame=CGRectMake(_margin+_width/4,
                                      _qrcodeSep.frame.origin.y+_qrcodeSep.frame.size.height,
                                      _width/2,
                                      _width/2);
    
    if(self.theLesson.weburl)
    {
        NSError *error = nil;
        ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
        ZXBitMatrix* result = [writer encode:self.theLesson.weburl
                                      format:kBarcodeFormatQRCode
                                       width:self.QRImageView.frame.size.width
                                      height:self.QRImageView.frame.size.width
                                       error:&error];
        
        if (result)
        {
            UIImage* uiImage = [[UIImage alloc] initWithCGImage:[[ZXImage imageWithMatrix:result] cgimage]];
            [self.QRImageView setImage:uiImage];
            
            UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTapQR:)];
            [self.QRImageView addGestureRecognizer:longTap];
        }
        else
        {
            //NSString *errorMessage = [error localizedDescription];
            [self.QRImageView setImage:[UIImage imageNamed:@"logo"]];
        }
    }
    else
    {
        //NSString *errorMessage = [error localizedDescription];
        [self.QRImageView setImage:[UIImage imageNamed:@"logo"]];
    }
}

- (void)handleLongTapQR:(UILongPressGestureRecognizer *)recognizer
{
    if(recognizer.state==UIGestureRecognizerStateBegan)
    {
        NSString *title = @"确认";
        NSString *message = @"需要保存二维码到相册吗？";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"点错了"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        [alertView addButtonWithTitle:@"确认"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  
                                  [self saveImageToPhotos:self.QRImageView.image];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
    }
}

- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if(error != NULL)
    {
        [self.view makeToast:@"保存二维码失败，再试试了：）"];
    }
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{
    self.contentView=nil;
    self.lessonCoverImageView=nil;
    self.playImageView=nil;
    self.otherScroll=nil;
    self.buyAndDownloadView=nil;
    self.lessonTitleLabel=nil;
    self.buyButton=nil;
    self.lessonTagView=nil;
    self.lessonSummaryLabel=nil;
    self.KeyWordTagView=nil;
    self.keypointLabel=nil;
    self.QRImageView=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

//////////////////////////////////////////////////////////////
#pragma mark download and play
//////////////////////////////////////////////////////////////
- (void)playNow:(id)sender
{
    if(!_hasRight)
    {
        [self.contentView makeToast:@"请购买或者联网同步购买记录!!" duration:3 position:CSToastPositionCenter];
    }
    else
    {
        if (!_lessonData)
        {
            if ([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
            {
                [self playLesson:self.theLesson.lessonID];
            }
            else
            {
                //在线播放
                _playonline=YES;
                [self watchNetworkStateNow];
            }
        }
        else
        {
            if(_lessonData.BEDLPERCENT ==1)
            {
                [self playLesson:self.theLesson.lessonID];
            }
            else if(_lessonData.BEDLSTATE==YES)
            {
                [self.contentView makeToast:@"离线缓存中..." duration:3 position:CSToastPositionCenter];
            }
            else
            {
                [self buyOrDownloadNow];
            }
        }
    }
}

- (void) playLesson:(NSString *) lessonID
{
    [self.playImageView setHidden:YES];
    [self showLoadingIndicator];
    
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
                
                [self.playImageView setHidden:NO];
                [self hideLoadingIndicator];
            }
        }
    }
    else if([self.theLesson.contentType isEqualToString:KContentTypeAudio])
    {
        FlyingDialogViewController *dialogVC =[[FlyingDialogViewController alloc] init];
        [dialogVC setLessonID:lessonID];
        [self.navigationController pushViewController:dialogVC animated:YES];
        
        [self.playImageView setHidden:NO];
        [self hideLoadingIndicator];
    }
    else if ([self.theLesson.contentType isEqualToString:KContentTypeText])
    {
        NSString *extention = [self.theLesson.contentURL pathExtension];
        
        if ([extention isEqualToString:@"pdf"])
        {
            ReaderViewController *pdfVC= [[ReaderViewController alloc] init];
            [pdfVC setLessonID:lessonID];
            [pdfVC setPlayOnline:_playonline];
            
            pdfVC.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            [self  presentViewController:pdfVC animated:YES completion:NULL];
            
            [self.playImageView setHidden:NO];
            [self hideLoadingIndicator];
        }
        else
        {
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.delegate = self;
            
            // start previewing the document at the current section index
            previewController.currentPreviewItemIndex = 0;
            [[self navigationController] pushViewController:previewController animated:YES];
            
            [self.playImageView setHidden:NO];
            [self hideLoadingIndicator];
        }
    }
    else if ([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
    {
        FlyingWebViewController * webVC =[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
        [webVC setWebURL:self.theLesson.contentURL];
        [self.navigationController pushViewController:webVC animated:YES];
        
        [self.playImageView setHidden:NO];
        [self hideLoadingIndicator];
    }
    else if([self.theLesson.downloadType isEqualToString:KDownloadTypeM3U8] || [NSString checkMp4URL:self.theLesson.contentURL])
    {
        [self playVedio];
    }
    else
    {
        [self.contentView makeToast:@"抱歉：请升级支持新课程类型！" duration:3 position:CSToastPositionCenter];
        
        [self.playImageView setHidden:NO];
        [self hideLoadingIndicator];
    }
}

- (void)buyOrDownloadNow
{
    if(_hasRight || _hasHistoryRecord)
    {
        FlyingLessonData    * lessonData = [_lessonDAO selectWithLessonID:self.theLesson.lessonID];
        if(lessonData.BEDLPERCENT ==1)
        {
            if(self.player && self.player.rate==0)
            {
                [self playAndDoAI];
            }
            else
            {
                [self playLesson:self.theLesson.lessonID];
            }
        }
        else
        {
            if ([self.theLesson.contentType isEqualToString:KContentTypePageWeb])
            {
                [self playLesson:self.theLesson.lessonID];
            }
            else
            {
                _saveToLocal=YES;
                
                [self.buyButton setTitle:@"准备下载..." forState:UIControlStateNormal];
                [self watchNetworkStateNow];
            }
        }
    }
    else
    {
        if (_hasCheckedHistoryRecord)
        {
            
            [self alertBuyAction];
        }
        else
        {
            [self inquiryRightWithUserID:_currentPassport];
        }
    }
}

-(void) saveToDBForDownload:(BOOL) forDownload
{
    //插入公共课程记录
    _lessonData =  [[FlyingLessonData alloc] initWithPubData:self.theLesson];
    [_lessonDAO insertWithData:_lessonData];
    
    //个人记录
    if(forDownload){
        
        _nowLessonData = [[FlyingNowLessonData alloc] initWithLessonData:_lessonData];
        [_nowLessonDAO insertWithData:_nowLessonData];
        
        if([self.theLesson.contentType isEqualToString:KContentTypePageWeb]){
            
            [_lessonDAO  updateDowloadPercent:1 LessonID:self.theLesson.lessonID];
            [_lessonDAO updateDowloadState:YES LessonID:self.theLesson.lessonID];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KlessonStateChange object:nil userInfo:nil];
            
            //没有用下载管理、直接缓存
            //[self.delegate closeAndReleaseDownloaderForID:lessonID];
        }
    }
}

-(void) downloadRelated
{
    //保存封面图,离线已经不需要保存了
    //[UIImagePNGRepresentation(self.lessonCoverImageView.image) writeToFile:_lessonData.localURLOfCover  atomically:YES];
    
    //下载字幕
    dispatch_async(_background_queue, ^{
        
        [FlyingMyLessonsViewController getSrtForLessonID:self.theLesson.lessonID Title:self.theLesson.title];
    });
    
    //下载课程字典
    dispatch_async(_background_queue, ^{
        
        [FlyingMyLessonsViewController getDicWithURL:self.theLesson.pronunciationURL LessonID:self.theLesson.lessonID];
    });
    
    //下载课程辅助资源
    dispatch_async(_background_queue, ^{
        
        [FlyingMyLessonsViewController getRelativeWithURL:self.theLesson.relativeURL LessonID:self.theLesson.lessonID];
    });
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    if(self.player)
    {
        [self playAndDoAI];
    }
    
    //监控下载更新
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadState:)
                                                 name:KlessonStateChange
                                               object:nil];
    
    //监控下载结束
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadOk:)
                                                 name:KlessonFinishTask
                                               object:nil];
    
    //监控设备方向
    [MotionOrientation sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(motionOrientationChanged:)
                                                 name:MotionOrientationChangedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //关闭实时监控
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KlessonStateChange    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KlessonFinishTask    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MotionOrientationChangedNotification    object:nil];
    
    if(self.player)
    {
        [self pauseAndDoAI];
    }
    
    [super viewWillDisappear:animated];
}

-(void)godReset
{
    if (self.player) {
        [self dismiss];
    }
}

- (void) updateDownloadState:(NSNotification*) aNotification
{
    if (!_UpdateDownlonaSource) {
        
        _UpdateDownlonaSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_event_handler(_UpdateDownlonaSource, ^{
            
            NSString * lessonID = [[aNotification userInfo] objectForKey:@"lessonID"];
            
            if([lessonID isEqualToString:self.theLesson.lessonID]){
                
                _lessonData    = [_lessonDAO selectWithLessonID:self.theLesson.lessonID];

                
                if (_lessonData.BEDLPERCENT==1)
                {
                    if (_saveToLocal)
                    {
                        [self.buyButton setTitle:@"现在欣赏" forState:UIControlStateNormal];
                    }
                }
                else
                {
                    if (_saveToLocal)
                    {
                        [self.buyButton setTitle:[NSString stringWithFormat:@"下载:%.2f%%",_lessonData.BEDLPERCENT*100] forState:UIControlStateNormal];
                    }
                    
                    if (_playonline && [self.theLesson.contentType isEqualToString:KContentTypeText])
                    {
                        [self.buyButton setTitle:@"缓存中..." forState:UIControlStateNormal];
                    }
                }
            }
        });
        dispatch_resume(_UpdateDownlonaSource);
    }
    
    dispatch_source_merge_data(_UpdateDownlonaSource, 1);
}

- (void) updateDownloadOk:(NSNotification*) aNotification
{
    NSString * lessonID = [[aNotification userInfo] objectForKey:@"lessonID"];
    
    if([lessonID isEqualToString:self.theLesson.lessonID])
    {
        //如果是直接播放的文本
        if([self.theLesson.contentType isEqualToString:KContentTypeText] && _playonline==YES)
        {
            [self playLesson:self.theLesson.lessonID];
            [self.buyButton setTitle:@"离线缓存" forState:UIControlStateNormal];
        }
        else
        {
            [self hideLoadingIndicator];
            [self initData];
            [self initPlayButton];
            [self initBuyButton];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////
- (void) watchNetworkStateNow
{
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        if (_playonline)
        {
            [self saveToDBForDownload:NO];
        }
        
        if(_saveToLocal)
        {
            [self saveToDBForDownload:YES];
        }
        
        //下载
        if (_playonline || _saveToLocal) {
            
            [self downloadRelated];
        }
        
        if (_playonline)
        {
            if([self.theLesson.contentType isEqualToString:KContentTypeText]){

                [self.playImageView setHidden:YES];
                [self showLoadingIndicator];
                
                iFlyingAppDelegate *delegate = (iFlyingAppDelegate *)[UIApplication sharedApplication].delegate;
                [delegate startDownloaderForID:self.theLesson.lessonID];
            }
            else
            {
                [self playLesson:self.theLesson.lessonID];
            }
        }
        
        if(_saveToLocal)
        {
            [self.buyButton setTitle:@"进入下载队列..." forState:UIControlStateNormal];
            if(![self.theLesson.contentType isEqualToString:KContentTypePageWeb]){
                
                iFlyingAppDelegate *delegate = (iFlyingAppDelegate *)[UIApplication sharedApplication].delegate;
                [delegate startDownloaderForID:self.theLesson.lessonID];
            }
        }
    }
    else
    {
        [self.buyButton setTitle:@"请联网再试！" forState:UIControlStateNormal];
    }
    
    //第一次版权提醒
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"BEEverDownload"])
    {
        [self.contentView makeToast:@"提醒：第三方提供内容！！" duration:3 position:CSToastPositionCenter];
        
        [[NSUserDefaults standardUserDefaults]  setBool:YES forKey:@"BEEverDownload"];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark Money and Right related
//////////////////////////////////////////////////////////////

- (void) inquiryRightWithUserID:(NSString *) currentPassport
{
    FlyingTouchRecord * touchData = [[FlyingTouchDAO new] selectWithUserID:currentPassport LessonID:self.theLesson.lessonID];
    
    if (touchData)
    {
        _hasRight=YES;
        [self initBuyButton];
        return;
    }
    
    //向服务器获取相关数据
    [AFHttpTool getTouchDataForUserID:currentPassport
                             lessonID:self.theLesson.lessonID
                              success:^(id response) {
                                  //
                                  if (response) {
                                      
                                      _hasCheckedHistoryRecord=YES;
                                      
                                      NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                      
                                      [[FlyingTouchDAO new] insertDataForUserID:currentPassport
                                                                       LessonID:self.theLesson.lessonID
                                                                     touchTimes:[tempStr integerValue]];
                                      
                                      if ([tempStr integerValue]>0)
                                      {
                                          _hasHistoryRecord=YES;
                                          _hasRight=YES;
                                          [self initBuyButton];
                                      }
                                      else
                                      {
                                          _hasHistoryRecord=NO;
                                      }
                                  }

                              } failure:^(NSError *err) {
                                  //
                              }];
}

-(void) alertBuyAction
{
    NSString *title = @"确认";
    NSString *message = @"请确认你要购买课程";
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alertView addButtonWithTitle:@"点错了"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                          }];
    [alertView addButtonWithTitle:@"购买"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              
                              [self buyLessonWithCoin];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    [alertView show];
}

- (void) buyLessonWithCoin
{
    FlyingStatisticDAO * statisticDAO = [FlyingStatisticDAO new];
    
    NSInteger balanceCoin  = [statisticDAO finalMoneyWithUserID:_currentPassport];
    NSInteger touchWordCount = [statisticDAO touchCountWithUserID:_currentPassport];
    
    if ((balanceCoin-self.theLesson.coinPrice)<=-500) {
        
        [SoundPlayer soundEffect:@"iMoneyDialogOpen"];
        
        NSString *title = @"付费提醒";
        NSString *message = [NSString stringWithFormat:@"你的信用额度已经用完,必须在《我的档案》充值才能继续使用!"];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
        return;
    }
    else{
        
        NSInteger sysTouchCount =[[NSUserDefaults standardUserDefaults] integerForKey:@"sysTouchAccount"];
        
        if (touchWordCount-sysTouchCount>1000) {
            
            [FlyingSysWithCenter uploadUserCenter];
            
            [SoundPlayer soundEffect:@"iMoneyDialogOpen"];
            NSString *title = @"同步提醒";
            NSString *message = [NSString stringWithFormat:@"你很久没有同步数据了,如果再次提醒请联网使用!"];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
            [alertView addButtonWithTitle:@"知道了"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView show];
            return;
        }
        
        if (balanceCoin<0)
        {
            [SoundPlayer soundEffect:@"iMoneyDialogOpen"];
            [self.contentView makeToast:@"提醒：帐户金币已经用完,请尽快在《我的档案》充值！" duration:3 position:CSToastPositionCenter];

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //更新点击次数和单词纪录
            [statisticDAO updateWithUserID:_currentPassport TouchCount:(touchWordCount+self.theLesson.coinPrice)];
            [[FlyingTouchDAO new] plusTouchTime:self.theLesson.coinPrice
                                     WithUserID:_currentPassport
                                       LessonID:self.theLesson.lessonID];
            
            //向服务器备份消费数据
            [FlyingSysWithCenter uploadUserCenter];
            
            _hasRight=YES;
            [self initBuyButton];
            [self buyOrDownloadNow];
            [SoundPlayer soundEffect:@"iMoneyDialogClose"];
        });
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
    return [NSURL fileURLWithPath:[(FlyingLessonData*)[_lessonDAO selectWithLessonID:self.theLesson.lessonID] localURLOfContent]];
}

//////////////////////////////////////////////////////////////
#pragma Menu and controller events
//////////////////////////////////////////////////////////////

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) doShare
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if (self.theLesson.weburl)
    {
        [appDelegate shareImageURL:self.theLesson.imageURL
                        withURL:self.theLesson.weburl
                          Title:self.theLesson.title
                           Text:self.theLesson.desc
         Image:[self.lessonCoverImageView.image makeThumbnailOfSize:CGSizeMake(90, 120)]];
    }
}

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
    [self.navigationController pushViewController:search animated:YES];
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
    UISwipeGestureRecognizer *recognizerRight= [[UISwipeGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(handleSwipeFrom:)];
    
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.otherScroll addGestureRecognizer:recognizerRight];
    
    UISwipeGestureRecognizer *recognizerLeft= [[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleSwipeFrom:)];
    
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.otherScroll addGestureRecognizer:recognizerLeft];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        
        //[self nextContent];
    }
}

-(void) showLoadingIndicator
{
    if (self.indicatorView)
    {
        if(!self.indicatorView.isAnimating)
        {
            [self.indicatorView startAnimating];
        }
    }
    else
    {
        //初始化:
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        //设置显示样式,见UIActivityIndicatorViewStyle的定义
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        
        //设置显示位置
        [indicator setCenter:CGPointMake(self.contentView.frame.size.width / 2, self.contentView.frame.size.height / 2)];
        
        //设置背景色
        indicator.backgroundColor = [UIColor grayColor];
        
        //设置背景透明
        indicator.alpha = 0.5;
        
        //设置背景为圆角矩形
        indicator.layer.cornerRadius = 6;
        indicator.layer.masksToBounds = YES;
        
        //将初始化好的indicator add到view中
        [self.contentView addSubview:indicator];
        self.indicatorView=indicator;
        
        //开始显示Loading动画
        [indicator startAnimating];
        
        [self.contentView bringSubviewToFront:indicator];
    }
}

-(void) hideLoadingIndicator
{
    if (self.indicatorView)
    {
        [self.indicatorView removeFromSuperview];
    }
}

//////////////////////////////////////////////////////////////
#pragma Play vedio and audio
//////////////////////////////////////////////////////////////
- (void)playVedio
{
    //基本辅助信息和工具准备
    _tagTransform=[[FlyingTagTransform alloc] init];
    
    _speechPlayer = [[SoundPlayer alloc] init];
    _lastScreen=nil;
    
    //智能字幕相关
    _enableAISub=NO;
    _enableUpdateSub=NO;
    
    //收费相关
    FlyingStatisticDAO *statisticDAO = [[FlyingStatisticDAO alloc] init];
    [statisticDAO initDataForUserID:_currentPassport];
    _touchDAO     = [[FlyingTouchDAO alloc] init];
    [_touchDAO initDataForUserID:_currentPassport LessonID:self.theLesson.lessonID];
    
    _touchWordCount = [statisticDAO touchCountWithUserID:_currentPassport];
    _balanceCoin  = [statisticDAO finalMoneyWithUserID:_currentPassport];
    
    //播放器准备
    [self prepareMovie];
}

-(void) preparePlayAndControlView
{
    CGRect frame = self.contentView.bounds;
    
    if (!self.playerView) {
        
        self.playerView = [[FlyingPlayerView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.playerView];
    }
    
    if (!self.aiLearningView) {
        
        self.aiLearningView=[[FlyingAILearningView alloc] initWithFrame:self.contentView.bounds];
        self.aiLearningView.userInteractionEnabled=YES;
        self.aiLearningView.multipleTouchEnabled=YES;
        self.aiLearningView.backgroundColor=[UIColor clearColor];
        self.aiLearningView.delegate=self;
        
        [self.contentView addSubview:self.aiLearningView];
        
        if (!self.gestureControlView) {
            
            CGRect gestureframe=frame;
            gestureframe.size.height = frame.size.height*4/5;
            
            self.gestureControlView= [[FlyingGestureControlView alloc] initWithFrame:gestureframe];
            self.gestureControlView.userInteractionEnabled=YES;
            self.gestureControlView.multipleTouchEnabled=YES;
            self.gestureControlView.backgroundColor=[UIColor clearColor];
            
            [self.aiLearningView addSubview:self.gestureControlView];
            
            [self addPlayBaseControlGestureRecognizer];
            
            if (!self.buttonsView) {
                
                CGRect buttonsframe=frame;
                buttonsframe.size.height = frame.size.height/5;
                
                self.buttonsView = [[UIView alloc] initWithFrame:buttonsframe];
                self.buttonsView.userInteractionEnabled=YES;
                self.buttonsView.multipleTouchEnabled=YES;
                
                [self.gestureControlView addSubview:self.buttonsView];
                
                if (!self.lockImageView) {
                    
                    CGRect lockframe=frame;
                    
                    lockframe.size.width  = frame.size.width/16;
                    lockframe.size.height = frame.size.width/16;
                    lockframe.origin.x    = frame.size.width/32;
                    lockframe.origin.y    = frame.size.width/40;
                    
                    self.lockImageView = [[UIImageView alloc] initWithFrame:lockframe];
                    self.lockImageView.image = [UIImage imageNamed:@"unlock"];
                    self.lockImageView.userInteractionEnabled=YES;
                    
                    self.lockImageView.contentMode=UIViewContentModeScaleAspectFit;
                    // 单击的 Recognizer
                    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSwitchLock)];
                    singleRecognizer.numberOfTapsRequired = 1; // 单击
                    [self.lockImageView addGestureRecognizer:singleRecognizer];
                    
                    [self.buttonsView addSubview:self.lockImageView];
                }
                
                if (!self.slider) {
                    
                    CGRect sliderframe=frame;
                    
                    sliderframe.size.width  = frame.size.width*3/4;
                    sliderframe.size.height = frame.size.width*9/160;
                    sliderframe.origin.x    = frame.size.width/8;
                    sliderframe.origin.y    = frame.size.width*9/320;
                    
                    self.slider =  [[UISlider alloc] initWithFrame:sliderframe];
                    [self.slider setTintColor:[UIColor redColor]];
                    
                    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventTouchDragInside];
                    [self.slider addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
                    [self.slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
                    [self.slider addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
                    
                    [self.slider  setValue:0];
                    self.slider.userInteractionEnabled=NO;
                    self.slider.multipleTouchEnabled = NO;
                    
                    [self.buttonsView addSubview:self.slider];
                }
                
                if (!self.timeLabe) {
                    
                    CGRect timeLableframe=frame;
                    
                    timeLableframe.size.width  = frame.size.width/8;
                    timeLableframe.size.height = frame.size.width*9/80;
                    timeLableframe.origin.x    = frame.size.width*7/8;
                    
                    self.timeLabe = [[UILabel alloc] initWithFrame:timeLableframe];
                    self.timeLabe.textColor =[UIColor whiteColor];
                    self.timeLabe.textAlignment = NSTextAlignmentCenter;
                    self.timeLabe.numberOfLines=0;
                    
                    if (INTERFACE_IS_PAD) {
                        
                        self.timeLabe.font    = [UIFont systemFontOfSize:15.0];
                    }
                    else{
                        
                        self.timeLabe.font     = [UIFont systemFontOfSize:7.0];
                    }
                    
                    [self.buttonsView addSubview:self.timeLabe];
                }
            }
            
            if (!self.magicImageView) {
                
                CGRect magicButtonframe=frame;
                
                magicButtonframe.size.width  = frame.size.width*8/80;
                magicButtonframe.size.height = frame.size.height/5;
                magicButtonframe.origin.x    = frame.size.width*71/80;
                magicButtonframe.origin.y    = frame.size.height*3/5;
                
                self.magicImageView = [[UIImageView alloc] initWithFrame:magicButtonframe];
                self.magicImageView.image = [UIImage imageNamed:@"subtitle"];
                self.magicImageView.userInteractionEnabled=YES;
                
                self.magicImageView.contentMode=UIViewContentModeScaleAspectFit;
                // 单击的 Recognizer
                UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doMagic)];
                singleRecognizer.numberOfTapsRequired = 1; // 单击
                [self.magicImageView addGestureRecognizer:singleRecognizer];
                self.magicImageView.hidden=YES;
                self.magicImageView.alpha=0.6;
                
                [self.gestureControlView addSubview:self.magicImageView];
            }
            
            if (!self.fullImageView) {
                
                CGRect fullButtonframe=frame;
                
                fullButtonframe.size.width  = frame.size.width*8/80;
                fullButtonframe.size.height = frame.size.height/5;
                fullButtonframe.origin.x    = frame.size.width*1/80;
                fullButtonframe.origin.y    = frame.size.height*3/5;
                
                self.fullImageView = [[UIImageView alloc] initWithFrame:fullButtonframe];
                self.fullImageView.image = [UIImage imageNamed:@"full"];
                self.fullImageView.userInteractionEnabled=YES;
                
                self.fullImageView.contentMode=UIViewContentModeScaleAspectFit;
                // 单击的 Recognizer
                UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSwitchFullScreen)];
                singleRecognizer.numberOfTapsRequired = 1; // 单击
                [self.fullImageView addGestureRecognizer:singleRecognizer];
                self.fullImageView.hidden=NO;
                self.fullImageView.alpha=0.6;
                
                [self.gestureControlView addSubview:self.fullImageView];
            }
        }
        
        if (!self.stytleView) {
            
            CGRect styleframe=frame;
            styleframe.size.height = frame.size.height*1/5;
            styleframe.origin.y = frame.size.height*4/5;
            
            self.stytleView=[[FlyingStytleView alloc] initWithFrame:styleframe];
            self.stytleView.userInteractionEnabled=YES;
            self.stytleView.backgroundColor=[UIColor blackColor];
            self.stytleView.alpha=0.5;
            self.stytleView.hidden=YES;

            [self.aiLearningView addSubview:self.stytleView];
        }
        
        if (!self.subtitleTextView) {
            
            CGRect subtitleframe=self.stytleView.frame;
            
            self.subtitleTextView=[[FlyingSubtitleTextView alloc] initWithFrame:subtitleframe];
            self.subtitleTextView.userInteractionEnabled=YES;
            self.subtitleTextView.multipleTouchEnabled=YES;
            self.subtitleTextView.backgroundColor=[UIColor clearColor];
            self.subtitleTextView.textColor= [UIColor whiteColor];
            self.subtitleTextView.textAlignment=NSTextAlignmentCenter;
            
            //字幕基本设置|默认黑底风格字幕
            self.subtitleTextView.text=@"Welcome!";
            
            if (INTERFACE_IS_PAD) {
                
                self.subtitleTextView.font = [UIFont systemFontOfSize:24.0];
            }
            else{
                
                self.subtitleTextView.font = [UIFont systemFontOfSize:8.5];
            }
            
            /*
             [self.subtitleTextView addObserver:self forKeyPath:@"contentSize"
             options:(NSKeyValueObservingOptionNew)
             context:FlyingViewControllerSubtitlStatusObserverContext];
             */
            
            [self.aiLearningView addSubview:self.subtitleTextView];
            
            self.subtitleTextView.hidden=YES;
        }
    }
    
    //设置智能字幕和控制
    [self prepareControlAndAI];
}

#pragma mark - prepare for playing

-(void) prepareMovie
{
    _error=0;
    _firstPlaying=YES;
    _movieURLStr=nil;
    _needParserContentURL=NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_lessonData.localURLOfContent]){
        
        //本地
        if([NSString checkM3U8URL:_lessonData.localURLOfContent]){
            
            NSString* contentFileName     = [self.theLesson.lessonID stringByAppendingPathExtension:kLessonVedioLivingType];
            _movieURLStr=[NSString stringWithFormat:@"http://127.0.0.1:12345/%@/%@",self.theLesson.lessonID,contentFileName];
            
            _contentType=BELocalM3U8Vedio;
            
            iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate startLocalHttpserver];
        }
        else{
            
            _movieURLStr =_lessonData.localURLOfContent;
            
            if([NSString checkMp4URL:_lessonData.localURLOfContent]){
                
                _contentType=BELocalMp4Vedio;
            }
            else{
                
                if([NSString checkMp3URL:_lessonData.localURLOfContent]){
                    
                    _contentType=BELocalMp3Audio;
                }
                else{
                    
                    _contentType=BEWebSourceURL;
                }
            }
        }
    }
    else{
        
        //网络
        if([NSString checkMp4URL:_lessonData.localURLOfContent]){
            
            _movieURLStr =_lessonData.BECONTENTURL;
            _contentType=BEWebMp4Vedio;
        }
        else{
            
            if([NSString checkMp3URL:_lessonData.localURLOfContent]){
                
                _movieURLStr =_lessonData.BECONTENTURL;
                _contentType=BEWebMp3Audio;
            }
            else{
                
                if([NSString checkM3U8URL:_lessonData.localURLOfContent]){
                    
                    _movieURLStr =_lessonData.BECONTENTURL;
                    _contentType=BEWebM3U8Vedio;
                }
                else{
                    
                    _movieURLStr=nil;
                    _contentType=BEWebSourceURL;
                }
            }
        }
    }
    
    if(_contentType==BEWebMp3Audio || _contentType==BELocalMp3Audio){
        
        //去除播放内容视图
        [self.playerView removeFromSuperview];
    }
    
    if (_movieURLStr) {
        
        [self prepareAVPlayer];
    }
    else{
        
        _needParserContentURL=YES;
        [self getContentUrlFronWeb];
    }
}

-(void)  prepareAVPlayer
{
    //播放起始时间
    _initialPlaybackTime = 0;
    
    if(_nowLessonData){
        
        _initialPlaybackTime=_nowLessonData.BESTAMP;
    }
    
    self.timestamp=_initialPlaybackTime;
    
    NSURL *movieURL;
    
    switch (_contentType) {
        case BELocalMp4Vedio:
        case BELocalMp3Audio:
            movieURL = [NSURL fileURLWithPath:_movieURLStr];
            break;
        case BEWebMp4Vedio:
        case BEWebMp3Audio:
        case BEWebM3U8Vedio:
        case BELocalM3U8Vedio:
            movieURL = [NSURL URLWithString:_movieURLStr];
            break;
            
        default:
            movieURL=nil;
    }
    
    /*
     Create an asset for inspection of a resource referenced by a given URL.
     Load the values for the asset keys "tracks", "playable".
     */
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movieURL options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
}

#pragma mark Prepare to play asset

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
         out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        [self.playerItem removeObserver:self forKeyPath:kTracksKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:FlyingViewControllerPlayerItemStatusObserverContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:kTracksKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:FlyingViewControllerTrackObservationContext];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    /* Create new player, if we don't already have one. */
    if (![self player])
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:FlyingViewControllerRateObservationContext];
        
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
        
        //[self syncPlayPauseButtons];
    }
    
    //get Play Duration
    _totalDuration=CMTimeGetSeconds([self playerItemDuration:asset]);
    
    //设置字幕自动同步机制
    double interval = .2f;
    __weak typeof(self) weakSelf = self;
    
    self.playerObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                    queue:NULL
                                                               usingBlock:
                           ^(CMTime time)
                           {
                               [weakSelf updateTimerFired];
                               
                           }];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == FlyingViewControllerPlayerItemStatusObserverContext)
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                [self.contentView makeToast:@"如果加载时间很长，建议离线后再使用：）" duration:3 position:CSToastPositionCenter];

                [self  performSelector:@selector(autoReportLessonError) withObject:nil afterDelay:10];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                _timeScale = self.player.currentItem.asset.duration.timescale;
                
                if (_timeScale==0) {
                    _timeScale=NSEC_PER_SEC;
                }
                
                if (_firstPlaying) {
                    
                    //设置播放器初试时间
                    [self.player seekToTime:CMTimeMakeWithSeconds(_initialPlaybackTime, _timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                    
                    if (_needShareM3U8URL) {
                        
                        [self shareM3U8Url:_movieURLStr forLessonID:self.theLesson.lessonID];
                    }
                    
                    //加载完毕
                    [self hideLoadingIndicator];
                    [self preparePlayAndControlView];
                    
                    [self.playerView  setPlayer:self.player];
                    self.playerView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
                    self.playerView.playerLayer.hidden = NO;
                }
                
                [self playAndDoAI];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:thePlayerItem.error];
            }
                break;
        }
    }
    /* AVPlayer "rate" property value observer. */
    else if (context == FlyingViewControllerRateObservationContext)
    {
        if (self.player.rate==0) {
            
            [self showControlBar];
            
            if (self.player.status!=AVPlayerStatusReadyToPlay)
            {
                [self showLoadingIndicator];
            }
            
            [self.buyButton setEnabled:YES];
        }
        else{
            
            [self.buyButton setEnabled:NO];
            
            if( !(_contentType== BELocalMp3Audio || _contentType==BEWebMp3Audio) ){
                
                [self hideControlBar];
            }
            [self hideLoadingIndicator];
        }
    }
    /* AVPlayer "Track" property value observer. */
    else if (context == FlyingViewControllerTrackObservationContext)
    {
        
    }
    else if (context == FlyingViewControllerSubtitlStatusObserverContext){
        
        UITextView *tv = object;
        CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
        tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
    else
    {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
    
    return;
}

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    /* Display the error. */
    
    NSLog(@"move failed:%@", [error localizedDescription]);
    
    [self reportError];
}


-(void) autoReportLessonError
{
    
    if (self.player.currentItem.status==AVPlayerItemStatusFailed || self.player.currentItem.status==AVPlayerItemStatusUnknown) {
        [self reportError];
    }
}

-(void) reportError
{
    NSString * type;
    
    if ([NSString checkOfficialURL:_movieURLStr]) {
        
        type=@"err_m3u8";
    }
    else if (_needParserContentURL) {
        
        type=@"err_url1";
    }
    else{
        
        type=@"err_url2";
    }
    
    [AFHttpTool reportLessonErrorType:type
                           contentURL:_movieURLStr
                             lessonID:self.theLesson.lessonID
                              success:^(id response) {
                                  //
                                  NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                  
                                  if ([tempStr isEqualToString:@"10"] || [tempStr isEqualToString:@"11"])
                                  {
                                      [self.contentView makeToast:@"如果还有问题，建议删除课程更新一下：）" duration:3 position:CSToastPositionCenter];

                                  }
                                  else
                                  {
                                      [self.contentView makeToast:@"我们正在处理你碰到的问题..." duration:3 position:CSToastPositionCenter];
                                  }

                              } failure:^(NSError *err) {
                                  //
                                  NSLog(@"reportLessonErrorType:%@",err.description);
                              }];
}

//////////////////////////////////////////////////////////////
#pragma play control
//////////////////////////////////////////////////////////////

//添加播放控制手势
- (void)addPlayBaseControlGestureRecognizer
{
    // 单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.gestureControlView addGestureRecognizer:singleRecognizer];
    
    // 双击的 Recognizer
    UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapFrom:)];
    doubleRecognizer.numberOfTapsRequired = 2; // 双击
    [self.gestureControlView addGestureRecognizer:doubleRecognizer];
    
    // 关键在这一行，如果双击确定偵測失败才會触发单击
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    
    // 右划的 Recognizer
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleRightSwipeTapFrom:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.gestureControlView addGestureRecognizer:rightSwipe];
    
    // 左划的 Recognizer
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleLeftSwipeTapFrom:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.gestureControlView addGestureRecognizer:leftSwipe];
    
    // 下划的 Recognizer
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleDownSwipeTapFrom:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.gestureControlView addGestureRecognizer:downSwipe];
    
    // 上划的 Recognizer
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(handleUpSwipeTapFrom:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.gestureControlView addGestureRecognizer:upSwipe];
}

#pragma mark - Player Touch Control/GestureRecognizer

//屏幕单击
- (void)handleSingleTapFrom: (id) sender
{
    if ([self playerIsReady]) {
        
        [self toggleButton];
    }
}

//屏幕双击
- (void)handleDoubleTapFrom: (id) sender
{
    [self doMagic];
}

//控制进度条出现
-(void) showControlBar
{
    self.buttonsView.alpha=1;
}

//控制进度条消失
- (void)hideControlBar
{
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.buttonsView.alpha=0;
        
    } completion:^(BOOL finished) {}];
}

- (void)showControlBarSomeTime
{
    self.buttonsView.alpha=1;
    
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.buttonsView.alpha=0;
        
    } completion:^(BOOL finished) {}];
}

//屏幕右划
- (void)handleRightSwipeTapFrom: (id) sender
{
    if (_subtitleFile)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BESwipRight"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSTimeInterval npt=0;
        NSUInteger index = self.subtitleTextView.currentSubtitleIndex;
        
        //学习字幕区
        if (index < _subtitleFile.countOfSubItems) {
            //第一个字幕回到开头
            if( index ==  0  ){
                //回退到开头
                npt=0;
            }
            else{
                //回退到上一个字幕
                npt=[[_subtitleFile  getSubItemForIndex:(index-1)] startTimeInSeconds];
            }
        }
        else{
            
            //如果现在无学习字幕或者空白play
            CMTime nowTime = self.player.currentTime;
            
            NSTimeInterval  freshTimeInSeconds = CMTimeGetSeconds(nowTime);
            
            NSUInteger afterIndex = [_subtitleFile idxAfterCurrentSubTime:freshTimeInSeconds];
            
            //片头回到开始
            if(afterIndex == 0){
                
                npt=0;//第一个字幕回到开头
            }
            else{
                
                if (afterIndex<_subtitleFile.countOfSubItems) {
                    //普通字幕空白区回到紧挨的上一个字幕开头
                    npt=[[_subtitleFile  getSubItemForIndex:(afterIndex-1)] startTimeInSeconds];
                }
                else{
                    
                    //最后的结束空白区，回到最后一个字幕开头
                    npt=[[_subtitleFile  getLastSubtitleItem] startTimeInSeconds];
                }
            }
        }
        //加0.2是为了修正计算误差导致跳转失灵
        [self seekToTime:(npt+0.2)];
    }
    else
    {
        CMTime nowTime = self.player.currentTime;
        NSTimeInterval  freshTimeInSeconds = CMTimeGetSeconds(nowTime);
        
        NSTimeInterval npt=freshTimeInSeconds-2;
        
        if (npt<0)
        {
            [self.contentView makeToast:@"已经播放完毕.." duration:3 position:CSToastPositionCenter];
        }
        else
        {
            [self seekToTime:npt];
        }
    }
}

//屏幕左划
- (void)handleLeftSwipeTapFrom: (id) sender
{
    if(_subtitleFile)
    {
        NSTimeInterval npt=0;
        NSUInteger index = self.subtitleTextView.currentSubtitleIndex;
        
        //学习字幕区
        if (index < _subtitleFile.countOfSubItems) {
            
            if( index ==  (_subtitleFile.countOfSubItems-1) ){
                //跳转到片尾开头
                npt=[_subtitleFile getEndSubtitleTime]+0.1;
            }
            else{
                //跳转到下一个字幕
                npt=[[_subtitleFile  getSubItemForIndex:(index+1)] startTimeInSeconds];
            }
        }
        else{
            
            //如果现在无学习字幕或者空白play
            CMTime nowTime = self.player.currentTime;
            NSTimeInterval  freshTimeInSeconds = CMTimeGetSeconds(nowTime);
            NSUInteger afterIndex = [_subtitleFile idxAfterCurrentSubTime:freshTimeInSeconds];
            
            if(afterIndex<_subtitleFile.countOfSubItems){
                
                //普通字幕空白区跳转到紧挨的下一个字幕开头
                npt=[[_subtitleFile  getSubItemForIndex:afterIndex] startTimeInSeconds];
            }
        }
        //加0.2是为了修正计算误差导致跳转失灵
        [self seekToTime:(npt+0.2)];
    }
    else
    {
        CMTime nowTime = self.player.currentTime;
        NSTimeInterval  freshTimeInSeconds = CMTimeGetSeconds(nowTime);
        
        NSTimeInterval npt=freshTimeInSeconds+2;
        NSTimeInterval  duration = CMTimeGetSeconds(self.player.currentItem.duration);
        
        if (npt>duration)
        {
            [self.contentView makeToast:@"已经播放完毕!" duration:3 position:CSToastPositionCenter];
        }
        else
        {
            [self seekToTime:npt];
        }
    }
}

//屏幕上划－－ 提高音量

- (void)handleUpSwipeTapFrom: (id) sender
{
    //[self.player setVolume:(self.player.volume+0.5)];
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    // retrieve system volume
    float systemVolume = volumeViewSlider.value;
    
    // change system volume, the value is between 0.0f and 1.0f
    [volumeViewSlider setValue:(systemVolume+0.1) animated:NO];
    
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

//屏幕下划－－ 降低音量
- (void)handleDownSwipeTapFrom: (id) sender
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider* volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    // retrieve system volume
    float systemVolume = volumeViewSlider.value;
    
    // change system volume, the value is between 0.0f and 1.0f
    [volumeViewSlider setValue:(systemVolume-0.1) animated:NO];
    
    // send UI control event to make the change effect right now.
    [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void) playAndDoAI
{
    
    if (_firstPlaying) {
        
        _firstPlaying=NO;
    }
    
    //清理屏幕以及AI数据
    [self resetAIViewsAndData];
    
    //关闭放大镜
    [self.aiLearningView setAImagnifyEnabled:NO];
    
    //打开自动更新字幕
    _enableUpdateSub=YES;
    
    [self.player play];
}

- (void) pauseAndDoAI
{
    //关闭自动更新字幕
    _enableUpdateSub=NO;
    
    [self.player pause];
    
    NSInteger length = self.subtitleTextView.text.length;
    
    //如果有学习字幕，进行AI分析准备
    if (length!=0) {
        
        //开启放大镜
        if (self.subtitleTextView.text!=nil) {
            [self.aiLearningView setAImagnifyEnabled:YES];
        }
        
        if (_tagAndTokens.count==0){
            //进行语法分析,得到语法分析结果
            [self NLPTheSubtitle];
        }
    }
    
    //如果可以，则开启进度条
    if(!(_contentType==BELocalMp3Audio||_contentType==BEWebMp3Audio)){
        
        if ([self enableScrubber]) {
            
            [self syncScrubber:self.timestamp];
        }
    }
}

- (void)toggleButton
{
    if(self.player.rate != 0.f)
    {
        [self.fullImageView setHidden:NO];
        [self pauseAndDoAI];
        [self  showHintHelp];
        
        if(_enableAISub)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showAutoAIContent];
            });
        }
    }
    else
    {
        [self playAndDoAI];
        
        [self.fullImageView setHidden:YES];
    }
}

- (void) seekToTime:(NSTimeInterval ) interval
{
    if(_subtitleFile)
    {
        [self resetAIViewsAndData];
    }
    
    /*
    if (self.player.rate!=0) {
        
        [self.player setRate:0];
    }
     */
    
    if([self playerIsReady]) {
        
        _timeScale = self.player.currentItem.asset.duration.timescale;
        
        [self.player seekToTime:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
            //动更新字幕，因为有时是暂停播放状态的跳转
            [self updateSubtitleTimerFired:interval];
            [self syncScrubber:interval];
            
            //刷新字幕词性解析
            if(![self isPlayingNow])
            {
                [self NLPTheSubtitle];
            }
        }];
    }
}

- (void) stop
{
    if (_webView) {
        
        [_webView stopLoading];
        _webView=nil;
    }
    
    if (self.player) {
        
        [self.player pause];
        [self afterStopplaying];
    }
    
    if (_playonline) {
        
        //删除数据库本地纪录，资源自动释放
        [[[FlyingNowLessonDAO alloc] init] deleteWithUserID:_currentPassport LessonID:self.theLesson.lessonID];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) isPlayingNow
{
    return self.player.rate!=0;
}

-(BOOL) hasSubtitleContent
{
    
    NSInteger length = self.subtitleTextView.text.length;
    
    return  length!=0;
}

#pragma mark - 进度条相关
/* The user is dragging the movie controller thumb to scrub through the movie. */
- (void)beginScrubbing:(id)sender
{
    [self.player setRate:0.f];
    
    //清理屏幕以及AI数据
    [self resetAIViewsAndData];
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (void)endScrubbing:(id)sender
{
    
    if (_contentType==BEWebMp4Vedio  || _contentType==BELocalMp4Vedio || _contentType==BEWebMp3Audio ||_contentType==BELocalMp3Audio )
    {
        
        [self playAndDoAI];
    }
}

/* Set the player current time to match the scrubber position. */
- (void)sliderChanged:(id)sender
{
    
    UISlider* slider = sender;
    
    if ([self playerIsReady])
    {
        
        _timeScale = self.player.currentItem.asset.duration.timescale;
        
        [self.player seekToTime:CMTimeMakeWithSeconds(_totalDuration*slider.value, _timeScale) completionHandler:^(BOOL finished) {
            
            [self updateSubtitleTimerFired:_totalDuration*slider.value];
            [self syncScrubber:_totalDuration*slider.value];
        }];
    }
}

/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (self.playerObserver)
    {
        [self.player removeTimeObserver:self.playerObserver];
        self.playerObserver = nil;
    }
}

- (NSString*) timeformatFromSeconds:(NSInteger)seconds
{
    if(seconds/3600==0)
    {
        //format of minute
        NSString *str_minute  = [NSString stringWithFormat:@"%02ld",(long)(seconds%3600)/60];
        //format of second
        NSString *str_second  = [NSString stringWithFormat:@"%02ld",(long)seconds%60];
        //format of time
        NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
        return format_time;
    }
    else
    {
        //format of hour
        NSString *str_hour    = [NSString stringWithFormat:@"%02ld",(long)seconds/3600];
        
        //format of minute
        NSString *str_minute  = [NSString stringWithFormat:@"%02ld",(long)(seconds%3600)/60];
        //format of second
        NSString *str_second  = [NSString stringWithFormat:@"%02ld",(long)seconds%60];
        //format of time
        NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
        
        return format_time;
    }
}


#pragma mark - Player Control Related

//播放准备ok后，增加字幕控制图层
- (void)prepareControlAndAI
{
    //更新播放时间数据
    [_lessonDAO updateDuration:_totalDuration LessonID:_lessonData.BELESSONID];
    
    //增加基本控制手势
    [self showControlBar];
    
    //添加字幕和智能学习内容
    NSString *subfileURLStr = _lessonData.localURLOfSub;
    if (![[NSFileManager defaultManager] fileExistsAtPath:subfileURLStr]){
        
        //如果是网络地址从网络请求字幕
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self getSrtFromBE];
        });
    }
    else{
        
        _subtitleFile=[[FlyingSubTitle alloc] initWithFile:subfileURLStr];
        
        if (_subtitleFile) {
            
            //准备词法分析工具
            [self prepareNLP];
            self.stytleView.subStyle=BEAISubHideBackgroundStyle;
            [self.stytleView reDrawStytle];
            
            _enableAISub=YES;
            self.stytleView.hidden=NO;
            self.subtitleTextView.hidden=NO;
            self.magicImageView.hidden=NO;
        }
        else{
            _enableAISub=NO;
            self.stytleView.hidden=YES;
            self.subtitleTextView.hidden=YES;
            self.magicImageView.hidden=YES;
        }
    }
}

// 自然结束播放后，退回原先的界面
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    self.timestamp=0;
    [self seekToTime:0];
}

//课程结束，进行相关处理
- (void)afterStopplaying
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //[self.subtitleTextView removeObserver:self forKeyPath:@"contentSize"];
    
    [self.playerItem  removeObserver:self forKeyPath:kStatusKey];
    [self.playerItem  removeObserver:self forKeyPath:kTracksKey];
    
    [self.player  removeObserver:self       forKeyPath:kRateKey];
    [self.player  removeTimeObserver:self.playerObserver];
    [self.player  replaceCurrentItemWithPlayerItem:nil];
    
    if(_nowLessonData){
        
        _nowLessonData.BESTAMP=self.timestamp;
        _nowLessonData.BEORDER++;
        
        FlyingNowLessonDAO * nowLessonDAO = [[FlyingNowLessonDAO alloc] init];
        [nowLessonDAO insertWithData:_nowLessonData];
    }
}

#pragma mark - Timer Fire (Subtitle Upate and play time update)

- (void)updateTimerFired
{
    @autoreleasepool{
        
        [self updateSubtitleTimerFired:0];
        
        if(_contentType==BEWebMp3Audio || _contentType==BELocalMp3Audio){
            
            [self enableScrubber];
            
            [self syncScrubber:CMTimeGetSeconds(self.player.currentTime)];
        }
    }
}

-(BOOL)enableScrubber
{
    
    if (_totalDuration==0 || _totalDuration!=_totalDuration) {
        
        return NO;
    }
    else{
        
        self.slider.value= self.timestamp/_totalDuration;
        self.slider.userInteractionEnabled = YES;
        
        return YES;
    }
}

- (CMTime)playerItemDuration:(AVURLAsset*) asset
{
    AVPlayerItem *thePlayerItem = [self.player currentItem];
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        
        return([self.playerItem duration]);
    }
    else{
        
        return asset.duration;
    }
}

-(BOOL) playerIsReady
{
    
    AVPlayerItem *thePlayerItem = [self.player currentItem];
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return YES;
    }
    else{
        return NO;
    }
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber:(NSTimeInterval) time
{
    
    NSTimeInterval  freshTimeInSeconds;
    
    if (time==0) {
        
        if([self playerIsReady]){
            
            CMTime nowTime = self.player.currentTime;
            freshTimeInSeconds = CMTimeGetSeconds(nowTime);
        }
        else{
            
            freshTimeInSeconds = 0.0;
        }
    }
    else{
        
        freshTimeInSeconds=time;
    }
    
    self.timeLabe.text=[NSString stringWithFormat:@"%@/%@", [self timeformatFromSeconds:freshTimeInSeconds],[self timeformatFromSeconds:_totalDuration]];
    [self.slider setValue:freshTimeInSeconds/(_totalDuration*1.00) animated:YES];
}

- (void)updateSubtitleTimerFired:(NSTimeInterval) time
{
    
    NSTimeInterval freshTimeInSeconds=0;
    
    if (time!=0) {
        
        freshTimeInSeconds=time;
    }
    else{
        
        if(![self playerIsReady]){
            
            return;
        }
        else{
            
            CMTime nowTime = self.player.currentTime;
            
            freshTimeInSeconds = CMTimeGetSeconds(nowTime);
            freshTimeInSeconds+=_error;
        }
    }
    
    [self setTimestamp:freshTimeInSeconds];//更新时间戳
    
    if ((_enableAISub&&_enableUpdateSub) ||time!=0) {
        
        NSUInteger freshIndex = [_subtitleFile idxOfSubItemWithSubTime:freshTimeInSeconds];
        
        //如果现在是字幕时间
        if(freshIndex != NSNotFound){
            
            //取得更新字幕内容
            FlyingSubRipItem * currentSubItem =[_subtitleFile getSubItemForIndex:freshIndex];
            [self.subtitleTextView setText:currentSubItem.text];
        }
        //空白字幕区
        else{
            
            //片头字幕区
            if (freshTimeInSeconds < ([_subtitleFile getStartSubtitleTime]-1) ) {
                
                [self.subtitleTextView setText:@"Welcome!"];
                
            }
            else{
                
                if ( freshTimeInSeconds > [_subtitleFile getEndSubtitleTime] ) {
                    
                    [self.subtitleTextView setText:@"Game over,you are great!"];
                }
                else{
                    //延迟字幕一秒钟,不更新
                    if (freshTimeInSeconds<[_subtitleFile getSubItemForIndex:self.subtitleTextView.currentSubtitleIndex].endTimeInSeconds+2) {
                        freshIndex= self.subtitleTextView.currentSubtitleIndex;
                    }
                    else{
                        //超过一秒，更新字幕为空
                        [self.subtitleTextView setText:nil];
                    }
                }
            }
        }
        
        //更新字幕索引
        self.subtitleTextView.currentSubtitleIndex = freshIndex;
    }
}

#pragma mark - AI show

-(void) prepareNLP
{
    //准备语法解析
    if (_tagAndTokens==NULL) _tagAndTokens = [[NSMutableArray alloc] initWithCapacity:KCounts_Average_Screen_Subtitle];
    
    if (_flyingNPL==NULL) {
        
        //忽略空格、符号和连接词
        NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace |NSLinguisticTaggerOmitPunctuation |
        NSLinguisticTaggerOmitOther | NSLinguisticTaggerJoinNames;
        
        //只需要词性和名称
        NSArray * tagSchemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeNameTypeOrLexicalClass,NSLinguisticTagSchemeLemma,nil];
        
        _flyingNPL = [[NSLinguisticTagger alloc] initWithTagSchemes:tagSchemes options:options];
    }
    
    //准备注释视图
    if (_annotationWordViews==NULL) _annotationWordViews = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    //准备放大镜
    if (_mag==Nil) {
        _mag= [[ACMagnifyingGlass alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        _mag.scale = 2;
        self.aiLearningView.magnifyingGlass = _mag;
    }
}

- (void) showAutoAIContent
{
     if (_tagAndTokens.count==0) {
     return;
     }
     
     //自动显示学习目标内的学习单词
     NSMutableArray  * tagAndTokens = [_tagAndTokens mutableCopy];
     NSString * subtileNow = [self.subtitleTextView.text mutableCopy];
     
    UIFont * tempFont = self.subtitleTextView.font;
    
     //设置默认生词白色，system 20 大小
     __block NSArray* objects = [[NSArray  alloc] initWithObjects:tempFont, [UIColor whiteColor], nil];
     __block NSArray* keys    = [[NSArray  alloc] initWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil];
     
     NSDictionary *defaultFont = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
     NSMutableAttributedString * styleSentence =[[NSMutableAttributedString alloc] initWithString:subtileNow attributes:defaultFont];
    
    NSArray * wordArray =  [[[FlyingTaskWordDAO alloc] init] selectWordsWithUserID:_currentPassport];
    
    if (wordArray.count!=0)
    {
        [tagAndTokens enumerateObjectsUsingBlock:^(FlyingWordLinguisticData * theTagWord, NSUInteger idx, BOOL *stop) {
            
            //用词性色代替背景色
            UIColor * wordColor = [UIColor whiteColor];
            UIColor * backgroundColor = [UIColor clearColor];
            
            if ([wordArray containsObject:[theTagWord  getLemma]]) {
                
                backgroundColor=[_tagTransform corlorForTag:theTagWord.tag];
                
                if (theTagWord.tag == NSLinguisticTagAdjective || theTagWord.tag == NSLinguisticTagPronoun) {
                    wordColor = [UIColor blackColor];
                }
            }
            
            objects = [[NSArray  alloc] initWithObjects:tempFont,backgroundColor, wordColor, nil];
            keys    = [[NSArray  alloc] initWithObjects:NSFontAttributeName, NSBackgroundColorAttributeName, NSForegroundColorAttributeName,nil];
            
            NSDictionary *attrs = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            [styleSentence  setAttributes:attrs range:theTagWord.tokenRange];
            [self.subtitleTextView setAttributedText:styleSentence];
            [self.subtitleTextView setTextAlignment:NSTextAlignmentCenter];
        }];
    }
}

- (void) resetAIViewsAndData
{
    [self removeAllPersonalWordViews];
    
    if (_tagAndTokens.count!=0) {
        [_tagAndTokens removeAllObjects];
    }
}

#pragma mark - Annatation related

//得到单词在AILearingView中的位置
-(CGRect) getWordLocationForAIview:(NSRange) range
{
    if (range.length == 0) {
        return  CGRectMake(0, 0, 0, 0);
    }
    
    UITextPosition *beginning = self.subtitleTextView.beginningOfDocument;
    UITextPosition *start = [self.subtitleTextView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [self.subtitleTextView positionFromPosition:start offset:range.length];
    
    UITextRange *textRange = [self.subtitleTextView textRangeFromPosition:start toPosition:end];
    CGRect rect = [self.subtitleTextView firstRectForRange:textRange];
    
    if (rect.size.width == 0) {
        return  CGRectMake(0, 0, 0, 0);
    }
    
    return [self.subtitleTextView.textInputView  convertRect:rect toView:self.aiLearningView];
}

#pragma mark - Personal Wordview Related

-(void) showViewForWord: (FlyingWordLinguisticData *) tagWord
{
    
    FlyingItemView * aTagWordView = [_annotationWordViews objectForKey:[tagWord getIDKey]];
    
    if (!aTagWordView) {
        
        CGRect frame=CGRectMake(0, 0, 100, 100);
        if (INTERFACE_IS_PAD ) {
            
            frame=CGRectMake(0, 0, 200, 200);
        }
        
        aTagWordView =[[FlyingItemView alloc] initWithFrame:frame];
        
        [aTagWordView setLessonID:self.theLesson.lessonID];
        
        [aTagWordView setWord:[self.subtitleTextView.text substringWithRange:tagWord.tokenRange]];
        [aTagWordView  drawWithLemma:tagWord.getLemma AppTag:tagWord.tag];
        
        //纪录下来,为了复用
        [_annotationWordViews setObject:aTagWordView forKey:[tagWord getIDKey]];
    }
    
    //显示磁贴单词图
    [self showSinglelWordView:aTagWordView];
}

-(void) showSinglelWordView: (FlyingItemView *) personalWordView
{
    if (!personalWordView.superview) {
        
        //随机散开磁贴的显示位置
        srand((unsigned int)personalWordView.lemma.hash);
        
        CGFloat x = (self.aiLearningView.frame.size.width-personalWordView.frame.size.width)*rand()/(RAND_MAX+1.0);
        CGFloat y=  (self.aiLearningView.frame.size.height-self.subtitleTextView.frame.size.height-personalWordView.frame.size.height)*rand()/(RAND_MAX+1.0);
        
        personalWordView.frame =CGRectMake(x, y, personalWordView.frame.size.width, personalWordView.frame.size.height) ;
        
        [personalWordView adjustForAutosizing];
        [self.aiLearningView addSubview:personalWordView];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            personalWordView.alpha=1;
            
        } completion:^(BOOL finished) {}];
    }
    else{
        
        [personalWordView.superview bringSubviewToFront:personalWordView];
    }
}

- (void) removeAllPersonalWordViews
{
    if (_annotationWordViews.count != 0) {
        
        for (FlyingItemView * object in [_annotationWordViews allValues]) {
            
            [object dismissViewAnimated:YES];
        }
    }
    [_annotationWordViews removeAllObjects];
}


#pragma mark - 字幕相关手势 FlyingAILearningViewDelegate

//手指接触字幕后，AI高亮显示选中单词
- (void) touchOnSubtileBegin: (CGPoint) touchPoint
{
    
    //纪录当前点击位置单词
    FlyingWordLinguisticData * theTagWord = [self getWordForTouch:touchPoint];
    
    if (theTagWord) {
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"BEHelpSubtitleTouch"]){
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BEHelpSubtitleTouch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        [self showAIColorForWord:theTagWord];
        
        [_speechPlayer speechWord:theTagWord.word LessonID:self.theLesson.lessonID];
    }
    
    //纪录当前单词，规避重复刷新
    _theOnlyTagWord=theTagWord;
}

//手指在字幕上移动，AI高亮显示选中单词
- (void) touchOnSubtileMoved: (CGPoint) touchPoint
{
    
    //在当前点击位置显示单词简单解释
    FlyingWordLinguisticData * theTagWord = [self getWordForTouch:touchPoint];
    
    if (theTagWord) {
        
        if (theTagWord!=_theOnlyTagWord) {
            
            [self showAIColorForWord:theTagWord];
            [_speechPlayer speechWord:theTagWord.getLemma LessonID:self.theLesson.lessonID];
            
            _theOnlyTagWord=theTagWord;
        }
    }
}

//手指离开字幕后，直接显示选中单词解释
- (void) touchOnSubtileEnd: (CGPoint) touchPoint
{
    if (_theOnlyTagWord) {
        
        [self showViewForWord:_theOnlyTagWord];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //更新点击次数和单词纪录
            [_touchDAO countPlusWithUserID:_currentPassport LessonID:self.theLesson.lessonID];
        });
        
        //纪录重点单词
        [self addToucLammaRecord:_theOnlyTagWord Sentence:self.subtitleTextView.text];
    }
}

- (void) touchOnSubtileCancelled: (CGPoint) touchPoint
{
    
    if (_theOnlyTagWord) {
        
    }
    
    _theOnlyTagWord=nil;
}

- (void) doMagic
{
    if (self.subtitleTextView.isHidden) {
        
        _enableAISub=YES;
        [self.subtitleTextView setHidden:NO];
        [self.stytleView setHidden:NO];
        
        [self.aiLearningView setAImagnifyEnabled:YES];
    }
    else{
        
        _enableAISub=NO;

        [self.subtitleTextView setHidden:YES];
        [self.stytleView setHidden:YES];
        
        [self.aiLearningView setAImagnifyEnabled:NO];
    }
}

//得到点击位置单词，位置以AIlearningView坐标为准
-(FlyingWordLinguisticData *) getWordForTouch:( CGPoint) touchPoint
{
    //判断点击位置的单词
    for (FlyingWordLinguisticData * object in _tagAndTokens) {
        
        if(CGRectContainsPoint([self getWordLocationForAIview:object.tokenRange],touchPoint))
            
            return object;
    }
    
    return nil;
}

#pragma mark - Flying Magic NLP & AIColor
//解析当前字幕
-(void) NLPTheSubtitle
{
    
    //如果没有学习字幕，返回
    if (self.subtitleTextView.text==nil) {
        return;
    }
    
    //清理旧的语法分析结果
    if (_tagAndTokens.count != 0) {
        [_tagAndTokens removeAllObjects];
    }
    
    // This range contains the entire string, since we want to parse it completely
    NSRange stringRange = NSMakeRange(0, self.subtitleTextView.text.length);
    
    if (stringRange.length==0) {
        return;
    }
    
    //忽略空格、符号和连接词
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace |NSLinguisticTaggerOmitPunctuation |
    NSLinguisticTaggerOmitOther | NSLinguisticTaggerJoinNames;
    
    // Dictionary with a language map
    NSArray *language = [NSArray arrayWithObjects:@"en",nil];
    NSDictionary* languageMap = [NSDictionary dictionaryWithObject:language forKey:@"Latn"];
    NSOrthography * orthograsphy = [NSOrthography orthographyWithDominantScript:@"Latn" languageMap:languageMap];
    
    NSString *  text = [self sentenceProcessing:self.subtitleTextView.text];
    [_flyingNPL setString:text];
    [_flyingNPL setOrthography:orthograsphy range:stringRange];
    
    [_flyingNPL enumerateTagsInRange:stringRange
                              scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass
                             options:options
                          usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                              
                              if (tag) {
                                  
                                  FlyingWordLinguisticData *data= [[FlyingWordLinguisticData alloc] initWithTag:tag tokenRange:tokenRange sentenceRange:sentenceRange];
                                  [data setWord:[self.subtitleTextView.text substringWithRange:tokenRange]];
                                  [_tagAndTokens addObject:data];
                              }
                          }];
    __block int i=0;
    
    [_flyingNPL enumerateTagsInRange:stringRange
                              scheme:NSLinguisticTagSchemeLemma
                             options:options
                          usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                              
                              if (i<_tagAndTokens.count) {
                                  if (tag) {
                                      
                                      [(FlyingWordLinguisticData *) [_tagAndTokens objectAtIndex:i] setLemma:tag];
                                  }
                                  else{
                                      
                                      [(FlyingWordLinguisticData *) [_tagAndTokens objectAtIndex:i] setLemma:[text substringWithRange:tokenRange]];
                                  }
                              }
                              i++;
                          }];
    
}

//6.0版本机器支持彩色显示AI单词
-(void) showAIColorForWord:(FlyingWordLinguisticData *) theTagWord
{
    //空字幕不需要再进行智能解析
    if (theTagWord==Nil){
        return;
    }
    
    UIFont * tempFont = self.subtitleTextView.font;
    
    //设置默认生词白色，system 20 大小
    NSArray* objects = [[NSArray  alloc] initWithObjects:tempFont, [UIColor whiteColor], nil];
    NSArray* keys    = [[NSArray  alloc] initWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil];
    
    NSDictionary *defaultFont = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSMutableAttributedString * styleSentence =[[NSMutableAttributedString alloc] initWithString:self.subtitleTextView.text attributes:defaultFont];
    
    //用词性色代替背景色
    UIColor * wordColor = [UIColor whiteColor];
    if (theTagWord.tag == NSLinguisticTagAdjective || theTagWord.tag == NSLinguisticTagPronoun) {
        wordColor = [UIColor blackColor];
    }
    
    objects = [[NSArray  alloc] initWithObjects:tempFont, [_tagTransform corlorForTag:theTagWord.tag], wordColor, nil];
    keys    = [[NSArray  alloc] initWithObjects:NSFontAttributeName, NSBackgroundColorAttributeName, NSForegroundColorAttributeName,nil];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [styleSentence  setAttributes:attrs range:theTagWord.tokenRange];
    [self.subtitleTextView setAttributedText:styleSentence];
    [self.subtitleTextView setTextAlignment:NSTextAlignmentCenter];
}

//规避...word  不能语法解析问题
- (NSString *) sentenceProcessing:(NSString *) sentence
{
    
    NSString * text = [sentence stringByReplacingOccurrencesOfString:@"."  withString:@"-"];
    return text;
}

#pragma mark - Save Data related

//把点击重点单词纪录下来
-(void) addToucLammaRecord:(FlyingWordLinguisticData *) touchWord  Sentence:(NSString*) sentence
{
    
    dispatch_async(_background_queue, ^{
        
        FlyingTaskWordDAO * taskWordDAO   = [[FlyingTaskWordDAO alloc] init];
        [taskWordDAO setUserModle:NO];
        
        //保存截图(例句视频不截图)
        if (_contentType==BELocalMp4Vedio || _contentType==BEWebMp4Vedio) {
            
            [self screenCopyWord:touchWord.getLemma];
        }
        
        [taskWordDAO insertWithUesrID:_currentPassport
                                 Word:touchWord.getLemma
                           Sentence:sentence
                             LessonID:self.theLesson.lessonID];
    });
}

#pragma mark - Flying back

//back delegate functions
- (void)dismiss{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KGodIsComing    object:nil];
    
    //保存截图(例句视频不截图)
    if ( self.player &&
        self.timestamp!=0 && !_playonline) {
        
        [self.player pause];
        [self screenCopy];
    }
    
    [self stop];
}


//从网络获取字幕
- (void) getSrtFromBE
{
    if(_lessonData.BEOFFICIAL)
    {
        [AFHttpTool lessonResourceType:kResource_Sub
                              lessonID:self.theLesson.lessonID
                            contentURL:nil
                                 isURL:NO
                               success:^(id response) {
                                   //
                                   [self dealWithSrtData:response];
                               } failure:^(NSError *err) {
                                   //
                                   NSLog(@"getSrtFromBE:%@",err.description);
                               }];
    }
    else
    {
        //用文件指纹获取
    }
}

-(void) dealWithSrtData:(NSData *) data
{
    NSString * temStr =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
    
    if ( (segmentRange.location==NSNotFound) && (data!=nil) ) {
        
        [data writeToFile:_lessonData.localURLOfSub atomically:YES];
        
        _subtitleFile=[[FlyingSubTitle alloc] initWithData:data];
        
        if (_subtitleFile){
            
            //准备词法分析工具
            [self prepareNLP];
            self.stytleView.subStyle=BEAISubHideBackgroundStyle;
            [self.stytleView reDrawStytle];
            
            _enableAISub=YES;
            self.stytleView.hidden=NO;
            self.subtitleTextView.hidden=NO;
            self.magicImageView.hidden=NO;
        }
        else{
            _enableAISub=NO;
            self.stytleView.hidden=YES;
            self.subtitleTextView.hidden=YES;
            self.magicImageView.hidden=YES;
        }
    }
    else
    {
        [self.contentView makeToast:@"没有字幕,不能智能学习.." duration:3 position:CSToastPositionCenter];

        _enableAISub=NO;
    }
}


-(void)showHintHelp
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"BEHelpSubtitleTouch"])
    {
        
        [self.contentView makeToast:@"点击单词自动解释!" duration:3 position:CSToastPositionCenter];
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"BESwipRight"])
    {
        
        [self.contentView makeToast:@"右划跳转到上一个场景!" duration:3 position:CSToastPositionCenter];
    }
}

-(void) screenCopy
{
    AVAsset *myAsset = self.player.currentItem.asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:myAsset];
    
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:self.player.currentTime actualTime:nil error:nil];
    
    if (halfWayImage != NULL) {
        
        _lastScreen=[UIImage imageWithCGImage:halfWayImage];
        
        //如果没有封面图片文件就创建一个
        if (_lastScreen && ![[NSFileManager defaultManager] fileExistsAtPath:_nowLessonData.BELOCALCOVER]){
            
            if(![[NSFileManager defaultManager] createFileAtPath:_nowLessonData.BELOCALCOVER contents:nil attributes:nil])
            {
                NSLog(@"Error was code: %d - message: %s", errno, strerror(errno));
            }
        }
        
        //CGSize size = [self sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        [UIImageJPEGRepresentation(_lastScreen,0) writeToFile:_nowLessonData.BELOCALCOVER atomically:YES];
        _lastScreen=nil;
        // Do something interesting with the image.
        CGImageRelease(halfWayImage);
    }
}

-(void) screenCopyWord:(NSString*) word
{
    AVAsset *myAsset = self.player.currentItem.asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:myAsset];
    
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:self.player.currentTime actualTime:nil error:nil];
    
    if (halfWayImage != NULL) {
        
        NSString * wordPicURL =[NSString picPathForWord:word];
        UIImage *screen=[UIImage imageWithCGImage:halfWayImage];
        
        //如果没有封面图片文件就创建一个
        if (![[NSFileManager defaultManager] fileExistsAtPath:wordPicURL]){
            [[NSFileManager defaultManager] createFileAtPath:wordPicURL contents:nil attributes:nil];
        }
        
        [UIImageJPEGRepresentation([screen  makeThumbnailOfSize:self.contentView.bounds.size],0) writeToFile:wordPicURL atomically:YES];
        // Do something interesting with the image.
        CGImageRelease(halfWayImage);
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - M3U8 Related
//////////////////////////////////////////////////////////////

-(void) getContentUrlFronWeb
{
    //目前只有动态获取M3U8这一种情况！！！！！
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.scalesPageToFit   = NO;
        _webView.delegate          = self;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        
        if(_lessonData.BECONTENTURL)
        {
            NSURL *url =[[NSURL alloc] initWithString:_lessonData.BECONTENTURL];
            NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
            [_webView loadRequest:request];
        }
    });
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    _parseContentURLOK=NO;
    //取页面M3U8
    NSString * lJs2 = @"(document.getElementsByTagName(\"video\")[0]).src";  // youku,tudou,ku6 ,souhu
    NSString * lm3u8 = [webView stringByEvaluatingJavaScriptFromString:lJs2];
    
    NSRange textRange;
    NSString * substring= @"m3u8";
    textRange =[lm3u8 rangeOfString:substring];
    
    if(textRange.location != NSNotFound)
    {
        _movieURLStr =lm3u8;
        _contentType=BEWebM3U8Vedio;
        
        _parseContentURLOK=YES;
        
        if (INTERFACE_IS_PAD) {
            _needShareM3U8URL=NO;
        }
        else{
            _needShareM3U8URL=YES;
        }
        _webView=nil;
        [self prepareAVPlayer];
    }
}

//分享M3U8--URL
- (void) shareM3U8Url:(NSString*) m3u8URL  forLessonID:(NSString *) lessonID
{
    [AFHttpTool shareContentUrl:m3u8URL
                    contentType:@"m3u8_o"
                    forLessonID:lessonID
                        success:^(id response) {
                            //
                            NSString * msg=[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                            NSLog(@"分享M3U8 succeess is:%@",msg);

                        } failure:^(NSError *err) {
                            //
                            NSLog(@"web answer is%@",err.description);
                        }];
}

#pragma only UI events
//////////////////////////////////////////////////////////////

- (void)motionOrientationChanged:(NSNotification *)notification
{
    if (_lockScreen || !self.playerView) {
        
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIDeviceOrientation oritation=[MotionOrientation sharedInstance].deviceOrientation;
        
        if (oritation==UIInterfaceOrientationPortrait||
            oritation==UIInterfaceOrientationPortraitUpsideDown ||
            oritation==UIInterfaceOrientationLandscapeLeft ||
            oritation==UIInterfaceOrientationLandscapeRight)
        {
            
            if (self.deviceOrientation!=oritation)
            {
                int rotationDegree = 0;
                CGSize oldSize = self.contentView.bounds.size;
                
                float sx=1,sy=1;
                BOOL isportrait=YES;
                
                switch ([MotionOrientation sharedInstance].deviceOrientation) {
                        
                    case UIInterfaceOrientationPortrait:
                        
                        [self.navigationController setNavigationBarHidden:NO animated:YES];
                        
                        rotationDegree = 0;
                        
                        sx=_standardSize.width/oldSize.width;
                        sy=_standardSize.width*_ratioHeightToW/oldSize.height;
                        
                        isportrait=YES;
                        
                        break;
                        
                    case UIInterfaceOrientationLandscapeLeft:
                        
                        [self.navigationController setNavigationBarHidden:YES animated:YES];
                        
                        rotationDegree = 270;
                        sx=_standardSize.height/oldSize.width;
                        sy=_standardSize.width/oldSize.height;
                        
                        isportrait=NO;
                        
                        break;
                        
                    case UIInterfaceOrientationPortraitUpsideDown:
                        
                        [self.navigationController setNavigationBarHidden:NO animated:YES];
                        
                        rotationDegree = 180;
                        sx=_standardSize.width/oldSize.width;
                        sy=_standardSize.width*_ratioHeightToW/oldSize.height;
                        
                        isportrait=YES;
                        
                        break;
                        
                    case UIInterfaceOrientationLandscapeRight:
                        
                        [self.navigationController setNavigationBarHidden:YES animated:YES];
                        
                        rotationDegree = 90;
                        sx=_standardSize.height/oldSize.width;
                        sy=_standardSize.width/oldSize.height;
                        
                        isportrait=NO;
                        
                        break;
                        
                    default:
                        break;
                }
                
                CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_RADIANS(rotationDegree));
                transform = CGAffineTransformScale(transform, sx,sy);
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [self.contentView setTransform: transform];    // this effects the SUBVIEWS rotate and scale
                [UIView commitAnimations];
                
                if(isportrait)
                {
                    CGRect frame = self.contentView.frame;
                    frame.origin.x=0;
                    frame.origin.y=0;
                    
                    self.contentView.frame= frame;
                    [self.view bringSubviewToFront:self.contentView];
                    
                    self.fullImageView.image = [UIImage imageNamed:@"full"];
                }
                else
                {
                    [self.contentView setCenter:self.view.center];
                    [self.view bringSubviewToFront:self.contentView];
                    self.fullImageView.image = [UIImage imageNamed:@"close"];
                }
                
                [self.fullImageView setHidden:YES];
                
                self.deviceOrientation=[MotionOrientation sharedInstance].deviceOrientation;
            }
        }
    });
}

- (void)doSwitchFullScreen
{
    if (!self.playerView) {
        
        return;
    }
    
    if(!_lockScreen)
    {
        _lockScreen=YES;
        self.lockImageView.image = [UIImage imageNamed:@"lock"];
    }
    
    int rotationDegree = 0;
    CGSize oldSize = self.contentView.bounds.size;
    
    float sx=1,sy=1;
    BOOL isportrait=YES;
    
    switch (self.deviceOrientation) {
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:

            [self.navigationController setNavigationBarHidden:NO animated:YES];
            
            rotationDegree = 0;
            
            sx=_standardSize.width/oldSize.width;
            sy=_standardSize.width*_ratioHeightToW/oldSize.height;
            
            isportrait=YES;
            
            break;
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            
            rotationDegree = 90;
            sx=_standardSize.height/oldSize.width;
            sy=_standardSize.width/oldSize.height;
            
            isportrait=NO;
            
            break;
            
        default:
            break;
    }
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(DEGREES_RADIANS(rotationDegree));
    transform = CGAffineTransformScale(transform, sx,sy);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self.contentView setTransform: transform];    // this effects the SUBVIEWS rotate and scale
    [UIView commitAnimations];
    
    if(isportrait)
    {
        CGRect frame = self.contentView.frame;
        frame.origin.x=0;
        frame.origin.y=0;
        
        self.contentView.frame= frame;
        [self.view bringSubviewToFront:self.contentView];
        
        self.deviceOrientation=UIInterfaceOrientationPortrait;
        
        self.fullImageView.image = [UIImage imageNamed:@"full"];
    }
    else
    {
        [self.contentView setCenter:self.view.center];
        [self.view bringSubviewToFront:self.contentView];
        
        self.deviceOrientation=UIInterfaceOrientationLandscapeRight;
        
        self.fullImageView.image = [UIImage imageNamed:@"close"];
    }
}


- (void)doSwitchLock
{
    
    if(_lockScreen)
    {
        _lockScreen=NO;
        
        self.lockImageView.image = [UIImage imageNamed:@"unlock"];
    }
    else
    {
        _lockScreen=YES;
        self.lockImageView.image = [UIImage imageNamed:@"lock"];
    }
}

@end