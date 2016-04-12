//
//  RCDataBaseManager.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/6/3.
//  Copyright (c) 2015年 dlz. All rights reserved.
//

#import "RCDataBaseManager.h"
#import "FlyingUserData.h"
#import "FlyingHttpTool.h"
#import "DBHelper.h"

@implementation RCDataBaseManager

static NSString * const userTableName = @"USERTABLE";
static NSString * const groupTableName = @"GROUPTABLE";
static NSString * const friendTableName = @"FRIENDTABLE";

+ (RCDataBaseManager*)shareInstance
{
    static RCDataBaseManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        [instance CreateUserTable];
    });
    return instance;
}

//创建用户存储表
-(void)CreateUserTable
{
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        if (![DBHelper isTableOK: userTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE USERTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_userid ON USERTABLE(userid);";
            
            [db executeUpdate:createIndexSQL];
        }
        if (![DBHelper isTableOK: groupTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_groupid ON GROUPTABLE(userid);";

            [db executeUpdate:createIndexSQL];
        }
        if (![DBHelper isTableOK: friendTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE FRIENDTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_friendId ON FRIENDTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
    }];
}

//存储用户信息
-(void)insertUserToDB:(RCUserInfo*)user
{
    NSString *insertSql = @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,user.userId,user.name,user.portraitUri];
    }];
    
}
//从表中获取用户信息
-(RCUserInfo*) getUserByUserId:(NSString*)userId
{
    __block RCUserInfo *model = nil;
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE where userid = ?",userId];
        while ([rs next]) {
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return model;
}

//从表中获取所有用户信息
-(NSArray *) getAllUserInfo
{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//存储好友信息
-(void)insertFriendToDB:(RCUserInfo *)friend
{
    NSString *insertSql = @"REPLACE INTO FRIENDTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,friend.userId, friend.name, friend.portraitUri];
    }];
    
}

//从表中获取所有好友信息 //RCUserInfo
-(NSArray *) getAllFriends
{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FRIENDTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}
@end
