//
//  FlyingNowLessonDAO.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"

@class FlyingNowLessonData;

@interface FlyingNowLessonDAO : FlyingBaseDao

- (void) insertWithData: (FlyingNowLessonData *)   nowLessonData;        //创建课程公共信息

- (NSMutableArray *) selectWithUserID: (NSString *) userID;

- (NSMutableArray *) selectIDWithUserID: (NSString *) userID;

- (NSInteger) countOfLessons:(NSString *) userID;

- (id)   selectWithUserID: (NSString *)userID  LessonID:(NSString *)lessonID;
- (BOOL) deleteWithUserID: (NSString *)userID  LessonID:(NSString *)lessonID;

- (void) updateDBFromLocal:(NSString *) userID;
- (void) updateUserID:(NSString*) newUserID;

-(void)  clearAll;

@end
