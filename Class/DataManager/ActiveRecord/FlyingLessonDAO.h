//
//  FlyingLessonDAO.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"
#import "shareDefine.h"

@class FlyingLessonData;

@interface FlyingLessonDAO : FlyingBaseDao

- (NSMutableArray *) select;

- (id)   selectWithLessonID: (NSString *)lessonID;
- (BOOL) deleteWithLessonID: (NSString *)lessonID;
- (void) deleteDBWithLessonIDOnly:(NSString *)lessonID;

- (void) insertWithData:    (FlyingLessonData *)   pubLessonData;        //创建课程公共信息

- (void) updateDowloadState  :  (BOOL)      downloadState   LessonID:(NSString *) lessonID;
- (void) updateDuration      :  (double)    duration        LessonID:(NSString *) lessonID;
- (void) updateDowloadPercent:  (double)    downloadPercent LessonID:(NSString *) lessonID;
- (void) updateSubURL        :  (NSString*) subURL          LessonID:(NSString *) lessonID;
- (void) updateContentURL    :  (NSString*) contentURL      LessonID:(NSString *) lessonID;
- (void) updateProURL        :  (NSString*) proURL          LessonID:(NSString *) lessonID;
- (void) updateRelativeURL   :  (NSString*) relativeURL     LessonID:(NSString *) lessonID;

- (void) updateDowloadStateOffine;
- (id)   selectWithWaittingDownload;


- (BOOL) insertContentType;
- (BOOL) insertDownloadType;
- (BOOL) insertTag;
- (BOOL) insertOfficeURL;
- (BOOL) insertISBN;

- (BOOL) hasOfficeURL;
- (BOOL) hasISBN;

- (BOOL) hasRelativeURL;
- (BOOL) insertRelativeURL;
-(void)  clearAll;

@end


