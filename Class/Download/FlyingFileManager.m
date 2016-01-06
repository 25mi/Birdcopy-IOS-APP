//
//  FlyingFileManager.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/6/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingFileManager.h"
#import "MHWDirectoryWatcher.h"
#import "shareDefine.h"
#import "FlyingDBManager.h"

@interface FlyingFileManager()

@property (nonatomic,strong) NSString            *userDownloadDir;
@property (nonatomic,strong) NSString            *userDataDir;
//本地Document管理
@property (nonatomic,strong) MHWDirectoryWatcher *docWatcher;
@property (nonatomic,strong) dispatch_source_t    source;

@end

@implementation FlyingFileManager


+ (FlyingFileManager*)shareInstance
{
    static FlyingFileManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - 文件位置管理

+ (NSString *) getUserDataDir
{
    if (![FlyingFileManager shareInstance].userDataDir) {
        
        NSString  * libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString  *   dbDir = [libPath stringByAppendingPathComponent:KUSerDataFoldName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = FALSE;
        BOOL isDirExist = [fileManager fileExistsAtPath:dbDir isDirectory:&isDir];
        
        if(!(isDirExist && isDir))
        {
            BOOL bCreateDir = [fileManager createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"Create Directory Failed.");
                
                return nil;
            }
        }
        
        [FlyingFileManager shareInstance].userDataDir=dbDir;
    }
    
    return [FlyingFileManager shareInstance].userDataDir;
}

+ (NSString *) getDownloadsDir
{
    if (![FlyingFileManager shareInstance].userDownloadDir) {
        
        NSString  *   dbDir = [[FlyingFileManager  getUserDataDir]  stringByAppendingPathComponent:KUserDownloadsDir];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = FALSE;
        BOOL isDirExist = [fileManager fileExistsAtPath:dbDir isDirectory:&isDir];
        
        if(!(isDirExist && isDir))
        {
            BOOL bCreateDir = [fileManager createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"Create Directory Failed.");
                
                return nil;
            }
        }
        
        [FlyingFileManager shareInstance].userDownloadDir=dbDir;
    }
    
    return [FlyingFileManager shareInstance].userDownloadDir;
}

+ (NSString*) getLessonDir:(NSString*) lessonID
{
    //创建下载内容目录
    NSString *dbDir = [[FlyingFileManager getDownloadsDir] stringByAppendingPathComponent:lessonID];
    
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(!([fm fileExistsAtPath:dbDir isDirectory:&isDir] && isDir))
    {
        [fm createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return dbDir;
}

//////////////////////////////////////////////////////////////
#pragma mark -监控分享的本地文件夹
//////////////////////////////////////////////////////////////
- (void) watchDocumentStateNow
{
    //开启文件夹监控
    [FlyingDBManager updataDBForLocal];
    
    if (!_docWatcher) {
        
        NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        _docWatcher = [MHWDirectoryWatcher directoryWatcherAtPath:documentDirectory callback:^{
            
            NSLog(@"watchDocumentStateNow");
            
            if (!_source) {
                
                _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
                dispatch_source_set_event_handler(_source, ^{
                    
                    [FlyingDBManager updataDBForLocal];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KDocumentStateChange object:nil];
                });
                dispatch_resume(_source);
            }
            
            dispatch_source_merge_data(_source, 1);
        }];
        
        [_docWatcher startWatching];
    }
}

+(void)setNotBackUp
{
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSURL *url = [NSURL fileURLWithPath:documentDirectory];
    
    [FlyingFileManager addSkipBackupAttributeToItemAtURL:url];
    
    NSString *myDataDir = [FlyingFileManager getUserDataDir];
    url = [NSURL fileURLWithPath:myDataDir];
    
    [FlyingFileManager addSkipBackupAttributeToItemAtURL:url];
}

+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
