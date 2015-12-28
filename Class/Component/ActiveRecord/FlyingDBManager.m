//
//  FlyingDBManager.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/22/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingDBManager.h"

#import "shareDefine.h"
#import "FlyingDownloadManager.h"

#import "FlyingNowLessonDAO.h"
#import "FlyingNowLessonData.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "FlyingItemData.h"
#import "FlyingItemDao.h"
#import "FlyingItemParser.h"

#import "FileHash.h"
#import "FlyingMediaVC.h"
#import "ReaderViewController.h"

#import "NSString+FlyingExtention.h"

@interface FlyingDBManager ()
{
    //loacal DB managemnet
    FMDatabaseQueue *_userDBQueue;
    FMDatabaseQueue *_pubUserDBQueue;
    FMDatabaseQueue *_baseDBQueue;
    FMDatabaseQueue *_pubBaseDBQueue;
    FMDatabaseQueue *_oldDBQueue;
    FMDatabaseQueue *_oldDicDBQueue;
}
@end

@implementation FlyingDBManager

+ (FlyingDBManager*)shareInstance
{
    
    static FlyingDBManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

+ (void) updataDBForLocal
{
    FlyingNowLessonDAO * nowLessonDAO =[[FlyingNowLessonDAO alloc] init];
    
    NSString *openID = [NSString getOpenUDID];
    
    [nowLessonDAO updateDBFromLocal:openID];
    
    //得到本地课程详细信息
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager* mgr = [NSFileManager defaultManager];
    
    //用户目录包含的可读内容
    
    NSArray* contents = [mgr contentsOfDirectoryAtPath:path error:nil];
    
    FlyingLessonDAO * lessonDAO =[[FlyingLessonDAO alloc] init];
    
    for (NSString *fileName in contents) {
        
        @autoreleasepool {
            
            BOOL isMp3 = [NSString checkMp3URL:fileName];
            BOOL isMp4 = [NSString checkMp4URL:fileName];
            BOOL isdoc = [NSString checkDocumentURL:fileName];
            
            if(isMp4
               || [NSString checkOtherVedioURL:fileName]
               || isdoc
               || isMp3){
                
                NSString* filePath = [path stringByAppendingPathComponent:fileName];
                
                //本地文件统一这么处理，最关键是保持和官方lessonID的唯一性。
                NSString * lessonID= [FileHash md5HashOfFileAtPath:filePath];
                
                FlyingLessonData * pubLessondata =[lessonDAO   selectWithLessonID:lessonID];
                
                //如果没有相关纪录
                if (!pubLessondata)
                {
                    NSString* lessontitle =[[filePath lastPathComponent] stringByDeletingPathExtension];
                    
                    NSString * localSrtPath = [lessontitle localSrtURL];
                    NSString * localCoverPath = [lessontitle localCoverURL];
                    
                    UIImage * coverImage=nil;
                    if (isMp3) {
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            coverImage = [FlyingMediaVC thumbnailImageForMp3:[NSURL fileURLWithPath:filePath]];
                            
                            if (coverImage) {
                                
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    else if(isMp4){
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            coverImage = [FlyingMediaVC thumbnailImageForVideo:[NSURL fileURLWithPath:filePath] atTime:10];
                            
                            if (coverImage) {
                                
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    else if(isdoc)
                    {
                        if (![[NSFileManager defaultManager] fileExistsAtPath:localCoverPath]){
                            
                            NSString *phrase=@"";
                            
                            if ( [NSString checkPDFURL:fileName])
                            {
                                coverImage =[ReaderViewController thumbnailImageForPDF:[NSURL fileURLWithPath:filePath]
                                                                            passWord:phrase];
                            }
                            if (coverImage)
                            {
                                [UIImagePNGRepresentation(coverImage) writeToFile:localCoverPath atomically:YES];
                            }
                        }
                    }
                    
                    NSString * contentType = KContentTypeVideo;
                    if(isMp3){
                        
                        contentType = KContentTypeAudio;
                    }
                    else if (isdoc) {
                        
                        contentType = KContentTypeText;
                    }
                    
                    pubLessondata =[[FlyingLessonData alloc] initWithLessonID:lessonID
                                                                   LocalTitle:lessontitle
                                                              LocalContentURL:filePath
                                                                  LocalSubURL:localSrtPath
                                                                LocalCoverURL:localCoverPath
                                                                  ContentType:contentType
                                                                 DownloadType:KDownloadTypeNormal
                                                                          Tag:nil];
                    [lessonDAO insertWithData:pubLessondata];
                    
                }
                
                NSString *openID = [NSString getOpenUDID];
                
                if (![nowLessonDAO selectWithUserID:openID LessonID:lessonID]) {
                    
                    FlyingNowLessonData * data = [[FlyingNowLessonData alloc] initWithUserID:openID
                                                                                    LessonID:lessonID
                                                                                   TimeStamp:0
                                                                                  LocalCover:pubLessondata.localURLOfCover];
                    [nowLessonDAO insertWithData:data];
                }
            }
        }
    }
}

+ (void) updateBaseDic:(NSString *) lessonID
{
    NSString * lessonDir = [FlyingDownloadManager getLessonDir:lessonID];
    
    NSString * fileName = [lessonDir stringByAppendingPathComponent:KLessonDicName];
    
    FlyingItemParser * parser= [FlyingItemParser alloc];
    [parser SetData:[NSData dataWithContentsOfFile:fileName]];
    
    FlyingItemDao * dao= [[FlyingItemDao alloc] init];
    [dao setUserModle:NO];
    parser.completionBlock = ^(NSArray *itemList, NSInteger allRecordCount)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [itemList enumerateObjectsUsingBlock:^(FlyingItemData  *item, NSUInteger idx, BOOL *stop) {
                
                [dao insertWithData:item];
            }];
        });
    };
    
    parser.failureBlock = ^(NSError *error)
    {
        
        NSLog(@"word xml  失败！");
    };
    
    [parser parse];
}


- (FMDatabaseQueue *) shareUserDBQueue
{
    if (!_userDBQueue) {
        
        //dbPath： 数据库路径，在dbDir中。
        NSString *dbPath = [[FlyingDownloadManager getUserDataDir] stringByAppendingPathComponent:KUserDatdbaseFilename];
        
        //如果有直接打开，没有用户纪录文件就从安装文件复制一个用户模板
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dbPath]){
            
            NSString *soureDbpath = [[NSBundle mainBundle] pathForResource:KUserDBResource ofType:KDBType];
            NSError* error=nil;
            [fileManager copyItemAtPath:soureDbpath toPath:dbPath error:&error ];
            if (error!=nil) {
                NSLog(@"%@", error);
                NSLog(@"%@", [error userInfo]);
            }
        }
        
        _userDBQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return _userDBQueue;
}

- (void) closeUserDBQueue
{
    if (_userDBQueue) {
        
        [_userDBQueue close];
        _userDBQueue=nil;
    }
}

- (FMDatabaseQueue *) sharePubUserDBQueue
{
    if (!_pubUserDBQueue) {
        
        //dbPath： 数据库路径，在dbDire中。
        NSString *dbPath = [[FlyingDownloadManager getUserDataDir] stringByAppendingPathComponent:KUserDatdbaseFilename];
        
        //如果有直接打开，没有用户纪录文件就从安装文件复制一个用户模板
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dbPath]){
            
            NSString *soureDbpath = [[NSBundle mainBundle] pathForResource:KUserDBResource ofType:KDBType];
            NSError* error=nil;
            [fileManager copyItemAtPath:soureDbpath toPath:dbPath error:&error ];
            if (error!=nil) {
                NSLog(@"%@", error);
                NSLog(@"%@", [error userInfo]);
            }
        }
        
        _pubUserDBQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return _pubUserDBQueue;
}

- (void) closePubUserDBQueue
{
    if (_pubUserDBQueue) {
        
        [_pubUserDBQueue close];
        _pubUserDBQueue=nil;
    }
}

- (FMDatabaseQueue *) shareBaseDBQueue
{
    if (!_baseDBQueue) {
        
        NSString* path = [FlyingDownloadManager prepareDictionary];
        
        _baseDBQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    
    return _baseDBQueue;
}

- (void) closeBaseDBQueue
{
    if (_baseDBQueue) {
        
        [_baseDBQueue close];
        _baseDBQueue=nil;
    }
}

- (FMDatabaseQueue *) sharePubBaseDBQueue
{
    if (!_pubBaseDBQueue) {
                
        NSString* path = [FlyingDownloadManager prepareDictionary];
        
        _pubBaseDBQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    
    return _pubBaseDBQueue;
}

- (void) closePubBaseDBQueue
{
    if (_pubBaseDBQueue) {
        
        [_pubBaseDBQueue close];
        _pubBaseDBQueue=nil;
    }
}

- (void) closeDBQueue
{
    [self closeBaseDBQueue];
    [self closeUserDBQueue];
    [self closePubBaseDBQueue];
    [self closePubUserDBQueue];
}

@end