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

#import "MHWDirectoryWatcher.h"

#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

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

#import "FlyingSysWithCenter.h"
#import "FlyingTouchDAO.h"

#import <Social/Social.h>
#import "FlyingWebViewController.h"
#import "FlyingLessonParser.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

#include "common.h"

#import "FlyingMyGroupsVC.h"
#import "FlyingLessonVC.h"

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

#import "MKStoreKit.h"
#import <StoreKit/StoreKit.h>

@interface iFlyingAppDelegate ()
{
    //loacal DB managemnet
    FMDatabaseQueue *_userDBQueue;
    FMDatabaseQueue *_pubUserDBQueue;
    FMDatabaseQueue *_baseDBQueue;
    FMDatabaseQueue *_pubBaseDBQueue;
    FMDatabaseQueue *_oldDBQueue;
    FMDatabaseQueue *_oldDicDBQueue;
    
    //本地Document管理
    MHWDirectoryWatcher         *_docWatcher;
    dispatch_source_t            _source;

    
    //M3U8相关
    HTTPServer                  *_httpServer;
    
    //后台处理
    dispatch_queue_t             _background_Pub_queue;
    dispatch_queue_t             _background_AI_queue;
    
    //下载管理
    FlyingDownloadManager       *_downloadManager;
    
    NSString                    *_userDataDir;
    NSString                    *_userDownloadDir;
    
    //界面UI
    RESideMenu                  *_menu;
    
    //充值、同步、帐户管理
    FlyingSysWithCenter         *_sysWithCenter;
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
    
    //
    RCDRCIMDataSource           *_rongDataSource;
}
@end


@implementation iFlyingAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
#ifndef __CLIENT__IS__PLATFORM__
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSArray *strings = [bundleIdentifier componentsSeparatedByString:@"."];
    NSString * temp =  (NSString*)[strings lastObject];
    
    if ([temp isEqualToString:@"beyond"]) {
        
        temp=@"beiyang";
    }
 
    [[NSUserDefaults standardUserDefaults] setValue:temp forKey:KAppOwner];
    [[NSUserDefaults standardUserDefaults] setValue:[[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"] forKey:KAppOwnerNickname];

#endif
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(openID==nil)
    {
        //从本地终端生成账号
        openID = [OpenUDID value];
        keychain[KOPENUDIDKEY]=openID;
    }
    //如果有旧账号
    else if (openID && openID.length==32)
    {
        //dbPath： 数据库路径，在dbDire中。
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsDirectory = [iFlyingAppDelegate getUserDataDir];
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject]))
        {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
        
        //从本地终端生成账号
        openID = [OpenUDID value];
        keychain[KOPENUDIDKEY]=openID;
    }

    [self jumpToNext];
    
    dispatch_async([self getBackPubQueue], ^{
        
        //缓存设置
        int cacheSizeMemory = 8*1024*1024; // 8MB
        int cacheSizeDisk   = 64*1024*1024; // 64MB
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
        [NSURLCache setSharedURLCache:sharedCache];
        
        //[UIApplication sharedApplication].applicationIconBadgeNumber=0;
        
        [self setNotBackUp];
        
        //准备PDF环境
        queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
        ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
        fz_register_document_handlers(ctx);
        screenScale = [[UIScreen mainScreen] scale];
        
        //准备购买环境
        [self prepairIAP];
        
        //向微信注册
        [WXApi registerApp:KBEWeixinAPPID];
        
        //准备字典
        [self prepareDictionary];
        
        //监控本地文件夹状态
        [self watchDocumentStateNow];
        
        //同步没有完成的内容
        [self downloadDataIfpossible];
        
        //监控下载更新
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(CalledToJumpToLessinID:)
                                                     name:KBEJumpToLesson
                                                   object:nil];
        
    });
    
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
    //震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1007);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
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
    
    [[RCIM sharedRCIM] setUserInfoDataSource:[self getRongDataSource]];
    [[RCIM sharedRCIM] setGroupInfoDataSource:[self getRongDataSource]];
    
    //设置会话列表头像和会话界面头像
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    
    if (INTERFACE_IS_PHONE6PLUS) {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
    }else{
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    }
    
    NSString *rongDeviceKoken = [UICKeyChainStore keyChainStore][kRongCloudDeviceToken];
    
    if(rongDeviceKoken.length==0)
    {
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
        NSString *openID = keychain[KOPENUDIDKEY];
        
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

                                           [self connectWithRongCloud:rongDeviceKoken];
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

-(RCDRCIMDataSource*) getRongDataSource
{
    if (!_rongDataSource) {
        
        _rongDataSource = [RCDRCIMDataSource shareInstance];
    }
    
    return _rongDataSource;
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
                                                                         
                                                                         //设置当前的用户信息
                                                                         [RCIMClient sharedRCIMClient].currentUserInfo = user;
                                                                         
                                                                         [[RCDataBaseManager shareInstance] insertUserToDB:user];
                                                                         
                                                                         [UICKeyChainStore keyChainStore][kUserNickName] = user.name;
                                                                         [UICKeyChainStore keyChainStore][kUserPortraitUri] = user.portraitUri;

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
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status
{
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的帐号在别的设备上登录，您被迫下线！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void) jumpToNext
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunchedNewVersion"]) {
        
        //增加标识，用于判断是否是第一次启动应用...
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunchedNewVersion"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"activeBEAccount"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"activeBETouchAccount"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[UIDevice currentDevice] name] forKey:KLoginNickName];
    }
    else{
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        //默认每次必须登录
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"defaultLoginFirst"];
    }
    
    //第一次安装或者重装或者没有激活
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"] ||
        ![[NSUserDefaults standardUserDefaults] boolForKey:@"activeBEAccount"] ||
        ![[NSUserDefaults standardUserDefaults] boolForKey:@"activeBETouchAccount"]) {
    
        //从服务器获取用户数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [FlyingSysWithCenter activeAccount];
        });
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [[FlyingGuideViewController alloc] init];
    }
    else{

        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [self getMenu];
    }
    
    [self doStatisticJob];
}

#pragma mark -

-(void) doStatisticJob
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
        NSString *openID = keychain[KOPENUDIDKEY];
        FlyingStatisticDAO * statistic = [[FlyingStatisticDAO alloc] init];
        [statistic setUserModle:NO];
        
        //学习次数加一
        NSInteger learnedTimes = [statistic timesWithUserID:openID];
        learnedTimes = learnedTimes+1;
        [statistic updateWithUserID:openID Times:learnedTimes];
    });
}

-(void) sysWithCenter
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //和服务器同步数据
        [FlyingSysWithCenter sysWithCenter];
        
        //数据告警
        [FlyingSysWithCenter lowCointAlert];
    });
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    FlyingLessonDAO * dao=[[FlyingLessonDAO alloc] init];
    NSArray * lessonsBeResumeDownload=[dao selectWithWaittingDownload];
    
    FlyingNowLessonDAO * nowDao=[[FlyingNowLessonDAO alloc] init];
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
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
    
    [self closePubBaseDBQueue];
    [self closePubUserDBQueue];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //同步重要数据
        [self sysWithCenter];
        
        double before=[[NSUserDefaults standardUserDefaults] doubleForKey:@"BELunchTimeBefore"];
        double now= [[NSDate date] timeIntervalSince1970];
        
        if(now-before>600.0){
            
            UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
            NSString *openID = keychain[KOPENUDIDKEY];
            
            if (openID) {

                [[NSUserDefaults standardUserDefaults] setDouble:now forKey:@"BELunchTimeBefore"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                FlyingStatisticDAO * statisticDAO = [[FlyingStatisticDAO alloc] init];
                [statisticDAO setUserModle:NO];
                
                //学习次数加一
                NSInteger giftCountNow=[statisticDAO giftCountWithUserID:openID];
                giftCountNow++;
                [statisticDAO updateWithUserID:openID GiftCount:giftCountNow];
                
                [FlyingSoundPlayer soundEffect:@"iMoneyDialogClose"];
                
                NSInteger learnedTimes = [statisticDAO timesWithUserID:openID];
                learnedTimes = learnedTimes+1;
                [statisticDAO updateWithUserID:openID Times:learnedTimes];
            }
        }
    });
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[[FlyingLessonDAO alloc] init] updateDowloadStateOffine];
    [self closeMyresource];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
}

- (FMDatabaseQueue *) shareUserDBQueue
{
    if (!_userDBQueue) {
        
        //dbPath： 数据库路径，在dbDir中。
        NSString *dbPath = [[iFlyingAppDelegate getUserDataDir] stringByAppendingPathComponent:KUserDatdbaseFilename];
        
        //如果有直接打开，没有用户纪录文件就从安装文件复制一个用户模板
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dbPath]){
            
            NSString *soureDbpath = [[NSBundle mainBundle] pathForResource:KUserDBResource ofType:KDBType];
            NSError* error=nil;
            [fileManager copyItemAtPath:soureDbpath toPath:dbPath error:&error ];
            if (error!=nil) {
                NSLog(@"%@", error);
                NSLog(@"%@", [error userInfo]);
            }
        }
        
        _userDBQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return _userDBQueue;
}

- (void) closeUserDBQueue
{
    if (_userDBQueue) {
        
        [_userDBQueue close];
        _userDBQueue=nil;
    }
}

- (FMDatabaseQueue *) sharePubUserDBQueue
{
    if (!_pubUserDBQueue) {
        
        //dbPath： 数据库路径，在dbDire中。
        NSString *dbPath = [[iFlyingAppDelegate getUserDataDir] stringByAppendingPathComponent:KUserDatdbaseFilename];
        
        //如果有直接打开，没有用户纪录文件就从安装文件复制一个用户模板
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dbPath]){
            
            NSString *soureDbpath = [[NSBundle mainBundle] pathForResource:KUserDBResource ofType:KDBType];
            NSError* error=nil;
            [fileManager copyItemAtPath:soureDbpath toPath:dbPath error:&error ];
            if (error!=nil) {
                NSLog(@"%@", error);
                NSLog(@"%@", [error userInfo]);
            }
        }

        _pubUserDBQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return _pubUserDBQueue;
}

- (void) closePubUserDBQueue
{
    if (_pubUserDBQueue) {
        
        [_pubUserDBQueue close];
        _pubUserDBQueue=nil;
    }
}

- (FMDatabaseQueue *) shareBaseDBQueue
{
    if (!_baseDBQueue) {
        
        /*
        NSString * downloadDir = [iFlyingAppDelegate getDownloadsDir];
        NSString * baseDir =[downloadDir stringByAppendingPathComponent:kShareBaseDir];
        
        NSString *path = [baseDir stringByAppendingPathComponent:KBaseDatdbaseFilename];
                
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]){
            
            [self startDownloadShareData];
        }
         */
        
        NSString* path = [self prepareDictionary];

        _baseDBQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    
    return _baseDBQueue;
}

- (void) closeBaseDBQueue
{
    if (_baseDBQueue) {
        
        [_baseDBQueue close];
        _baseDBQueue=nil;
    }
}

- (FMDatabaseQueue *) sharePubBaseDBQueue
{

    if (!_pubBaseDBQueue) {
        
        /*
        NSString * downloadDir = [iFlyingAppDelegate getDownloadsDir];
        NSString * baseDir =[downloadDir stringByAppendingPathComponent:kShareBaseDir];
        
        NSString *path = [baseDir stringByAppendingPathComponent:KBaseDatdbaseFilename];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]){
            
            [self startDownloadShareData];
        }
         */
        
        NSString* path = [self prepareDictionary];

        _pubBaseDBQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    
    return _pubBaseDBQueue;
}

- (void) closePubBaseDBQueue
{
    if (_pubBaseDBQueue) {
        
        [_pubBaseDBQueue close];
        _pubBaseDBQueue=nil;
    }
}

- (void) closeMyresource
{
    [self closeBaseDBQueue];
    [self closeUserDBQueue];
    [self closePubBaseDBQueue];
    [self closePubUserDBQueue];
    [self closeDownloadResource];
    [self closeLocalHttpserver];
    [self closeBackgroundQueue];
    [self close_flyingSoundPlayer_queue];
    [self closeSpeechSynthesizer];
}

- (void)setNotBackUp
{
    
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSURL *url = [NSURL fileURLWithPath:documentDirectory];
    
    [self addSkipBackupAttributeToItemAtURL:url];
    
    NSString *myDataDir = [iFlyingAppDelegate getUserDataDir];
    url = [NSURL fileURLWithPath:myDataDir];
    
    [self addSkipBackupAttributeToItemAtURL:url];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void) startLocalHttpserver
{
    if (!_httpServer) {
        // Create server using our custom MyHTTPServer class
        _httpServer = [[HTTPServer alloc] init];
        [_httpServer setType:@"_http._tcp."];
        
        [_httpServer setPort:12345];
        
        [_httpServer setDocumentRoot:[self getDownloadsDir]];
        
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

-(dispatch_queue_t) getBackPubQueue
{
    if (!_background_Pub_queue) {
        _background_Pub_queue =dispatch_queue_create("com.birdcopy.background.processing", NULL);
    }
    
    return _background_Pub_queue;
}

-(dispatch_queue_t) getAIQueue
{
    if (!_background_AI_queue) {
        _background_AI_queue =dispatch_queue_create("com.birdengcopy.background.processing", NULL);
    }
    
    return _background_AI_queue;
}

-(void)closeBackgroundQueue
{
    _background_AI_queue=nil;
    _background_Pub_queue=nil;
}

- (NSString *) getUserDataPath
{
    if (!_userDataDir) {
        
        NSString  * libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString  *   dbDir = [libPath stringByAppendingPathComponent:KUSerDataFoldName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = FALSE;
        BOOL isDirExist = [fileManager fileExistsAtPath:dbDir isDirectory:&isDir];
        
        if(!(isDirExist && isDir))
        {
            BOOL bCreateDir = [fileManager createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"Create Directory Failed.");
                
                return nil;
            }
        }
        
        _userDataDir=dbDir;
    }
    
    return _userDataDir;
}

+ (NSString *) getUserDataDir
{
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return [appDelegate getUserDataPath];
}

- (NSString*) getDownloadsDir
{
    
    if (!_userDownloadDir) {
        
        NSString  *   dbDir = [[iFlyingAppDelegate getUserDataDir]  stringByAppendingPathComponent:KUserDownloadsDir];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = FALSE;
        BOOL isDirExist = [fileManager fileExistsAtPath:dbDir isDirectory:&isDir];
        
        if(!(isDirExist && isDir))
        {
            BOOL bCreateDir = [fileManager createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"Create Directory Failed.");
                
                return nil;
            }
        }
        
        _userDownloadDir=dbDir;
    }
    
    return _userDownloadDir;
}

+ (NSString*) getDownloadsDir
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return [appDelegate getDownloadsDir];
}

+ (NSString*) getLessonDir:(NSString*) lessonID
{
    //创建下载内容目录
    NSString *dbDir = [[iFlyingAppDelegate getDownloadsDir] stringByAppendingPathComponent:lessonID];
    
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(!([fm fileExistsAtPath:dbDir isDirectory:&isDir] && isDir))
    {
        [fm createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return dbDir;
}

//////////////////////////////////////////////////////////////
#pragma mark - Document Related
//////////////////////////////////////////////////////////////
- (void) watchDocumentStateNow
{
    //开启文件夹监控
    [iFlyingAppDelegate updataDBForLocal];
    
    if (!_docWatcher) {
        
        NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        _docWatcher = [MHWDirectoryWatcher directoryWatcherAtPath:documentDirectory callback:^{
            
            NSLog(@"dispatch_source_merge_data:updateNow");
            
            if (!_source) {
                
                _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
                dispatch_source_set_event_handler(_source, ^{
                    
                    [iFlyingAppDelegate updataDBForLocal];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDocumentStateChange object:nil];
                });
                dispatch_resume(_source);
            }
            
            dispatch_source_merge_data(_source, 1);
        }];
        
        [_docWatcher startWatching];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Network Related
//////////////////////////////////////////////////////////////
- (void) downloadDataIfpossible
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // -- Reachable -- //
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
                    
                    [self resumeAllDownloader];
                }

                break;
            case AFNetworkReachabilityStatusNotReachable:
                
                [[[FlyingLessonDAO alloc] init] updateDowloadStateOffine];

                break;
            default:
                // -- Not reachable -- //
                NSLog(@"Not Reachable");
                break;
        }
        
    }];
}

// 准备英文字典
- (NSString *)prepareDictionary
{
    //判断是否后台加载基础字典（MP3+DB）
    NSString * baseDir     = [[iFlyingAppDelegate getDownloadsDir] stringByAppendingPathComponent:kShareBaseDir];
    NSString  * newDicpath = [baseDir stringByAppendingPathComponent:KBaseDatdbaseFilename];

    //分享目录如果没有就创建一个
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if(!([fileManager fileExistsAtPath:baseDir isDirectory:&isDir] && isDir))
    {
        [fileManager createDirectoryAtPath:baseDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString * result=nil;
    if ([fileManager fileExistsAtPath:newDicpath])
    {
        result=newDicpath;
    }
    else
    {
        NSString *soureDbpath = [[NSBundle mainBundle] pathForResource:KDicModelName ofType:KDBType];
        NSError* error=nil;
        [fileManager copyItemAtPath:soureDbpath toPath:newDicpath error:&error ];
        if (error!=nil) {
            NSLog(@"%@", error);
            NSLog(@"%@", [error userInfo]);
            
            result=nil;
        }
        else
        {
            result=newDicpath;
        }
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everDownloadBaseDictionary"])
    {
        
        if ([AFNetworkReachabilityManager sharedManager].isReachableViaWiFi)
        {
            
            [self startDownloadShareData];
        }
    }
    
    return result;
}


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
                                  FlyingLessonVC * vc=[[FlyingLessonVC alloc] init];
                                  vc.theLesson=lesson;
                                  
                                  [self pushViewController:vc];
                              }];
}

- (void) showLessonViewWithCode:(NSString*) code
{
    [FlyingHttpTool getLessonForISBN:code
                          Completion:^(FlyingPubLessonData *lesson) {
                              FlyingLessonVC * vc=[[FlyingLessonVC alloc] init];
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
#pragma mark - Download  Related
//////////////////////////////////////////////////////////////

-(void) startDownloadShareData
{
    if (!_downloadManager) {
        
        _downloadManager = [[FlyingDownloadManager alloc] init];
    }
    
    [_downloadManager startDownloadShareData];
}

- (void) startDownloaderForID:(NSString *)lessonID
{
    if (!_downloadManager) {
        
        _downloadManager = [[FlyingDownloadManager alloc] init];
    }
    
    [_downloadManager startDownloaderForID:lessonID];
}

-(void) continueDownloadingWork
{
    if (!_downloadManager) {
        
        _downloadManager = [[FlyingDownloadManager alloc] init];
    }

    [_downloadManager continueDownloadingWork];
}

- (BOOL) isWaitting:(NSString*) lessonID
{
    if (_downloadManager) {
        
        return [_downloadManager isWaitting:lessonID];
    }
    else{
        return NO;
    }
}

- (void) resumeAllDownloader
{
    if (!_downloadManager) {
        
        _downloadManager = [[FlyingDownloadManager alloc] init];
    }
    
    [_downloadManager resumeAllDownloader];
}

- (void) closeAllDownloader
{
    if (_downloadManager) {
        
        [_downloadManager closeAllDownloader];
    }
}

- (void) closeAndReleaseDownloaderForID:(NSString *)lessonID
{
    if (_downloadManager) {
        
        [_downloadManager closeAndReleaseDownloaderForID:lessonID];
    }
}

- (void) closeDownloadResource
{
    if (_downloadManager) {
        
        [_downloadManager closeAllDownloader];
        [_downloadManager closeDownloadShareData];
    }
}

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
        
        backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:backgroundColorData];
        
        if (!backgroundColor) {
            
            backgroundColor = [UIColor whiteColor];
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

- (FlyingSysWithCenter*) getSysWithCenter
{
    if(!_sysWithCenter){
        
        _sysWithCenter =[[FlyingSysWithCenter alloc] init];
    }
    
    return _sysWithCenter;
}

- (void) upgrade
{
    //金币
    FlyingStatisticDAO * statistic=[[FlyingStatisticDAO alloc] init];
    
    if(![statistic hasQRCount]){
    
        [statistic insertQRCount];
        [statistic insertTimeStamp];
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
        NSString *openID = keychain[KOPENUDIDKEY];
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
            
            [self awardGold:KBEGoldAwardCount];
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

-(void)  awardGold:(int) MoneyCount
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    //奖励金币
    FlyingStatisticDAO * statisticDAO = [[FlyingStatisticDAO alloc] init];
    [statisticDAO setUserModle:NO];
    
    NSInteger giftCountNow=[statisticDAO giftCountWithUserID:openID];
    giftCountNow+=KBEGoldAwardCount;
    [statisticDAO updateWithUserID:openID GiftCount:giftCountNow];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil];
    [FlyingSoundPlayer soundEffect:@"iMoneyDialogClose"];
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
        
        [self awardGold:KBEGoldAwardCount];
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
        
        __weak __typeof(self)weakSelf = self;

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
                
                [weakSelf awardGold:KBEGoldAwardCount];
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
        
        __weak __typeof(self)weakSelf = self;

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
                
                [weakSelf awardGold:KBEGoldAwardCount];
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

- (void)shareToWifi
{
    [_shareCircleView dismissAnimated:YES];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *shareLessons = [storyboard instantiateViewControllerWithIdentifier:@"share"];
    [self presentViewController:shareLessons];
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
        
        __weak __typeof(self)weakSelf = self;

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
                
                [weakSelf awardGold:KBEGoldAwardCount];
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
    
    if(! ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]] ||
          [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]]) )
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
-(void) prepairIAP
{
    [[MKStoreKit sharedKit] startProductRequest];
}

- (void) presentStoreView
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //NSString*  startDateStr =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"membershipStartTime"];
    NSString*  endDateStr =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"membershipEndTime"];
    
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
                [self buyAppleIdentify:availableProducts[0]];
            }
        }
        else
        {
            [self.window makeToast:@"需要打开应用内购买功能才能继续!" duration:3 position:CSToastPositionCenter];
        }
    }
}

- (void) buyAppleIdentify:(SKProduct*) product
{
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:product.productIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                                                                            
                                                      NSCalendar *calendar = [NSCalendar currentCalendar];
                                                      NSDate *startDate = [NSDate date];
                                                      
                                                      NSDateComponents *components = [[NSDateComponents alloc] init];
                                                      [components setYear:1];
                                                      
                                                      NSDate *endDate =[calendar dateByAddingComponents:components toDate:startDate options:0]      ;
                                                      
                                                      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                      [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

                                                      NSString *startDateStr = [dateFormatter stringFromDate:startDate];
                                                      NSString *endDateStr = [dateFormatter stringFromDate:endDate];

                                                      [[NSUserDefaults standardUserDefaults] setObject:startDateStr forKey:@"membershipStartTime"];
                                                      [[NSUserDefaults standardUserDefaults] setObject:endDateStr forKey:@"membershipEndTime"];
                                                      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sysMembership"];

                                                      [[NSUserDefaults standardUserDefaults] synchronize];

                                                      [FlyingSysWithCenter  uploadMembershipWithCenter];
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                      
                                                      NSString *message =@"购买失败，好事耐磨哦：）";                                                      
                                                      [self.window makeToast:message duration:3 position:CSToastPositionCenter];
                                                  }];
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

+ (void) updataDBForLocal
{
    FlyingNowLessonDAO * nowLessonDAO =[[FlyingNowLessonDAO alloc] init];
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    [nowLessonDAO updateDBFromLocal:openID];
    
    //得到本地课程详细信息
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    //用户目录包含的可读内容
    
    NSArray* contents = [mgr contentsOfDirectoryAtPath:path error:nil];
    
    FlyingLessonDAO * lessonDAO =[[FlyingLessonDAO alloc] init];
    
    for (NSString *fileName in contents) {
        
        @autoreleasepool {
            
            BOOL isMp3 = [NSString checkMp3URL:fileName];
            BOOL isMp4 = [NSString checkMp4URL:fileName];
            BOOL isdoc = [NSString checkDocumentURL:fileName];
            
            if(isMp4
               || [NSString checkOtherVedioURL:fileName]
               || isdoc
               || isMp3){
                
                NSString* filePath = [path stringByAppendingPathComponent:fileName];
                
                //本地文件统一这么处理，最关键是保持和官方lessonID的唯一性。
                NSString * lessonID= [FileHash md5HashOfFileAtPath:filePath];
                
                FlyingLessonData * pubLessondata =[lessonDAO   selectWithLessonID:lessonID];
                
                //如果没有相关纪录
                if (!pubLessondata)
                {
                    NSString* lessontitle =[[filePath lastPathComponent] stringByDeletingPathExtension];
                    
                    NSString * localSrtPath = [lessontitle localSrtURL];
                    NSString * localCoverPath = [lessontitle localCoverURL];
                    
                    UIImage * coverImage=nil;
                    if (isMp3) {
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            coverImage = [iFlyingAppDelegate thumbnailImageForMp3:[NSURL fileURLWithPath:filePath]];
                            
                            if (coverImage) {
                                
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    else if(isMp4){
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            coverImage = [iFlyingAppDelegate thumbnailImageForVideo:[NSURL fileURLWithPath:filePath] atTime:10];
                            
                            if (coverImage) {
                                
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    else if(isdoc)
                    {
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            NSString *phrase=@"";
                            
                            if ( [NSString checkPDFURL:fileName])
                            {
                                coverImage =[iFlyingAppDelegate thumbnailImageForPDF:[NSURL fileURLWithPath:filePath]
                                                                                       passWord:phrase];
                            }
                            if (coverImage)
                            {
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    
                    NSString * contentType = KContentTypeVideo;
                    if(isMp3){
                        
                        contentType = KContentTypeAudio;
                    }
                    else if (isdoc) {
                        
                        contentType = KContentTypeText;
                    }
                    
                    pubLessondata =[[FlyingLessonData alloc] initWithLessonID:lessonID
                                                                   LocalTitle:lessontitle
                                                              LocalContentURL:filePath
                                                                  LocalSubURL:localSrtPath
                                                                LocalCoverURL:localCoverPath
                                                                  ContentType:contentType
                                                                 DownloadType:KDownloadTypeNormal
                                                                          Tag:nil];
                    [lessonDAO insertWithData:pubLessondata];
                    
                }
                
                UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
                NSString *openID = keychain[KOPENUDIDKEY];
                
                if (![nowLessonDAO selectWithUserID:openID LessonID:lessonID]) {
                    
                    FlyingNowLessonData * data = [[FlyingNowLessonData alloc] initWithUserID:openID
                                                                                    LessonID:lessonID
                                                                                   TimeStamp:0
                                                                                  LocalCover:pubLessondata.localURLOfCover];
                    [nowLessonDAO insertWithData:data];
                }
            }
        }
    }
}


+ (UIImage*) thumbnailImageForMp3:(NSURL *)mp3fURL
{
    
    AVAsset *assest = [AVURLAsset URLAssetWithURL:mp3fURL options:nil];
    
    for (NSString *format in [assest availableMetadataFormats]) {
        
        for (AVMetadataItem *item in [assest metadataForFormat:format]) {
            
            if ([[item commonKey] isEqualToString:@"artwork"]) {
                UIImage *img = nil;
                if ([item.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                    img = [UIImage imageWithData:[item.value copyWithZone:nil]];
                }
                else { // if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                    NSData *data = [(NSDictionary *)[item value] objectForKey:@"data"];
                    img = [UIImage imageWithData:data]  ;
                }
                
                return img;
            }
        }
    }
    
    return nil;
}

+ (UIImage*) thumbnailImageForPDF:(NSURL *)pdfURL  passWord:(NSString*) password
{
    
    CGPDFDocumentRef documentRef = CGPDFDocumentCreateX((__bridge CFURLRef)pdfURL, password);
    CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, 1);
    CGRect pageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
    
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, CGRectGetMinX(pageRect),CGRectGetMaxY(pageRect));
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, -(pageRect.origin.x), -(pageRect.origin.y));
    CGContextDrawPDFPage(context, pageRef);
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGPDFDocumentRelease(documentRef), documentRef = NULL;
    
    return finalImage;
}


+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [UIImage imageWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

@end
