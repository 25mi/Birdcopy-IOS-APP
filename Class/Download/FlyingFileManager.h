//
//  FlyingFileManager.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/6/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingFileManager : NSObject

+ (FlyingFileManager*)shareInstance;

//文件位置管理
+ (NSString *) getUserDataDir;
+ (NSString*)  getDownloadsDir;
+ (NSString *) getUserShareDir;
+ (NSString*)  getLessonDir:(NSString*) lessonID;

//监控分享的本地文件夹
- (void) watchDocumentStateNow;
+(void)  setNotBackUp;

@end
