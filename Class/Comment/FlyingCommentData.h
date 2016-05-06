//
//  FlyingCommentData.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingCommentData : NSObject

@property (nonatomic, strong) NSString *openUDID;       //用户ID

@property (nonatomic, strong) NSString *nickName;     //用户昵称
@property (nonatomic, strong) NSString *portraitURL;  //用户头像

@property (nonatomic, strong) NSString *commentTime;  //评论时间

@property (nonatomic, strong) NSString *commentContent; //评论

@property (nonatomic, strong) NSString *contentID;      //课程ID
@property (nonatomic, strong) NSString *contentType;    //课程类型

@end
