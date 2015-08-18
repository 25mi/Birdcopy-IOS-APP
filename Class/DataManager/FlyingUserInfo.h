//
//  FlyingUserInfo.h
//  FlyingEnglish
//
//  Created by vincent on 6/16/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingUserInfo : NSObject

/** 用户ID */
@property(nonatomic, strong) NSString* userId;
/** 用户名*/
@property(nonatomic, strong) NSString* userName;
/** 头像URL*/
@property(nonatomic, strong) NSString* portraitUri;
/** 名片*/
@property(nonatomic, strong) NSString* nameCard;
/** email*/
@property(nonatomic, strong) NSString* mobileNumber;

@property(nonatomic, strong) NSString* email;

/**  1 好友, 2 请求添加, 3 请求被添加, 4 请求被拒绝, 5 我被对方删除*/
@property(nonatomic, strong) NSString* status;

@end
