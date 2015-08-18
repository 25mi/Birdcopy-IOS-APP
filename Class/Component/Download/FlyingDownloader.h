//  FlyingDownloader.h
//  FlyingEnglish
//
//  Created by BE_Air on 9/8/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shareDefine.h"


@protocol FlyingDownloadDelegate <NSObject>

@optional
- (void)  continueDownloadingWork;
- (void) closeAndReleaseDownloaderForID:(NSString *)lessonID;

@end

@interface FlyingDownloader : NSObject<UIWebViewDelegate>

@property (nonatomic,strong) id downloader;

@property (nonatomic,strong) NSString * lessonID;
@property (nonatomic, weak) id<FlyingDownloadDelegate> delegate;


- (void) initWithLessonID:(NSString *)lessonID;


-(void) resumeDownload;
-(void) cancelDownload;

@end
