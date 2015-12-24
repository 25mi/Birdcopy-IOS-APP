//  FlyingDownloader.h
//  FlyingEnglish
//
//  Created by BE_Air on 9/8/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shareDefine.h"

@interface FlyingDownloader : NSObject<UIWebViewDelegate>

@property (nonatomic,strong) id downloader;
@property (nonatomic,strong) NSData *resumeData;

@property (nonatomic,strong) NSString * lessonID;

- (id) initWithLessonID:(NSString *)lessonID;

-(void) resumeDownload;
-(void) cancelDownload;

@end
