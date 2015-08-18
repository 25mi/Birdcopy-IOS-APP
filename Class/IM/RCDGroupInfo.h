//
//  RCDGroupInfo.h
//  RCloudMessage
//
//  Created by 杜立召 on 15/3/19.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDGroupInfo : NSObject
/** 群ID */
@property(nonatomic, strong) NSString* groupId;
/** 群名称 */
@property(nonatomic, strong) NSString* groupName;
/** 群头像URL */
@property(nonatomic, strong) NSString* portraitUri;

/** 人数 */
@property(nonatomic, strong) NSString* number;
/** 最大人数 */
@property(nonatomic, strong) NSString* maxNumber;
/** 群简介 */
@property(nonatomic, strong) NSString* introduce;

/** 创建者Id */
@property(nonatomic, strong) NSString* creatorId;
/** 创建日期 */
@property(nonatomic, strong) NSString* creatorTime;
/** 是否加入 */
@property(nonatomic, assign) BOOL  isJoin;


@end
