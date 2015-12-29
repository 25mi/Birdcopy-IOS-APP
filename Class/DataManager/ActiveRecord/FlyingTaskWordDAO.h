//
//  FlyingTaskWordDAO.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"

@class FlyingTaskWordData;

@interface FlyingTaskWordDAO : FlyingBaseDao

- (id )  selectWithUserID:(NSString *) userID;
- (id)   selectWordsWithUserID: (NSString *) userID;
- (id )  selectWithUserID:(NSString *) userID Word:(NSString *) word;

- (void)  insertWithUesrID:(NSString *) userID
                    Word:(NSString *) word
              Sentence:(NSString *) sentence
                LessonID:(NSString *) lessonID;

- (void) insertWithData:(FlyingTaskWordData *) data;

- (BOOL) cancelWithUserID: (NSString *) userID
                   WordID:(NSString *) word;

- (NSInteger) countWithUserID:(NSString *) userID;
- (void)      updateUserID:(NSString*) newUserID;

- (BOOL)       cleanTaskWithUSerID:(NSString *) userID;

-(void)  clearAll;

@end
