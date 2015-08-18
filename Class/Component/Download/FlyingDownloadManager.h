//
//  FlyingDownloadManager.h
//  FlyingEnglish
//
//  Created by BE_Air on 9/8/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlyingDownloader.h"

@interface FlyingDownloadManager : NSObject<FlyingDownloadDelegate>


- (void) startDownloaderForID:(NSString *)lessonID;

- (BOOL) isWaitting:(NSString*) lessonID;

- (void) resumeAllDownloader;
- (void) closeAllDownloader;

- (void) startDownloadShareData;
- (void) closeDownloadShareData;

@end
