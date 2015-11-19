//
//  FlyingWebViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 8/26/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingWebViewController.h"
#import "RESideMenu.h"
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
#import "FlyingLessonVC.h"
#import "FlyingSysWithCenter.h"
#import "FlyingPubLessonData.h"
#import "UIImageView+WebCache.h"
#import "UIImage+localFile.h"
#import <AFNetworking.h>
#import "FlyingHttpTool.h"
#import "UIView+Toast.h"

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
    
    image= [UIImage imageNamed:@"refresh"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* freshButton= [[UIButton alloc] initWithFrame:frame];
    [freshButton setBackgroundImage:image forState:UIControlStateNormal];
    [freshButton addTarget:self action:@selector(doFresh) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* freshBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:freshButton];
    
    image= [UIImage imageNamed:@"share"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* shareButton= [[UIButton alloc] initWithFrame:frame];
    [shareButton setBackgroundImage:image forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* shareBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareBarButtonItem,freshBarButtonItem,nil];

    
    [self loadWebview];
    
    //基本辅助信息和工具准备
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    _background_queue = [appDelegate getAIQueue];
    _speechPlayer = [[FlyingSoundPlayer alloc] init];
    [self autoRemoveWordView];
    
    //收费相关
    _statisticDAO = [[FlyingStatisticDAO alloc] init];
    
    NSString *openID = [NSString getOpenUDID];
    
    [_statisticDAO initDataForUserID:openID];
    _touchDAO     = [[FlyingTouchDAO alloc] init];
    
    _touchWordCount = [_statisticDAO touchCountWithUserID:openID];
    _balanceCoin  = [_statisticDAO finalMoneyWithUserID:openID];
    
    //
    [self prepairNLP];
}

-(void) loadWebview
{
    [_webView setDelegate:self];
    [_webView setFlyingwebviewdelegate:self];
    [_webView initContextMenu];

    if(!self.webURL){
        
        self.webURL = [[[[FlyingLessonDAO alloc] init] selectWithLessonID:self.lessonID] BECONTENTURL];
    }
        
    NSURL *webURL = [NSURL URLWithString:self.webURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webURL];
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }

    [_webView loadRequest:request];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{

    [_webView stopLoading];
    _webView = nil;
    _flyingNPL = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //释放UI资源
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setStateBar:nil];
    [self setTipsLabel:nil];
    
    self.webURL=nil;
    self.lessonID=nil;
    
   _aWordView=nil;
    _speechPlayer=nil;
    _background_queue=nil;
    
    _statisticDAO=nil;
    _touchDAO=nil;
    
    _currentURL=nil;
    
    _flyingNPL=nil;
    
    if (_webView) {
        
        [_webView stopLoading];
        _webView=nil;
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

//////////////////////////////////////////////////////////////
#pragma mark 
//////////////////////////////////////////////////////////////

//LogoDone functions
- (void)dismiss
{    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) backNow
{
    if (self.webView.canGoBack)
    {
        [self.webView goBack];
    }
    else
    {
        [self dismiss];
    }
}

- (void) outNow
{
    [self dismiss];
}


- (void) doSomething
{
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(self.lessonID)
    {
        [FlyingHttpTool getLessonForLessonID:self.lessonID
                                  Completion:^(FlyingPubLessonData *lesson) {
                                      //
                                      if (lesson) {
                                          
                                          UIImageView *coverImageView = [[UIImageView alloc] init];
                                          [appDelegate shareImageURL:lesson.imageURL
                                                             withURL:lesson.contentURL
                                                               Title:lesson.title
                                                                Text:lesson.desc
                                                               Image:[coverImageView.image makeThumbnailOfSize:CGSizeMake(90, 120)]];
                                      }

                                  }];
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

//////////////////////////////////////////////////////////////
#pragma mark UIWebViewDelegate
//////////////////////////////////////////////////////////////

- (BOOL) webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString * lessonID = [NSString getLessonIDFromOfficalURL:[request.URL absoluteString]];
    
    if (lessonID)
    {
        [webView stopLoading];
        [self performSelector:@selector(dismissAndJumpFor:) withObject:lessonID afterDelay:0.2];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void) dismissAndJumpFor:(NSString *)lessonID
{

    [self dismiss];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KBEJumpToLesson object:nil userInfo:[NSDictionary dictionaryWithObject:lessonID forKey:@"lessonID"]];
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
    
    
    if(self.webView.canGoBack){
        
        //顶部导航
        UIImage* image= [UIImage imageNamed:@"back"];
        CGRect frame= CGRectMake(0, 0, 28, 28);
        UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
        [menuButton setBackgroundImage:image forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        
        self.navigationItem.leftBarButtonItem = menuBarButtonItem;
    }
    
    if(self.webView.canGoBack){
        
        //顶部导航
        UIImage* image= [UIImage imageNamed:@"back"];
        CGRect frame= CGRectMake(0, 0, 28, 28);
        UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
        [backButton setBackgroundImage:image forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backNow) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        image= [UIImage imageNamed:@"close"];
        frame= CGRectMake(0, 0, 28, 28);
        UIButton* outButton= [[UIButton alloc] initWithFrame:frame];
        [outButton setBackgroundImage:image forState:UIControlStateNormal];
        [outButton addTarget:self action:@selector(outNow) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* outBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:outButton];

        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:outBarButtonItem, backBarButtonItem, nil];
    }
    
    //更改字体大小
    /*
    int alpha =1;
    if (!INTERFACE_IS_PAD) {
        alpha = 2;
    }
    
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",128*alpha];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
     
    
    //更改网页背景颜色和当前环境一致
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.background = '#ffffff';"];
    
    //去除右侧的滚动条和边界的地图
    for (UIView *_aView in [webView subviews])
    {
        if ([_aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO]; //右侧的滚动条
            
            for (UIView *_inScrollview in _aView.subviews)
            {
                
                if ([_inScrollview isKindOfClass:[UIImageView class]])
                {
                    _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                }
            }
        } 
    }  
     */
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
            
            if (_balanceCoin<=-500) {
                
                [FlyingSoundPlayer soundEffect:@"iMoneyDialogOpen"];
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
            }
            else{
                
                NSInteger sysTouchCount =[[NSUserDefaults standardUserDefaults] integerForKey:@"sysTouchAccount"];
                
                if (_touchWordCount-sysTouchCount>1000) {
                    
                    [FlyingSysWithCenter uploadUserCenter];

                    [FlyingSoundPlayer soundEffect:@"iMoneyDialogOpen"];
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
                }
                
                [self showWordView:newWord];
                
                if (_balanceCoin<0) {
                    
                    [FlyingSoundPlayer soundEffect:@"iMoneyDialogOpen"];
                    [self.view makeToast:@"帐户金币数不足,请尽快在《我的档案》充值!" duration:3 position:CSToastPositionCenter];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //更新点击次数和课程相关记录
                    NSString * currentLessonID = self.lessonID;
                    if(!currentLessonID){
                    
                        currentLessonID =@"BirdCopyCommonID";
                    }
                    
                    NSString *openID = [NSString getOpenUDID];

                    [_touchDAO countPlusWithUserID:openID LessonID:currentLessonID];
                });
                
                //纪录点击单词
                [self addToucLammaRecord:newWord];
            }
        }
    }
}

- (void) showWordView:(NSString*) word
{
    
    if(word){
        
        [_speechPlayer speechWord:word LessonID:self.lessonID];

        if(![_aWordView.word isEqualToString:word]){
            
            CGRect frame=CGRectMake(0, 0, 200, 200);
            if (INTERFACE_IS_PAD ) {
                
                frame=CGRectMake(0, 0, 400, 400);
            }
            
            _aWordView =[[FlyingItemView alloc] initWithFrame:frame];
            [_aWordView setFullScreenModle:YES];
            [_aWordView setLessonID:self.lessonID];
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
        
        NSString *openID = [NSString getOpenUDID];

        [taskWordDAO insertWithUesrID:openID
                                 Word:[touchWord lowercaseString]
                           Sentence:nil
                             LessonID:self.lessonID];
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

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shakeNow];
    }
}

- (void) viewDidDisappear:(BOOL)animated
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
