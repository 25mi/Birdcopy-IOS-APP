//
//  RCDRCIMDelegateImplementation.h
//  RongCloud
//  实现RCIM的数据源
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

#define RCDDataSource [RCDRCIMDataSource shareInstance]


/**
 *  此类写了一个provider的具体示例，开发者可以根据此类结构实现provider
 *  用户信息和群组信息都要通过回传id请求服务器获取，参考具体实现代码。
 */
@interface RCDRCIMDataSource : NSObject<RCIMUserInfoDataSource>

+(RCDRCIMDataSource *) shareInstance;

/*
 * 当客户端第一次运行时，调用此接口初始化所有用户数据。
 */
- (void)cacheAllData:(void (^)())completion;
/*
 * 获取所有用户信息
 */
- (NSArray *)getAllUserInfo:(void (^)())completion;
/*
 * 获取所有群组信息
 */
- (NSArray *)getAllGroupInfo:(void (^)())completion;
/*
 * 获取所有好友信息
 */
- (NSArray *)getAllFriends:(void (^)())completion;
@end
