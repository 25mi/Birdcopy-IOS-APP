//
//  FlyingCoverData.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/7/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingCoverData : NSObject

@property (nonatomic, strong) NSString *tagString;     //Tag
@property (nonatomic, strong) NSString *tagtype;       //类型
@property (nonatomic, strong) NSString *desc;          //课程描述

@property (nonatomic, strong) NSString *imageURL;      //封面图
@property (nonatomic, assign) NSInteger count;         //数目数
@property (nonatomic, strong) NSString  *author;       //作者


@end
