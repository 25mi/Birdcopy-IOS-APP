//
//  FlyingDataManager.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/5/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKStoreKit.h"
#import <StoreKit/StoreKit.h>

@interface FlyingDataManager : NSObject

//基础用户数据
+ (NSString*) getServerAddress;
+ (NSString*) getWeixinID;
+ (NSString*) getRongAppKey;
+ (NSString*) getOfficalURL;
+ (NSString*) getAppID;
+ (NSString*) getOpenUDID;
+ (NSString*) getRongID;
+ (NSString*) getBusinessID;

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
+(void)getOpenUDIDFromLocal;

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
