//
//  FlyingGroupMemberData.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingGroupMemberData : NSObject

@property (nonatomic, strong) NSString *openUDID;
@property (nonatomic, strong) NSString *ayJoinTime;       //加入申请时间

@property (nonatomic, strong) NSString *ayJoinStatus;     //加入申请状态
@property (nonatomic, strong) NSString *rpJoinDesc;       //未通过加入申请描述

@property (nonatomic, strong) NSString *ayRcgpTime;       //聊天申请时间

@property (nonatomic, strong) NSString *ayRcgpStatus;     //聊天申请状态
@property (nonatomic, strong) NSString *rpRcgpDesc;       //未通过聊天申请描述
@property (nonatomic, assign) BOOL ownerRecom;              //属主是否已推荐
@property (nonatomic, assign) BOOL sysRecom;                //系统是否已推荐

@property(nonatomic, strong)  NSDate     *startDate;        //生效开始时间
@property(nonatomic, strong)  NSDate     *endDate;          //生效结束时间

@property (nonatomic, strong) NSString *token;              //融云token
@property (nonatomic, strong) NSString *name;               //融云用户名称
@property (nonatomic, strong) NSString *portrait_url;       //融云头像文件url

@end
