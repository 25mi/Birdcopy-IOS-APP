//
//  FlyingDataManager.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/5/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "MKStoreKit.h"
#import "FlyingAppData.h"

@interface FlyingDataManager : NSObject


//APP数据
+(void) saveAppData:(FlyingAppData*) appData;

+ (NSString*) getBirdcopyAppID;
+ (NSString*) getBusinessID;

+ (NSString*) getServerAddress;
+ (NSString*) getRongAppKey;
+ (NSString*) getWeixinID;

+ (NSString*) getOfficalURL;


//终端用户数据
+ (NSString*) getOpenUDID;
+ (NSString*) getRongID;

+ (NSString*) getUserName;
+ (void)      setUserName:(NSString*) userName;
+ (NSString*) getUserPassword;
+ (void)      setUserPassword:(NSString*) passWord;

+ (NSString*) getNickName;
+ (void)      setNickName:(NSString*) nickName;
+ (NSString*) getUserAbstract;
+ (void)      setUserAbstract:(NSString*) userAbstract;
+ (NSString*) getUserPortraitUri;
+ (void)      setUserPortraitUri:(NSString*) portraitUri;

//获取openUDID
+(void)makeOpenUDIDFromLocal;

//向服务器获取备份数据和最新充值数据
+(void) creatLocalUSerProfileWithServer;

//清理缓存
+(void) clearCache;

//清理所有用户相关数据(数据库＋影射文件)
+(void) clearAllUserDate;

+ (void) buyAppleIdentify:(SKProduct*) product;

+(void)  awardGold:(int) MoneyCount;
+(void) lowCointAlert;

+(void) doStatisticJob;

@end
