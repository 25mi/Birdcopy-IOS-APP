//
//  FlyingM3U8Downloader.h
//  FlyingEnglish
//
//  Created by BE_Air on 5/27/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FlyingM3U8Downloader;

@protocol FlyingM3U8DownloaderDelegate <NSObject>
@optional
-(void)videoDownloaderFinished:(FlyingM3U8Downloader*)request;
-(void)videoDownloaderFailed:(FlyingM3U8Downloader*)request;
@end


@class  FlyingM3U8List;

@interface FlyingM3U8Downloader : NSObject

@property   (strong,nonatomic)     FlyingM3U8List   * playlist;
@property   (assign,nonatomic)     float            totalprogress;
@property   (assign,nonatomic)     NSInteger        count;
@property   (assign,nonatomic)     BOOL             freeDownloadSoure;

-(id)initWithM3U8List:(FlyingM3U8List*)list;

//开始下载
-(void)startDownloadVideo;

//暂停下载
-(void)pauseDownloadVideo;

//取消下载，清除下载的部分文件
-(void)cancelDownloadVideo;

@end
