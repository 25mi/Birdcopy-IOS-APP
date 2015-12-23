//
//  FlyingDownloadManager.h
//  FlyingEnglish
//
//  Created by BE_Air on 9/8/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHWDirectoryWatcher.h"
#import "FlyingPubLessonData.h"

@interface FlyingDownloadManager : NSObject

+ (FlyingDownloadManager*)shareInstance;

+ (NSString *) getUserDataDir;
+ (NSString*)  getDownloadsDir;
+ (NSString*)  getLessonDir:(NSString*) lessonID;

// 准备英文字典
+ (NSString *)prepareDictionary;

+(void) downloadRelated:(FlyingLessonData *) lessonData;

+ (void) getSrtForLessonID: (NSString *) lessonID
                     Title:(NSString *) title;

+ (void) getDicWithURL: (NSString *) baseURLStr
              LessonID: (NSString *) lessonID;

+ (void) getRelativeWithURL: (NSString *) relativeURLStr
                   LessonID: (NSString *) lessonID;


+ (void) getDicForLessonID: (NSString *) lessonID   Title:(NSString *) title;


//监控分享的本地文件夹
- (void) watchDocumentStateNow;
+(void)  setNotBackUp;

- (void) startDownloaderForID:(NSString *)lessonID;

- (void) closeAndReleaseDownloaderForID:(NSString *)lessonID;

- (void) resumeAllDownloader;
- (void) closeAllDownloader;

- (void) startDownloadShareData;
- (void) closeDownloadShareData;

//下载没有完成的任务
- (void) downloadDataIfpossible;


@end
