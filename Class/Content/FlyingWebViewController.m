//
//  FlyingWebViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 8/26/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingWebViewController.h"
#import "FlyingItemView.h"
#import "UIView+Autosizing.h"
#import "FlyingSoundPlayer.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "iFlyingAppDelegate.h"
#import "FlyingTaskWordDAO.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "NSString+FlyingExtention.h"
#import "FlyingFakeHUD.h"
#import "FlyingStatisticDAO.h"
#import "SIAlertView.h"
#import "FlyingTouchDAO.h"
#import "FlyingNowLessonDAO.h"
#import "FlyingLessonParser.h"
#import "FlyingPubLessonData.h"
#import "UIImageView+WebCache.h"
#import "UIImage+localFile.h"
#import <AFNetworking.h>
#import "FlyingHttpTool.h"
#import "UIView+Toast.h"

#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"
#import "FlyingCommentVC.h"
#import "FlyingPubLessonData.h"

@interface FlyingWebViewController ()
{
    
    FlyingUIWebView         *_webView;
    
    FlyingItemView          *_aWordView;
    
    FlyingSoundPlayer       *_speechPlayer;
    dispatch_queue_t         _background_queue;
    
    FlyingStatisticDAO      *_statisticDAO;
    NSInteger                _balanceCoin;
    NSInteger                _touchWordCount;
    
    FlyingTouchDAO          *_touchDAO;
    
    NSString                *_currentURL;
    
    NSLinguisticTagger      * _flyingNPL;
    
    //跳转App内部逻辑用
    FlyingLessonParser      *_parser;
}

@property (strong, nonatomic) UIButton *accessChatbutton;
@property (strong, nonatomic) UIView   *accessChatContainer;

@end

@implementation FlyingWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.webView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"网页内容";
    
    [self addBackFunction];
    
    //顶部导航
    UIButton* freshButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [freshButton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [freshButton addTarget:self action:@selector(doFresh) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* freshBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:freshButton];
    
    UIButton* shareButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* shareBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareBarButtonItem,freshBarButtonItem,nil];

    
    [self loadWebview];
    
    //基本辅助信息和工具准备
    _background_queue = dispatch_queue_create("com.birdengcopy.background.processing", NULL);
    _speechPlayer = [[FlyingSoundPlayer alloc] init];
    [self autoRemoveWordView];
    
    //收费相关
    _statisticDAO = [[FlyingStatisticDAO alloc] init];
    
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    [_statisticDAO initDataForUserID:openID];
    _touchDAO     = [[FlyingTouchDAO alloc] init];
    
    _touchWordCount = [_statisticDAO touchCountWithUserID:openID];
    _balanceCoin  = [_statisticDAO finalMoneyWithUserID:openID];
    
    //
    [self prepairNLP];
    
    [self prepareForChatRoom];
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
    if (_webView) {
        
        [_webView stopLoading];
        _webView=nil;
    }
}

-(void) prepareForChatRoom
{
    if (INTERFACE_IS_PAD) {
        
        return;
    }
    
    if(!self.accessChatbutton)
    {
        CGRect chatButtonFrame=self.view.frame;
        
        CGRect frame=self.view.frame;
        
        chatButtonFrame.size.width  = frame.size.width/8;
        chatButtonFrame.size.height = frame.size.width/8;
        chatButtonFrame.origin.x    = frame.size.width*8/10;
        chatButtonFrame.origin.y    = frame.size.height-frame.size.width/5;
        
        self.accessChatContainer = [[UIView alloc]  initWithFrame:chatButtonFrame];
        
        self.accessChatbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, chatButtonFrame.size.width, chatButtonFrame.size.height)];
        [self.accessChatbutton setBackgroundImage:[UIImage imageNamed:@"Comment"]
                                         forState:UIControlStateNormal];
        [self.accessChatbutton addTarget:self action:@selector(doComment) forControlEvents:UIControlEventTouchUpInside];
        
        [self.accessChatContainer addSubview:self.accessChatbutton];
        [self.view addSubview:self.accessChatContainer];
    }
}

- (void) shakeToShow:(UIView*)aView

{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = 1.5;// 动画时间
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    // 这三个数字，我只研究了前两个，所以最后一个数字我还是按照它原来写1.0；前两个是控制view的大小的；
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 1.0)]];
    
    animation.values = values;
    
    [aView.layer addAnimation:animation forKey:nil];
}

- (void)doComment
{
    FlyingCommentVC *commentVC =[[FlyingCommentVC alloc] init];
    
    commentVC.contentID=self.thePubLesson.lessonID;
    commentVC.contentType=self.thePubLesson.contentType;
    commentVC.commentTitle=self.thePubLesson.title;
    
    commentVC.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}


- (void) doSomething
{
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.thePubLesson) {
        
        UIImageView *coverImageView = [[UIImageView alloc] init];
        [appDelegate shareImageURL:self.thePubLesson.imageURL
                           withURL:self.thePubLesson.contentURL
                             Title:self.thePubLesson.title
                              Text:self.thePubLesson.desc
                             Image:[coverImageView.image makeThumbnailOfSize:CGSizeMake(90, 120)]];
    }
    else
    {
        
        NSString *theTitle=[self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        [appDelegate shareImageURL:nil
                           withURL:self.webURL
                             Title:theTitle
                              Text: @"好友分享的网页"
                             Image:nil];
    }
}

- (void) doFresh
{
    [_webView reload];
}

-(void) loadWebview
{
    [_webView setDelegate:self];
    [_webView setFlyingwebviewdelegate:self];
    [_webView initContextMenu];

    if(!self.webURL){
        
        self.webURL = self.thePubLesson.weburl;
    }
        
    NSURL *webURL = [NSURL URLWithString:self.webURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webURL];
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }

    [_webView loadRequest:request];
}

//////////////////////////////////////////////////////////////
#pragma mark UIWebViewDelegate
//////////////////////////////////////////////////////////////

- (BOOL) webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    //隐藏状态显示
    self.stateBar.alpha=1;
}


- (void) webViewDidFinishLoad:(UIWebView *)webView
{

    //隐藏状态显示
    if (self.stateBar.alpha==1) {
        
        [self.stateBar dismissViewAnimated:YES];
    }
    
    _currentURL = webView.request.URL.absoluteString;
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{

}

//////////////////////////////////////////////////////////////
#pragma mark FlyingUIWebViewDelegate
//////////////////////////////////////////////////////////////

- (void) willShowWordView:(NSString*) word
{
    
    if (word) {
        
        NSArray *times = [word componentsSeparatedByString:@" "];
        
        if (times.count>2) {
            //是句子
            
            double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
            if (version<7.0) {

                NSString *title = @"友情提醒";
                NSString *message = [NSString stringWithFormat:@"请升级手机或者IPAD到7.0版本使用！"];
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
                [alertView addButtonWithTitle:@"知道了"
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alertView) {
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
                [alertView show];
            }
            else{
            
                [FlyingSoundPlayer soundSentence:word];
            }
        }
        else
        {
            NSString * newWord = [self NLPTheString:word];
            
            [self showWordView:newWord];
                        
            //更新点击次数和课程相关记录
            NSString * currentLessonID = self.thePubLesson.lessonID;
            if(!currentLessonID){
                
                currentLessonID =@"BirdCopyCommonID";
            }
            
            NSString *openID = [FlyingDataManager getOpenUDID];
            
            [_touchDAO countPlusWithUserID:openID LessonID:currentLessonID];
            
            //纪录点击单词
            [self addToucLammaRecord:newWord];
        }
    }
}

- (void) showWordView:(NSString*) word
{
    
    if(word){
        
        [_speechPlayer speechWord:word LessonID:self.thePubLesson.lessonID];

        if(![_aWordView.word isEqualToString:word]){
            
            CGRect frame=CGRectMake(0, 0, 200, 200);
            if (INTERFACE_IS_PAD ) {
                
                frame=CGRectMake(0, 0, 400, 400);
            }
            
            _aWordView =[[FlyingItemView alloc] initWithFrame:frame];
            [_aWordView setFullScreenModle:YES];
            [_aWordView setLessonID:self.thePubLesson.lessonID];
            [_aWordView setWord:word];
            [_aWordView  drawWithLemma:[word lowercaseString] AppTag:nil];
            
            //随机散开磁贴的显示位置
            srand((unsigned int)_aWordView.lemma.hash);
            
            CGFloat x = (self.view.frame.size.width-_aWordView.frame.size.width)*rand()/(RAND_MAX+1.0);
            CGFloat y=  (self.view.frame.size.height-_aWordView.frame.size.height)*rand()/(RAND_MAX+1.0);
            
            _aWordView.frame =CGRectMake(x, y, _aWordView.frame.size.width, _aWordView.frame.size.height) ;
            
            [_aWordView adjustForAutosizing];
            [self.view addSubview:_aWordView];
            
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                _aWordView.alpha=1;
                
            } completion:^(BOOL finished) {}];
        }
        else{
            
            [_aWordView bringSubviewToFront:_aWordView];
        }
    }
    else{
    
        [_aWordView dismissViewAnimated:YES];
    }
}

- (void) autoRemoveWordView
{
    //在一个函数里面（初始化等）里面添加要识别触摸事件的范围
    UITapGestureRecognizer *recognizer= [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleTapFrom:)];
    [recognizer setDelegate:self];
    [_webView addGestureRecognizer:recognizer];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void) handleTapFrom:(UITapGestureRecognizer *)sender
{
    if(_aWordView){
    
        [_aWordView dismissViewAnimated:YES];
        _aWordView =nil;
    }
}

//把点击单词纪录下来
-(void) addToucLammaRecord:(NSString *) touchWord
{
    
    dispatch_async(_background_queue, ^{
        
        FlyingTaskWordDAO * taskWordDAO   = [[FlyingTaskWordDAO alloc] init];
        [taskWordDAO setUserModle:NO];
        
        NSString *openID = [FlyingDataManager getOpenUDID];

        [taskWordDAO insertWithUesrID:openID
                                 Word:[touchWord lowercaseString]
                           Sentence:nil
                             LessonID:self.thePubLesson.lessonID];
    });
}


#pragma mark - Flying Magic NLP & AIColor
//解析当前字幕

-(void) prepairNLP
{
    
    if (_flyingNPL==nil) {
        
        //忽略空格、符号和连接词
        NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace |NSLinguisticTaggerOmitPunctuation |
        NSLinguisticTaggerOmitOther | NSLinguisticTaggerJoinNames;
        
        //只需要词性和名称
        NSArray * tagSchemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeNameTypeOrLexicalClass,NSLinguisticTagSchemeLemma,nil];
        
        _flyingNPL = [[NSLinguisticTagger alloc] initWithTagSchemes:tagSchemes options:options];
    }
}

-(NSString*) NLPTheString:(NSString *) string
{
    
    //如果没有学习字幕，返回
    if (string==nil) {
        return nil;
    }
    
    // This range contains the entire string, since we want to parse it completely
    NSRange stringRange = NSMakeRange(0, string.length);
    
    if (stringRange.length==0) {
        return nil;
    }
    
    //忽略空格、符号和连接词
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace |NSLinguisticTaggerOmitPunctuation |
    NSLinguisticTaggerOmitOther | NSLinguisticTaggerJoinNames;
    
    // Dictionary with a language map
    NSArray *language = [NSArray arrayWithObjects:@"en",nil];
    NSDictionary* languageMap = [NSDictionary dictionaryWithObject:language forKey:@"Latn"];
    NSOrthography * orthograsphy = [NSOrthography orthographyWithDominantScript:@"Latn" languageMap:languageMap];
    
    __block NSString * result;
    
    [_flyingNPL setString:string];
    [_flyingNPL setOrthography:orthograsphy range:stringRange];
    [_flyingNPL enumerateTagsInRange:stringRange
                              scheme:NSLinguisticTagSchemeLemma
                             options:options
                          usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                              
                              if (tag) {
                               
                                  result = tag;
                              }
                              else{
                                  
                                  result = [string substringWithRange:tokenRange];
                              }
                          }];
    
    return result;
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

-(BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
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
