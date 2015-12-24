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
#import "RCDGroupInfo.h"
#import "FlyingUserInfo.h"
#import "FlyingHttpTool.h"
#import "DBHelper.h"
#import "FMDatabaseQueue.h"
#import "RCDataBaseManager.h"

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

-(void) syncGroups
{
    /*
    //开发者调用自己的服务器接口获取所属群组信息，同步给融云服务器，也可以直接
    //客户端创建，然后同步
    [FLYINGHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {
        if ([result count]) {
            //同步群组
            [[RCIMClient sharedRCIMClient] syncGroups:result
                                              success:^{
                                                  //DebugLog(@"同步成功!");
                                              } error:^(RCErrorCode status) {
                                                  //DebugLog(@"同步失败!  %ld",(long)status);
                                                  
                                              }];
        }
    }];
     */
    
}

#pragma mark - GroupInfoFetcherDelegate
- (void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup*))completion
{
    if ([groupId length] == 0)
        return;
    
    //开发者调自己的服务器接口根据userID异步请求数据
    [FLYINGHTTPTOOL getGroupByID:groupId
            successCompletion:^(RCGroup *group)
     {
         completion(group);
     }];
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
    if ([userId length] == 0)
        return;
    
    RCUserInfo *userInfo=[[RCDataBaseManager shareInstance] getUserByUserId:userId];
    
    if (userInfo==nil) {

        [FlyingHttpTool getUserInfoByRongID:userId
                              completion:^(RCUserInfo *user) {
                                  
                                  if (user) {
                                      [[RCDataBaseManager shareInstance] insertUserToDB:user];
                                      [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:user.userId];

                                      completion(user);
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
- (void)cacheAllIMGroup:(void (^)())completion
{
    /*
    [FLYINGHTTPTOOL getAllIMGroupsWithCompletion:^(NSMutableArray *result) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for(int i = 0;i < result.count;i++){
                RCGroup *userInfo =[result objectAtIndex:i];
                [[RCDataBaseManager shareInstance] insertGroupToDB:userInfo];
            }
            completion();
        });
    }];
     */
}

- (void)cacheAllFriends:(void (^)())completion
{
    [FLYINGHTTPTOOL getFriends:^(NSMutableArray *result) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [result enumerateObjectsUsingBlock:^(FlyingUserInfo *userInfo, NSUInteger idx, BOOL *stop) {
                RCUserInfo *friend = [[RCUserInfo alloc] initWithUserId:userInfo.userId name:userInfo.userName portrait:userInfo.portraitUri];
                [[RCDataBaseManager shareInstance] insertFriendToDB:friend];
            }];
            completion();
        });
    }];
}
- (void)cacheAllData:(void (^)())completion
{
    __weak RCDRCIMDataSource *weakSelf = self;
    [self cacheAllUserInfo:^{
        /*
        [weakSelf cacheAllGroup:^{
            [weakSelf cacheAllFriends:^{
                //[DEFAULTS setBool:YES forKey:@"notFirstTimeLogin"];
                //[DEFAULTS synchronize];
                completion();
            }];
        }];
         */
    }];
}

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
/*
 * 获取所有群组信息
 */
- (NSArray *)getAllGroupInfo:(void (^)())completion
{
    
    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllGroup];
    /*
    if (!allUserInfo.count) {
        [self cacheAllGroup:^{
            completion();
        }];
    }
     */
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
