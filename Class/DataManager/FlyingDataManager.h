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
#import "FlyingUserData.h"
#import "FlyingUserRightData.h"

@interface FlyingDataManager : NSObject

//APP数据

+ (NSString*) getServerAddress;
+ (NSString*) getWeixinID;
+ (NSString*) getRongKey;

+(void) saveAppData:(FlyingAppData*) appData;
+(FlyingAppData*) getAppData;

+ (NSString*) getOfficalURL;

//终端用户数据
+ (NSString*) getOpenUDID;
+ (NSString*) getRongID;

+ (NSString*) getUserName;
+ (void)      setUserName:(NSString*) userName;
+ (NSString*) getUserPassword;
+ (void)      setUserPassword:(NSString*) passWord;

+ (FlyingUserData*) getUserData:(NSString*)        openUDID;
+ (void)            saveUserData:(FlyingUserData*) userData;

+(FlyingUserRightData*) getUserRightForDomainID:(NSString*) domainID domainType:(NSString*) domainType;
+(void) saveUserRightData:(FlyingUserRightData *)userRightData;

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
