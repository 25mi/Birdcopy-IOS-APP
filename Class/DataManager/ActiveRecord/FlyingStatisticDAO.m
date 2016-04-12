//
//  FlyingStatisticDAO.m
//  FlyingEnglish
//
//  Created by vincent sung on 3/4/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingStatisticDAO.h"
#import "FMResultSet.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

#import "FlyingStatisticData.h"
#import "shareDefine.h"

@implementation FlyingStatisticDAO

-(NSString *)setTable:(NSString *)sql
{
    
    return [NSString stringWithFormat:sql,  @"BE_STATISTIC"];
}

- (FMDatabaseQueue *)dbQueue
{
    //默认是用户模式
    if (!self.workDbQueue) {
        self.workDbQueue = self.userDBQueue;
    }
    return self.workDbQueue;
}

- (NSInteger)  timesWithUserID:  (NSString *) userID
{
    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BETIMES FROM %@  WHERE BEUSERID=?"],userID];
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: timesWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return result;
}

- (void)       updateWithUserID: (NSString *) userID
                          Times: (NSInteger)  times
{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BETIMES = ? WHERE BEUSERID = ?"],
         @(times),
         userID];
        
        if ([db hadError]) {
            NSLog(@"Err updateWithUserID:Times %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (NSInteger)  appleMoneyWithUserID:  (NSString *) userID
{
    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BEMONEYCOUNT FROM %@  WHERE BEUSERID=?"],userID];
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: moneyWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return result;
}

- (void)       updateWithUserID: (NSString *) userID
                AppleMoneyCount: (NSInteger)  moneyCount
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEMONEYCOUNT = ? WHERE BEUSERID = ?"],
         @(moneyCount),
         userID];

        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: updateWithUserID:MoneyCount %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (NSInteger)  qrMoneyWithUserID:  (NSString *) userID
{
    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BEQRCOUNT FROM %@  WHERE BEUSERID=?"],userID];
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: qrMoneyWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return result;
}

- (void)       updateWithUserID: (NSString *) userID
                   QRMoneyCount:(NSInteger) qrMoneyCount
{
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEQRCOUNT = ? WHERE BEUSERID = ?"],
         @(qrMoneyCount),
         userID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: qrMoneyWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}


- (NSInteger)  touchCountWithUserID:  (NSString *) userID
{
    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BETOUCHCOUNT FROM %@  WHERE BEUSERID=?"],userID];
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: touchCountWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return result;
}

- (void)       updateWithUserID: (NSString *) userID
                     TouchCount:(NSInteger) touchCount
{

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BETOUCHCOUNT = ? WHERE BEUSERID = ?"],
         @(touchCount),
         userID];

        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: updateWithUserID:touchCount %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (NSInteger)  giftCountWithUserID:  (NSString *) userID
{
    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BEGIFTCOUNT FROM %@  WHERE BEUSERID=?"],userID];
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: giftCountWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return result;

}

- (void)       updateWithUserID: (NSString *) userID
                      GiftCount:(NSInteger) giftCount
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEGIFTCOUNT = ? WHERE BEUSERID = ?"],
         @(giftCount),
         userID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: updateWithUserID:GiftCount %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (id) selectAll
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@"]];
        
        while ([rs next]) {
            
            FlyingStatisticData *tr =  [[FlyingStatisticData alloc]
                                        initWithUserID:[rs stringForColumn:@"BEUSERID"]
                                        MoneyCount:  [rs intForColumn:@"BEMONEYCOUNT"]
                                        TouchCount:  [rs intForColumn:@"BETOUCHCOUNT"]
                                        LearnedTimes:[rs intForColumn:@"BETIMES"]
                                        GiftCount:   [rs intForColumn:@"BEGIFTCOUNT"]
                                        QRCount:     [rs intForColumn:@"BEQRCOUNT"]
                                        TimeStamp:   [rs stringForColumn:@"BETIMESTAMP"]];
            
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

- (FlyingStatisticData *) selectWithUserID: (NSString *) userID
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE  BEUSERID=?"],userID];
        
        while ([rs next]) {
            
            FlyingStatisticData *tr =  [[FlyingStatisticData alloc]
                                        initWithUserID:[rs stringForColumn:@"BEUSERID"]
                                        MoneyCount:  [rs intForColumn:@"BEMONEYCOUNT"]
                                        TouchCount:  [rs intForColumn:@"BETOUCHCOUNT"]
                                        LearnedTimes:[rs intForColumn:@"BETIMES"]
                                        GiftCount:   [rs intForColumn:@"BEGIFTCOUNT"]
                                        QRCount:     [rs intForColumn:@"BEQRCOUNT"]
                                        TimeStamp:   [rs stringForColumn:@"BETIMESTAMP"]];
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

- (void)  initDataForUserID: (NSString *) userID
{
    if (![self selectWithUserID:userID]) {
        
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID) VALUES (?)"],userID];
            
            if ([db hadError]) {
                NSLog(@"Err FlyingStatisticDAO: updateWithUserID:touchCount %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
        }];
    }
}

- (void) insertWithData: (FlyingStatisticData *)   data
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BEUSERID,BEMONEYCOUNT,BETOUCHCOUNT,BEGIFTCOUNT,BETIMES,BEQRCOUNT,BETIMESTAMP) VALUES (?,?,?,?,?,?,?)"],
         data.BEUSERID,
         @(data.BEMONEYCOUNT),
         @(data.BETOUCHCOUNT),
         @(data.BEGIFTCOUNT),
         @(data.BETIMES),
         @(data.BEQRCOUNT),
         data.BETIMESTAMP];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingStaticDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (NSInteger)  totalBuyMoneyWithUserID:  (NSString *) userID
{

    __block NSInteger result=0;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        result = [db intForQuery:[self setTable:@"SELECT BEQRCOUNT FROM %@  WHERE BEUSERID=?"],userID];
        
        result +=[db intForQuery:[self setTable:@"SELECT BEMONEYCOUNT FROM %@  WHERE BEUSERID=?"],userID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: touchCountWithUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return result;

}

- (NSInteger)  finalMoneyWithUserID:  (NSString *) userID
{
    
    FlyingStatisticData * data = [self selectWithUserID:userID];
    
    NSInteger balanceCoin =0;
    
    if(data){
        
        balanceCoin = (KBEFreeTouchCount+data.BEQRCOUNT+data.BEMONEYCOUNT+data.BEGIFTCOUNT) - data.BETOUCHCOUNT;
    }
    
    return balanceCoin;
}

- (BOOL) hasQRCount
{
    __block BOOL success;

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if ([db columnExists:@"BEQRCOUNT" inTableWithName:@"BE_STATISTIC"])
        {
            if ([db hadError]) {
                NSLog(@"Err FlyingStaticDAO: hasQRBuy %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }

            success = YES;
        }
        else{
            
            if ([db hadError]) {
                NSLog(@"Err FlyingStaticDAO: hasQRBuy %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }

            success = NO;
        }
    }];
    
    return success;
}

- (BOOL) insertQRCount
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"ALTER TABLE BE_STATISTIC ADD COLUMN BEQRCOUNT INTEGER NOT NULL DEFAULT 0"];

        if ([db hadError]) {
        
            NSLog(@"Err FlyingStaticDAO: insertQRCount %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}


- (BOOL) insertTimeStamp
{
    __block BOOL success;

    [self.dbQueue inDatabase:^(FMDatabase *db) {

        success = [db executeUpdate:@"ALTER TABLE BE_STATISTIC ADD COLUMN BETIMESTAMP VARCHAR(50) NOT NULL  DEFAULT 0"];
        
        if ([db hadError]) {

            NSLog(@"Err FlyingStaticDAO: insertTimeStamp %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}

- (void) updateUserID:(NSString*) newUserID;
{

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEUSERID = ?"],newUserID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingStatisticDAO: updateUserID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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
