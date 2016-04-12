//
//  FlyingNowLessonDAO.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingNowLessonDAO.h"
#import "FlyingNowLessonData.h"

#import "FMResultSet.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"

#import "NSData+NSHash.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"


@interface FlyingNowLessonDAO ()
{
    BOOL  _oldDB;
}
@end


@implementation FlyingNowLessonDAO

-(NSString *) setTable:(NSString *)sql
{
    
    return [NSString stringWithFormat:sql,  @"BE_LOCAl_LESSON"];
}

- (FMDatabaseQueue *)dbQueue
{
    
    //默认是用户模式
    if (!self.workDbQueue) {
        self.workDbQueue = self.userDBQueue;
    }
    return self.workDbQueue;
}

- (void) insertWithData: (FlyingNowLessonData *)   nowLessonData
{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BELESSONID,BESTAMP,BELOCALCOVER,BETIME) VALUES (?,?,?,?,?)"],
         nowLessonData.BEUSERID,
         nowLessonData.BELESSONID,
         [NSNumber numberWithDouble:nowLessonData.BESTAMP],
         nowLessonData.BELOCALCOVER,
         @(nowLessonData.BEORDER)];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}


- (NSMutableArray *) selectWithUserID: (NSString *) userID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs;
        rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=?  ORDER BY BETIME DESC"],userID];
        
        while ([rs next]) {
            
            FlyingNowLessonData *tr =  [[FlyingNowLessonData alloc]
                                        initWithUserID:userID
                                        LessonID:[rs stringForColumn:@"BELESSONID"]
                                        TimeStamp:[rs doubleForColumn:@"BESTAMP"]
                                        LocalCover:[rs stringForColumn:@"BELOCALCOVER"]];
            
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);

        }
        [rs close];

    }];
    
    return result;
}

- (NSMutableArray *) selectIDWithUserID: (NSString *) userID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs;
        rs = [db executeQuery:[self setTable:@"SELECT BELESSONID FROM %@  WHERE  BEUSERID=?  ORDER BY BETIME DESC"],userID];
        
        while ([rs next]) {
            
            [result addObject:[rs stringForColumn:@"BELESSONID"]];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            
        }
        [rs close];
        
    }];
    
    return result;
}


-(NSInteger) countOfLessons:(NSString *) userID
{

    __block NSInteger count=0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT count(BELESSONID) AS number FROM %@  WHERE BEUSERID=?"],userID];
        
        while ([rs next]) {
            
            count +=[rs intForColumn:@"number"];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            
        }
        [rs close];
        
    }];

    return count;
}


- (id) selectWithUserID: (NSString *) userID  LessonID: (NSString *) lessonID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs;
        rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=? AND BELESSONID=?"],
              userID,
              lessonID];
        
        
        while ([rs next]) {
            
            FlyingNowLessonData *tr =  [[FlyingNowLessonData alloc]
                                        initWithUserID:userID
                                        LessonID:lessonID
                                        TimeStamp:[rs doubleForColumn:@"BESTAMP"]
                                        LocalCover:[rs stringForColumn:@"BELOCALCOVER"]];
            
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];

    }];
    
    if (result.count==0) {
        return nil;
    }
    else{
        return [result objectAtIndex:0];
    }
}

- (BOOL) deleteWithUserID: (NSString *) userID  LessonID: (NSString *) lessonID
{
        
    __block BOOL deleteFile = NO;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE BEUSERID=? AND BELESSONID=?"],
         userID,
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO:deleteWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        
        NSString *result = [db stringForQuery:[self setTable:@"SELECT BEUSERID FROM %@  WHERE  BELESSONID=?"],lessonID];
        //如果没有用户实用此课程资源删除之        
        if (!result) {
            
            deleteFile=YES;
        }
    }];
    
    if (deleteFile) {
        [[[FlyingLessonDAO alloc] init] deleteWithLessonID:lessonID];
    }
    
    return deleteFile;
}

//只删除数据库纪录，不涉及课程资源，因为有时候数据纪录错误并不是资源出了问题
- (void) deleteDBWithUserIDOnly: (NSString *) userID  LessonID: (NSString *) lessonID
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE BEUSERID=? AND BELESSONID=?"],
         userID,
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO:deleteDBWithUserIDOnly %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    [[[FlyingLessonDAO alloc] init] deleteDBWithLessonIDOnly:lessonID];
}

- (void) updateDBFromLocal:(NSString *) userID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=?"],userID];
        
        while ([rs next]) {
            
            [result addObject:[rs stringForColumn:@"BELESSONID"]];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            
        }
        [rs close];

    }];
    
    FlyingLessonDAO * pubLessonDAO = [[FlyingLessonDAO alloc] init];
    
    [result enumerateObjectsUsingBlock:^(NSString * lessonID, NSUInteger idx, BOOL *stop) {
        
        BOOL delete=NO;
        
        FlyingLessonData * pubLessonData = [pubLessonDAO selectWithLessonID:lessonID];
        
        if (pubLessonData) {
            
            if (!pubLessonData.BEOFFICIAL) {
                
                //课程内容文件不存在删除
                if (![[NSFileManager defaultManager] fileExistsAtPath:pubLessonData.localURLOfContent]){
                    
                    delete=YES;
                }
            }
        }
        else{
            //没有课程公共纪录删除
            delete=YES;
        }
        
        if (delete) {
            
            [self deleteDBWithUserIDOnly:userID LessonID:lessonID];
            //[self deleteWithUserID:userID LessonID:lessonID];
        }
    }];
}

- (void) updateUserID:(NSString*) newUserID;
{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEUSERID = ?"],newUserID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingNowLessonDAO: updateUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

-(void)  clearAll
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"DELETE FROM %@"]];
        
        if ([db hadError]) {
            NSLog(@"Err clearAll %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}


@end
