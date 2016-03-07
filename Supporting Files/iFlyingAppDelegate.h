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
#import <RongIMKit/RongIMKit.h>
#import "RCDRCIMDataSource.h"
#import <UIKit/UITabBarController.h>

@class FlyingM3U8Downloader;
@class FlyingMagnetDownloader;
@class FMDatabaseQueue;
@class FMDatabase;
@class FlyingBonjourServer;
@class FlyingPubLessonData;


@interface iFlyingAppDelegate : UIResponder <UIApplicationDelegate,
                                                WXApiDelegate,
                                                CFShareCircleViewDelegate,
                                                MFMessageComposeViewControllerDelegate,
                                                MFMailComposeViewControllerDelegate,
                                                RCIMConnectionStatusDelegate,
                                                RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow *window;




//本地环境准备
+(void) preparelocalEnvironment;

//社会化资源管理
- (void) shareImageURL:(NSString *)imageURL  withURL:(NSString*) webURL  Title:(NSString*) title  Text:(NSString*) text  Image:(UIImage *)image;
- (void) shakeNow;

//购买管理
- (void)presentStoreView;

//发音管理
- (NSOperationQueue    *) get_flyingSoundPlayer_queue;
- (AVSpeechSynthesizer *) getSpeechSynthesizer;

//本地Httpserver
- (void) startLocalHttpserver;
- (void) closeLocalHttpserver;

- (void) closeMyresource;

- (void) setnavigationBarWithClearStyle:(BOOL) clearStyle;
- (void) resetnavigationBarWithDefaultStyle;

//界面跳转管理

- (UITabBarController*) getTabBarController;

- (BOOL) handleOpenURL:(NSURL *)url;

- (void) showLessonViewWithID:(NSString *) lessonID;
- (void) showLessonViewWithCode:(NSString*) code;
- (BOOL) showWebviewWithURL:(NSString *) webURL;

- (void) presentViewController:(UIViewController *)viewController;

@end
