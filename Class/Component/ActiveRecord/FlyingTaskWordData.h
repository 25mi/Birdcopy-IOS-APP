//
//  FlyingTaskWordData.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingTaskWordData : NSObject

@property   (nonatomic, strong) NSString *BEUSERID;        //用户ID
@property   (nonatomic, strong) NSString *BEWORD;          //词条ID
@property   (nonatomic, strong) NSString *BESENTENCE;      //最新的句子
@property   (nonatomic, strong) NSString *BELESSONID;      //最新的课程ID
@property   (nonatomic, assign) int       BETIMES;         //学习次数

- (id) initWithUserID:(NSString *)     userID
                 Word:(NSString*)      word
                Sentence:(NSString *)  sentence
             LessonID:(NSString*)      lessonID
                 Times:(int)           times;
@end
