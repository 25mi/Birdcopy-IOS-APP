//
//  FlyingDBManager.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/22/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface FlyingDBManager : NSObject

+ (FlyingDBManager*)shareInstance;

//根据本地文件情况更新数据库（离线下载本地问题，以后可以加上缓存文件相关的处理）
+ (void) updataDBForLocal;

+ (void) updateBaseDic:(NSString *) lessonID;

//个人数据库用户管理
- (FMDatabaseQueue *) shareUserDBQueue;

//个人数据库公用管理
- (FMDatabaseQueue *) sharePubUserDBQueue;

//大字典数据库用户管理
- (FMDatabaseQueue *) shareBaseDBQueue;

//大字典数据库公用管理
- (FMDatabaseQueue *) sharePubBaseDBQueue;

- (void) closeDBQueue;

@end