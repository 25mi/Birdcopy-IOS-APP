//
//  FlyingTouchDAO.h
//  FlyingEnglish
//
//  Created by BE_Air on 2/20/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"

@class FlyingTouchRecord;

@interface FlyingTouchDAO : FlyingBaseDao

- (BOOL) tableExists;

- (BOOL) creatTouchTable;

- (id) selectWithUserID: (NSString *) userID;

- (FlyingTouchRecord *) selectWithUserID: (NSString *) userID
                                LessonID:(NSString*) lessonID;

- (void) countPlusWithUserID:(NSString *) userID
                     LessonID: (NSString *) lessonID;

- (void) plusTouchTime:(NSInteger) tochTimes
        WithUserID:(NSString *) userID
        LessonID: (NSString *) lessonID;

- (NSInteger) touchTimesWithUserID:(NSString *) userID
                         LessonID: (NSString *) lessonID;

- (void)  initDataForUserID: (NSString *) userID
                   LessonID:(NSString*) lessonID;

- (void)  insertDataForUserID: (NSString *) userID
                   LessonID:(NSString*) lessonID
                   touchTimes:(NSInteger) tochTimes;

-(void)  clearAll;

@end
