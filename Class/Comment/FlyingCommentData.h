//
//  FlyingCommentData.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingCommentData : NSObject

@property (nonatomic, strong) NSString *userType;     //用户类型
@property (nonatomic, strong) NSString *userID;       //用户ID

@property (nonatomic, strong) NSString *nickName;     //用户昵称
@property (nonatomic, strong) NSString *portraitURL;  //用户头像

@property (nonatomic, strong) NSString *commentContent; //评论


@end
