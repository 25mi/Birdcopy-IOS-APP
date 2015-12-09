//
//  FlyingDialogViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 11/16/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingDialogViewController.h"
#import "shareDefine.h"
#import "ACMagnifyingGlass.h"
#import "FlyingSubTitle.h"
#import "FlyingSubRipItem.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVMediaFormat.h>
#import "FlyingWordLinguisticData.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "UICKeyChainStore.h"
#import "FlyingSoundPlayer.h"
#import "NSString+FlyingExtention.h"

#import "UIBubbleTableView.h"

#import "FlyingNowLessonDAO.h"

#import "UIImage+localFile.h"
#import "FlyingItemView.h"
#import "iFlyingAppDelegate.h"
#import "UIView+Autosizing.h"
#import "FlyingTaskWordDAO.h"
#import "FlyingTagTransform.h"
#import "FlyingSubtitleTextView.h"
#import "FlyingMagView.h"
#import "SIAlertView.h"
#import "FlyingStatisticDAO.h"
#import "FlyingTouchDAO.h"
#import "UIImageView+WebCache.h"

#import "RESideMenu.h"
#import <AFNetworking.h>
#import "AFHttpTool.h"
#import "UIView+Toast.h"

@interface FlyingDialogViewController ()
{
    UIBubbleTableView          *_bubbleTable;
    NSMutableArray             *_currentBubbleData;
    
    NSString                   *_lastRole;
    BOOL                        _isLeft;
    FlyingSubTitle             *_subtitleFile;
    
    FlyingWordLinguisticData   *_theOnlyTagWord;
    
    BOOL                        _enableUpdateSub;
    BOOL                        _enableAISub;
    
    NSLinguisticTagger        *_flyingNPL;
    NSMutableArray            *_tagAndTokens;
    FlyingTagTransform        *_tagTransform;
    
    FlyingLessonData          *_lessonData;
    
    NSString                  *_movieURLStr;
    BE_Vedio_Type              _contentType;
    BOOL                      _isClosedFlag;    //关闭标志，控制是或否背后播放
    NSTimeInterval             _totalDuration;
    NSTimeInterval            _initialPlaybackTime;
    NSTimeInterval            _endPlaybackTime;

    int32_t                   _timeScale;
    BOOL                      _autoPlayModle;    //帮助判断是否需要主动播放
    
    FlyingSoundPlayer          *_speechPlayer;
    //后台处理
    dispatch_queue_t            _background_queue;
    
    FlyingSubtitleTextView     *_subtitleTextView;
    FlyingMagView              *_modalView;
    NSMutableDictionary        *_annotationWordViews;

    BOOL                       _isPlayingNow;
    BOOL                       _isReachEnd;
    
    NSInteger                       _balanceCoin;
    NSInteger                       _touchWordCount;
    FlyingStatisticDAO       *_statisticDAO;
    FlyingTouchDAO           *_touchDAO;
    
    NSMutableArray           *_lessonList;
    
    NSIndexPath              *_highLightIndexPath;
    
    UIImage* buttonImageN;
    UIImage* buttonImageH;
}

@end

@implementation FlyingDialogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];

    //self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    buttonImageN= [UIImage imageNamed:@"PlayAudio"];
    buttonImageH= [UIImage imageNamed:@"Pause"];
    
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
    
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* moreButton= [[UIButton alloc] initWithFrame:frame];
    [moreButton setBackgroundImage:buttonImageH forState:UIControlStateNormal];
    [moreButton setBackgroundImage:buttonImageN forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* moreBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    self.navigationItem.rightBarButtonItem = moreBarButtonItem;
    
    self.backgroundImagview =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    [self.backgroundImagview setContentMode:UIViewContentModeScaleAspectFit];
    [self.backgroundImagview setFrame:self.view.frame];
    
    [self.view addSubview:self.backgroundImagview];

    _bubbleTable = [[UIBubbleTableView alloc] initWithFrame:CGRectMake(0.0f, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _bubbleTable.backgroundColor=[UIColor clearColor];
    
    [self.view addSubview:_bubbleTable];
    
    [self commonInit];
}


- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //释放UI资源
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setBackgroundImagview:nil];
    [self setPlayer:nil];
    [self setPlayerItem:nil];
    
    [self setPlayerObserver:nil];
    
     _bubbleTable=nil;
    _currentBubbleData=nil;
    _lastRole=nil;
    _subtitleFile=nil;
    _theOnlyTagWord=nil;
    _flyingNPL=nil;
    _tagAndTokens=nil;
    _tagTransform=nil;
    
    _lessonData=nil;
    _movieURLStr=nil;
    
    _speechPlayer=nil;
    _background_queue=nil;
    
    _subtitleTextView=nil;
    _modalView=nil;
    _annotationWordViews=nil;
    _statisticDAO=nil;
    _touchDAO=nil;
    _lessonList=nil;
}

-(void) commonInit
{

    //基本辅助信息和工具准备
    _isClosedFlag=NO;
    _lessonData    = [[[FlyingLessonDAO alloc] init] selectWithLessonID:self.lessonID];
    _speechPlayer = [[FlyingSoundPlayer alloc] init];
    _tagTransform=[[FlyingTagTransform alloc] init];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    _background_queue = [appDelegate getAIQueue];
    
    _autoPlayModle=YES;
    
    //更新欢迎语言
    self.title =_lessonData.BETITLE;
    
    dispatch_async(dispatch_get_main_queue() , ^{
        [self loadDialogSubtitle];
        [self prepairMovie];
    });
    
    NSString *openID = [NSString getOpenUDID];

    //收费相关
    _statisticDAO = [[FlyingStatisticDAO alloc] init];
    [_statisticDAO initDataForUserID:openID];
    _touchDAO     = [[FlyingTouchDAO alloc] init];
    [_touchDAO initDataForUserID:openID LessonID:self.lessonID];
    
    _touchWordCount = [_statisticDAO touchCountWithUserID:openID];
    _balanceCoin  = [_statisticDAO finalMoneyWithUserID:openID];
    
    _highLightIndexPath=nil;
}

- (void)showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
    [self pauseAndDoAI];
}

- (void) doSomething
{
    [self toggleButton];
}

- (void)toggleButton
{
    
    if (self.player) {

        if(self.player.rate != 0.f)
        {
            [self pauseAndDoAI];
            
        }
        else
        {
            if(_isReachEnd)
            {
                [_bubbleTable reloadData];
                [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {}];
            }

            [self playAndDoAI];
        }
    }
}

//加载对话字幕
-(void)loadDialogSubtitle
{
    _bubbleTable.bubbleDataSource = self;
    _bubbleTable.snapInterval = 120;
    _bubbleTable.showAvatars = NO;
    _bubbleTable.typingBubble = NSBubbleTypingTypeNobody;
    _bubbleTable.isDialog=YES;
    
    
    UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.backgroundImagview.frame.size.width, self.backgroundImagview.frame.size.height*3/4)];
    [aView setAlpha:0];
    [_bubbleTable setTableFooterView:aView];

    //加载字幕
    NSString *subfileURLStr = _lessonData.localURLOfSub;
    if (![[NSFileManager defaultManager] fileExistsAtPath:subfileURLStr]){
        
        //如果是网络地址从网络请求字幕
        [self getSrtFromBE];
    }
    else{
        
        _subtitleFile=[[FlyingSubTitle alloc] initWithFile:subfileURLStr];
        
        if (_subtitleFile) {
            
            [self presentDialog];
        }
    }
}

//从网络获取字幕
- (void) getSrtFromBE
{
    [AFHttpTool lessonResourceType:kResource_Sub
                          lessonID:self.lessonID
                        contentURL:nil
                             isURL:NO
                           success:^(id response) {
                               //
                               NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                               NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
                               
                               if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                                   
                                   [response writeToFile:_lessonData.localURLOfSub atomically:YES];
                                   
                                   _subtitleFile=[[FlyingSubTitle alloc] initWithData:response];
                                   
                                   if (_subtitleFile){
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           
                                           [self presentDialog];
                                       });
                                   }
                                   else{
                                       _enableAISub=NO;
                                   }
                               }
                               else{
                                   _enableAISub=NO;
                               }

                           } failure:^(NSError *err) {
                               //
                           }];
}


//转换字幕为对话形式并显示
-(void)presentDialog
{
    
    _lastRole=nil;
    _isLeft=YES;
    
    _currentBubbleData= [[NSMutableArray alloc] initWithCapacity:0];
    
    for(int i=0;i<_subtitleFile.countOfSubItems;i++){
        
        @autoreleasepool {
        
            FlyingSubRipItem * subItem =[_subtitleFile getSubItemForIndex:i];
            NSString * content=subItem.text;
            NSArray  * subSegments = [content componentsSeparatedByString:@":"];
            
            if (subSegments.count==2) {
                
                NSString * role =subSegments[0];
                
                if ([self isLeftRole:role]) {
                    
                    NSBubbleData  *     rightBubble  = [NSBubbleData dataWithText:content
                                                                             date:[NSDate dateWithTimeIntervalSinceNow:-300]
                                                                             type:BubbleTypeMine];
                    [_currentBubbleData  addObject:rightBubble];
                }
                else{

                    NSBubbleData  *     leftBubble  = [NSBubbleData dataWithText:content
                                                                            date:[NSDate dateWithTimeIntervalSinceNow:-300]
                                                                            type:BubbleTypeSomeoneElse];
                    [_currentBubbleData  addObject:leftBubble];
                }
            }
            else{
                
                NSBubbleData  *     middleBubble  = [NSBubbleData dataWithText:content
                                                                         date:[NSDate dateWithTimeIntervalSinceNow:-300]
                                                                         type:BubbleTypeSomeoneElse];
                [_currentBubbleData  addObject:middleBubble];
            }
        }
    }
    
    [_bubbleTable reloadData];
    
    [_bubbleTable setBackgroundView:nil];
    
    //准备词法分析工具
    [self prepairNLP];
}

-(BOOL) isLeftRole:(NSString*) role
{

    if (_lastRole==nil || role==nil)
    {
        _lastRole=role;
        _isLeft=YES;
        return YES;
    }
    else
    {
        if ([role isEqualToString:_lastRole])
        {
            if (_isLeft)
            {
                return YES;
            }
            else
            {
                _isLeft=NO;
                return NO;
            }
        }
        else
        {
            _lastRole=role;

            if (_isLeft)
            {
                _isLeft=NO;
                return NO;
            }
            else
            {
                return YES;
            }
        }
    }
}

-(void) prepairNLP
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
    
    //实例化长按手势监听
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleTableviewCellLongPressed:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    //将长按手势添加到需要实现长按操作的视图里
    [_bubbleTable addGestureRecognizer:longPress];
    
    _enableAISub=YES;
}

#pragma mark - Prepair for playing

-(void) prepairMovie
{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    _movieURLStr=nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_lessonData.localURLOfContent]){
        
        _movieURLStr =_lessonData.localURLOfContent;
        _contentType=BELocalMp3Audio;
    }
    else{
        
        _movieURLStr =_lessonData.BECONTENTURL;
        _contentType=BEWebMp3Audio;
    }
    
    //添加视频截图
    [self.backgroundImagview sd_setImageWithURL:[NSURL URLWithString:_lessonData.BEIMAGEURL]
                               placeholderImage:[UIImage imageWithContentsOfFile:_lessonData.localURLOfCover]];
    
    [self prepareAVPlayer];
}

-(void)  prepareAVPlayer
{
    
    NSURL *movieURL;
    
    switch (_contentType) {
        case BELocalMp3Audio:
            movieURL = [NSURL fileURLWithPath:_movieURLStr];
            break;
        case BEWebMp3Audio:
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
    
    if (_isClosedFlag) {
        
        return;
    }
    
    /* Make sure that the value of each key has loaded successfully. */
	for (NSString *thisKey in requestedKeys)
	{
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed)
		{
			[self reportError];
			return;
		}
		/* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
         out properly in the case of cancellation. */
	}
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        /*
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
		NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
								   localizedDescription, NSLocalizedDescriptionKey,
								   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
								   nil];
		NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        */
        /* Display the error to the user. */
        [self reportError];
        
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
                         context:FlyingDialogViewControllerPlayerItemStatusObserverContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:kTracksKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:FlyingDialogViewControllerTrackObservationContext];
    
	
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
                         context:FlyingDialogViewControllerRateObservationContext];
        
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
    if (_isClosedFlag) {
        
        return;
    }
    
	/* AVPlayerItem "status" property value observer. */
	if (context == FlyingDialogViewControllerPlayerItemStatusObserverContext)
	{
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                //[self disablePlayeControl];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                
                [self playAndDoAI];
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                [self reportError];
            }
                break;
        }
	}
    /* AVPlayer "rate" property value observer. */
	else if (context == FlyingDialogViewControllerRateObservationContext)
	{
        if (self.player.rate==0) {
            
            [self showPlayControlBar];
            
            if (self.player.status!=AVPlayerStatusReadyToPlay) {
                [self hideControlBar];
            }
        }
        else{
            
            [self showPauseControlBar];
        }
	}
    /* AVPlayer "Track" property value observer. */
	else if (context == FlyingDialogViewControllerTrackObservationContext)
	{
        
	}
    else if (context == FlyingDialogViewControllerSubtitlStatusObserverContext){
        
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

-(void)showPlayControlBar
{
    
    [self.navigationItem.rightBarButtonItem.customView setHidden:NO];
}

-(void)showPauseControlBar
{
    
    [self.navigationItem.rightBarButtonItem.customView setHidden:NO];
}

-(void)hideControlBar
{

    [self.navigationItem.rightBarButtonItem.customView setHidden:YES];
}

-(void) reportError
{
    [AFHttpTool reportLessonErrorType:@"err_url2"
                           contentURL:_movieURLStr
                             lessonID:self.lessonID
                              success:^(id response) {
                                  //
                                  NSLog(@"reportError success!");
                              } failure:^(NSError *err) {
                                  //
                                  NSLog(@"reportError:%@",err.description);
                              }];
}

#pragma mark - Timer Fire (Subtitle Upate and play time update)

- (void)updateTimerFired
{
    @autoreleasepool{
        
        CMTime nowTime = self.player.currentTime;
        
        NSTimeInterval freshTimeInSeconds = CMTimeGetSeconds(nowTime);
        
        NSUInteger freshIndex = [_subtitleFile idxOfSubItemWithSubTime:freshTimeInSeconds];
        
        double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
        //如果现在是字幕时间
        if(freshIndex != NSNotFound){
            
            if(_highLightIndexPath==nil){
            
                //高亮当前字幕
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:freshIndex inSection:0];
                
                if (version<7.0) {
                    
                    [_bubbleTable  cellForRowAtIndexPath:indexPath].contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
                }
                else{
                    
                    [[_bubbleTable  cellForRowAtIndexPath:indexPath] setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
                }
                
                _highLightIndexPath=indexPath;
            }
        }
        else{
        
            if(_highLightIndexPath!=nil){
                
                if (version<7.0) {
                    
                    [_bubbleTable  cellForRowAtIndexPath:_highLightIndexPath].contentView.backgroundColor = [UIColor clearColor];
                }
                else{
                    
                    [[_bubbleTable  cellForRowAtIndexPath:_highLightIndexPath] setBackgroundColor:[UIColor clearColor]];
                }
                
                _highLightIndexPath=nil;
            }
        }
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


#pragma mark - Play Control Basic functions

- (void) playAndDoAI
{
    _isReachEnd=NO;
    //打开自动更新字幕
    _enableUpdateSub=YES;
    
	[self.player play];
    
    CGRect frame= CGRectMake(0, 0, 24, 24);
    UIButton* moreButton= [[UIButton alloc] initWithFrame:frame];
    [moreButton setBackgroundImage:buttonImageH forState:UIControlStateNormal];
    [moreButton setBackgroundImage:buttonImageN forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* moreBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    self.navigationItem.rightBarButtonItem = moreBarButtonItem;
}

- (void) pauseAndDoAI
{
    //关闭自动更新字幕
    _enableUpdateSub=NO;
    
    [self.player pause];
    
    CGRect frame= CGRectMake(0, 0, 24, 24);
    UIButton* moreButton= [[UIButton alloc] initWithFrame:frame];
    [moreButton setBackgroundImage:buttonImageN forState:UIControlStateNormal];
    [moreButton setBackgroundImage:buttonImageH forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* moreBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    self.navigationItem.rightBarButtonItem = moreBarButtonItem;
}

//长按事件的实现方法
- (void) handleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        if (self.player.rate!=0) {
            
            _isPlayingNow=YES;
            [self pauseAndDoAI];
        }
        else{
            
            _isPlayingNow=NO;
        }
        
        CGPoint p = [gestureRecognizer locationInView:_bubbleTable];
        NSIndexPath *indexPath = [_bubbleTable indexPathForRowAtPoint:p];//获取响应的长按的indexpath
        
        if (indexPath == nil)
        {
            return;
        }

        NSInteger index = indexPath.row;
        
        NSString * content=[_subtitleFile getSubItemForIndex:index].text;
        
        if (content){
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"handleTableviewCellLongPressed"]) {
            
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"handleTableviewCellLongPressed"];
                
                [self.view makeToast:@"点击单词可以直接翻译" duration:3 position:CSToastPositionCenter];
            }
            
            _modalView = [[FlyingMagView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            _modalView.opaque = NO;
            _modalView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
            
            ACMagnifyingGlass *mag= [[ACMagnifyingGlass alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
            mag.scale = 1.5;
            _modalView.magnifyingGlass = mag;
            [_modalView setMyDelegate:self];
            [_modalView setAImagnifyEnabled:YES];

            //准备学习层显示
            CGFloat deviceWith=_modalView.frame.size.width;
            CGFloat deviceHeight=_modalView.frame.size.height;
            
            CGFloat coinShopWith=0;
            CGFloat coinShopHeight=0;
            
            if (INTERFACE_IS_PAD ) {
                
                if (deviceWith<deviceHeight) {
                    
                    coinShopWith=KLandscapeShopWith*2;
                    coinShopHeight=KLandscapeShopHeight*2;
                }
                else{
                    
                    coinShopWith=KPortraitShopWith*2;
                    coinShopHeight=KPortraitShopWith*2;
                }
            }
            else{
                
                if (_modalView.frame.size.width<_modalView.frame.size.height) {
                    
                    coinShopWith=KLandscapeShopWith;
                    coinShopHeight=KLandscapeShopHeight/2;
                }
                else{
                    
                    coinShopWith=KPortraitShopWith;
                    coinShopHeight=KPortraitShopWith/2;
                }
            }
            CGRect frame=CGRectMake((deviceWith-coinShopWith)/2, (deviceHeight-coinShopHeight)/2, coinShopWith, coinShopHeight);
            _subtitleTextView   = [[FlyingSubtitleTextView alloc] initWithFrame:frame];
            
            if (INTERFACE_IS_PAD) {
                
                _subtitleTextView.font = [UIFont systemFontOfSize:24.0];
            }
            else{
                
                _subtitleTextView.font = [UIFont systemFontOfSize:16.0];
            }
            [_subtitleTextView setTextAlignment:NSTextAlignmentCenter];
            [_subtitleTextView setText:content];
            [_subtitleTextView setTextColor:[UIColor whiteColor]];
            [_subtitleTextView setEditable:NO];
            [_subtitleTextView setUserInteractionEnabled:YES];
            _subtitleTextView.backgroundColor = [UIColor blackColor];
            _subtitleTextView.opaque = NO;
            
            [_modalView addSubview:_subtitleTextView];
            
            [self NLPTheSubtitle];
            
            
            [self.view addSubview:_modalView];
            [self.view bringSubviewToFront:_modalView];
            
            /*
            
            [[self.view window] addSubview:_modalView];
            [[self.view window] bringSubviewToFront:_modalView];
             */
        }
    }
}


-(void) tapSomeWhere: (CGPoint) touchPoint
{

    [_modalView removeFromSuperview];
    _modalView=nil;
    _subtitleTextView=nil;
    
    if (_isPlayingNow) {
        
        [self playAndDoAI];
    }
}

#pragma mark - Flying Magic NLP & AIColor
//解析当前字幕
-(void) NLPTheSubtitle
{
    
    //如果没有学习字幕，返回
    if (_subtitleTextView.text==nil) {
        return;
    }
    
    //清理旧的语法分析结果
    if (_tagAndTokens.count != 0) {
        [_tagAndTokens removeAllObjects];
    }
    
    // This range contains the entire string, since we want to parse it completely
    NSRange stringRange = NSMakeRange(0, _subtitleTextView.text.length);
    
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
    
    NSString *  text = [self sentenceProcessing:_subtitleTextView.text];
    [_flyingNPL setString:text];
    [_flyingNPL setOrthography:orthograsphy range:stringRange];
    
    [_flyingNPL enumerateTagsInRange:stringRange
                              scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass
                             options:options
                          usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                              
                              if (tag) {
                                  
                                  FlyingWordLinguisticData *data= [[FlyingWordLinguisticData alloc] initWithTag:tag tokenRange:tokenRange sentenceRange:sentenceRange];
                                  [data setWord:[_subtitleTextView.text substringWithRange:tokenRange]];
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

- (NSString *) sentenceProcessing:(NSString *) sentence
{
    
    NSString * text = [sentence stringByReplacingOccurrencesOfString:@"."  withString:@"-"];
    return text;
}


#pragma mark - 字幕相关手势 FlyingAILearningViewDelegate
//手指接触字幕后，AI高亮显示选中单词
- (void) touchOnSubtileBegin: (CGPoint) touchPoint
{
    
    //纪录当前点击位置单词
    FlyingWordLinguisticData * theTagWord = [self getWordForTouch:touchPoint];
    
    if (theTagWord) {
        
        [self showAIColorForWord:theTagWord];
        
        [_speechPlayer speechWord:theTagWord.word LessonID:self.lessonID];
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
            [_speechPlayer speechWord:theTagWord.getLemma LessonID:self.lessonID];
            
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
            
            NSString *openID = [NSString getOpenUDID];

            //更新点击次数和课程相关消费记录
            [_touchDAO countPlusWithUserID:openID LessonID:self.lessonID];
        });
        
        //纪录点击单词
        [self addToucLammaRecord:_theOnlyTagWord Sentence:_subtitleTextView.text];
    }
}

//得到点击位置单词，位置以AIlearningView坐标为准
-(FlyingWordLinguisticData *) getWordForTouch:( CGPoint) touchPoint
{
    //判断点击位置的单词
    for (FlyingWordLinguisticData * object in _tagAndTokens) {
        
        if(CGRectContainsPoint([self getWordLocationaAtSubtitleView:object.tokenRange],touchPoint))
            
            return object;
    }
    
    return nil;
}

//得到单词在学习层中的位置
-(CGRect) getWordLocationaAtSubtitleView:(NSRange) range
{
    if (range.length == 0) {
        return  CGRectMake(0, 0, 0, 0);
    }
    
    UITextPosition *beginning = _subtitleTextView.beginningOfDocument;
    UITextPosition *start = [_subtitleTextView positionFromPosition:beginning offset:range.location];
    UITextPosition *end = [_subtitleTextView positionFromPosition:start offset:range.length];
    
    UITextRange *textRange = [_subtitleTextView textRangeFromPosition:start toPosition:end];
    CGRect rect = [_subtitleTextView firstRectForRange:textRange];
    
    if (rect.size.width == 0) {
        return  CGRectMake(0, 0, 0, 0);
    }
    
    return [_subtitleTextView.textInputView  convertRect:rect toView:_modalView];
}

-(void) showAIColorForWord:(FlyingWordLinguisticData *) theTagWord
{
    //空字幕不需要再进行智能解析
    if (theTagWord==Nil){
        return;
    }
    
    UIFont * tempFont = _subtitleTextView.font;
    
    //设置默认生词白色，system 20 大小
    NSArray* objects = [[NSArray  alloc] initWithObjects:tempFont, [UIColor whiteColor], nil];
    NSArray* keys    = [[NSArray  alloc] initWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil];
    
    NSDictionary *defaultFont = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    NSMutableAttributedString * styleSentence =[[NSMutableAttributedString alloc] initWithString:_subtitleTextView.text attributes:defaultFont];
    
    //用词性色代替背景色
    UIColor * wordColor = [UIColor whiteColor];
    
    if (theTagWord.tag == NSLinguisticTagAdjective || theTagWord.tag == NSLinguisticTagPronoun) {
        wordColor = [UIColor blackColor];
    }
    
    objects = [[NSArray  alloc] initWithObjects:tempFont, [_tagTransform corlorForTag:theTagWord.tag], wordColor, nil];
    keys    = [[NSArray  alloc] initWithObjects:NSFontAttributeName, NSBackgroundColorAttributeName, NSForegroundColorAttributeName,nil];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [styleSentence  setAttributes:attrs range:theTagWord.tokenRange];
    [_subtitleTextView setAttributedText:styleSentence];
    [_subtitleTextView setTextAlignment:NSTextAlignmentCenter];
}


-(void) showViewForWord: (FlyingWordLinguisticData *) tagWord
{
    
    FlyingItemView * aTagWordView = [_annotationWordViews objectForKey:[tagWord getIDKey]];
    
    if (!aTagWordView) {
        
        CGRect frame=CGRectMake(0, 0, 200, 200);
        if (INTERFACE_IS_PAD ) {
            
            frame=CGRectMake(0, 0, 400, 400);
        }
        
        aTagWordView =[[FlyingItemView alloc] initWithFrame:frame];
        [aTagWordView setFullScreenModle:YES];
        
        [aTagWordView setLessonID:self.lessonID];
        
        [aTagWordView setWord:[_subtitleTextView.text substringWithRange:tagWord.tokenRange]];
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
        
        CGFloat x = (_modalView.frame.size.width-personalWordView.frame.size.width)*rand()/(RAND_MAX+1.0);
        CGFloat y=  (_modalView.frame.size.height-personalWordView.frame.size.height)*rand()/(RAND_MAX+1.0);
        
        personalWordView.frame =CGRectMake(x, y, personalWordView.frame.size.width, personalWordView.frame.size.height) ;
        
        [personalWordView adjustForAutosizing];
        [_modalView addSubview:personalWordView];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            personalWordView.alpha=1;
            
        } completion:^(BOOL finished) {}];
    }
    else{
        
        [personalWordView.superview bringSubviewToFront:personalWordView];
    }
}


- (void) touchOnSubtileCancelled: (CGPoint) touchPoint
{
    
    if (_theOnlyTagWord) {
        
    }
    
    _theOnlyTagWord=nil;
}

//把点击重点单词纪录下来
-(void) addToucLammaRecord:(FlyingWordLinguisticData *) touchWord  Sentence:(NSString*)sentence
{
    
    dispatch_async(_background_queue, ^{
        
        FlyingTaskWordDAO * taskWordDAO   = [[FlyingTaskWordDAO alloc] init];
        [taskWordDAO setUserModle:NO];
        
        NSString *openID = [NSString getOpenUDID];

        [taskWordDAO insertWithUesrID:openID
                                 Word:touchWord.getLemma
                           Sentence:sentence
                             LessonID:self.lessonID];
    });
}

// 自然结束播放后，退回原先的界面
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    //
    _isReachEnd=YES;
    
    CGRect frame= CGRectMake(0, 0, 24, 24);
    UIButton* moreButton= [[UIButton alloc] initWithFrame:frame];
    [moreButton setBackgroundImage:buttonImageN forState:UIControlStateNormal];
    [moreButton setBackgroundImage:buttonImageH forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* moreBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    self.navigationItem.rightBarButtonItem = moreBarButtonItem;
}

//课程结束，进行相关处理
- (void)finishLearning
{
    [self pauseAndDoAI];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.playerItem  removeObserver:self forKeyPath:kStatusKey];
    [self.playerItem  removeObserver:self forKeyPath:kTracksKey];
    
    [self.player  removeObserver:self       forKeyPath:kRateKey];
    [self.player  removeTimeObserver:self.playerObserver];
    [self.player  replaceCurrentItemWithPlayerItem:nil];
    
    self.playerItem=nil;
    self.player=nil;
    self.playerObserver=nil;
    
    dispatch_async(_background_queue, ^{
        
        if (_contentType==BEWebM3U8Vedio || _contentType==BEWebMp4Vedio || _contentType==BEWebMp3Audio) {
            
            //删除数据库本地纪录，资源自动释放
            NSString *openID = [NSString getOpenUDID];
            [[[FlyingNowLessonDAO alloc] init] deleteWithUserID:openID LessonID:self.lessonID];
        }
    });
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [_currentBubbleData count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [_currentBubbleData objectAtIndex:row];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[_bubbleTable reloadData];
    
    NSInteger index = indexPath.row;
    FlyingSubRipItem * subItem = [_subtitleFile getSubItemForIndex:index];
    
    if (_modalView) {
        _modalView=nil;
    }
    
    [self pauseAndDoAI];
    
    if([self playerIsReady]) {
        
        _timeScale = self.player.currentItem.asset.duration.timescale;
        
        NSTimeInterval startTime = subItem.startTimeInSeconds;
        
        [self.player seekToTime:CMTimeMakeWithSeconds(startTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        }];
        
        [self playAndDoAI];
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

//////////////////////////////////////////////////////////////
#pragma mark 
//////////////////////////////////////////////////////////////

//LogoDone functions
- (void)dismiss
{
    [self finishLearning];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) getNewLessonList
{
    NSString *openID = [NSString getOpenUDID];

    NSArray * tempArrayID =  [[ [[FlyingNowLessonDAO alloc] init] selectIDWithUserID:openID] mutableCopy] ;
    
    FlyingLessonDAO * lessonDAO= [[FlyingLessonDAO alloc] init];
    
    __block NSMutableArray * lessons = [NSMutableArray arrayWithCapacity:0];
    
    [tempArrayID enumerateObjectsUsingBlock:^(NSString* lessonID, NSUInteger idx, BOOL *stop) {
        
        FlyingLessonData * lesson = [lessonDAO selectWithLessonID:lessonID];
        
        if(lesson.BEDLPERCENT==1 && [NSString checkMp3URL:lesson.BECONTENTURL]){
            
            [lessons addObject:lesson];
        }
    }];
    
    
    NSArray * sortedArray = [lessons sortedArrayUsingComparator:^NSComparisonResult(FlyingLessonData * a, FlyingLessonData * b) {
        
        return [a.BETITLE compare:b.BETITLE];
    }];
    
    
    _lessonList=[NSMutableArray arrayWithArray:sortedArray];
}


-(void) nextContent
{
    
    [self getNewLessonList];
    
    if (_lessonList) {
        
        __block NSInteger index;
        
        [_lessonList enumerateObjectsUsingBlock:^(FlyingLessonData* obj, NSUInteger idx, BOOL *stop) {
            
            if([obj.BELESSONID isEqualToString:_lessonData.BELESSONID])
            {
            
                index=idx;
                *stop=YES;
            }
        }];
        
        index+=1;
        
        if (index<_lessonList.count)
        {
            self.lessonID=[(FlyingLessonData*)_lessonList[index] BELESSONID];
            [self commonInit];
        }
        else
        {
            [self.view makeToast:@"已经到最后一个对话式课程。请返回重新刷新!" duration:3 position:CSToastPositionCenter];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

-(BOOL)canBecomeFirstResponder
{
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
        //[self performSegueWithIdentifier:@"fromWordToHome" sender:nil];
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
    [self.view addGestureRecognizer:recognizerRight];
    
    UISwipeGestureRecognizer *recognizerLeft= [[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleSwipeFrom:)];
    
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:recognizerLeft];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        
        [self nextContent];
    }
}

-(void) handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if ((recognizer.state ==UIGestureRecognizerStateEnded) || (recognizer.state ==UIGestureRecognizerStateCancelled)) {
        
        [self dismiss];
    }
}
@end

