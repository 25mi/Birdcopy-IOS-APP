//  iFlyingAppDelegate.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/3/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "iFlyingAppDelegate.h"

#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#include "OpenUDID.h"

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

#import "FlyingLessonListViewController.h"
#import "FlyingGuideViewController.h"

#include <sys/xattr.h>

#import "SIAlertView.h"

#import "FlyingDownloadManager.h"

#import "BEMenuController.h"

#import "FlyingTouchDAO.h"

#import <Social/Social.h>
#import "FlyingWebViewController.h"
#import "FlyingLessonParser.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

#include "common.h"

#import "FlyingMyGroupsVC.h"
#import "FlyingContentVC.h"

#import "FlyingNavigationController.h"
#import "FlyingProviderListVC.h"

#import <RongIMKit/RCIM.h>
#import "AFHttpTool.h"
#import "FlyingUserInfo.h"
#import "RCDRCIMDataSource.h"
#import "UIColor+RCColor.h"
#import "FlyingHttpTool.h"
#import "FlyingShareWithFriends.h"
#import "RCDataBaseManager.h"

#import <AFNetworking/AFNetworking.h>
#import "AFHttpTool.h"
#import "FlyingHttpTool.h"
#import "UIView+Toast.h"

#import "ReaderViewController.h"
#import "FlyingNowLessonDAO.h"
#import "CGPDFDocument.h"
#import "FlyingNowLessonData.h"
#import "FileHash.h"

#import "FlyingDiscoverContent.h"
#import "FlyingDIscoverGroups.h"


#import "FlyingDataManager.h"
#import "FlyingHttpTool.h"

#import "MKStoreKit.h"
#import <StoreKit/StoreKit.h>

#import "FlyingDBManager.h"

@interface iFlyingAppDelegate ()
{
    //M3U8相关
    HTTPServer                  *_httpServer;
    
    //界面UI
    RESideMenu                  *_menu;
    
    FlyingLessonParser          *_parser;
    
    //发音管理
    NSOperationQueue            *_flyingSoundPlayer_queue;
    AVSpeechSynthesizer         *_synthesizer;
    
    //分享管理
    MFMessageComposeViewController *_msmVC;
    SLComposeViewController        *_slComposerSheet;

    CFShareCircleView           *_shareCircleView;
    NSString                    *_sharingTitle;
    NSString                    *_sharingText;
    NSString                    *_sharingImageURL;
    NSString                    *_sharingURL;
    UIImage                     *_sharingImage;
}
@end


@implementation iFlyingAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    //验证OPenUDID
    [FlyingDataManager getOpenUDIDFromLocal];
    
    //检查是否有效登录决定是否注册激活
    [self jumpToNext];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 初始化融云SDK
    [self initIM];
    
    [self.window makeKeyAndVisible];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        //注册推送, iOS 8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    //更改导航条样式    
    [self setnavigationBarWithClearStyle:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];
    return YES;
}

- (void)didReceiveMessageNotification:(NSNotification *)notification
{
    //
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[[[deviceToken description]
                         stringByReplacingOccurrencesOfString:@"<" withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

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

-(void) jumpToNext
{
    [FlyingHttpTool verifyOpenUDID:[NSString getOpenUDID]
                             AppID:[NSString getAppID]
                        Completion:^(BOOL result) {
                                 //有注册记录
                                 if (result) {
                                     
                                     [[NSUserDefaults standardUserDefaults] boolForKey:KBEFIRSTLAUNCH];
                                     
                                     if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
                                         
                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
                                     }
                                     else{
                                         
                                         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
                                     }

                                     if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
                                         //从服务器获取新数据
                                         [FlyingDataManager creatLocalUSerProfileWithServer];
                                     }
                                                                         
                                     [iFlyingAppDelegate preparelocalEnvironment];
                                     
                                     self.window = [UIWindow new];
                                     [self.window makeKeyAndVisible];
                                     self.window.frame = [[UIScreen mainScreen] bounds];
                                     self.window.rootViewController = [self getMenu];
                                 }
                                 else
                                 {
                                     self.window = [UIWindow new];
                                     [self.window makeKeyAndVisible];
                                     self.window.frame = [[UIScreen mainScreen] bounds];
                                     self.window.rootViewController = [[FlyingGuideViewController alloc] init];
                                 }
                             }];

}

//本地环境准备
+(void) preparelocalEnvironment
{
    dispatch_async(dispatch_queue_create("com.birdcopy.background.prepare", NULL), ^{
        
        //缓存设置
        int cacheSizeMemory = 8*1024*1024; // 8MB
        int cacheSizeDisk   = 64*1024*1024; // 64MB
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
        
        [FlyingDownloadManager setNotBackUp];
        
        //准备PDF环境
        queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
        ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
        fz_register_document_handlers(ctx);
        screenScale = [[UIScreen mainScreen] scale];
        
        //准备购买环境
        [[MKStoreKit sharedKit] startProductRequest];
        
        //向微信注册
        [WXApi registerApp:[NSString getWeixinID]];
        
        //准备字典
        [FlyingDownloadManager prepareDictionary];
        
        //监控本地文件夹状态
        [[FlyingDownloadManager shareInstance] watchDocumentStateNow];
        
        //下载没有完成的内容
        [[FlyingDownloadManager shareInstance] downloadDataIfpossible];
        
        //监控下载更新
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(CalledToJumpToLessinID:)
                                                     name:KBEJumpToLesson
                                                   object:nil];
        [FlyingDataManager doStatisticJob];
        
    });
}


- (void) CalledToJumpToLessinID:(NSNotification*) aNotification
{
    NSString * lessonID = [[aNotification userInfo] objectForKey:@"lessonID"];
    
    if(lessonID){
    
        [self showLessonViewWithID:lessonID];
    }
}

- (void) initIM
{
    NSString* rongAPPkey=[NSString getRongAppKey];
    
    //初始化融云SDK
    [[RCIM sharedRCIM] initWithAppKey:rongAPPkey];
    
    //设置会话列表头像和会话界面头像
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    
    if (INTERFACE_IS_PHONE6PLUS) {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
    }else{
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    }
    
    //设置用户信息源和群组信息源
    [[RCIM sharedRCIM] setUserInfoDataSource:[RCDRCIMDataSource shareInstance]];
    [[RCIM sharedRCIM] setGroupInfoDataSource:[RCDRCIMDataSource shareInstance]];
    
    //设置群组内用户信息源。如果不使用群名片功能，可以不设置
    [RCIM sharedRCIM].groupUserInfoDataSource = [RCDRCIMDataSource shareInstance];
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    
    //设置接收消息代理
    [RCIM sharedRCIM].receiveMessageDelegate=self;
    //    [RCIM sharedRCIM].globalMessagePortraitSize = CGSizeMake(46, 46);
    
    //设置显示未注册的消息
    //如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
    [RCIM sharedRCIM].showUnkownMessage = YES;
    [RCIM sharedRCIM].showUnkownMessageNotificaiton = YES;

    NSString *rongDeviceKoken = [UICKeyChainStore keyChainStore][kRongCloudDeviceToken];
    
    if(rongDeviceKoken.length==0)
    {
        NSString *openID = [NSString getOpenUDID];
        
        if (!openID) {
            
            return;
        }
        
        [AFHttpTool getTokenWithOpenID:openID
                               success:^(id response) {
                                   //
                                   if (response) {
                                       NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                       
                                       if ([code isEqualToString:@"1"]) {
                                           
                                           NSString *rongDeviceKoken = response[@"token"];
                                           
                                           //保存默认用户
                                           [UICKeyChainStore keyChainStore][kRongCloudDeviceToken] = rongDeviceKoken;
                                           
                                           [AFHttpTool refreshUesrWithOpenID:openID
                                                                        name:[NSString getNickName]
                                                                 portraitUri:nil
                                                                    br_intro:[NSString getUserAbstract]
                                                                     success:^(id response) {
                                                                         //
                                                                         [self connectWithRongCloud:rongDeviceKoken];

                                                                     } failure:^(NSError *err) {
                                                                         //
                                                                     }];
                                       }
                                       else
                                       {
                                           NSLog(@"Get rongcloud Token %@",response[@"rm"]);
                                       }
                                   }
                               } failure:^(NSError *err) {
                                   //
                                   NSLog(@"Get rongcloud Token %@",err.description);

                               }];
    }
    else
    {
        [self connectWithRongCloud:rongDeviceKoken];
    }
}

-(void)  connectWithRongCloud:(NSString*)rongDeviceKoken
{
    //连接融云服务器
    [[RCIM sharedRCIM] connectWithToken:rongDeviceKoken
                                success:^(NSString *userId) {
                                    //
                                    RCUserInfo *currentUserInfo=[[RCDataBaseManager shareInstance] getUserByUserId:userId];
                                    if (currentUserInfo==nil)
                                    {
                                        [FlyingHttpTool getUserInfoByRongID:userId
                                                                 completion:^(RCUserInfo *user) {
                                                                     
                                                                     if (user) {
                                                                         
                                                                         //保存当前的用户信息（IM本地）
                                                                         [RCIMClient sharedRCIMClient].currentUserInfo = user;
                                                                         [[RCDataBaseManager shareInstance] insertUserToDB:user];
                                                                         
                                                                         //保存当前的用户信息（系统本地）
                                                                         [NSString setNickName:user.name];
                                                                         [NSString setUserPortraitUri:user.portraitUri];
                                                                     }
                                                                 }];
                                    }
                                    else
                                    {
                                        [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
                                    }
                                }
                                  error:^(RCConnectErrorCode status) {
                                      //
                                      NSLog(@"Get rongcloud Token %@",@(status));
                                      [UICKeyChainStore keyChainStore][kRongCloudDeviceToken] = @"";
                                  }
                         tokenIncorrect:^{
                             //
                             [UICKeyChainStore keyChainStore][kRongCloudDeviceToken] = @"";
                             NSLog(@"Get rongcloud tokenIncorrect");
                         }];
}

#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的帐号在别的设备上登录，您被迫下线！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if (status == ConnectionStatus_TOKEN_INCORRECT) {

        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"Token已过期，请重新登录"
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - RCIMReceiveMessageDelegate

-(void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left
{
    if ([message.content isMemberOfClass:[RCInformationNotificationMessage class]]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessage object:nil userInfo:nil];
    }
}

- (void)dealloc {
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
        NSString *startDateStr =[[NSUserDefaults standardUserDefaults] objectForKey:KMembershipStartTime];
        NSString *endDateStr   =[[NSUserDefaults standardUserDefaults] objectForKey:KMembershipEndTime];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *startDate = [dateFormatter dateFromString:startDateStr];
        NSDate *endDate = [dateFormatter dateFromString:endDateStr];
        
        [FlyingHttpTool updateMembershipForAccount:[NSString getOpenUDID]
                                             AppID:[NSString getAppID]
                                         StartDate:startDate
                                           EndDate:endDate
                                        Completion:^(BOOL result) {
                                            //
                                            
                                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KShouldSysMembership];
                                        }];
    }
    
    FlyingLessonDAO * dao=[[FlyingLessonDAO alloc] init];
    NSArray * lessonsBeResumeDownload=[dao selectWithWaittingDownload];
    
    FlyingNowLessonDAO * nowDao=[[FlyingNowLessonDAO alloc] init];
    NSString *openID = [NSString getOpenUDID];
    
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
        
        [_httpServer setDocumentRoot:[FlyingDownloadManager getDownloadsDir]];
        
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
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (void) showLessonViewWithID:(NSString *) lessonID
{
    
    [FlyingHttpTool getLessonForLessonID:lessonID
                              Completion:^(FlyingPubLessonData *lesson) {
                                  //
                                  FlyingContentVC * vc=[[FlyingContentVC alloc] init];
                                  vc.theLesson=lesson;
                                  
                                  [self pushViewController:vc];
                              }];
}

- (void) showLessonViewWithCode:(NSString*) code
{
    [FlyingHttpTool getLessonForISBN:code
                          Completion:^(FlyingPubLessonData *lesson) {
                              FlyingContentVC * vc=[[FlyingContentVC alloc] init];
                              vc.theLesson=lesson;
                              
                              [self pushViewController:vc];
                          }];
}

- (void) shakeNow
{
    [[self getMenu] hideMenuViewController];
    [[self getMenu] presentRightMenuViewController];
}

- (void) pushViewController:(UIViewController *)viewController
{
    
    [[self getMenu] hideMenuViewController];
    
    FlyingNavigationController *navigationController =(FlyingNavigationController *)[[self getMenu] contentViewController];
    
    [navigationController pushViewController:viewController animated:YES];
}

- (void) presentViewController:(UIViewController *)viewController
{
    
    //[[self getFrostedVC] hideMenuViewController];
    
    FlyingNavigationController *navigationController =(FlyingNavigationController *)[[self getMenu] contentViewController];
    
    [navigationController presentViewController:viewController animated:YES completion:nil];
}

- (BOOL) showWebviewWithURL:(NSString *) webURL
{
    if (webURL) {
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
        [webpage setWebURL:webURL];
        
        [self pushViewController:webpage];
        
        return YES;
    }
    else{
    
        return NO;
    }
}

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
- (RESideMenu*) getMenu
{
    if (!_menu) {
        
#ifdef __CLIENT__GROUP__VERSION
        FlyingMyGroupsVC  * homeVC = [[FlyingMyGroupsVC alloc] init];
#else
        FlyingDiscoverContent * homeVC = [[FlyingDiscoverContent alloc] init];
#endif
        
        FlyingNavigationController *navigationController = [[FlyingNavigationController alloc] initWithRootViewController:homeVC];
        BEMenuController *menuViewController = [[BEMenuController alloc] init];
        
        _menu = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                                        leftMenuViewController:menuViewController
                                                                       rightMenuViewController:nil];
    }
    
    return _menu;
}

-(void) setnavigationBarWithClearStyle:(BOOL) clearStyle
{
    
    UIColor *backgroundColor;

    if(clearStyle)
    {
        backgroundColor = [UIColor clearColor];
        
     }
    else
    {
        NSData * backgroundColorData = [[NSUserDefaults standardUserDefaults] objectForKey:kNavigationBackColor];
        
        if(backgroundColorData)
        {
            backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:backgroundColorData];
            
            if (!backgroundColor) {
                
                backgroundColor = [UIColor whiteColor];
            }
        }
    }
    
    [[UINavigationBar appearance] setBarTintColor:backgroundColor];
    [[UINavigationBar appearance] setBackgroundColor:backgroundColor];
    
    UINavigationController * nowNav = (UINavigationController*)[self getMenu].contentViewController;
    
    nowNav.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
    nowNav.navigationBar.backgroundColor = [UINavigationBar appearance].backgroundColor;
    
    if (clearStyle)
    {
        [nowNav.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        nowNav.navigationBar.shadowImage = [UIImage new];
    }
    else
    {
        [nowNav.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        nowNav.navigationBar.shadowImage = nil;
    }
}

-(void) resetnavigationBarWithDefaultStyle
{
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *textColor= [UIColor blackColor];
    
    //统一导航条样式
    UIFont* font = [UIFont systemFontOfSize:19.f];
    NSDictionary* textAttributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:textColor};
    
    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
    [[UINavigationBar appearance] setTintColor:textColor];
    [[UINavigationBar appearance] setBarTintColor:backgroundColor];
    
    UINavigationController * nowNav = (UINavigationController*)[self getMenu].contentViewController;
    
    nowNav.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
    nowNav.navigationBar.backgroundColor = [UINavigationBar appearance].backgroundColor;
    
    [nowNav.navigationBar setBackgroundImage:nil
                               forBarMetrics:UIBarMetricsDefault];
    nowNav.navigationBar.shadowImage = nil;
    nowNav.navigationBar.translucent = NO;
    
    NSData *textColorData = [NSKeyedArchiver archivedDataWithRootObject:textColor];
    NSData *backgroundColorData = [NSKeyedArchiver archivedDataWithRootObject:backgroundColor];
    
    [[NSUserDefaults standardUserDefaults] setObject:textColorData forKey:kNavigationTextColor];
    [[NSUserDefaults standardUserDefaults] setObject:backgroundColorData forKey:kNavigationBackColor];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
        NSString *openID = [NSString getOpenUDID];
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
        
        NSString*msg,*title;
        
        if (resp.errCode==WXSuccess) {
            
            title = @"分享成功";
            msg=@"你有机会获得50个金币，查查我的档案吧！";
        }
        else{
            
            title = @"分享失败或者取消";
            msg=@"再试试，分享成功有机会获得50个金币奖励哦：）";
        }
        
        NSTimeInterval nowTimeSeconds=[[NSDate date] timeIntervalSince1970];
        NSTimeInterval lastTimeSeconds=[[NSUserDefaults standardUserDefaults] doubleForKey:@"BEGIFTAWARDTIME"];
        
        if([title isEqualToString: @"分享成功"] && ((nowTimeSeconds-lastTimeSeconds)/(24*60*60)>=1)){
            
            [[NSUserDefaults standardUserDefaults] setDouble:nowTimeSeconds forKey:@"BEGIFTAWARDTIME"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [FlyingDataManager awardGold:KBEGoldAwardCount];
        }
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:msg];
        [alertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
    }
}

- (void) shareImageURL:(NSString *)imageURL  withURL:(NSString*) webURL  Title:(NSString*) title  Text:(NSString*) text  Image:(UIImage *)image;
{
    if (imageURL) {
        _sharingImageURL=imageURL;
    }
    
    if (webURL) {
        
        _sharingURL=webURL;
    }
    else{

        _sharingURL=kBEAppstore_China_URL;
    }
    
    if (title)
    {
        _sharingTitle=title;
    }
    else
    {
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        _sharingTitle=appName;
    }
    
    if (text)
    {
        _sharingText=text;
    }
    else
    {
        _sharingText=@"太酷了！马上分享给你!";
    }
    
    if (image) {
        
        _sharingImage =image;
    }
    else{
    
        _sharingImage =[UIImage imageNamed:@"Icon"];
    }

    if ( !_shareCircleView) {
        _shareCircleView = [[CFShareCircleView alloc] init];
        
        _shareCircleView.delegate = self;
    }
    
    [_shareCircleView show];
}


- (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectSharer:(CFSharer *)sharer
{
    
    if ([sharer.name isEqualToString:@"微信好友"]) {
        
        [self shareToWeiXinIsSession:YES];
    }
    else if ([sharer.name isEqualToString:@"微信圈"]) {
        
        [self shareToWeiXinIsSession:NO];
    }
    else if ([sharer.name isEqualToString:@"微博分享"]) {
        
        [self shareToWeibo];
    }
    else if ([sharer.name isEqualToString:@"短信分享"]) {
        
        [self sharetoSMS];
    }
    else if ([sharer.name isEqualToString:@"邮件分享"]) {
        
        [self shareToEmail];
    }
    else if ([sharer.name isEqualToString:@"复制链接"]) {
        
        [self copylessonLink];
    }
    else if ([sharer.name isEqualToString:@"聊天好友"]) {
        
        [self shareToIM];
    }
}

- (void)displaySMS
{
    
    _msmVC  = [[MFMessageComposeViewController alloc] init];
    _msmVC.messageComposeDelegate= self;
    _msmVC.navigationBar.tintColor= [UIColor blackColor];
    _sharingText = [NSString stringWithFormat:@"%@ 网址:%@",_sharingTitle,_sharingURL];
    _msmVC.body = _sharingText; // 默认信息内容
    // 默认收件人(可多个)
    //picker.recipients = [NSArray arrayWithObject:@"12345678901", nil];
    
    [_shareCircleView dismissAnimated:YES];
    [self presentViewController:_msmVC];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    NSString*msg,*title;
    
    if (result==MessageComposeResultSent) {
        
        title = @"分享成功";
        msg=@"你有机会获得50个金币，查查我的档案吧！";
    }
    else{
        
        title = @"分享失败或者取消";
        msg=@"再试试，分享成功有机会获得50个金币奖励哦：）";
    }
    
    
    NSTimeInterval nowTimeSeconds=[[NSDate date] timeIntervalSince1970];
    NSTimeInterval lastTimeSeconds=[[NSUserDefaults standardUserDefaults] doubleForKey:@"BEGIFTAWARDTIME"];
    
    if([title isEqualToString: @"分享成功"] && ((nowTimeSeconds-lastTimeSeconds)/(24*60*60)>=1)){
        
        [[NSUserDefaults standardUserDefaults] setDouble:nowTimeSeconds forKey:@"BEGIFTAWARDTIME"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [FlyingDataManager awardGold:KBEGoldAwardCount];
    }
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:msg];
    [alertView addButtonWithTitle:@"知道了"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    [alertView show];
    
    [controller dismissViewControllerAnimated:YES
                                   completion:^{
                                       //
                                   }];
}

- (void)sharetoSMS
{
    
    if (INTERFACE_IS_PAD){
        
        NSString *title = @"友好提醒";
        NSString *message = @"设备没有短信功能！";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {}];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
    } else {
        
        [self displaySMS];
    }
}

- (void)shareToWeibo
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
    {
        _slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        
        _sharingText = [NSString stringWithFormat:@"%@ 网址:%@",_sharingTitle,_sharingURL];
        [_slComposerSheet setInitialText:_sharingText];
        [_slComposerSheet addImage:_sharingImage];
        [_slComposerSheet addURL:[NSURL URLWithString:@"http://www.weibo.com/"]];
        
        [_slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString*msg,*title;
            
            if (result==SLComposeViewControllerResultDone) {
                
                title = @"分享成功";
                msg=@"你有机会获得50个金币，查查我的档案吧！";
            }
            else{
                
                title = @"分享失败或者取消";
                msg=@"再试试，分享成功有机会获得50个金币奖励哦：）";
            }
            
            NSTimeInterval nowTimeSeconds=[[NSDate date] timeIntervalSince1970];
            NSTimeInterval lastTimeSeconds=[[NSUserDefaults standardUserDefaults] doubleForKey:@"BEGIFTAWARDTIME"];
            
            if([title isEqualToString: @"分享成功"] && ((nowTimeSeconds-lastTimeSeconds)/(24*60*60)>=1)){
                
                [[NSUserDefaults standardUserDefaults] setDouble:nowTimeSeconds forKey:@"BEGIFTAWARDTIME"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [FlyingDataManager awardGold:KBEGoldAwardCount];
            }
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:msg];
            [alertView addButtonWithTitle:@"知道了"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView show];
        }];
        
        [_shareCircleView dismissAnimated:YES];
        [self presentViewController:_slComposerSheet];
    }
}

- (void)shareToFacebook
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        _slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        _sharingText = [NSString stringWithFormat:@"%@ 网址:%@",_sharingTitle,_sharingURL];
        [_slComposerSheet setInitialText:_sharingText];
        [_slComposerSheet addImage:_sharingImage];
        [_slComposerSheet addURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
        
        [_slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString*msg,*title;
            
            if (result==SLComposeViewControllerResultDone) {
                
                title = @"分享成功";
                msg=@"你有机会获得50个金币，查查我的档案吧！";
            }
            else{
                
                title = @"分享失败或者取消";
                msg=@"再试试，分享成功有机会获得50个金币奖励哦：）";
            }
            
            NSTimeInterval nowTimeSeconds=[[NSDate date] timeIntervalSince1970];
            NSTimeInterval lastTimeSeconds=[[NSUserDefaults standardUserDefaults] doubleForKey:@"BEGIFTAWARDTIME"];
            
            if([title isEqualToString: @"分享成功"] && ((nowTimeSeconds-lastTimeSeconds)/(24*60*60)>=1)){
                
                [[NSUserDefaults standardUserDefaults] setDouble:nowTimeSeconds forKey:@"BEGIFTAWARDTIME"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [FlyingDataManager awardGold:KBEGoldAwardCount];
            }

            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:msg];
            [alertView addButtonWithTitle:@"知道了"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView show];
        }];
        
        [_shareCircleView dismissAnimated:YES];
        [self presentViewController:_slComposerSheet];
    }
}

- (void)shareToTwitter
{
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        _slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        _sharingText = [NSString stringWithFormat:@"%@ 网址:%@",_sharingTitle,_sharingURL];
        [_slComposerSheet setInitialText:_sharingText];
        [_slComposerSheet addImage:_sharingImage];
        [_slComposerSheet addURL:[NSURL URLWithString:@"http://www.twitter.com/"]];
        
        [_slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            NSString*msg,*title;
            
            if (result==SLComposeViewControllerResultDone) {
                
                title = @"分享成功";
                msg=@"你有机会获得50个金币，查查我的档案吧！";
            }
            else{
                
                title = @"分享失败或者取消";
                msg=@"再试试，分享成功有机会获得50个金币奖励哦：）";
            }
            
            NSTimeInterval nowTimeSeconds=[[NSDate date] timeIntervalSince1970];
            NSTimeInterval lastTimeSeconds=[[NSUserDefaults standardUserDefaults] doubleForKey:@"BEGIFTAWARDTIME"];
            
            if([title isEqualToString: @"分享成功"] && ((nowTimeSeconds-lastTimeSeconds)/(24*60*60)>=1)){
                
                [[NSUserDefaults standardUserDefaults] setDouble:nowTimeSeconds forKey:@"BEGIFTAWARDTIME"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [FlyingDataManager awardGold:KBEGoldAwardCount];
            }
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:msg];
            [alertView addButtonWithTitle:@"知道了"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView show];
        }];
        
        [_shareCircleView dismissAnimated:YES];
        [self pushViewController:_slComposerSheet];
    }
}

- (void) shareToWeiXinIsSession:(BOOL) isSession
{
    if (![WXApi isWXAppInstalled]) 
    {
        [self.window makeToast:@"抱歉：只有安装微信才能使用此功能" duration:3 position:CSToastPositionCenter];

        return;
    }

    WXMediaMessage *message = [WXMediaMessage message];
    message.title =_sharingTitle;
    message.description = _sharingText;
    
    if (!isSession)
    {
        UIImage *myIcon = [UIImageView imageWithImage:_sharingImage scaledToSize:CGSizeMake(20, 20)];
        [message setThumbImage:myIcon];
    }
    else
    {
        [message setThumbImage:_sharingImage];
    }

    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = _sharingURL;
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    if (isSession) {
        req.scene = WXSceneSession;
    }
    else{
        req.scene = WXSceneTimeline;
    }
    
    [WXApi sendReq:req];
}

- (void) shareToEmail
{
    
	if ([MFMailComposeViewController canSendMail] == NO) return;
    
    NSData *attachment =UIImagePNGRepresentation(_sharingImage);
    
    if (attachment != nil) // Ensure that we have valid document file attachment data
    {
        MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
        
        [mailComposer addAttachmentData:attachment mimeType:@"image/png" fileName:@"birdengish"];
        
        [mailComposer setSubject:[NSString stringWithFormat:@"来自%@的无私分享",[[UIDevice currentDevice] name]]]; // Use the document file name for the subject
        
        _sharingText = [NSString stringWithFormat:@"<HTML><B>Hi!</B><BR/>我觉得不错，推荐给你:<a href=\"%@\">%@</a></HTML>",_sharingURL,_sharingTitle];
        
        [mailComposer setMessageBody:_sharingText
                              isHTML:YES];
        
        mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
        
        mailComposer.mailComposeDelegate = self; // Set the delegate
        
        [_shareCircleView dismissAnimated:YES];
        [self presentViewController:mailComposer];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Buy  Related
//////////////////////////////////////////////////////////////
- (void) presentStoreView
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //NSString*  startDateStr =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KMembershipStartTime];
    NSString*  endDateStr =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KMembershipEndTime];
    
    //NSDate *startDate = [dateFormatter dateFromString:startDateStr];
    NSDate *endDate = [dateFormatter dateFromString:endDateStr];

    NSDate *nowDate = [NSDate date];
    
    if ([nowDate compare:endDate] == NSOrderedAscending) {
        
        [self.window makeToast:@"你已经是会员，无需购买会员资格!" duration:3 position:CSToastPositionCenter];
    }
    else
    {
        if ([SKPaymentQueue canMakePayments])
        {
            NSArray *availableProducts = [[MKStoreKit  sharedKit] availableProducts];
            
            if (availableProducts.count>0) {
                
                [FlyingDataManager buyAppleIdentify:availableProducts[0]];
            }
        }
        else
        {
            [self.window makeToast:@"需要打开应用内购买功能才能继续!" duration:3 position:CSToastPositionCenter];
        }
    }
}

- (void) copylessonLink
{
    if (_sharingURL) {
        
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:_sharingURL];
        
        [_shareCircleView dismissAnimated:YES];
        
        NSString *title = @"复制内容链接成功";
        NSString *message = [NSString stringWithFormat:@"你现在可以随意粘贴转发了：）"];
        SIAlertView *copyAlertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [copyAlertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        copyAlertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        copyAlertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [copyAlertView show];
    }
}

- (void) shareToIM
{
    if (_sharingURL) {
        
        RCRichContentMessage * richMessage = [RCRichContentMessage messageWithTitle:_sharingTitle
                                                                              digest:_sharingText
                                                                            imageURL:_sharingImageURL
                                                                                 url:_sharingURL
                                                                               extra:@""];
                                              
        FlyingShareWithFriends * shareFriends = [[FlyingShareWithFriends alloc] init];
        
        shareFriends.message=richMessage;
        
        [_shareCircleView dismissAnimated:YES];
        [self pushViewController:shareFriends];
    }
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
	[controller dismissViewControllerAnimated:YES completion:NULL]; // Dismiss
}


#pragma mark Remote control Event methods

-(BOOL)canBecomeFirstResponder
{
    return YES;
}





@end
