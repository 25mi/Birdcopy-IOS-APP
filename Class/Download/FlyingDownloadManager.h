//
//  FlyingDownloadManager.h
//  FlyingEnglish
//
//  Created by BE_Air on 9/8/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlyingPubLessonData.h"
#import "AFNetworking.h"

@interface FlyingDownloadManager : NSObject

+ (FlyingDownloadManager*)shareInstance;

- (AFURLSessionManager*) getAFURLSessionManager;
- (dispatch_queue_t) getBackgroudQueue;

//课程本身下载管理
- (void) startDownloaderForID:(NSString *)lessonID;
- (void) closeAndReleaseDownloaderForID:(NSString *)lessonID;
- (void) resumeAllDownloader;
- (void) closeAllDownloader;

//课程相关辅助下载管理
+ (void) downloadRelated:(FlyingLessonData *) lessonData;
+ (void) getSrtForLessonID: (NSString *) lessonID Title:(NSString *) title;
+ (void) getDicForLessonID: (NSString *) lessonID   Title:(NSString *) title;
+ (void) getRelativeForLessonID:  (NSString *) lessonID   Title:(NSString *) title;

//公共资源文件管理
- (void) startDownloadShareData;
- (void) closeDownloadShareData;

//下载没有完成的任务
- (void) downloadDataIfpossible;


@end
