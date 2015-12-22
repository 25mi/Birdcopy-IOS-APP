//
//  FlyingDataManager.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/5/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingDataManager.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"
#import "FlyingNowLessonDAO.h"
#import "FlyingNowLessonData.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "FlyingHttpTool.h"
#import "UICKeyChainStore.h"
#import "OpenUDID.h"
#import "FlyingStatisticDAO.h"
#import "FlyingStatisticData.h"
#import "SIAlertView.h"
#import "FlyingSoundPlayer.h"

#import "FlyingTaskWordDAO.h"
#import "FlyingTouchDAO.h"
#import "FlyingDownloadManager.h"

@implementation FlyingDataManager

//获取openUDID
+ (void)getOpenUDIDFromLocal
{
    //check openUDID
    
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
        NSString *documentsDirectory = [FlyingDownloadManager getUserDataDir];
        
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
    
    //Bug Fix ios
    [[NSUserDefaults standardUserDefaults] setObject:openID forKey:KOPENUDIDKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//向服务器获取备份数据和最新充值数据
+(void) creatLocalUSerProfileWithServer
{
    NSString *openID = [NSString getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    //会员信息
    [FlyingHttpTool getMembershipForAccount:openID
                                      AppID:[NSString getAppID]
                                 Completion:^(NSDate *startDate, NSDate *endDate) {
                                          //
                                          
                                      }];
    
    //苹果渠道购买、金币消费、点击单词统计
    [FlyingHttpTool getMoneyDataWithOpenID:openID
                                     AppID:[NSString getAppID]
                                Completion:^(BOOL result) {
                                    //
                                }];
    
    
    //充值卡记录
    [FlyingHttpTool getQRDataForUserID:openID
                                 AppID:[NSString getAppID]
                            Completion:^(BOOL result) {
                                //
                            }];
    
    //课程统计信息
    [FlyingHttpTool getStatisticDetailWithOpenID:openID
                                           AppID:[NSString getAppID]
                                      Completion:^(BOOL result) {
                                           //
    }];
    
    
    //个人头像和昵称
    [FlyingHttpTool getUserInfoByopenID:openID
                             completion:^(RCUserInfo *user) {
                                 //
                             }];
}


//清理所有用户相关数据(数据库＋影射文件)
+(void) clearAllUserDate
{
    //清除缓存
    [FlyingDataManager clearCache];
    
    //个人充值记录
    [[FlyingStatisticDAO new] clearAll];
    
    //公共课程记录
    [[FlyingLessonDAO new] clearAll];
    
    //个人课程记录
    [[FlyingNowLessonDAO new] clearAll];
    
    //单词任务记录
    [[FlyingTaskWordDAO new] clearAll];
    
    //点击记录
    [[FlyingTouchDAO new] clearAll];
}

//清理缓存
+(void) clearCache
{
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }

                       //清楚缓存课程文件
                       NSString *openID = [NSString getOpenUDID];
                       
                       if (!openID) {
                           
                           return;
                       }
                       NSArray * tempArray =  [[[FlyingNowLessonDAO new] selectWithUserID:openID] mutableCopy] ;
                                              
                       [tempArray enumerateObjectsUsingBlock:^(FlyingNowLessonData* nowLessonData, NSUInteger idx, BOOL *stop) {
                           //
                           
                           //通知下载中心关闭相关资源，没有下载就是无意义操作
                           [[FlyingDownloadManager shareInstance] closeAndReleaseDownloaderForID:nowLessonData.BELESSONID];
                           
                           //删除数据库本地纪录，资源自动释放
                           [[FlyingNowLessonDAO new] deleteWithUserID:openID LessonID:nowLessonData.BELESSONID];
                       }];
                       
                       tempArray =  [[[FlyingLessonDAO new] select] mutableCopy] ;
                       
                       [tempArray enumerateObjectsUsingBlock:^(FlyingLessonData* lessonData, NSUInteger idx, BOOL *stop) {
                           //
                           
                           //通知下载中心关闭相关资源，没有下载就是无意义操作
                           [[FlyingDownloadManager shareInstance] closeAndReleaseDownloaderForID:lessonData.BELESSONID];
                           
                           //删除数据库本地纪录，资源自动释放
                           [[FlyingLessonDAO new]  deleteWithLessonID:lessonData.BELESSONID];
                       }];
                       
                       
                       [[NSNotificationCenter defaultCenter] postNotificationName:KBELocalCacheClearOK object:nil];
                   });
}

+(void) lowCointAlert
{
    NSString *openID = [NSString getOpenUDID];
    
    if(!openID)
    {
        return;
    }
    FlyingStatisticData * staticDat = [[[FlyingStatisticDAO alloc] init] selectWithUserID:openID];
    
    if (((KBEFreeTouchCount+staticDat.BEQRCOUNT+staticDat.BEMONEYCOUNT+staticDat.BEGIFTCOUNT)-staticDat.BETOUCHCOUNT)<0) {
        
        NSString *title = @"友情提醒！";
        NSString *message = @"帐户金币数不足,请尽快在《我的档案》充值！";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {}];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
    }
}


+ (void) buyAppleIdentify:(SKProduct*) product
{
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:product.productIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSCalendar *calendar = [NSCalendar currentCalendar];
                                                      NSDate *startDate = [NSDate date];
                                                      
                                                      NSDateComponents *components = [[NSDateComponents alloc] init];
                                                      [components setYear:1];
                                                      
                                                      NSDate *endDate =[calendar dateByAddingComponents:components toDate:startDate options:0]      ;
                                                      
                                                      [FlyingHttpTool updateMembershipForAccount:[NSString getOpenUDID]
                                                                                           AppID:[NSString getAppID]
                                                                                       StartDate:startDate
                                                                                         EndDate:endDate
                                                                                      Completion:^(BOOL result) {
                                                                                          //
                                                                                          [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil userInfo:nil];
                                                                                      }];
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                      
                                                      
                                                      UIAlertView *shakingAlert = [[UIAlertView alloc] initWithTitle:@"重要提醒"
                                                                                                             message:@"购买失败，好事耐磨哦：）"
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:@"确认"
                                                                                                   otherButtonTitles:nil, nil];
                                                      [shakingAlert show];

                                                  }];
}

+(void)  awardGold:(int) MoneyCount
{
    NSString *openID = [NSString getOpenUDID];
    
    //奖励金币
    FlyingStatisticDAO * statisticDAO = [[FlyingStatisticDAO alloc] init];
    [statisticDAO setUserModle:NO];
    
    NSInteger giftCountNow=[statisticDAO giftCountWithUserID:openID];
    giftCountNow+=KBEGoldAwardCount;
    [statisticDAO updateWithUserID:openID GiftCount:giftCountNow];
    
    [FlyingSoundPlayer soundEffect:@"iMoneyDialogClose"];
}


+(void) doStatisticJob
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *openID = [NSString getOpenUDID];
        FlyingStatisticDAO * statistic = [[FlyingStatisticDAO alloc] init];
        [statistic setUserModle:NO];
        
        //学习次数加一
        NSInteger learnedTimes = [statistic timesWithUserID:openID];
        learnedTimes = learnedTimes+1;
        [statistic updateWithUserID:openID Times:learnedTimes];
    });
}


@end

