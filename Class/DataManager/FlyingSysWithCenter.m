//
//  FlyingSysWithCenter.m
//  FlyingEnglish
//
//  Created by BE_Air on 2/7/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingSysWithCenter.h"
#import "NSString+FlyingExtention.h"
#import "SIAlertView.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "FlyingStatisticDAO.h"
#import "FlyingStatisticData.h"

#import "FlyingNowLessonDAO.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "FlyingTouchDAO.h"
#import "FlyingTouchRecord.h"
#import "AFHttpTool.h"

#import "MKStoreKit.h"
#import "FlyingHttpTool.h"

@implementation FlyingSysWithCenter

- (void) chargingCrad:(NSString*) cardID
{
    @synchronized(self)
    {
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
        NSString *openID = keychain[KOPENUDIDKEY];
        
        if (!openID) {
            
            return;
        }

        //向服务器帐户进行充值
        [AFHttpTool chargingCardSysURLForUserID:openID
                                         CardID:cardID
                                        success:^(id response) {
                                            //
                                            if (response) {
                                                
                                                NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                                
                                                if([NSString isPureInt:tempStr]){
                                                    
                                                    NSInteger resultNum =[tempStr integerValue];
                                                    
                                                    NSString * responseStr=nil;
                                                    FlyingStatisticDAO * statDAO = [[FlyingStatisticDAO alloc] init];
                                                    FlyingStatisticData *userData = [statDAO selectWithUserID:openID];
                                                    
                                                    switch (resultNum) {
                                                        case -1:
                                                            responseStr = @"必须参数缺少";
                                                            break;
                                                        case -11:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -12:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -13:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -21:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -22:
                                                            responseStr = @"充值卡未出售";
                                                            break;
                                                        case -23:
                                                            responseStr = @"充值卡被锁定";
                                                            break;
                                                        case -24:
                                                            responseStr = @"充值卡失效";
                                                            break;
                                                        case -31:
                                                            responseStr = @"充值卡已充值";
                                                            break;
                                                        case -32:
                                                            responseStr = @"充值卡已充值";
                                                            break;
                                                        case -99:
                                                            responseStr = @"中途出错(系统原因)";
                                                            break;
                                                        default:
                                                            [statDAO updateWithUserID:openID QRMoneyCount:resultNum];
                                                            
                                                            
                                                            responseStr = [NSString stringWithFormat:@"充值成功:充值金币数目:%@",[@(resultNum-userData.BEQRCOUNT) stringValue]];
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil];
                                                    }
                                                    
                                                    NSString *title = @"充值提醒";
                                                    
                                                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                                                                     andMessage:responseStr];
                                                    [alertView addButtonWithTitle:@"知道了"
                                                                             type:SIAlertViewButtonTypeDefault
                                                                          handler:^(SIAlertView *alertView) {}];
                                                    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                                                    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
                                                    [alertView show];
                                                }
                                            }
                                            else
                                            {
                                                NSString *title = @"充值提醒！";
                                                NSString *message = @"服务器繁忙或者网络故障请稍后再试！";
                                                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
                                                [alertView addButtonWithTitle:@"知道了"
                                                                         type:SIAlertViewButtonTypeDefault
                                                                      handler:^(SIAlertView *alertView) {}];
                                                alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                                                alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
                                                [alertView show];
                                            }

                                        } failure:^(NSError *err) {
                                            //
                                            NSLog(@"chargingCardSysURLForUserID:%@",err.description);
                                        }];
    }
}

//获取充值卡数据
+(void) sysQRMoneyWithCenter
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(!openID)
    {
        return;
    }
    //向服务器获取最新QR数据
    [AFHttpTool getQRCountForUserID:openID
                            success:^(id response) {
                                //
                                if (response) {
                                    
                                    NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                    
                                    if([NSString isPureInt:tempStr]){
                                        
                                        NSInteger resultNum =[tempStr integerValue];
                                        if(resultNum>=0){
                                            
                                            FlyingStatisticDAO * statDAO = [[FlyingStatisticDAO alloc] init];
                                            FlyingStatisticData *userData = [statDAO selectWithUserID:openID];
                                            
                                            if(!userData){
                                                
                                                userData = [[FlyingStatisticData alloc] initWithUserID:openID
                                                                                            MoneyCount:0
                                                                                            TouchCount:0
                                                                                          LearnedTimes:0
                                                                                             GiftCount:0
                                                                                               QRCount:0
                                                                                             TimeStamp:0];
                                            }
                                            
                                            userData.BEQRCOUNT = resultNum;
                                            
                                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                                            NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
                                            userData.BETIMESTAMP = destDateString;
                                            
                                            [statDAO insertWithData:userData];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil];
                                        }
                                    }
                                }

                            } failure:^(NSError *err) {
                                //
                                NSLog(@"getQRCountForUserID:%@",err.description);
                            }];
}

//向服务器获备份消费以及其其它非充值数据
+(void) uploadUserCenter
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(!openID)
    {
        return;
    }
    FlyingStatisticData * staticDat = [[[FlyingStatisticDAO alloc] init] selectWithUserID:openID];
    
    
    [AFHttpTool sysOtherMoneyWithAccount:openID
                              MoneyCount:staticDat.BEMONEYCOUNT
                               GiftCount:staticDat.BEGIFTCOUNT
                              TouchCount:staticDat.BETOUCHCOUNT
                                 success:^(id response) {
                                     //
                                     if (response) {
                                         
                                         NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                         
                                         if([NSString isPureInt:tempStr]){
                                             
                                             NSInteger resultNum =[tempStr integerValue];
                                             
                                             //上传消费值成功
                                             if(resultNum==1){
                                                 
                                                 NSLog(@"上传备份消费值成功");
                                                 
                                                 [[NSUserDefaults standardUserDefaults] setInteger:staticDat.BETOUCHCOUNT forKey:@"sysTouchAccount"];
                                             }
                                         }
                                     }

                                 } failure:^(NSError *err) {
                                     //
                                     NSLog(@"sysOtherMoneyWithAccount:%@",err.description);
                                 }];
    

    FlyingTouchDAO * touchDAO = [[FlyingTouchDAO alloc] init];
    NSArray *recordList = [touchDAO selectWithUserID:openID];
    
    __block NSMutableString * updateStr =[NSMutableString new];
    
    __block BOOL first=YES;
    
    [recordList enumerateObjectsUsingBlock:^(FlyingTouchRecord* toucRecord, NSUInteger idx, BOOL *stop) {
        
        if (first) {
            
            [updateStr appendFormat:@"%@;%d",toucRecord.BELESSONID,toucRecord.BETOUCHTIMES];
            
            first=NO;
        }
        else{
            
            [updateStr appendFormat:@"|%@;%d",toucRecord.BELESSONID,toucRecord.BETOUCHTIMES];
        }
    }];

    [AFHttpTool sysLessonTouchWithAccount:openID
                           lessonAndTouch:updateStr
                                  success:^(id response) {
                                      //
                                      if (response) {
                                          
                                          NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                          
                                          if([NSString isPureInt:tempStr]){
                                              
                                              NSInteger resultNum =[tempStr integerValue];
                                              
                                              //上传课程具体消费值成功
                                              if(resultNum==1){
                                                  
                                                  NSLog(@"上传课程具体消费值成功");
                                              }
                                          }
                                      }

                                  } failure:^(NSError *err) {
                                      //
                                      NSLog(@"sysLessonTouchWithAccount:%@",err.description);

                                  }];
}

//向服务器获取备份数据和最新充值数据，在本地激活用户ID
+(void) activeAccount
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if (!openID) {
        
        return;
    }
    
    [FlyingSysWithCenter sysMembershipWithCenter];
    
    [AFHttpTool getMoneyDataWithOpenID:openID success:^(id response) {
        //
        if (response) {
            
            NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSArray *tempArray = [tempStr componentsSeparatedByString:@";"];
            
            if (tempArray.count==4) {
                
                NSInteger BEMONEYCOUNT = [tempArray[0] integerValue];
                NSInteger BEGIFTCOUNT  = [tempArray[1] integerValue];
                NSInteger BETOUCHCOUNT = [tempArray[2] integerValue];
                NSInteger BEQRCOUNT    = [tempArray[3] integerValue];
                
                //查询现有数据库是否初始化
                FlyingStatisticDAO * statDAO = [[FlyingStatisticDAO alloc] init];
                FlyingStatisticData *userData = [statDAO selectWithUserID:openID];
                
                if(!userData){
                    
                    userData = [[FlyingStatisticData alloc] initWithUserID:openID
                                                                MoneyCount:0
                                                                TouchCount:0
                                                              LearnedTimes:0
                                                                 GiftCount:0
                                                                   QRCount:0
                                                                 TimeStamp:0];
                }
                
                //更新本地数据
                userData.BEQRCOUNT    = BEQRCOUNT;
                userData.BEMONEYCOUNT = BEMONEYCOUNT;
                userData.BETOUCHCOUNT = BETOUCHCOUNT;
                userData.BEGIFTCOUNT  = BEGIFTCOUNT;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
                userData.BETIMESTAMP = destDateString;
                
                [statDAO insertWithData:userData];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activeBEAccount"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountActive object:nil];
            }
            
        }

    } failure:^(NSError *err) {
        //
        NSLog(@"getMoneyDataWithOpenID:%@",err.description);
    }];
    
    NSArray *lessonIDlist = [[[FlyingNowLessonDAO alloc] init] selectIDWithUserID:openID];
    
    FlyingLessonDAO * lessonDao= [[FlyingLessonDAO alloc] init];
    FlyingTouchDAO * touchDAO = [[FlyingTouchDAO alloc] init];
    
    
    if (lessonIDlist.count==0) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activeBETouchAccount"];
        [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountActive object:nil];
    }
    else{

        [lessonIDlist enumerateObjectsUsingBlock:^(NSString* lessonID, NSUInteger idx, BOOL *stop) {
            
            FlyingLessonData * lessonData=[lessonDao selectWithLessonID:lessonID];
            
            if (lessonData.BEOFFICIAL==YES) {
                
                //向服务器获取最新课程相关统计数据
                [AFHttpTool getTouchDataForUserID:openID
                                         lessonID:lessonID
                                          success:^(id response) {
                                              //
                                              if (response) {
                                                  
                                                  NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                                  
                                                  [touchDAO insertDataForUserID:openID
                                                                       LessonID:lessonID
                                                                     touchTimes:[tempStr integerValue]];
                                              }
                                              
                                              if (idx==lessonIDlist.count-1) {
                                                  
                                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activeBETouchAccount"];
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountActive object:nil];
                                              }
                                              
                                          } failure:^(NSError *err) {
                                              //
                                              NSLog(@"getTouchDataForUserID:%@",err.description);

                                          }];
            }
        }];
    }
}

+(void) sysMembershipWithCenter
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(!openID)
    {
        return;
    }

    NSArray *availableProducts = [[MKStoreKit  sharedKit] availableProducts];
    
    if (availableProducts.count>0) {
        
        if ([[MKStoreKit sharedKit] isProductPurchased:availableProducts[0]]) {

            //向服务器获取最新会员数据
            [FlyingHttpTool getMembershipForAccount:openID
                                              AppID:nil
                                         Completion:^(NSDate *startDate, NSDate *endDate) {
                                             //
                                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                             [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                             
                                             NSString *startDateStr = [dateFormatter stringFromDate:startDate];
                                             NSString *endDateStr = [dateFormatter stringFromDate:endDate];
                                             
                                             [[NSUserDefaults standardUserDefaults] setObject:startDateStr forKey:@"membershipStartTime"];
                                             [[NSUserDefaults standardUserDefaults] setObject:endDateStr forKey:@"membershipEndTime"];
                                             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sysMembership"];
                                             
                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                         }];
        }
    }
}

+(void) uploadMembershipWithCenter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString*  startDateStr =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"membershipStartTime"];
    NSString*  endDateStr =(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"membershipEndTime"];

    NSDate *startDate = [dateFormatter dateFromString:startDateStr];
    NSDate *endDate = [dateFormatter dateFromString:endDateStr];
    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if (openID) {
        
        [FlyingHttpTool updateMembershipForAccount:openID
                                             AppID:nil
                                         StartDate:startDate
                                           EndDate:endDate
                                        Completion:^(BOOL result) {
                                            //
                                            if (result) {
                                                
                                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"sysMembership"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:KBEAccountChange object:nil];
                                            }
                                        }];
    }
}

+(void) sysWithCenter
{
    //获取充值卡数据
    [FlyingSysWithCenter sysQRMoneyWithCenter];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeBEAccount"]&&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"activeBETouchAccount"]) {

        //向服务器备份消费数据
        [FlyingSysWithCenter uploadUserCenter];
    }
    
    //如果买了会员没有同步到服务器
    NSArray *availableProducts = [[MKStoreKit  sharedKit] availableProducts];
    
    if (availableProducts.count>0) {
        
        if ([[MKStoreKit sharedKit] isProductPurchased:availableProducts[0]]) {
            
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"sysMembership"])
            {
                //
                [FlyingSysWithCenter uploadMembershipWithCenter];
            }
        }
    }
}

+(void) lowCointAlert
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
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

//用终端登录官网后台
+(void) loginWithQR:(NSString*)loginID
{    
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(!openID)
    {
        return;
    }
    
    [AFHttpTool loginWithQR:loginID
                    Account:openID
                    success:^(id response) {
                        //
                        if (response) {
                            
                            NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                            
                            if([NSString isPureInt:tempStr]){
                                
                                NSInteger resultNum =[tempStr integerValue];
                                
                                // 登录成功
                                if(resultNum==1){
                                    
                                    NSLog(@"扫描登录成功");
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:KBERQloginOK object:nil];
                                }
                            }
                        }

                    } failure:^(NSError *err) {
                        //
                        NSLog(@"loginWithQR:%@",err.description);

                    }];
}

@end
