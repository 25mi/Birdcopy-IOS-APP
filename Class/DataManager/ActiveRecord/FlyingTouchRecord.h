//
//  FlyingTouchRecord.h
//  FlyingEnglish
//
//  Created by BE_Air on 2/20/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingTouchRecord : NSObject

@property (nonatomic, strong) NSString *BEUSERID;          //用户ID
@property (nonatomic, strong) NSString *BELESSONID;        //课程ID
@property (nonatomic,assign)   int      BETOUCHTIMES;      //点击次数

- (id)initWithUserID: (NSString *) userID
            LessonID: (NSString *) lessonID
          TouchTimes: (double)     touchTimes;

@end



