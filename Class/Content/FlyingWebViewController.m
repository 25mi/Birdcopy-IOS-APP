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

@interface FlyingWebViewController ()<UIViewControllerRestoration,
                                        WKNavigationDelegate,
                                        WKUIDelegate,
                                        WKScriptMessageHandler>
{
    //跳转App内部逻辑用
    //FlyingLessonParser      *_parser;
}

@property(nonatomic,strong)  WKWebView * webView;
@property(nonatomic,strong)  UIProgressView *  progressView;

@property(nonatomic,strong)  WKUserContentController *userContentController;

@property (strong, nonatomic) UIButton *shareButton;

@property (strong,nonatomic) MPMoviePlayerViewController *playerVC;

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
    
    if (![self.webURL isBlankString] ||
        self.thePubLesson)
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
        self.webView.restorationIdentifier = self.restorationIdentifier;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.edgesForExtendedLayout = UIRectEdgeAll;

    self.title = @"网页内容";
    
    //顶部导航
    UIButton* commentButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [commentButton setBackgroundImage:[UIImage imageNamed:@"Comment"] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(doCommnet) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* commentBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:commentButton];
    
    self.shareButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* shareBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:self.shareButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareBarButtonItem,commentBarButtonItem,nil];
    
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
        
        self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
        
        // 设置代理
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        
        // 添加进度监控
        
        /*
         NSKeyValueObservingOptionNew 把更改之前的值提供给处理方法
         
         　　NSKeyValueObservingOptionOld 把更改之后的值提供给处理方法
         
         　　NSKeyValueObservingOptionInitial 把初始化的值提供给处理方法，一旦注册，立马就会调用一次。通常它会带有新值，而不会带有旧值。
         
         　　NSKeyValueObservingOptionPrior 分2次调用。在值改变之前和值改变之后。
         
         */
        
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        //开启手势触摸
        self.webView.allowsBackForwardNavigationGestures = YES;
        
        // 设置 可以前进 和 后退
        //适应你设定的尺寸
        [self.webView sizeToFit];
        
        [self.view addSubview:self.webView];
    }
    
    if (!self.progressView)
    {
        
        self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        CGRect barFrame = CGRectMake(0, 64, self.view.frame.size.width, 1);
        
        self.progressView.frame = barFrame;
        
        // 设置进度条的色彩
        
        [self.progressView setTrackTintColor:[UIColor clearColor]];
        
        NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
        UIColor *tintColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];

        self.progressView.progressTintColor = tintColor;
        
        [self.view addSubview:self.progressView];
    }
    
    if (![self.webURL isBlankString] ||
        self.thePubLesson)
    {
        [self loadWebview];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.userContentController removeScriptMessageHandlerForName:@"playvideo"];
}

- (void) willDismiss
{
    if (_webView) {
        
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView stopLoading];
        //_webView=nil;
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

-(void) doCommnet
{
    FlyingCommentVC *commentVC =[[FlyingCommentVC alloc] init];
    
    commentVC.contentID=self.thePubLesson.lessonID;
    commentVC.contentType=self.thePubLesson.contentType;
    commentVC.commentTitle=self.thePubLesson.title;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void) doSomething
{
    if (self.thePubLesson) {
        
        FlyingShareData * shareData = [[FlyingShareData alloc] init];
        
        shareData.webURL  = [NSURL URLWithString:self.thePubLesson.weburl];
        shareData.title   = self.thePubLesson.title;
        shareData.digest  = self.thePubLesson.desc;
        
        shareData.imageURL= self.thePubLesson.imageURL;
        
        shareData.image   = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:shareData.imageURL]]] makeThumbnailOfSize:CGSizeMake(90, 120)];
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shareContent:shareData fromView:self.shareButton];
    }
    else
    {
        FlyingShareData * shareData = [[FlyingShareData alloc] init];
        
        shareData.webURL  = [NSURL URLWithString:self.webURL];
        shareData.title   = self.title;
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shareContent:shareData fromView:self.shareButton];
    }
}

- (void) doFresh
{
    [_webView reload];
}

-(void) loadWebview
{    
    if(!self.webURL){
        
        self.webURL = self.thePubLesson.contentURL;
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

    
    [webView evaluateJavaScript:javaScript completionHandler:nil];
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
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
    
    [webView evaluateJavaScript:javascript completionHandler:nil];
    
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


@end
