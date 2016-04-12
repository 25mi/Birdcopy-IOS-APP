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
#import "FlyingSoundPlayer.h"

#import "FlyingTaskWordDAO.h"
#import "FlyingTouchDAO.h"
#import "FlyingFileManager.h"
#import "FlyingDownloadManager.h"
#import "MKStoreKit.h"

@implementation FlyingDataManager


+(void) saveAppData:(FlyingAppData*) appData
{
    [[NSUserDefaults standardUserDefaults] setObject:appData.appID      forKey:KAPP_Birdcopy_APPID];
    [[NSUserDefaults standardUserDefaults] setObject:appData.domainID   forKey:KAPP_Domain_ID];

    [[NSUserDefaults standardUserDefaults] setObject:appData.webaddress forKey:KAPP_SERVER_ADDRESS];
    [[NSUserDefaults standardUserDefaults] setObject:appData.wexinID    forKey:KAPP_Weixin_ID];
    [[NSUserDefaults standardUserDefaults] setObject:appData.rongAppKey forKey:KAPP_RongCloud_Key];
    [[NSUserDefaults standardUserDefaults] setObject:appData.webaddress forKey:KAPP_SERVER_ADDRESS];
    [[NSUserDefaults standardUserDefaults] setObject:appData.webaddress forKey:KAPP_SERVER_ADDRESS];
    [[NSUserDefaults standardUserDefaults] setObject:appData.webaddress forKey:KAPP_SERVER_ADDRESS];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*) getBirdcopyAppID
{
    NSString *appID =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KAPP_Birdcopy_APPID];;
    
    return appID;
}

+ (NSString*) getBusinessID
{
    
    return [FlyingDataManager getBirdcopyAppID];
    
    //NSString *businessID =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KAPP_Domain_ID];;
    
    //return businessID;
}

+ (NSString*) getChannelID
{
    return [FlyingDataManager getBirdcopyAppID];
}

+ (NSString*) getServerAddress
{
    return @"http://e.birdcopy.com";

    /*
    NSString *serverNetAddress =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KAPP_SERVER_ADDRESS];;
    
    return serverNetAddress;
     */
}

+ (NSString*) getRongAppKey
{
    NSString *rongAPPkey =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KAPP_RongCloud_Key];;
    
    return rongAPPkey;
}


+ (NSString*) getWeixinID
{
    NSString *weixinAPPID =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KAPP_Weixin_ID];;
    
    return weixinAPPID;
}



+ (NSString*) getOfficalURL
{
    NSString* officalURL=@"http://www.birdcopy.com";
    
    
    return officalURL;
}

+ (NSString*) getOpenUDID
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(!openID)
    {
        openID=(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KOPENUDIDKEY];
    }
    
    return openID;
}

+ (NSString*) getRongID
{
    if ([FlyingDataManager getOpenUDID]) {
        
        return [[FlyingDataManager getOpenUDID] MD5];
    }
    else
    {
        return nil;
    }
}

+ (NSString*) getUserName
{
    NSString *userName=[UICKeyChainStore keyChainStore][kUserName];
    
    if (userName.length==0) {
        
        userName=(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:kUserName];
    }
    
    return userName;
}

+ (void) setUserName:(NSString*) userName
{
    [UICKeyChainStore keyChainStore][kUserName]=userName;
    
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kUserName];
    
    [[NSUserDefaults standardUserDefaults]  synchronize];
}


+ (NSString*) getUserPassword
{
    NSString *passWord=[UICKeyChainStore keyChainStore][kUserPassWord];
    
    return passWord;
}

+ (void) setUserPassword:(NSString*) passWord
{
    [UICKeyChainStore keyChainStore][kUserPassWord]=passWord;
    
}

+ (FlyingUserData*) getUserData:(NSString*) openUDID
{
    if (openUDID) {

        NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:openUDID];
        
        if (data) {
            
            return (FlyingUserData*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        else
        {
            return nil;
        }
    }
    else
    {
        NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:[FlyingDataManager getOpenUDID]];
        return (FlyingUserData*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

+ (void) saveUserData:(FlyingUserData*) userData
{

    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:userData]
                                              forKey:userData.openUDID];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}


+(FlyingUserRightData*) getUserRightForDomainID:(NSString*) domainID domainType:(NSString*) domainType
{
    
    NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:domainID];
    
    if (data) {
        
        return (FlyingUserRightData*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        return nil;
    }
}

+(void) saveUserRightData:(FlyingUserRightData *)userRightData;
{
    if (userRightData.domainID) {

        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:userRightData]
                                                  forKey:userRightData.domainID];
        [[NSUserDefaults standardUserDefaults]  synchronize];
    }
}

//获取openUDID
+ (void)makeOpenUDIDFromLocal
{
    //check openUDID
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(openID==nil)
    {
        openID = [[NSUserDefaults standardUserDefaults]  objectForKey:KOPENUDIDKEY];
    }
    
    if(openID==nil)
    {
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
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    //个人头像和昵称
    [FlyingHttpTool getUserInfoByopenID:openID
                             completion:^(FlyingUserData *userData,RCUserInfo *userInfo) {
                                 
                             }];
    
    //会员信息
    [FlyingHttpTool getMembershipForAccount:openID
                                 Completion:^(FlyingUserRightData *userRightData) {
                                          //
                                      }];
    
    //苹果渠道购买、金币消费、点击单词统计
    [FlyingHttpTool getMoneyDataWithOpenID:openID
                                Completion:^(BOOL result) {
                                    //
                                }];
    
    //充值卡记录
    [FlyingHttpTool getQRDataForUserID:openID
                            Completion:^(BOOL result) {
                                //
                            }];
    
    //课程统计信息
    [FlyingHttpTool getStatisticDetailWithOpenID:openID
                                      Completion:^(BOOL result) {
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
                       NSString *openID = [FlyingDataManager getOpenUDID];
                       
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
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    if(!openID)
    {
        return;
    }
    FlyingStatisticData * staticDat = [[[FlyingStatisticDAO alloc] init] selectWithUserID:openID];
    
    if (((KBEFreeTouchCount+staticDat.BEQRCOUNT+staticDat.BEMONEYCOUNT+staticDat.BEGIFTCOUNT)-staticDat.BETOUCHCOUNT)<0) {
        
        NSString *message = @"帐户金币数不足,请尽快在《我的档案》充值！";
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeToast:message];
    }
}


+ (void) buyAppleIdentify:(SKProduct*) product
{
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:product.productIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSArray *availableProducts = [MKStoreKit configs][@"Others"];;
                                                      
                                                      if ([product.productIdentifier isEqualToString:availableProducts[0]]) {
                                                          
                                                          NSCalendar *calendar = [NSCalendar currentCalendar];
                                                          NSDate *startDate = [NSDate date];
                                                          
                                                          NSDateComponents *components = [[NSDateComponents alloc] init];
                                                          [components setYear:1];
                                                          
                                                          NSDate *endDate =[calendar dateByAddingComponents:components toDate:startDate options:0]      ;
                                                          
                                                          [FlyingHttpTool updateMembershipForAccount:[FlyingDataManager getOpenUDID]
                                                                                           StartDate:startDate
                                                                                             EndDate:endDate
                                                                                          Completion:^(BOOL result) {
                                                                                              //
                                                                                              [FlyingSoundPlayer soundEffect:@"LootCoinSmall"];
                                                                                              [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil userInfo:nil];
                                                                                          }];
                                                      }
                                                      else
                                                      {
                                                          NSDictionary *availableConsumables = [MKStoreKit configs][@"Consumables"];
                                                          NSDictionary *thisConsumable = availableConsumables[product.productIdentifier];
                                                          
                                                          NSNumber *consumableCount = thisConsumable[@"ConsumableCount"];
                                                          
                                                          FlyingStatisticDAO * statisticDAO=[[FlyingStatisticDAO alloc] init];
                                                          NSInteger appleMoneyCountNow =[statisticDAO appleMoneyWithUserID:[FlyingDataManager getOpenUDID]];

                                                          appleMoneyCountNow+=consumableCount.integerValue;
                                                          [statisticDAO updateWithUserID:[FlyingDataManager getOpenUDID] AppleMoneyCount:appleMoneyCountNow];
                                                          
                                                          [FlyingHttpTool uploadMoneyDataWithOpenID:[FlyingDataManager getOpenUDID] Completion:^(BOOL result) {
                                                              //
                                                              [FlyingSoundPlayer soundEffect:@"LootCoinSmall"];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil userInfo:nil];
                                                          }];
                                                      }
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                      
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:KAPPBuyFail object:nil];
                                                  }];
}

+(void)  awardGold:(int) MoneyCount
{
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    //奖励金币
    FlyingStatisticDAO * statisticDAO = [[FlyingStatisticDAO alloc] init];
    
    NSInteger giftCountNow=[statisticDAO giftCountWithUserID:openID];
    giftCountNow+=KBEGoldAwardCount;
    [statisticDAO updateWithUserID:openID GiftCount:giftCountNow];
    
    [FlyingSoundPlayer soundEffect:@"iMoneyDialogClose"];
}


+(void) doStatisticJob
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *openID = [FlyingDataManager getOpenUDID];
        FlyingStatisticDAO * statistic = [[FlyingStatisticDAO alloc] init];
        
        //学习次数加一
        NSInteger learnedTimes = [statistic timesWithUserID:openID];
        learnedTimes = learnedTimes+1;
        [statistic updateWithUserID:openID Times:learnedTimes];
    });
}


@end

