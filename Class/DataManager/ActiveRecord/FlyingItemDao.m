//
//  FlyingItemDao.m
//  FlyingEnglish
//
//  Created by BE_Air on 10/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingItemDao.h"
#import "FlyingItemData.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@implementation FlyingItemDao


- (NSString *)setTable:(NSString *)sql{
    
    return [NSString stringWithFormat:sql,  @"BE_DIC_PUB"];
}

- (FMDatabaseQueue *)dbQueue
{
    if (!self.workDbQueue) {
        self.workDbQueue = self.dicDBQueue;
    }
    return self.workDbQueue;
}

#pragma mark - Base

- (id) selectWithWord: (NSString *) word
{
    __block NSMutableArray *result= [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE BEWORD=?"],word];
        
        while ([rs next]) {
            FlyingItemData *tr = [[FlyingItemData alloc]
                                  
                                  initWithWord:[rs stringForColumn:@"BEWORD"]
                                  Index:[rs intForColumn:@"BEINDEX"]
                                  Entry:[rs stringForColumn:@"BEENTRY"]
                                  Tag:[rs stringForColumn:@"BETAG"]];
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingItemDAO:selectWithID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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

- (id) selectWithWord: (NSString *) word
                index: (NSInteger)        index
{
    __block NSMutableArray *result= [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE BEWORD=? AND BEINDEX=?"],word,@(index)];
        
        while ([rs next]) {
            FlyingItemData *tr = [[FlyingItemData alloc]
                                  
                                  initWithWord:[rs stringForColumn:@"BEWORD"]
                                  Index:[rs intForColumn:@"BEINDEX"]
                                  Entry:[rs stringForColumn:@"BEENTRY"]
                                  Tag:[rs stringForColumn:@"BETAG"]];
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingItemDAO:selectWithID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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

- (void) insertWithData: (FlyingItemData *)   itemData
{
    if (![self selectWithWord:itemData.BEWORD index:(itemData.BEINDEX)]) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEWORD,BEINDEX, BEENTRY,BETAG) VALUES (?,?,?,?)"],
             itemData.BEWORD,
             @(itemData.BEINDEX),
             itemData.BEENTRY,
             itemData.BETAG];
            
            if ([db hadError]) {
                NSLog(@"Err FlyingItemDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }];
    }
 }

@end
