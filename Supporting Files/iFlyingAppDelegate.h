//
//  iFlyingAppDelegate.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/3/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WXApi.h"
#import "CFShareCircleView.h"
#import <MessageUI/MessageUI.h>
#import "RESideMenu.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDRCIMDataSource.h"

@class FlyingM3U8Downloader;
@class FlyingMagnetDownloader;
@class FMDatabaseQueue;
@class FMDatabase;
@class FlyingBonjourServer;
@class FlyingPubLessonData;
@class FlyingSysWithCenter;


@interface iFlyingAppDelegate : UIResponder <UIApplicationDelegate,
                                                WXApiDelegate,
                                                CFShareCircleViewDelegate,
                                                MFMessageComposeViewControllerDelegate,
                                                MFMailComposeViewControllerDelegate,
                                                RCIMConnectionStatusDelegate>

@property (strong, nonatomic) UIWindow *window;


//下载资源管理
- (void) startDownloaderForID:(NSString *)lessonID;
- (void) closeAndReleaseDownloaderForID:(NSString *)lessonID;
- (BOOL) isWaitting:(NSString*) lessonID;

- (void) continueDownloadingWork;

//社会化资源管理
- (void) shareImageURL:(NSString *)imageURL  withURL:(NSString*) webURL  Title:(NSString*) title  Text:(NSString*) text  Image:(UIImage *)image;
- (void) shakeNow;

//帐户、充值管理
- (FlyingSysWithCenter*) getSysWithCenter;
-(void)  awardGold:(int) MoneyCount;

//个人数据库用户管理
- (FMDatabaseQueue *) shareUserDBQueue;
- (void)              closeUserDBQueue;

-(RCDRCIMDataSource*) getRongDataSource;

//个人数据库公用管理
- (FMDatabaseQueue *) sharePubUserDBQueue;
- (void) closePubUserDBQueue;

//大字典数据库用户管理
- (FMDatabaseQueue *) shareBaseDBQueue;
- (void)              closeBaseDBQueue;

//大字典数据库公用管理
- (FMDatabaseQueue *) sharePubBaseDBQueue;
- (void)              closePubBaseDBQueue;

//发音管理
- (NSOperationQueue    *) get_flyingSoundPlayer_queue;
- (AVSpeechSynthesizer *) getSpeechSynthesizer;

//本地Httpserver
- (void) startLocalHttpserver;
- (void) closeLocalHttpserver;

//后台进程管理
-(dispatch_queue_t) getAIQueue;
-(dispatch_queue_t) getBackPubQueue;

- (void) closeMyresource;

- (RESideMenu*) getMenu;
- (void) setnavigationBarWithClearStyle:(BOOL) clearStyle;
- (void) resetnavigationBarWithDefaultStyle;

+ (NSString *) getUserDataDir;
+ (NSString*) getDownloadsDir;
+ (NSString*) getLessonDir:(NSString*) lessonID;

//界面跳转管理
- (BOOL) handleOpenURL:(NSURL *)url;

- (void) showLessonViewWithID:(NSString *) lessonID;
- (void) showLessonViewWithCode:(NSString*) code;
- (BOOL) showWebviewWithURL:(NSString *) webURL;

- (void) presentViewController:(UIViewController *)viewController;
- (void) pushViewController:(UIViewController *)viewController;

//share

+ (UIImage*) thumbnailImageForMp3:(NSURL *)mp3fURL;
+ (UIImage*) thumbnailImageForPDF:(NSURL *)pdfURL  passWord:(NSString*) password;
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;


@end
