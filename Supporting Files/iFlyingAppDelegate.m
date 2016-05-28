    //  iFlyingAppDelegate.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/3/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "iFlyingAppDelegate.h"

#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "OpenUDID.h"
#import "FlyingSoundPlayer.h"
#import "UICKeyChainStore.h"
#import "UIImage+localFile.h"
#import "UIImageView+thumnail.h"
#import "FlyingM3U8Downloader.h"
#import "HTTPServer.h"
#import "UIView+Autosizing.h"
#import "FlyingFakeHUD.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "FlyingPubLessonData.h"
#import "FlyingNowLessonDAO.h"
#import "FlyingTaskWordDAO.h"
#import "FlyingStatisticDAO.h"
#import "FlyingContentListVC.h"
#import "FlyingGuideViewController.h"
#import <sys/xattr.h>
#import "FlyingDownloadManager.h"
#import "FlyingTouchDAO.h"
#import <Social/Social.h>
#import "FlyingWebViewController.h"
#import "FlyingLessonParser.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "common.h"
#import "FlyingMyGroupsVC.h"
#import "FlyingContentVC.h"
#import "FlyingNavigationController.h"
#import <RongIMKit/RCIM.h>
#import "AFHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "UIColor+RCColor.h"
#import "FlyingHttpTool.h"
#import "RCDataBaseManager.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHttpTool.h"
#import "FlyingHttpTool.h"
#import "ReaderViewController.h"
#import "FlyingNowLessonDAO.h"
#import "CGPDFDocument.h"
#import "FlyingNowLessonData.h"
#import "FileHash.h"
#import "FlyingDataManager.h"
#import "FlyingHttpTool.h"
#import "MKStoreKit.h"
#import <StoreKit/StoreKit.h>
#import "FlyingDBManager.h"
#import "FlyingDataManager.h"
#import "FlyingFileManager.h"
#import "FlyingConversationListVC.h"
#import "FlyingHomeVC.h"
#import "WeChatMomentsActivity.h"
#import "WeChatSessionActivity.h"
#import "FlyingShareData.h"
#import "FlyingUserRightData.h"
#import "LEColorPicker.h"
#import "FlyingShareInAppActivity.h"
#import "FlyingAccountVC.h"
#import "UIAlertController+Window.h"
#import "FlyingTabBarController.h"
#import <CRToastManager.h>
#import <CRToast/CRToastConfig.h>
#import "FlyingConversationVC.h"

@interface iFlyingAppDelegate ()
{
    //M3U8相关
    HTTPServer                  *_httpServer;
        
    FlyingLessonParser          *_parser;
    
    //发音管理
    NSOperationQueue            *_flyingSoundPlayer_queue;
    AVSpeechSynthesizer         *_synthesizer;
}

@property (strong, nonatomic) FlyingTabBarController    *theTabBarController;

@property (assign, atomic)  BOOL hasMessageJob;

@property (nonatomic, retain) NSOperationQueue      *makeToastQueue;

@end


@implementation iFlyingAppDelegate


- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.window.rootViewController forKey:@"rootVC"];
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.window.rootViewController = [FlyingViewController new];

    /*
    UIViewController *vc = [coder decodeObjectForKey:@"rootVC"];
    
    if (vc)
    {
        self.window.rootViewController = vc;
        
        if ([vc isKindOfClass:[FlyingTabBarController class]])
        {
            self.tabBarController = (FlyingTabBarController*)vc;
        }
    }
     */
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //准备本地环境
    [iFlyingAppDelegate preparelocalEnvironment];

    //验证OPenUDID
    [FlyingDataManager makeOpenUDIDFromLocal];
    
    //融云推送处理1
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
        
    }
    //统计推送打开率1
    [[RCIMClient sharedRCIMClient] recordLaunchOptionsEvent:launchOptions];
    
    //获取融云推送服务扩展字段1
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromLaunchOptions:launchOptions];
    if (pushServiceData) {
        NSLog(@"该启动事件包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"%@", pushServiceData[key]);
        }
    } else {
        NSLog(@"该启动事件不包含来自融云的推送服务");
    }
    
    UIWindow * window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.restorationIdentifier = NSStringFromClass([window class]);
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    window.backgroundColor = backgroundColor;
    
    self.window = window;
    
    return YES;
}

//融云推送处理2
//注册用户通知设置
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

//融云推送处理3
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

//融云推送处理4
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    /**
     * 统计推送打开率2
     */
    [[RCIMClient sharedRCIMClient] recordRemoteNotificationEvent:userInfo];
    /**
     * 获取融云推送服务扩展字段2
     */
    NSDictionary *pushServiceData = [[RCIMClient sharedRCIMClient] getPushExtraFromRemoteNotification:userInfo];
    if (pushServiceData) {
        NSLog(@"该远程推送包含来自融云的推送服务");
        for (id key in [pushServiceData allKeys]) {
            NSLog(@"key = %@, value = %@", key, pushServiceData[key]);
        }
    } else {
        NSLog(@"该远程推送不包含来自融云的推送服务");
    }
}

//本地通知处理
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    /**
     * 统计推送打开率3
     */
    [[RCIMClient sharedRCIMClient] recordLocalNotificationEvent:notification];
    
    //震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1007);
}

//根据是否注册进行不同跳转处理
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (!self.window.rootViewController)
    {
        if([FlyingDataManager getUserData:[FlyingDataManager getOpenUDID]])
        {
            self.window.rootViewController = [self getTabBarController];
        }
        else
        {
            FlyingGuideViewController * guidVC =[[FlyingGuideViewController alloc] init];
            self.window.rootViewController = guidVC;
        }
    }
    
    [self.window makeKeyAndVisible];

    return YES;
}

//本地环境准备
+(void) preparelocalEnvironment
{
    //监控网络状态
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

    //缓存设置
    int cacheSizeMemory = 8*1024*1024; // 8MB
    int cacheSizeDisk   = 64*1024*1024; // 64MB
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    [FlyingFileManager setNotBackUp];
    
    //准备PDF环境
    queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
    ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
    fz_register_document_handlers(ctx);
    screenScale = [[UIScreen mainScreen] scale];
    
    //准备购买环境
    [[MKStoreKit sharedKit] startProductRequest];
    
    //向微信注册
    [WXApi registerApp:[FlyingDataManager getWeixinID]];
    
    //准备数据库（DB和音频）
    [FlyingDBManager prepareDB];
    
    //准备融云的初始化环境
    NSString* rongAPPkey=[FlyingDataManager getRongKey];
    
    //初始化融云SDK
    [[RCIM sharedRCIM] initWithAppKey:rongAPPkey];
    [[RCIM sharedRCIM] setConnectionStatusDelegate:(iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate]];
    
    //设置会话列表头像和会话界面头像
    if (INTERFACE_IS_PHONE6PLUS) {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
    }else{
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    }
    
    //设置用户信息源
    [[RCIM sharedRCIM] setUserInfoDataSource:[RCDRCIMDataSource shareInstance]];
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    
    //设置接收消息代理
    [RCIM sharedRCIM].receiveMessageDelegate=(iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    //    [RCIM sharedRCIM].globalMessagePortraitSize = CGSizeMake(46, 46);
    
    //设置显示未注册的消息
    //如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
    [RCIM sharedRCIM].showUnkownMessage = YES;
    [RCIM sharedRCIM].showUnkownMessageNotificaiton = YES;
    
    //监控本地文件夹状态
    [[FlyingFileManager shareInstance] watchDocumentStateNow];
    
    //监控下载更新
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(CalledToJumpToLessinID:)
                                                 name:KBEJumpToLesson
                                               object:nil];
    
    //准备APP Style
    [self prepairAppStyle];
    
    //设置消息参数
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    
    options[kCRToastNotificationTypeKey] = @(CRToastTypeNavigationBar);
    options[kCRToastInteractionRespondersKey] = @[[CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                                                                  automaticallyDismiss:YES
                                                                                                                 block:^(CRToastInteractionType interactionType)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate touchMessage];
    }]];
    
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    options[kCRToastBackgroundColorKey] = backgroundColor;
    options[kCRToastTextColorKey] = [UIColor blackColor];
    options[kCRToastFontKey] = [UIFont systemFontOfSize:KLargeFontSize];
    options[kCRToastImageKey] = [UIImage imageNamed:@"Message"];
    options[kCRToastTextAlignmentKey] =@(NSTextAlignmentLeft);
    
    [CRToastManager setDefaultOptions:options];

    //是否关闭所有的前台消息提示音，默认值是NO
    [[RCIM sharedRCIM] setDisableMessageAlertSound:YES];
    
    //获取平台管理员消息
    [FlyingHttpTool getUserInfoByRongID:@"sysAdminor"
                             completion:^(FlyingUserData *userData, RCUserInfo *userInfo) {
                                 //
                                 NSLog(@"");
                             }];
    
    //登录融云
    [FlyingHttpTool loginRongCloud];
}

- (void) CalledToJumpToLessinID:(NSNotification*) aNotification
{
    NSString * lessonID = [[aNotification userInfo] objectForKey:@"lessonID"];
    
    if(lessonID){
    
        [self showLessonViewWithID:lessonID];
    }
}

#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status
{
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        
        NSString *title = @"提示";
        NSString *message = @"您的帐号在别的设备上登录，您被迫下线！";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController show];
    }
    
    else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        
        NSString *title = @"提示";
        NSString *message = @"Token已过期，请重新登录";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController show];
    }
}

#pragma mark - RCIMReceiveMessageDelegate

-(void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    [self refreshTabBadgeValue];
    
    RCUserInfo *userInfo=[[RCDataBaseManager shareInstance] getUserByUserId:message.targetId];
    
    if (userInfo)
    {
        switch (message.conversationType)
        {
            case ConversationType_PRIVATE:
            case ConversationType_CUSTOMERSERVICE:
            case ConversationType_SYSTEM:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *messageText =[NSString stringWithFormat: NSLocalizedString(@"%@ is sending something...", nil),userInfo.name];
                    [self makeToast:messageText];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:message]
                                                              forKey:KJobMessageNow];
                    self.hasMessageJob = YES;
                });
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        [FlyingHttpTool getUserInfoByRongID:message.targetId
                                 completion:^(FlyingUserData *userData, RCUserInfo *userInfo) {
                                     //
                                     switch (message.conversationType)
                                     {
                                         case ConversationType_PRIVATE:
                                         case ConversationType_CUSTOMERSERVICE:
                                         case ConversationType_SYSTEM:
                                         {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 
                                                 NSString *messageText =[NSString stringWithFormat: NSLocalizedString(@"%@ is sending something...", nil),userInfo.name];
                                                 [self makeToast:messageText];
                                             });
                                         }
                                             break;
                                             
                                         default:
                                             break;
                                     }
                                 }];
    }

}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:RCKitDispatchMessageNotification
     object:nil];
}


#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //同步重要遗漏数据
    if([[NSUserDefaults standardUserDefaults] boolForKey:KShouldSysMembership])
    {
        FlyingUserRightData * userRight = [FlyingDataManager getUserRightForDomainID:[FlyingDataManager getAppData].appID
                                        domainType:BC_Domain_Business];
        
        
        if (userRight) {
            
            [FlyingHttpTool updateMembershipForAccount:[FlyingDataManager getOpenUDID]
                                             StartDate:userRight.startDate
                                               EndDate:userRight.endDate
                                            Completion:^(BOOL result) {
                                                //
                                                
                                                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KShouldSysMembership];
                                            }];

        }
    }
    
    FlyingLessonDAO * dao=[[FlyingLessonDAO alloc] init];
    NSArray * lessonsBeResumeDownload=[dao selectWithWaittingDownload];
    
    FlyingNowLessonDAO * nowDao=[[FlyingNowLessonDAO alloc] init];
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    //清理因为异常造成的伪下载任务
    [lessonsBeResumeDownload enumerateObjectsUsingBlock:^(FlyingLessonData * lessonData, NSUInteger idx, BOOL *stop) {
        
        if (![nowDao selectWithUserID:openID LessonID:lessonData.BELESSONID]) {
            
            [dao deleteWithLessonID:lessonData.BELESSONID];
        }
    }];
    
    [self closeMyresource];
    
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    application.applicationIconBadgeNumber = unreadMsgCount;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;      // try to clean up as much memory as possible. next step is to terminate app
{
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self closeMyresource];
    
    int success = fz_shrink_store(ctx, 50);
	NSLog(@"fz_shrink_store: success = %d", success);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[[FlyingLessonDAO alloc] init] updateDowloadStateOffine];
    [self closeMyresource];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
}

- (void) closeMyresource
{
    [[FlyingDBManager shareInstance] closeDBQueue];
    [[FlyingDownloadManager shareInstance] closeAllDownloader];
    [self closeLocalHttpserver];
    [self close_flyingSoundPlayer_queue];
    [self closeSpeechSynthesizer];
}

- (void) startLocalHttpserver
{
    if (!_httpServer) {
        // Create server using our custom MyHTTPServer class
        _httpServer = [[HTTPServer alloc] init];
        [_httpServer setType:@"_http._tcp."];
        
        [_httpServer setPort:12345];
        
        [_httpServer setDocumentRoot:[FlyingFileManager getMyDownloadsDir]];
        
        // Start the server (and check for problems)
        NSError *error;
        if(![_httpServer start:&error])
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
    }
}

- (void) closeLocalHttpserver
{
    if (_httpServer) {
        
        [_httpServer stop];
        _httpServer=nil;
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Network Related
//////////////////////////////////////////////////////////////
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (void) showLessonViewWithID:(NSString *) lessonID
{
    
    [FlyingHttpTool getLessonForLessonID:lessonID
                              Completion:^(FlyingPubLessonData *lesson) {
                                  //
                                  FlyingContentVC * vc=[[FlyingContentVC alloc] init];
                                  vc.thePubLesson=lesson;
                                  
                                  [self pushViewController:vc
                                                  animated:YES];
                              }];
}

- (void) showLessonViewWithCode:(NSString*) code
{
    [FlyingHttpTool getLessonForISBN:code
                          Completion:^(FlyingPubLessonData *pubLesson) {
                              FlyingContentVC * vc=[[FlyingContentVC alloc] init];
                              vc.thePubLesson=pubLesson;
                              
                              [self pushViewController:vc
                                              animated:YES];
                          }];
}

- (void) shakeNow
{
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL) animated
{

    [(FlyingNavigationController*)[self getTabBarController].selectedViewController
     pushViewController:viewController
     animated:YES];
}

- (void) presentViewController:(UIViewController *)viewController
{
    [[self getTabBarController]  presentViewController:viewController animated:YES completion:nil];
}

- (BOOL) showWebviewWithURL:(NSString *) webURL
{
    if (webURL) {
        
        FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
        [webVC setWebURL:webURL];
        
        [self pushViewController:webVC animated:YES];
        
        return YES;
    }
    else{
    
        return NO;
    }
}

//////////////////////////////////////////////////////////////
-(FlyingTabBarController*) getTabBarController
{
    if(!self.theTabBarController)
    {
        self.theTabBarController = [[FlyingTabBarController alloc] init];
    }
    
    return self.theTabBarController;
}
-(void)setTabBarController:(FlyingTabBarController*)tabBarController
{
    self.theTabBarController = tabBarController;
}

- (void)refreshTabBadgeValue
{    
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([[self getTabBarController].viewControllers count]==4)
        {
            UITabBarItem * item=[[self getTabBarController].tabBar.items objectAtIndex:2];
            
            if (unreadMsgCount==0) {
                
                item.badgeValue=nil;
            }
            else
            {
                item.badgeValue=[NSString stringWithFormat:@"%d",unreadMsgCount];
            }
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadMsgCount;
        }
        
    });
}

+(void) prepairAppStyle
{
    UIColor *backgroundColor;
    UIColor *textColor;
    
    LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
    LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:[UIImage imageNamed:@"Icon"]];
    //[colorScheme primaryTextColor];
    //[colorScheme secondaryTextColor];
    
    backgroundColor = [colorScheme backgroundColor];
    textColor=  [UIColor readableForegroundColorForBackgroundColor:backgroundColor];
    
    //统一导航条样式
    UIFont* font = [UIFont systemFontOfSize:19.f];
    NSDictionary* textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:textColor};
    
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:textColor];
    [[UINavigationBar appearance] setBarTintColor:backgroundColor];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:backgroundColor]
                                              forKey:@"backgroundColor"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:textColor]
                                              forKey:@"textColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) setNavigationBarWithLogoStyle:(BOOL) logoStyle
{
    
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *textColor= [UIColor blackColor];

    if(logoStyle)
    {
        LEColorPicker *colorPicker = [[LEColorPicker alloc] init];
        LEColorScheme *colorScheme = [colorPicker colorSchemeFromImage:[UIImage imageNamed:@"Icon"]];
        //[colorScheme primaryTextColor];
        //[colorScheme secondaryTextColor];
        
        backgroundColor = [colorScheme backgroundColor];
        textColor=  [UIColor readableForegroundColorForBackgroundColor:backgroundColor];
    }
    
    //统一导航条样式
    UIFont* font = [UIFont systemFontOfSize:19.f];
    NSDictionary* textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:textColor};
    
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:textColor];
    [[UINavigationBar appearance] setBarTintColor:backgroundColor];
    
    
    [self getTabBarController].tabBar.tintColor =  backgroundColor;
}

//////////////////////////////////////////////////////////////
#pragma mark - Account and Coin  Related
//////////////////////////////////////////////////////////////
- (void) upgrade
{
    //金币
    FlyingStatisticDAO * statistic=[[FlyingStatisticDAO alloc] init];
    
    if(![statistic hasQRCount]){
    
        [statistic insertQRCount];
        [statistic insertTimeStamp];
        NSString *openID = [FlyingDataManager getOpenUDID];
        [statistic updateUserID:openID];
        
        //课程相关数据
        FlyingNowLessonDAO * currentNowLessonDAO= [[FlyingNowLessonDAO alloc] init];
        [currentNowLessonDAO updateUserID:openID];
        
        //生词数据
        FlyingTaskWordDAO * currentTaskDAO= [[FlyingTaskWordDAO alloc] init];
        [currentTaskDAO updateUserID:openID];
    }
    
    //建立点击记录表
    FlyingTouchDAO * touchDAO =[[FlyingTouchDAO alloc] init];
    [touchDAO creatTouchTable];
    
    //增加课程内容和获取属性
    FlyingLessonDAO * lessonDAO = [[FlyingLessonDAO alloc] init];
    [lessonDAO insertContentType];
    [lessonDAO insertDownloadType];
    [lessonDAO insertTag];
}

//////////////////////////////////////////////////////////////
#pragma mark - Sound related
//////////////////////////////////////////////////////////////
- (NSOperationQueue *) get_flyingSoundPlayer_queue
{
    if (!_flyingSoundPlayer_queue) {
        _flyingSoundPlayer_queue =  [[NSOperationQueue alloc] init];
    }
    
    return _flyingSoundPlayer_queue;
}

- (void ) close_flyingSoundPlayer_queue
{
    _flyingSoundPlayer_queue=nil;
}

-(AVSpeechSynthesizer *) getSpeechSynthesizer
{
    if(!_synthesizer){
        _synthesizer     = [[AVSpeechSynthesizer alloc] init];
    }

    return _synthesizer;
}

-(void) closeSpeechSynthesizer
{
    _synthesizer=nil;
}

//////////////////////////////////////////////////////////////
#pragma mark - Socail media  Related
//////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    return [self handleOpenURL:url];
    
}

- (BOOL) handleOpenURL:(NSURL *)url
{

    if ([NSString checkWeixinSchem:url.absoluteString]) {
        
        return  [WXApi handleOpenURL:url delegate:self];
    }
    else{
        
        NSString *decoded = [NSString StringByAddingPercentEscapes:[url absoluteString]];
        
        NSString * lessonID =[NSString getLessonIDFromOfficalURL:decoded];
        
        if (lessonID) {
            
            [self showLessonViewWithID:lessonID];
            
            return YES;
        }
        else{
            
            return [self  showWebviewWithURL:[url absoluteString]];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([NSString checkWeixinSchem:url.absoluteString]) {

        return  [WXApi handleOpenURL:url delegate:self];
    }
    else{
    
        NSString * lessonID =[NSString getLessonIDFromOfficalURL:[url absoluteString]];
        
        if (lessonID) {
            
            [self showLessonViewWithID:lessonID];
            
            return YES;
        }
        else{
        
            return [self  showWebviewWithURL:[url absoluteString]];
        }
    }
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]]){
        
        //[self onRequestAppMessage];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        //[self onShowMediaMessage:temp.message];
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = temp.message.mediaObject;
        if (obj.extInfo) {
            
            [self  showLessonViewWithID:obj.extInfo];
        }
        else{
        
            NSString * lessonID =[NSString getLessonIDFromOfficalURL:obj.url];
            
            if (lessonID) {
                
                [self  showLessonViewWithID:lessonID];
            }
            else{
                
                [self  showWebviewWithURL:obj.url];
            }
        }
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        
        NSString*message,*title;
        
        if (resp.errCode==WXSuccess) {
            
            title = @"分享成功";
            message=@"你有机会获得50个金币，查查我的档案吧！";
        }
        else{
            
            title = @"分享失败或者取消";
            message=@"再试试，分享成功有机会获得50个金币奖励哦：）";
        }
        
        NSTimeInterval nowTimeSeconds=[[NSDate date] timeIntervalSince1970];
        NSTimeInterval lastTimeSeconds=[[NSUserDefaults standardUserDefaults] doubleForKey:@"BEGIFTAWARDTIME"];
        
        if([title isEqualToString: @"分享成功"] && ((nowTimeSeconds-lastTimeSeconds)/(24*60*60)>=1)){
            
            [[NSUserDefaults standardUserDefaults] setDouble:nowTimeSeconds forKey:@"BEGIFTAWARDTIME"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [FlyingDataManager awardGold:KBEGoldAwardCount];
        }
        
        [self makeToast:message];
    }
}

- (void) shareContent:(FlyingShareData*) shareData fromView:(UIView*) popView
{
    
    if (shareData) {

        NSMutableArray *activityItems = [NSMutableArray new];
        
        [activityItems addObject:shareData];
    
        if (shareData.webURL) {
            
            [activityItems  addObject:shareData.webURL];
        }

        if (![NSString isBlankString:shareData.title]) {
            
            [activityItems  addObject:shareData.title];
        }
        
        if (shareData.image) {
            
            [activityItems  addObject:shareData.image];
        }
        
        NSArray *activities = @[[[FlyingShareInAppActivity alloc] init],
                                [[WeChatSessionActivity alloc] init],
                                [[WeChatMomentsActivity alloc] init]];
        UIActivityViewController *alertController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                   applicationActivities:activities];
        
        alertController.excludedActivityTypes = @[UIActivityTypeMessage,
                                               UIActivityTypeMail,
                                               UIActivityTypePostToTencentWeibo,
                                               UIActivityTypePrint,
                                               UIActivityTypeAssignToContact,
                                               UIActivityTypeSaveToCameraRoll,
                                               UIActivityTypeAddToReadingList,
                                               UIActivityTypePostToFlickr,
                                               UIActivityTypePostToVimeo];
        
        if (INTERFACE_IS_PAD) {
            
            [alertController setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popPresenter = [alertController
                                                             popoverPresentationController];
            popPresenter.sourceView = popView;
            popPresenter.sourceRect = popView.bounds;
            
            [[self getTabBarController].parentViewController presentViewController:alertController animated:YES completion:^{
                //
            }];
        }
        else
        {
            [[self getTabBarController] presentViewController:alertController animated:YES completion:nil];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark some thing
//////////////////////////////////////////////////////////////
-(void) touchMessage
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.hasMessageJob)
    {
        NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:KJobMessageNow];
        
        if (data)
        {
            RCMessage *message =  (RCMessage*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            FlyingConversationVC *chatVC = [[FlyingConversationVC alloc] init];
            chatVC.targetId = message.targetId;
            chatVC.conversationType = ConversationType_PRIVATE;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [appDelegate pushViewController:chatVC animated:YES];
            });
        }
        
        appDelegate.hasMessageJob=NO;
    }
}

-(void) makeToast:(NSString*)message
{
    if(!self.makeToastQueue)
    {
        self.makeToastQueue = [NSOperationQueue new];
        [self.makeToastQueue setMaxConcurrentOperationCount:1];
    }
    
    [self.makeToastQueue cancelAllOperations];
    [self.makeToastQueue addOperationWithBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [CRToastManager showNotificationWithMessage:message
                                        completionBlock:^{
                                            NSLog(@"Completed");
                                        }];
        });
    }];
}

#pragma mark Remote control Event methods

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
