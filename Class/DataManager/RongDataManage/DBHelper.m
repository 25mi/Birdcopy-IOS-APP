//
//  DBHelper.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/5/22.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "DBHelper.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import <RongIMKit/RongIMKit.h>
#import "FlyingFileManager.h"

@implementation DBHelper

static FMDatabaseQueue *databaseQueue = nil;

+(FMDatabaseQueue *) getDatabaseQueue
{
    if (!databaseQueue) {
        NSString *documentDirectory = [FlyingFileManager getMyRongCloudDir];
        NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"RongIMDB"];
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return databaseQueue;
}

+ (BOOL) isTableOK:(NSString *)tableName withDB:(FMDatabase *)db
{
    BOOL isOK = NO;
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count)
        {
            isOK =  NO;
        }
        else
        {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}

@end
