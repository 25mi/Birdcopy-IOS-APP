//
//  FlyingNowLessonData.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlyingLessonData;

@interface FlyingNowLessonData : NSObject

@property (nonatomic, strong) NSString *BEUSERID;         //用户ID
@property (nonatomic, strong) NSString *BELOCALCOVER;     //学习结束时的屏幕快照

@property (nonatomic, strong) NSString *BELESSONID;       //课程ID
@property (nonatomic, assign)   double  BESTAMP;          //学习时间戳

@property (nonatomic,assign)       int  BEORDER;          //学习顺序，替代访问时间

- (id)initWithLessonData:(FlyingLessonData *) lessonData;

- (id)initWithUserID: (NSString *) userID
            LessonID: (NSString *) lessonID
           TimeStamp: (double)     timeStamp
          LocalCover: (NSString *) localCoverURL;

- (double)   learnedPercentage;

@end
