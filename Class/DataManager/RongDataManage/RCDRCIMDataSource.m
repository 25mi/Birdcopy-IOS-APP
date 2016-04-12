//
//  RCDRCIMDelegateImplementation.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "AFHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "FlyingHttpTool.h"
#import "DBHelper.h"
#import "FMDatabaseQueue.h"
#import "RCDataBaseManager.h"

#import "shareDefine.h"

@interface RCDRCIMDataSource ()

@end

@implementation RCDRCIMDataSource

- (instancetype)init
{
    self = [super init];
    return self;
}

+ (RCDRCIMDataSource*)shareInstance
{
    static RCDRCIMDataSource* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        
    });
    return instance;
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
    if ([userId length] == 0)
        return;
    
    RCUserInfo *userInfo=[[RCDataBaseManager shareInstance] getUserByUserId:userId];
    
    if (userInfo==nil) {

        [FlyingHttpTool getUserInfoByRongID:userId
                              completion:^(FlyingUserData *userData,RCUserInfo *userInfo) {
                                  
                                  if (userInfo) {
                                      completion(userInfo);
                                  }
                              }];
    }else
    {
        completion(userInfo);
    }
    
}
- (void)cacheAllUserInfo:(void (^)())completion
{
    //__block NSArray * regDataArray;
    
    /*
    
    [FLYINGHTTPTOOL getFriendsSuccess:^(id response) {
        if (response) {
            NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                if ([code isEqualToString:@"200"]) {
                    regDataArray = response[@"result"];
                    for(int i = 0;i < regDataArray.count;i++){
                        NSDictionary *dic = [regDataArray objectAtIndex:i];
                        
                        RCUserInfo *userInfo = [RCUserInfo new];
                        NSNumber *idNum = [dic objectForKey:@"id"];
                        userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                        userInfo.portraitUri = [dic objectForKey:@"portrait"];
                        userInfo.name = [dic objectForKey:@"username"];
                        [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                    }
                    completion();
                }
            });
        }
     
    } failure:^(NSError *err) {
        NSLog(@"getUserInfoByUserID error");
    }];
     
     */

}

- (void)cacheAllFriends:(void (^)())completion
{
    /*
    [FLYINGHTTPTOOL getFriends:^(NSMutableArray *result) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [result enumerateObjectsUsingBlock:^(FlyingUserInfo *userInfo, NSUInteger idx, BOOL *stop) {
                RCUserInfo *friend = [[RCUserInfo alloc] initWithUserId:userInfo.userId name:userInfo.userName portrait:userInfo.portraitUri];
                [[RCDataBaseManager shareInstance] insertFriendToDB:friend];
            }];
            completion();
        });
    }];
     */
}

/*
 * 当客户端第一次运行时，调用此接口初始化所有用户数据。
 */

- (void)cacheAllData:(void (^)())completion
{
    [self cacheAllUserInfo:^{

        completion();
    }];
}

/*
 * 获取所有用户信息
 */

- (NSArray *)getAllUserInfo:(void (^)())completion
{
    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllUserInfo];
    if (!allUserInfo.count) {
        [self cacheAllUserInfo:^{
            completion();
        }];
    }
    return allUserInfo;
}

- (NSArray *)getAllFriends:(void (^)())completion
{
    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllFriends];
    if (!allUserInfo.count) {
        [self cacheAllFriends:^{
            completion();
        }];
    }
    return allUserInfo;
}

@end
