//
//  FlyingGroupData.h
//  FlyingEnglish
//
//  Created by vincent on 9/10/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingGroupData : NSObject<NSCoding>

@property (nonatomic, strong) NSString *gp_id;         //群组id
@property (nonatomic, strong) NSString *gp_name;       //群组名称

@property (nonatomic, strong) NSString *gp_owner;      //群组属主
@property (nonatomic, strong) NSString *gp_author;     //群组作者

@property (nonatomic, strong) NSString *gp_desc;       //群组描述

@property (nonatomic, strong) NSString *logo;          //群组logo图片的url
@property (nonatomic, strong) NSString *cover;          //群组封面图片的url

@property (nonatomic, assign) BOOL      is_audit_join; //申请加入群组是否需要审核[1:是 0:否]
@property (nonatomic, assign) BOOL      is_rc_gp;      //是否已开通融云对应群组[1:是 0:否 null:空]"
@property (nonatomic, assign) BOOL      is_audit_rcgp; //申请加入融云对应群组是否需要审核[1:是 0:否]
@property (nonatomic, assign) BOOL      owner_recom;   //属主是否已推荐[1:是 0:否 null:空]
@property (nonatomic, assign) BOOL      sys_recom;     //系统是否已推荐[1:是 0:否 null:空]

@property (nonatomic, assign) BOOL      is_public_access;       //公开群[1:是 0:否 null:空]


@property (nonatomic, strong) NSString *gp_member_sum; //成员数
@property (nonatomic, strong) NSString *gp_ln_sum;     //课程数

-(void)encodeWithCoder:(NSCoder *)encoder;
-(id) initWithCoder:(NSCoder *)decoder;

- (BOOL) isEqual:(id)object;


@end
