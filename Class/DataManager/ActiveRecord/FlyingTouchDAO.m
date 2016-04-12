//
//  FlyingTouchDAO.m
//  FlyingEnglish
//
//  Created by BE_Air on 2/20/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingTouchDAO.h"
#import "FlyingTouchRecord.h"

#import "FMResultSet.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

#import "UICKeyChainStore.h"
#import "shareDefine.h"

@implementation FlyingTouchDAO


-(NSString *) setTable:(NSString *)sql{
    
    return [NSString stringWithFormat:sql,  @"BE_TOUCH_RECORD"];
}


- (FMDatabaseQueue *)dbQueue
{
    //默认是用户模式
    if (!self.workDbQueue) {
        self.workDbQueue = self.userDBQueue;
    }
    return self.workDbQueue;
}

- (id) selectWithUserID: (NSString *) userID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=?"],userID];
        
        while ([rs next]) {
            
            FlyingTouchRecord *tr =  [[FlyingTouchRecord alloc]
                                      initWithUserID:userID
                                      LessonID:[rs stringForColumn:@"BELESSONID"]
                                      TouchTimes:[rs intForColumn:@"BETOUCHTIMES"]];
            
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
        
    }];
    
    if (result.count==0) {
        return nil;
    }
    else{
        return result;
    }
}


- (FlyingTouchRecord *) selectWithUserID: (NSString *) userID
                                LessonID:(NSString*) lessonID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=? AND BELESSONID=?"],userID,lessonID];
        
        while ([rs next]) {
            
            FlyingTouchRecord *tr =  [[FlyingTouchRecord alloc]
                                        initWithUserID:userID
                                      LessonID:lessonID
                                      TouchTimes:[rs intForColumn:@"BETOUCHTIMES"]];
                                        
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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


- (BOOL) tableExists
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if ([db tableExists:@"BE_TOUCH_RECORD"])
        {
            success = YES;
        }
        else{
            
            if ([db hadError]) {
                NSLog(@"Err FlyingTouchDAO: hasQRBuy %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
            success = NO;
        }
    }];
    
    return success;
}


- (BOOL) creatTouchTable
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"CREATE TABLE BE_TOUCH_RECORD (BEUSERID VARCHAR(32) NOT NULL ,BELESSONID VARCHAR(32) NOT NULL ,BETOUCHTIMES INTEGER DEFAULT (0) ,BETIMESTAMP VARCHAR(50), PRIMARY KEY (BEUSERID,BELESSONID) )"];
        
        if ([db hadError]) {
            
            NSLog(@"Err FlyingTouchDAO: creatTouchTable %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}

- (void) countPlusWithUserID:(NSString *) userID
                         LessonID: (NSString *) lessonID;
{

    [self plusTouchTime:1
             WithUserID:userID
               LessonID:lessonID];
}
- (void) plusTouchTime:(NSInteger) tochTimes
            WithUserID:(NSString *) userID
              LessonID:(NSString *) lessonID
{

    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BETOUCHTIMES FROM %@  WHERE BEUSERID=? AND BELESSONID=?"],
                  userID,
                  lessonID];
        
        result+=tochTimes;
        
        [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BELESSONID,BETOUCHTIMES) VALUES (?,?,?)"],
         userID,
         lessonID,
         @(result)];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: updateUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (NSInteger) touchTimesWithUserID:(NSString *) userID
                          LessonID: (NSString *) lessonID
{

    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BETOUCHTIMES FROM %@  WHERE BEUSERID=? AND BELESSONID=?"],
                  userID,
                  lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: updateUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    
    return result;
}

- (void)  initDataForUserID: (NSString *) userID
                   LessonID:(NSString*) lessonID
{
    if (![self selectWithUserID:userID LessonID:lessonID]) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BELESSONID,BETOUCHTIMES) VALUES (?,?,?)"],
             userID,
             lessonID,
             [NSNumber numberWithInt:0]];
            
            if ([db hadError]) {
                NSLog(@"Err creatTouchTable: initDataForUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }];
    }
}

- (void)  insertDataForUserID: (NSString *) userID
                     LessonID:(NSString*) lessonID
                   touchTimes:(NSInteger) tochTimes
{

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BELESSONID,BETOUCHTIMES) VALUES (?,?,?)"],
         userID,
         lessonID,
         @(tochTimes)];
        
        if ([db hadError]) {
            NSLog(@"Err creatTouchTable: initDataForUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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
