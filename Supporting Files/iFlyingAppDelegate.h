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
#import <MessageUI/MessageUI.h>
#import <RongIMKit/RongIMKit.h>
#import "RCDRCIMDataSource.h"
#import <UIKit/UITabBarController.h>
#import "FlyingHomeVC.h"
#import "FlyingMyGroupsVC.h"
#import "FlyingConversationListVC.h"
#import "FlyingAccountVC.h"

@class FlyingM3U8Downloader;
@class FlyingMagnetDownloader;
@class FMDatabaseQueue;
@class FMDatabase;
@class FlyingBonjourServer;
@class FlyingPubLessonData;
@class FlyingShareData;
@class FlyingTabBarController;


@interface iFlyingAppDelegate : UIResponder <UIApplicationDelegate,
                                                WXApiDelegate,
                                                RCIMConnectionStatusDelegate,
                                                RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow                  *window;

@property (strong, nonatomic) FlyingHomeVC              *homeVC;
@property (strong, nonatomic) FlyingMyGroupsVC          *myGroupsVC;
@property (strong, nonatomic) FlyingConversationListVC  *messagesVC;
@property (strong, nonatomic) FlyingAccountVC           *accountVC;


//本地环境准备
+(void) preparelocalEnvironment;

//社会化资源管理
- (void) shareContent:(FlyingShareData*) shareData fromView:(UIView*) popView;
- (void) shakeNow;

//消息管理
-(void) makeToast:(NSString*)message;

//发音管理
- (NSOperationQueue    *) get_flyingSoundPlayer_queue;
- (AVSpeechSynthesizer *) getSpeechSynthesizer;

//本地Httpserver
- (void) startLocalHttpserver;
- (void) closeLocalHttpserver;

- (void) closeMyresource;

- (void) setNavigationBarWithLogoStyle:(BOOL) logoStyle;

//界面跳转管理
- (FlyingTabBarController*) getTabBarController;
-(void)setTabBarController:(FlyingTabBarController*)tabBarController;
- (void)refreshTabBadgeValue;


- (BOOL) handleOpenURL:(NSURL *)url;

- (void) showLessonViewWithID:(NSString *) lessonID;
- (void) showLessonViewWithCode:(NSString*) code;
- (BOOL) showWebviewWithURL:(NSString *) webURL;

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL) animated;
- (void) presentViewController:(UIViewController *)viewController;

@end
