//
//  FlyingLessonDAO.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"

#import "FMResultSet.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "iFlyingAppDelegate.h"
#import "ReaderDocument.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@implementation FlyingLessonDAO

-(NSString *) setTable:(NSString *)sql
{
    return [NSString stringWithFormat:sql,  @"BE_PUB_LESSON"];
}

-(void)       setUserModle:(BOOL) userModle;
{
    if ( !userModle) {
        self.workDbQueue = self.pubUserDBQueue;
    }
    else{
        self.workDbQueue = self.userDBQueue;
    }
}

- (FMDatabaseQueue *)dbQueue
{
    //默认是用户模式
    if (!self.workDbQueue) {
        self.workDbQueue = self.userDBQueue;
    }
    return self.workDbQueue;
}

// SELECT
-(NSMutableArray *)select
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@"]];
        
        while ([rs next]) {
            
            FlyingLessonData *tr =  [[FlyingLessonData alloc]
                                     initWithLessonID:[rs stringForColumn:@"BELESSONID"]
                                     Title:           [rs stringForColumn:@"BETITLE"]
                                     DESC:            [rs stringForColumn:@"BEDESC"]
                                     IMageURL:        [rs stringForColumn:@"BEIMAGEURL"]
                                     ContentURL:      [rs stringForColumn:@"BECONTENTURL"]
                                     SubtitleURL:     [rs stringForColumn:@"BESUBURL"]
                                     PronunciationURL:[rs stringForColumn:@"BEPROURL"]
                                     Level:           [rs stringForColumn:@"BELEVEL"]
                                     Duration:        [rs doubleForColumn:@"BEDURATION"]
                                     DownloadPercent: [rs doubleForColumn:@"BEDLPERCENT"]
                                     DownloadSate:    [rs boolForColumn:  @"BEDLSTATE"]
                                     officialFlag:    [rs boolForColumn:  @"BEOFFICIAL"]
                                     ContentType:     [rs stringForColumn:@"BECONTENTTYPE"]
                                     DownloadType:    [rs stringForColumn:@"BEDOWNLOADTYPE"]
                                     Tag:[rs stringForColumn:@"BETAG"]
                                     coinPrice:[rs intForColumn:@"BELESSONS"]
                                     webURL:[rs stringForColumn:@"BEWEBURL"]
                                     ISBN:[rs stringForColumn:@"BEISBN"]
                                     relativeURL:nil];
            
            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: select %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
    }];
    
    return result;
}

- (id)   selectWithLessonID:(NSString *)lessonID;
{
    
    if (!lessonID) {
        
        return nil;
    }
    
    __block NSMutableArray *result= [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE BELESSONID=?"],lessonID];
        
        while ([rs next]) {
            
            FlyingLessonData *tr =  [[FlyingLessonData alloc]
                                     initWithLessonID:[rs stringForColumn:@"BELESSONID"]
                                     Title:           [rs stringForColumn:@"BETITLE"]
                                     DESC:            [rs stringForColumn:@"BEDESC"]
                                     IMageURL:        [rs stringForColumn:@"BEIMAGEURL"]
                                     ContentURL:      [rs stringForColumn:@"BECONTENTURL"]
                                     SubtitleURL:     [rs stringForColumn:@"BESUBURL"]
                                     PronunciationURL:[rs stringForColumn:@"BEPROURL"]
                                     Level:           [rs stringForColumn:@"BELEVEL"]
                                     Duration:        [rs doubleForColumn:@"BEDURATION"]
                                     DownloadPercent: [rs doubleForColumn:@"BEDLPERCENT"]
                                     DownloadSate:    [rs boolForColumn:  @"BEDLSTATE"]
                                     officialFlag:    [rs boolForColumn:  @"BEOFFICIAL"]
                                     ContentType:     [rs stringForColumn:@"BECONTENTTYPE"]
                                     DownloadType:    [rs stringForColumn:@"BEDOWNLOADTYPE"]
                                     Tag:             [rs stringForColumn:@"BETAG"]
                                     coinPrice:       [rs intForColumn:@"BELESSONS"]
                                     webURL:          [rs stringForColumn:@"BEWEBURL"]
                                     ISBN:            [rs stringForColumn:@"BEISBN"]
                                     relativeURL:     [rs stringForColumn:@"BERELATIVEURL"]];

            [result addObject:tr];
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: selectWithLessonID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
    }];
    
    if (result.count!=0) {
        return [result objectAtIndex:0];
    }
    else{
        return nil;
    }
}


- (BOOL) deleteWithLessonID:(NSString *)lessonID;
{
    
    if (!lessonID) {
        
        return YES;
    }
    
    FlyingLessonData * data =[self selectWithLessonID:lessonID];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (data) {
        
        //删除
        NSString *lessonDirectory = [iFlyingAppDelegate  getLessonDir:lessonID];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [fileManager removeItemAtPath:lessonDirectory error:nil];
        });

        if (!data.BEOFFICIAL) {
            
            if ([fileManager fileExistsAtPath:data.localURLOfContent]){
                
                [fileManager removeItemAtPath:data.localURLOfContent error:nil];
            }
            
            if ([fileManager fileExistsAtPath:data.localURLOfSub]){
                
                [fileManager removeItemAtPath:data.localURLOfSub error:nil];
            }
            
            if ([fileManager fileExistsAtPath:data.localURLOfCover]){
                
                [fileManager removeItemAtPath:data.localURLOfCover error:nil];
            }
            
            //删除PDF辅助信息
            [fileManager removeItemAtPath:[ReaderDocument archiveFilePath:data.BETITLE] error:nil];

        }
        else{

            //删除PDF辅助信息
            [fileManager removeItemAtPath:[ReaderDocument archiveFilePath:data.BELESSONID] error:nil];
        }
    }
    
    __block BOOL success = YES;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE BELESSONID=?"],lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: deleteWithLessonID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}


//只删除数据库纪录，不涉及课程资源，因为有时候数据纪录错误并不是资源出了问题
- (void) deleteDBWithLessonIDOnly:(NSString *)lessonID;
{
    
    if (!lessonID) {
        
        return;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:[self setTable:@"DELETE FROM %@ WHERE BELESSONID=?"],lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: deleteWithLessonID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}


- (void) insertWithData: (FlyingLessonData *)   lessonData;        //创建课程公共信息
{
    if (!lessonData) {
        
        return;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
                
        [db executeUpdate:[self setTable:@"REPLACE INTO %@ (BELESSONID,BETITLE,BEDESC,BEIMAGEURL,BECONTENTURL,BESUBURL,BEPROURL,BELEVEL,BEDURATION,BEDLPERCENT,BEDLSTATE,BEOFFICIAL,BECONTENTTYPE,BEDOWNLOADTYPE,BETAG,BELESSONS,BEWEBURL,BEISBN,BERELATIVEURL) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"],
         lessonData.BELESSONID,
         lessonData.BETITLE ,
         lessonData.BEDESC,
         lessonData.BEIMAGEURL,
         lessonData.BECONTENTURL,
         lessonData.BESUBURL,
         lessonData.BEPROURL,
         lessonData.BELEVEL,
         [NSNumber numberWithDouble:lessonData.BEDURATION],
         [NSNumber numberWithDouble:lessonData.BEDLPERCENT],
         [NSNumber numberWithBool:lessonData.BEDLSTATE],
         [NSNumber numberWithBool:lessonData.BEOFFICIAL],
         lessonData.BECONTENTTYPE,
         lessonData.BEDOWNLOADTYPE,
         lessonData.BETAG,
         [NSNumber numberWithInt:lessonData.BECoinPrice],
         lessonData.BEWEBURL,
         lessonData.BEISBN,
         lessonData.BERELATIVEURL];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO:insertWithData %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateDowloadState:(BOOL) downloadState  LessonID:(NSString *) lessonID
{
    
    if (!lessonID) {
        
        return;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEDLSTATE=? WHERE BELESSONID=?"],
         [NSNumber numberWithBool:downloadState],
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateDowloadState %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateDuration:  (double) duration       LessonID:(NSString *) lessonID
{
    
    if (!lessonID) {
        
        return;
    }

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEDURATION=? WHERE BELESSONID=?"],
         [NSNumber numberWithDouble:duration],
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateDowloadState %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateDowloadPercent:  (double) downloadPercent LessonID:(NSString *) lessonID
{
    
    if (!lessonID) {
        
        return;
    }

    BOOL downState =YES;
    
    if(downloadPercent==1){
    
        downState=NO;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEDLPERCENT=? , BEDLSTATE=? WHERE BELESSONID=?"],
         [NSNumber numberWithDouble:downloadPercent],
         [NSNumber numberWithBool:downState],
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateDowloadState %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateSubURL       :  (NSString*) subURL         LessonID:(NSString *) lessonID
{
    if (!lessonID) {
        
        return;
    }

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BESUBURL=? WHERE BELESSONID=?"],
         subURL,
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateDowloadState %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateContentURL    :  (NSString*) contentURL      LessonID:(NSString *) lessonID;
{
    
    if (!lessonID) {
        
        return;
    }

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BECONTENTURL=? WHERE BELESSONID=?"],
         contentURL,
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateDowloadState %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateProURL        :  (NSString*) proURL          LessonID:(NSString *) lessonID
{
    
    if (!lessonID) {
        
        return;
    }

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEPROURL=? WHERE BELESSONID=?"],
         proURL,
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateProURL %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateRelativeURL   :  (NSString*) relativeURL     LessonID:(NSString *) lessonID
{
    
    if (!lessonID) {
        
        return;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BERELATIVEURL=? WHERE BELESSONID=?"],
         relativeURL,
         lessonID];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateRelativeURL %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void) updateDowloadStateOffine
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:[self setTable:@"UPDATE %@ SET BEDLSTATE=?"],
         [NSNumber numberWithBool:NO]];
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: updateDowloadState %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (id)   selectWithWaittingDownload
{
    __block NSMutableArray *result= [[NSMutableArray alloc] initWithCapacity:0];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        //FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE BEDLPERCENT>0 AND BEDLPERCENT<1"]];
        FMResultSet *rs = [db executeQuery:[self setTable:@"SELECT * FROM %@  WHERE BEDLPERCENT<1"]];

        while ([rs next]) {
            
            FlyingLessonData *tr =  [[FlyingLessonData alloc]
                                     initWithLessonID:[rs stringForColumn:@"BELESSONID"]
                                     Title:           [rs stringForColumn:@"BETITLE"]
                                     DESC:            [rs stringForColumn:@"BEDESC"]
                                     IMageURL:        [rs stringForColumn:@"BEIMAGEURL"]
                                     ContentURL:      [rs stringForColumn:@"BECONTENTURL"]
                                     SubtitleURL:     [rs stringForColumn:@"BESUBURL"]
                                     PronunciationURL:[rs stringForColumn:@"BEPROURL"]
                                     Level:           [rs stringForColumn:@"BELEVEL"]
                                     Duration:        [rs doubleForColumn:@"BEDURATION"]
                                     DownloadPercent: [rs doubleForColumn:@"BEDLPERCENT"]
                                     DownloadSate:    [rs boolForColumn:  @"BEDLSTATE"]
                                     officialFlag:    [rs boolForColumn:  @"BEOFFICIAL"]
                                     ContentType:     [rs stringForColumn:@"BECONTENTTYPE"]
                                     DownloadType:    [rs stringForColumn:@"BEDOWNLOADTYPE"]
                                     Tag:             [rs stringForColumn:@"BETAG"]
                                     coinPrice:       [rs intForColumn:@"BELESSONS"]
                                     webURL:          [rs stringForColumn:@"BEWEBURL"]
                                     ISBN:            [rs stringForColumn:@"BEISBN"]
                                     relativeURL:     [rs stringForColumn:@"BERELATIVEURL"]];
            
            if(![tr.BECONTENTTYPE isEqualToString:KContentTypePageWeb]){
                
                [result addObject:tr];
            }
        }
        
        if ([db hadError]) {
            NSLog(@"Err FlyingLessonDAO: selectWithLessonID %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
    }];
    
    return result;
}


- (BOOL) insertContentType
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"ALTER TABLE BE_PUB_LESSON ADD COLUMN BECONTENTTYPE VARCHAR(10)"];
        
        if ([db hadError]) {
            
            NSLog(@"Err FlyingLessonDAO: insertTimeStamp %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}

- (BOOL) insertDownloadType
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"ALTER TABLE BE_PUB_LESSON ADD COLUMN BEDOWNLOADTYPE VARCHAR(10)"];
        
        if ([db hadError]) {
            
            NSLog(@"Err FlyingLessonDAO: insertTimeStamp %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}


- (BOOL) insertTag
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"ALTER TABLE BE_PUB_LESSON ADD COLUMN BETAG VARCHAR(100)"];
        
        if ([db hadError]) {
            
            NSLog(@"Err FlyingLessonDAO: insertTimeStamp %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}

- (BOOL) hasOfficeURL
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if ([db columnExists:@"BEWEBURL" inTableWithName:@"BE_PUB_LESSON"])
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

- (BOOL) insertOfficeURL
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"ALTER TABLE BE_PUB_LESSON ADD COLUMN BEWEBURL VARCHAR(100)"];
        
        if ([db hadError]) {
            
            NSLog(@"Err FlyingLessonDAO: insertOfficeURL %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}


- (BOOL) hasISBN
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if ([db columnExists:@"BEISBN" inTableWithName:@"BE_PUB_LESSON"])
        {
            if ([db hadError]) {
                NSLog(@"Err FlyingLessonDAO: hasISBN %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
            success = YES;
        }
        else{
            
            if ([db hadError]) {
                NSLog(@"Err FlyingLessonDAO: hasISBN %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
            success = NO;
        }
    }];
    
    return success;
}

- (BOOL) insertISBN
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"ALTER TABLE BE_PUB_LESSON ADD COLUMN BEISBN VARCHAR(32)"];
        
        if ([db hadError]) {
            
            NSLog(@"Err FlyingLessonDAO: insertISBN %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
}

- (BOOL) hasRelativeURL
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        if ([db columnExists:@"BERELATIVEURL" inTableWithName:@"BE_PUB_LESSON"])
        {
            if ([db hadError]) {
                NSLog(@"Err FlyingLessonDAO: hasRelativeURL %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
            success = YES;
        }
        else{
            
            if ([db hadError]) {
                NSLog(@"Err FlyingLessonDAO: hasRelativeURL %d: %@", [db lastErrorCode], [db lastErrorMessage]);
            }
            
            success = NO;
        }
    }];
    
    return success;
}

- (BOOL) insertRelativeURL
{
    __block BOOL success;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        
        success = [db executeUpdate:@"ALTER TABLE BE_PUB_LESSON ADD COLUMN BERELATIVEURL VARCHAR(100)"];
        
        if ([db hadError]) {
            
            NSLog(@"Err FlyingLessonDAO: insertRelativeURL %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
    
    return success;
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

