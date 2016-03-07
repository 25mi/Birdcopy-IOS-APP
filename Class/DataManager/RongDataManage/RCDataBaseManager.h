//
//  RCDataBaseManager.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/6/3.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>


@interface RCDataBaseManager : NSObject

+ (RCDataBaseManager*)shareInstance;

//存储用户信息
-(void)insertUserToDB:(RCUserInfo*)user;

//从表中获取用户信息
-(RCUserInfo*) getUserByUserId:(NSString*)userId;

//从表中获取所有用户信息
-(NSArray *) getAllUserInfo;

//存储好友信息
-(void)insertFriendToDB:(RCUserInfo *)friend;

//从表中获取所有好友信息 //RCUserInfo
-(NSArray *) getAllFriends;
@end
