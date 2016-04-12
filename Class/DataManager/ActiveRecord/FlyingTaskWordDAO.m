//
//  FlyingTaskWordDAO.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingTaskWordDAO.h"
#import "FlyingTaskWordData.h"

#import "FMResultSet.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "NSString+FlyingExtention.h"

@implementation FlyingTaskWordDAO

-(NSString *) setTable:(NSString *)sql{
    
    return [NSString stringWithFormat:sql,  @"BE_TASK_WORD"];
}

- (FMDatabaseQueue *)dbQueue
{
    if (!self.workDbQueue) {
        self.workDbQueue = self.userDBQueue;
    }
    return self.workDbQueue;
}

- (id) selectWithUserID: (NSString *) userID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=? ORDER BY BETIME DESC"],userID];
        
        while ([rs next]) {
            
            FlyingTaskWordData *tr =  [[FlyingTaskWordData alloc]
                                       initWithUserID:userID
                                       Word:[rs stringForColumn:@"BEWORD"]
                                       Sentence:[rs stringForColumn:@"BESENTENCEID"]
                                       LessonID:[rs stringForColumn:@"BELESSONID"]
                                       Times:[rs intForColumn:@"BETIME"]];
                                       
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];

   }];
    
    return result;
}

- (id) selectWordsWithUserID: (NSString *) userID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT BEWORD FROM %@  WHERE  BEUSERID=? ORDER BY BETIME DESC"],userID];
        
        while ([rs next]) {
            
            [result addObject:[rs stringForColumn:@"BEWORD"]];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
        
    }];
    
    return result;
}

- (id )  selectWithUserID:(NSString *) userID Word:(NSString *) word
{

    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=? AND BEWORD=?"],userID,word];
        
        while ([rs next]) {
            
            FlyingTaskWordData *tr =  [[FlyingTaskWordData alloc]
                                       initWithUserID:userID
                                       Word:[rs stringForColumn:@"BEWORD"]
                                       Sentence:[rs stringForColumn:@"BESENTENCEID"]
                                       LessonID:[rs stringForColumn:@"BELESSONID"]
                                       Times:[rs intForColumn:@"BETIME"]];
            
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
        
    }];
    
    return result;

}

- (void)  insertWithUesrID:(NSString *) userID
                      Word:(NSString *) word
                Sentence:(NSString *)   sentence
                  LessonID:(NSString *) lessonID;
{
    
    NSArray * array=[self selectWithUserID:userID Word:word];
    
    if (array.count!=0)
    {
        FlyingTaskWordData *tr = [array objectAtIndex:0];
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BEWORD,BESENTENCEID,BELESSONID,BETIME) VALUES (?,?,?,?,?)"],
             userID,
             word,
             sentence,
             lessonID,
              @(tr.BETIMES+3)];
            
            if ([db hadError]) {
                NSLog(@"Err FlyingTaskWordDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }];
    }
    else
    {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BEWORD,BESENTENCEID,BELESSONID,BETIME) VALUES (?,?,?,?,?)"],
             userID,
             word,
             sentence,
             lessonID,
             @(3)];
            
            if ([db hadError]) {
                NSLog(@"Err FlyingTaskWordDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }];
    }
}


- (void) insertWithData:(FlyingTaskWordData *) data
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BEWORD,BESENTENCEID,BELESSONID,BETIME) VALUES (?,?,?,?,?)"],
            data.BEUSERID,
            data.BEWORD,
         data.BESENTENCE,
         data.BELESSONID,
        @(data.BETIMES)];

         if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
   }];
}


- (BOOL) cancelWithUserID: (NSString *) userID
                   WordID:(NSString *) word
{
    __block BOOL success = YES;

    FlyingTaskWordData *tr = [[self selectWithUserID:userID Word:word] objectAtIndex:0];
    
    if (tr)
    {
        if (tr.BETIMES>1 && tr.BETIMES<12)
        {
            [self.dbQueue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BEWORD,BESENTENCEID,BELESSONID,BETIME) VALUES (?,?,?,?,?)"],
                 userID,
                 word,
                 tr.BESENTENCE,
                 tr.BELESSONID,
                 @(tr.BETIMES-1)];
                
                if ([db hadError])
                {
                    NSLog(@"Err FlyingTaskWordDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                    
                    success=false;
                }
            }];
        }
        else
        {
            [self deleteWithUserID:userID WordID:word];
        }
    }
    
    return success;
}


- (BOOL) deleteWithUserID: (NSString *) userID
                   WordID:(NSString *) word
{
    __block BOOL success = YES;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE BEUSERID=? AND BEWORD=?"],
         userID,
         word];
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO:deleteWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            success = NO;
        }
    }];
    
    
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE BEWORD=?"],word];
        
        while ([rs next]) {
            
            FlyingTaskWordData *tr =  [[FlyingTaskWordData alloc]
                                       initWithUserID:userID
                                       Word:[rs stringForColumn:@"BEWORD"]
                                       Sentence:[rs stringForColumn:@"BESENTENCEID"]
                                       LessonID:[rs stringForColumn:@"BELESSONID"]
                                       Times:[rs intForColumn:@"BETIME"]];
            
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: selectWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
        
    }];
    
    if(result.count==0){
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSString picPathForWord:word] error:nil];
    }
    
    return success;
}


- (NSInteger) countWithUserID:(NSString *) userID
{
    __block NSInteger count;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT count(*) as 'count' FROM %@  WHERE  BEUSERID=?"], userID];
        
        while ([rs next]) {
            
            count = [rs intForColumn:@"count"];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: countWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];

    }];
    
    return count;
}


-(BOOL) cleanTaskWithUSerID:(NSString *) userID
{
    __block BOOL success = YES;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE BEUSERID=? AND BETIME=?"],
         userID,
         @(0)];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO:deleteWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            success = NO;
        }
    }];
    
    return success;
}

- (void) updateUserID:(NSString*) newUserID;
{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEUSERID = ?"],newUserID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingTaskWordDAO: updateUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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
