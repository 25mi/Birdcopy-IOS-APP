//
//  FlyingWebViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 8/26/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingWebViewController.h"
#import <WebKit/WebKit.h>
#import "FlyingCommentVC.h"
#import "FlyingShareData.h"
#import "iFlyingAppDelegate.h"
#import "UIImage+localFile.h"
#import "shareDefine.h"
#import <AFNetworking.h>
#import "NSString+FlyingExtention.h"
#import <MediaPlayer/MediaPlayer.h>

#import "UIImage+webview.h"

@interface FlyingWebViewController ()<UIViewControllerRestoration,
                                        WKNavigationDelegate,
                                        WKUIDelegate,
                                        WKScriptMessageHandler,
                                        UIScrollViewDelegate>
{
    //跳转App内部逻辑用
    //FlyingLessonParser      *_parser;
}

@property(nonatomic,strong)  WKWebView * webView;
@property (nonatomic,strong) NSMutableURLRequest *urlRequest;

@property(nonatomic,strong)  UIProgressView *  progressView;

@property(nonatomic,strong)  WKUserContentController *userContentController;

@property (strong,nonatomic) MPMoviePlayerViewController *playerVC;


@property (nonatomic,strong) UIToolbar * customToolBar;

/* Navigation Buttons */
@property (nonatomic,strong) UIBarButtonItem *backButton;             /* Moves the web view one page back */
@property (nonatomic,strong) UIBarButtonItem *forwardButton;          /* Moves the web view one page forward */
@property (nonatomic,strong) UIBarButtonItem *reloadStopButton;       /* Reload / Stop buttons */
@property (nonatomic,strong) UIBarButtonItem *actionButton;           /* Shows the UIActivityViewController */
@property (nonatomic,strong) UIBarButtonItem *readButton;           /* Shows the UIActivityViewController */

/* Images for the Reload/Stop button */
@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation FlyingWebViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (![self.webURL isBlankString])
    {
        [coder encodeObject:self.webURL forKey:@"self.webURL"];
    }
    
    if (self.thePubLesson)
    {
        [coder encodeObject:self.thePubLesson forKey:@"self.thePubLesson"];
    }
    
    if (!CGRectEqualToRect(self.webView.frame,CGRectZero))
    {
        [coder encodeCGRect:self.webView.frame forKey:@"self.webView.frame"];
    }

}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    NSString *webURL = [coder decodeObjectForKey:@"self.webURL"];
    
    if (![webURL isBlankString])
    {
        self.webURL = webURL;
    }
    
    FlyingPubLessonData * thePubLesson = [coder decodeObjectForKey:@"self.thePubLesson"];
    if(thePubLesson)
    {
        self.thePubLesson = thePubLesson;
    }
    
    CGRect frame = [coder decodeCGRectForKey:@"self.webView.frame"];
    if (!CGRectEqualToRect(frame,CGRectZero))
    {
        self.webView.frame = frame;
    }
    
    if (![self.webURL isBlankString] ||
        self.thePubLesson!=nil)
    {
        [self loadWebview];
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
    
    self.title = @"网页内容";
    
    //顶部导航
    UIButton* commentButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [commentButton setBackgroundImage:[UIImage imageNamed:@"Comment"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(doCommnet) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* commentBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    self.navigationItem.rightBarButtonItem = commentBarButtonItem;
    
    if (!self.webView)
    {
        //注册供js调用的方法
        self.userContentController =[[WKUserContentController alloc] init];
        [self.userContentController addScriptMessageHandler:self  name:@"playvideo"];
        // 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
        WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
        
        //打开JavaScript交互 默认为YES
        configuration.preferences.javaScriptEnabled = YES;
        configuration.userContentController = self.userContentController;
        
        //允许视频播放
        configuration.allowsAirPlayForMediaPlayback = YES;
        
        // 允许在线播放
        configuration.allowsInlineMediaPlayback = YES;
        
        // 允许可以与网页交互，选择视图
        configuration.selectionGranularity = YES;
        
        // 是否支持记忆读取
        configuration.suppressesIncrementalRendering = YES;
        
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-64)
                                          configuration:configuration];
        
        self.webView.restorationIdentifier = self.restorationIdentifier;

        // 设置代理
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        self.webView.scrollView.delegate =self;
        
        // 添加进度监控
        /*
         NSKeyValueObservingOptionNew 把更改之前的值提供给处理方法
         
         　　NSKeyValueObservingOptionOld 把更改之后的值提供给处理方法
         
         　　NSKeyValueObservingOptionInitial 把初始化的值提供给处理方法，一旦注册，立马就会调用一次。通常它会带有新值，而不会带有旧值。
         
         　　NSKeyValueObservingOptionPrior 分2次调用。在值改变之前和值改变之后。
         */
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        //开启手势触摸
        self.webView.allowsBackForwardNavigationGestures = NO;
        
        // 设置 可以前进 和 后退
        //适应你设定的尺寸
        [self.webView sizeToFit];
        
        [self.view addSubview:self.webView];
    }
    
    if (!self.progressView)
    {
        self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        CGRect barFrame = CGRectMake(0, 0, self.view.frame.size.width, 1);
        
        self.progressView.frame = barFrame;
        
        // 设置进度条的色彩
        
        [self.progressView setTrackTintColor:[UIColor clearColor]];
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
        UIColor *tintColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];

        self.progressView.progressTintColor = tintColor;
        
        [self.view addSubview:self.progressView];
    }
    
    if (![self.webURL isBlankString] ||
        self.thePubLesson!=nil)
    {
        [self loadWebview];
    }
    
    [self setUpNavigationButtons];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self setToolbarHidden:YES];
    [self.userContentController removeScriptMessageHandlerForName:@"playvideo"];
    
    //zombie bug fix
    self.webView.scrollView.delegate = nil;
}

- (void) willDismiss
{
    if (_webView)
    {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView stopLoading];
    }
}

-(void) doCommnet
{
    FlyingCommentVC *commentVC =[[FlyingCommentVC alloc] init];
    
    commentVC.contentID=self.thePubLesson.lessonID;
    commentVC.contentType=self.thePubLesson.contentType;
    commentVC.commentTitle=self.thePubLesson.title;
    
    commentVC.domainID = self.domainID;
    commentVC.domainType = self.domainType;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void) doSomething
{
    if (self.thePubLesson)
    {
        FlyingShareData * shareData = [[FlyingShareData alloc] init];
        
        shareData.webURL  = [NSURL URLWithString:self.thePubLesson.weburl];
        shareData.title   = self.thePubLesson.title;
        shareData.digest  = self.thePubLesson.desc;
        
        shareData.imageURL= self.thePubLesson.imageURL;
        
        shareData.image   = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:shareData.imageURL]]] makeThumbnailOfSize:CGSizeMake(90, 120)];
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shareContent:shareData fromView:self.actionButton];
    }
    else
    {
        FlyingShareData * shareData = [[FlyingShareData alloc] init];
        
        shareData.webURL  = [NSURL URLWithString:self.webURL];
        shareData.title   = self.title;
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shareContent:shareData fromView:self.actionButton];
    }
}

-(void) loadWebview
{
    if(!self.webURL){
        
        self.webURL = self.thePubLesson.contentURL;
    }
        
    NSURL *webURL = [NSURL URLWithString:self.webURL];
    
    self.urlRequest = [NSMutableURLRequest requestWithURL:webURL];
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [self.urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }

    [_webView loadRequest:self.urlRequest];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!INTERFACE_IS_PAD)
    {
        if (self.lastContentOffset > scrollView.contentOffset.y)
        {
            [self setToolbarHidden:NO];
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y)
        {
            [self setToolbarHidden:YES];
        }
        
        self.lastContentOffset = scrollView.contentOffset.y;
    }
}

//////////////////////////////////////////////////////////////
#pragma mark WKWebViewDelegate
//////////////////////////////////////////////////////////////
//这个是网页加载完成，导航的变化

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.progressView.hidden = YES;
    
    /*
     主意：这个方法是当网页的内容全部显示（网页内的所有图片必须都正常显示）的时候调用（不是出现的时候就调用），，否则不显示，或则部分显示时这个方法就不调用。
     
     */
    NSLog(@"加载完成调用");
    
    // 获取加载网页的标题
    self.title = self.webView.title;
    
    //遍历网页中的视频资源 并加上播放标示
    NSString *javaScript=[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"injectJSForVideo" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    [self.webView evaluateJavaScript:javaScript completionHandler:nil];
        
    [self refreshButtonsState];
}

//开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
}

//内容返回时调用

-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
    NSLog(@"当内容返回的时候调用");
    
    NSLog(@"%lf",   self.webView.estimatedProgress);
    
    //屏蔽放大镜
    /*
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
    
    [webView evaluateJavaScript:javascript completionHandler:nil];
     */
    
}

-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    
    NSLog(@"这是服务器请求跳转的时候调用");
    
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
    // 内容加载失败时候调用
    
    NSLog(@"这是加载失败时候调用");
    
    NSLog(@"%@",error);
    
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
    NSLog(@"通过导航跳转失败的时候调用");
    
}

-(void)webViewDidClose:(WKWebView *)webView
{
    
    NSLog(@"网页关闭的时候调用");
    
}

-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    
    NSLog(@"%lf",   webView.estimatedProgress);
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 首先，判断是哪个路径
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        // 判断是哪个对象
        if (object == self.webView)
        {
            NSLog(@"进度信息：%lf",self.webView.estimatedProgress);
            
            if (self.webView.estimatedProgress == 1.0)
            {
                //隐藏
                self.progressView.hidden = YES;
                
            }else
            {
                // 添加进度数值
                self.progressView.progress = self.webView.estimatedProgress;
            }
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark 实现WKScriptMessageHandler的协议方法
//////////////////////////////////////////////////////////////

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message

{
    //message.name  js发送的方法名称
    
    if([message.name  isEqualToString:@"playvideo"])
        
    {
        NSString * body = message.body;
        
        NSString * lessonID = [NSString getLessonIDFromOfficalURL:body];
        
        if (lessonID)
        {
            iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate showLessonViewWithID:lessonID];
            
            //// Optional data
            NSSet *websiteDataTypes
            = [NSSet setWithArray:@[
                                    WKWebsiteDataTypeDiskCache,
                                    //WKWebsiteDataTypeOfflineWebApplicationCache,
                                    WKWebsiteDataTypeMemoryCache,
                                    //WKWebsiteDataTypeLocalStorage,
                                    //WKWebsiteDataTypeCookies,
                                    //WKWebsiteDataTypeSessionStorage,
                                    //WKWebsiteDataTypeIndexedDBDatabases,
                                    //WKWebsiteDataTypeWebSQLDatabases
                                    ]];
            //// All kinds of data
            //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
            //// Date from
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            //// Execute
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                // Done
            }];
        }
        else
        {
            NSURL *url = [NSURL URLWithString:body];
            
            MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
            [self presentMoviePlayerViewControllerAnimated:playerVC];
        }

        NSLog(@"%@", body);

    }
}

/**  确认框 */
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    // 获取js 里面的提示
    
    [[[UIAlertView alloc] initWithTitle:@"标题" message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil] show];
    completionHandler();

}

/**  警告框 */
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    
    // js 信息的交流
    
    [[[UIAlertView alloc] initWithTitle:@"标题" message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil] show];
    
}

/**  输入框 */
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    // 交互。可输入的文本。
    
}

- (void)setUpNavigationButtons
{
    //set up the back button
    if (self.backButton == nil)
    {
        UIImage *backButtonImage = [UIImage backButton];
        
        self.backButton = [[UIBarButtonItem alloc] initWithImage:backButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    }
    
    //set up the forward button
    if (self.forwardButton == nil) {
        UIImage *forwardButtonImage = [UIImage forwardButton];
        self.forwardButton  = [[UIBarButtonItem alloc] initWithImage:forwardButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTapped:)];
    }
    
    //set up the reload button
    if (self.reloadStopButton == nil) {
        self.reloadIcon = [UIImage refreshButton];
        self.stopIcon   = [UIImage stopButton];
        
        self.reloadStopButton = [[UIBarButtonItem alloc] initWithImage:self.reloadIcon style:UIBarButtonItemStylePlain target:self action:@selector(reloadStopButtonTapped:)];
    }
    
    //set up the  action button
    if (self.actionButton == nil) {
        self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonTapped:)];
        
        CGFloat topInset = -2.0f;
        self.actionButton.imageInsets = UIEdgeInsetsMake(topInset, 0.0f, -topInset, 0.0f);
    }
    

    //set up the read button
    /*
    if (self.readButton == nil)
    {
        UIImage *readButtonImage = [UIImage readButton];
        self.readButton  = [[UIBarButtonItem alloc] initWithImage:readButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(readButtonTapped:)];
    }
     */
    
    [self layoutButtonsForCurrentSizeClass];
}

#define NAVIGATION_ICON_SPACING             25

- (void)layoutButtonsForCurrentSizeClass
{
    //Handle iPhone Layout
    if (!INTERFACE_IS_PAD)
    {
        //Set up array of buttons
        NSMutableArray *items = [NSMutableArray array];
        
        if (self.backButton)        { [items addObject:self.backButton]; }
        if (self.forwardButton)     { [items addObject:self.forwardButton]; }
        if (self.actionButton)      { [items addObject:self.actionButton]; }
        if (self.reloadStopButton)  { [items addObject:self.reloadStopButton]; }
        if (self.readButton)        { [items addObject:self.readButton]; }
        
        UIBarButtonItem *(^flexibleSpace)() = ^{
            return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        };
        
        BOOL lessThanFiveItems = items.count < 5;
        
        NSInteger index = 1;
        NSInteger itemsCount = items.count-1;
        for (NSInteger i = 0; i < itemsCount; i++) {
            [items insertObject:flexibleSpace() atIndex:index];
            index += 2;
        }
        
        if (lessThanFiveItems) {
            [items insertObject:flexibleSpace() atIndex:0];
            [items addObject:flexibleSpace()];
        }
        
        CGRect toolBarFrame=self.view.frame;
        CGRect frame=self.view.frame;
        
        NSInteger height = [[NSUserDefaults standardUserDefaults] integerForKey:KTabBarHeight];
        toolBarFrame.size.width  = frame.size.width;
        toolBarFrame.size.height = height;
        toolBarFrame.origin.x    = 0;
        toolBarFrame.origin.y    = CGRectGetHeight(self.webView.frame)-height;
        
        self.customToolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
        self.customToolBar.items = items;

        [self.view addSubview:self.customToolBar];
    }
    else
    {
        [self setToolbarHidden:YES];
        
        //Handle iPad layout
        NSMutableArray *rightItems = [NSMutableArray array];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = NAVIGATION_ICON_SPACING;
        
        if (self.actionButton)      { [rightItems addObject:self.actionButton];     [rightItems addObject:fixedSpace]; }
        
        if (self.reloadStopButton)  { [rightItems addObject:self.reloadStopButton]; [rightItems addObject:fixedSpace]; }
        if (self.forwardButton)     { [rightItems addObject:self.forwardButton];    [rightItems addObject:fixedSpace]; }
        if (self.backButton)        { [rightItems addObject:self.backButton];       [rightItems addObject:fixedSpace]; }
        
        self.navigationItem.rightBarButtonItems = rightItems;
    }
}

-(void) setToolbarHidden:(BOOL) hidden
{
    [self.customToolBar setHidden:hidden];
}

#pragma mark -
#pragma mark Button Callbacks
- (void)backButtonTapped:(id)sender
{
    [self.webView goBack];
    [self refreshButtonsState];
}

- (void)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
    [self refreshButtonsState];
}

- (void)reloadStopButtonTapped:(id)sender
{
    BOOL loaded = self.webView.estimatedProgress==1? YES:NO;
    
    //regardless of reloading, or stopping, halt the webview
    [self.webView stopLoading];
    
    if (loaded) {
        //In certain cases, if the connection drops out preload or midload,
        //it nullifies webView.request, which causes [webView reload] to stop working.
        //This checks to see if the webView request URL is nullified, and if so, tries to load
        //off our stored self.url property instead
        if (self.webView.URL.absoluteString.length == 0 && self.webURL)
        {
            [self.webView loadRequest:self.urlRequest];
        }
        else {
            [self.webView reload];
        }
    }
    
    //refresh the buttons
    [self refreshButtonsState];
}

- (void)actionButtonTapped:(id)sender
{
    //Do nothing if there is no url for action
    if (!self.webURL) {
        return;
    }
    
    [self doSomething];
}

- (void)readButtonTapped:(id)sender
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"reader" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [self.webView evaluateJavaScript:jsCode completionHandler:nil];
}

- (void)refreshButtonsState
{
    //update the state for the back button
    if (self.webView.canGoBack)
        [self.backButton setEnabled:YES];
    else
        [self.backButton setEnabled:NO];
    
    //Forward button
    if (self.webView.canGoForward)
        [self.forwardButton setEnabled:YES];
    else
        [self.forwardButton setEnabled:NO];
    
    BOOL loaded = self.webView.estimatedProgress==1? YES:NO;
    
    //Stop/Reload Button
    if (!loaded) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.reloadStopButton.image = self.stopIcon;
    }
    else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.reloadStopButton.image = self.reloadIcon;
    }
}


@end
