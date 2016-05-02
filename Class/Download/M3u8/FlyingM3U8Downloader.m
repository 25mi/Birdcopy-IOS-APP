//
//  FlyingM3U8Downloader.m
//  FlyingEnglish
//
//  Created by BE_Air on 5/27/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingM3U8Downloader.h"
#import "FlyingFileManager.h"
#import "FlyingDownloadManager.h"
#import "shareDefine.h"
#import "FlyingM3U8List.h"
#import "FlyingM3U8Segment.h"
#import "FlyingLessonData.h"
#import "FlyingLessonDAO.h"
#import "NSString+FlyingExtention.h"
#import "FlyingStatisticDAO.h"
#import "UICKeyChainStore.h"
#import "FlyingSoundPlayer.h"
#import "AFHttpTool.h"
#import <AFHTTPSessionManager.h>
#import "FlyingDataManager.h"
#include <stdio.h>
#include <stdint.h>

#define TS_SYNC_BYTE 0x47
#define TS_PACKET_SIZE 188
#define BENotFound  999999999.0

@interface FlyingM3U8Downloader ()
{
    BOOL            _bDownloading;
    NSInteger       _M3u8OrdeID;

    NSString         *_saveTo;
    NSFileHandle     *_fileHandle;
    NSFileHandle     *_fileMp4Handle;

    NSURLSessionDownloadTask *_downloadTask;
    FlyingLessonDAO * _dao;
    FlyingLessonDAO * _tempDAO;
}

@end


@implementation FlyingM3U8Downloader

-(id)initWithM3U8List:(FlyingM3U8List *)list
{
    self = [super init];
    if(self != nil)
    {
        self.playlist = list;
        self.totalprogress = 0.0;
        _bDownloading =NO;
        _M3u8OrdeID=0;
        self.count=0;
        
        _saveTo = [FlyingFileManager getMyLessonDir:self.playlist.lessonID];
        _dao=[[FlyingLessonDAO  alloc] init];
        
        _tempDAO= [[FlyingLessonDAO  alloc] init];
        
        [self addObserver:self forKeyPath:@"freeDownloadSoure" options:0 context:NULL];

        BOOL isDir = NO;
        NSFileManager *fm = [NSFileManager defaultManager];
        if(!([fm fileExistsAtPath:_saveTo isDirectory:&isDir] && isDir))
        {
            [fm createDirectoryAtPath:_saveTo withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }    

    return  self;
}

-(void)startDownloadVideo
{
    
    if(_bDownloading)
    {

        if (_downloadTask) {
            
            [_downloadTask resume];
        }
        else{
            
            [self continueDownload];
        }
    }
    else{
        
        [self continueDownload];
    }
    
    _bDownloading = YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self  continueDownload];
}


-(void) continueDownload
{
    
    @autoreleasepool {

        FlyingM3U8Segment* segment = [self.playlist getOneSegment];
        
        NSString *lessonID=self.playlist.lessonID;
        
        if (segment) {
            
            // M3U8特殊标识符，用时长0表示
            if (segment.duration==0) {
                
                self.count++;
                
                self.totalprogress=_count*1.00/self.playlist.length;
                [_dao updateDowloadPercent:self.totalprogress LessonID:lessonID];
                [_dao updateDowloadState:YES LessonID:lessonID];
                [[NSNotificationCenter defaultCenter] postNotificationName:KlessonStateChange object:nil userInfo:[NSDictionary dictionaryWithObject:lessonID forKey:@"lessonID"]];
                [self continueDownload];
            }
            else{
                
                __weak typeof(self) weakSelf = self;
                __weak typeof(_dao) dao = _dao;

                NSString *webURL = [segment.locationUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString* filename = [NSString stringWithFormat:@"id%@",[@(_M3u8OrdeID) stringValue]];
                NSString *localURL = [[NSString alloc] initWithString:[_saveTo stringByAppendingPathComponent:filename]];
                
               _downloadTask = [AFHttpTool downloadUrl:webURL destinationPath:localURL
                                
                                              progress:^(NSProgress *downloadProgress) {
                                                  //
                                              } success:^(id response) {
                                                  //
                                                  weakSelf.count++;
                                                  
                                                  weakSelf.totalprogress=weakSelf.count*1.00/weakSelf.playlist.length;
                                                  [dao updateDowloadPercent:weakSelf.totalprogress LessonID:lessonID];
                                                  [dao updateDowloadState:YES LessonID:lessonID];
                                                  
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:KlessonStateChange object:nil userInfo:[NSDictionary dictionaryWithObject:lessonID forKey:@"lessonID"]];
                                                  
                                                  //触发下一个下载
                                                  weakSelf.freeDownloadSoure=YES;
                                                  
                                              } failure:^(NSError *err) {
                                                  //
                                                  if( err.code== NSURLErrorNotConnectedToInternet || err.code==  NSURLErrorCannotConnectToHost || err.code== NSURLErrorNetworkConnectionLost){
                                                      
                                                  }
                                                  else{
                                                      
                                                      NSString * type=@"err_url2";
                                                      [weakSelf reportLessonErrorType:type];
                                                  }
                                                  
                                                  [[FlyingDownloadManager shareInstance] closeAndReleaseDownloaderForID:lessonID];
                                              }];
                
                [_downloadTask resume];
                _M3u8OrdeID++;
            }
        }
        else{
            
            FlyingLessonData * lessonData = [_tempDAO  selectWithLessonID:lessonID];
            [self createLocalAndShareM3U8file:![self isOfficialURL:lessonData.BECONTENTURL]];
            
            [_tempDAO updateDowloadPercent:1 LessonID:lessonID];
            [_tempDAO updateDowloadState:YES LessonID:lessonID];

            [[NSNotificationCenter defaultCenter] postNotificationName:KlessonStateChange object:nil userInfo:[NSDictionary dictionaryWithObject:lessonID forKey:@"lessonID"]];
            
            [[FlyingDownloadManager shareInstance] closeAndReleaseDownloaderForID:lessonID];
        }
    }
}

-(void) reportLessonErrorType:(NSString *) type
{
    [AFHttpTool reportLessonErrorType:type
                           contentURL:[[[FlyingLessonDAO alloc] selectWithLessonID:self.playlist.lessonID] BECONTENTURL]
                             lessonID:self.playlist.lessonID
                              success:^(id response) {
                                  //
                                  NSLog(@"reportLessonErrorType suceess!");
                              } failure:^(NSError *err) {
                                  //
                                  NSLog(@"reportLessonErrorType:%@!",err.description);
                              }];
}


-(BOOL) isOfficialURL:(NSString *) contentURL
{
    NSRange textRange;
    NSString * substring= @"birdenglish";
    textRange =[contentURL rangeOfString:substring];
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}


-(void)pauseDownloadVideo
{
    _bDownloading = NO;

    if(_bDownloading)
    {
        if (_downloadTask) {
            //[_operation pause];
        }
    }
}

-(void)cancelDownloadVideo
{
    if(_bDownloading)
    {
        if (_downloadTask) {
            [_downloadTask cancel];
            //[_operation deleteTempFileWithError:nil];
            
            _downloadTask=nil;
        }
    }
    _bDownloading = NO;
    _M3u8OrdeID=0;
    _count=0;
    
    [self removeObserver:self forKeyPath:@"freeDownloadSoure"];
}

- (NSTimeInterval) getTSDuration:(NSString *) tsFileSegement
{
    _fileHandle = [NSFileHandle fileHandleForReadingAtPath:tsFileSegement];
    
    long long fileLength = (long long)[_fileHandle seekToEndOfFile];
    
    int pidCount=(int)(fileLength/TS_PACKET_SIZE);
    double beginTime=BENotFound;
    double endTime=BENotFound;
    double tempTime=BENotFound;
    
    for (int i=0; i<pidCount; i++) {
    
        @autoreleasepool {

            //获取开始时间
            [_fileHandle seekToFileOffset:i*TS_PACKET_SIZE];
            NSData *chunkData = [_fileHandle readDataOfLength:TS_PACKET_SIZE];
            
            tempTime =[self getClock:(unsigned char* )[chunkData  bytes]];

            if (tempTime!=BENotFound) {
                
                beginTime=tempTime;
                i=pidCount;
            }
        }
    }
    for (int i=pidCount-1; i>=0; i--) {
        
        @autoreleasepool {
            
            //获取开始时间
            [_fileHandle seekToFileOffset:i*TS_PACKET_SIZE];
            NSData *chunkData = [_fileHandle readDataOfLength:TS_PACKET_SIZE];
            
            tempTime =[self getClock:(unsigned char* )[chunkData  bytes]];
            
            if (tempTime!=BENotFound) {
                
                endTime=tempTime;
                i=-1;
            }
        }
    }
    
    [_fileHandle closeFile];
    
    return endTime-beginTime;
}

-(double) getClock:(unsigned char* )pkt
{
    
    //unsigned pid = ((pkt[1] & 0x1F) << 8) | pkt[2];
    
    // Sanity check: Make sure we start with the sync byte:
    if (pkt[0] != TS_SYNC_BYTE) {

        return BENotFound;
    }
    
    // If this packet doesn't contain a PCR, then we're not interested in it:
    uint8_t const adaptation_field_control = (pkt[3] & 0x30) >> 4;
    if (adaptation_field_control != 2 && adaptation_field_control != 3) {
        return BENotFound;
    }
    
    // there's no adaptation_field
    uint8_t const adaptation_field_length = pkt[4];
    if (adaptation_field_length == 0) {
        
        return BENotFound;
    }
    
    // no PCR
    uint8_t const pcr_flag = pkt[5] & 0x10;
    if (pcr_flag == 0) {
        
        return BENotFound;
    }
    
    // yes, we get a pcr
    uint32_t pcr_base_high = (pkt[6] << 24) | (pkt[7] << 16) | (pkt[8] << 8)
    | pkt[9];
    // caculate the clock
    double clock = pcr_base_high / 45000.0;
    if ((pkt[10] & 0x80)) {
        
        clock += 1 / 90000.0; // add in low-bit (if set)
    }
    unsigned short pcr_extra = ((pkt[10] & 0x01) << 8) | pkt[11];
    clock += pcr_extra / 27000000.0;
    
    return clock;
}

-(void)  shareMyM3U8
{    
    NSString *uploadfileName     = [self.playlist.lessonID stringByAppendingPathExtension:kLessonVedioLivingType];
    
    NSString *fileName     = self.playlist.lessonID;
    NSString *fullpath     = [_saveTo stringByAppendingPathComponent:fileName];
    NSData   *m3u8Data     = [NSData dataWithContentsOfFile:fullpath];
    
    NSString * typeValue=@"m3u8_i";
    NSString *urlString =[NSString stringWithFormat:@"%@/%@",[FlyingDataManager getServerAddress],KUpdateM3U8FileURL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    //NSDictionary *parameters =@{@"ln_id":self.playlist.lessonID,@"type":typeValue};

    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //
        [formData appendPartWithFileData:m3u8Data name:@"f" fileName:uploadfileName mimeType:@"application/octet-stream"];
        [formData appendPartWithFormData:[self.playlist.lessonID dataUsingEncoding:NSUTF8StringEncoding] name:@"ln_id"];
        [formData appendPartWithFormData:[typeValue dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        FlyingStatisticDAO * statisticDAO = [[FlyingStatisticDAO alloc] init];
        NSString *openID = [FlyingDataManager getOpenUDID];
        NSInteger giftCountNow=[statisticDAO giftCountWithUserID:openID];
        giftCountNow+=10;
        [statisticDAO updateWithUserID:openID GiftCount:giftCountNow];
        
        [FlyingSoundPlayer noticeSound];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
        NSLog(@"Error: %@", error);
    }];
 }

 -(void)createLocalAndShareM3U8file:(BOOL) shareM3U8
 {
     if(self.playlist !=nil)
     {
         //创建下载内容目录
         NSString* contentFileName     = [self.playlist.lessonID stringByAppendingPathExtension:kLessonVedioLivingType];
         NSString *fullpath = [_saveTo stringByAppendingPathComponent:contentFileName];
         
         //创建文件头部
         NSString * head = @"#EXT-X-DISCONTINUITY\n";
         
         NSString * uplaodHead;
         
         NSString* segmentPrefix = [NSString stringWithFormat:@"http://127.0.0.1:12345/%@/",self.playlist.lessonID];
         //填充片段数据
         if (shareM3U8) {
             uplaodHead = [head mutableCopy];
         }
         
         int pidIndex=0;
         NSTimeInterval maxDuration=0;
         
         for(NSInteger i = 0;i< self.playlist.length;i++)
         {
             @autoreleasepool {
                 
                 FlyingM3U8Segment* segInfo = [self.playlist getSegment:i];
                 
                 //M3U8特殊标记符号
                 if (segInfo.duration==0) {
                     
                     head = [NSString stringWithFormat:@"%@%@\n",head,segInfo.locationUrl];
                     
                     if (shareM3U8) {
                         
                         uplaodHead = [NSString stringWithFormat:@"%@%@\n",uplaodHead,segInfo.locationUrl];
                     }
                 }
                 else{
                     
                     NSString* filename = [NSString stringWithFormat:@"id%d",pidIndex];
                     
                     NSString *segmentPath = [_saveTo stringByAppendingPathComponent:filename];
                     
                     NSTimeInterval duration;
                     if (shareM3U8) {
                         
                         duration =[self getTSDuration:segmentPath];
                     }
                     else{
                         
                         duration = segInfo.duration;
                     }
                     
                     if (duration>maxDuration) {
                         
                         maxDuration=duration;
                     }
                     
                     NSString* length = [NSString stringWithFormat:@"#EXTINF:%f,\n",duration];
                     
                     NSString* url = [segmentPrefix stringByAppendingString:filename];
                     
                     head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
                     
                     if (shareM3U8) {
                         url=segInfo.locationUrl;
                         uplaodHead = [NSString stringWithFormat:@"%@%@%@\n",uplaodHead,length,url];
                     }
                     
                     pidIndex++;
                 }
             }
         }
         //创建尾部
         NSString* end = @"#EXT-X-ENDLIST";
         head = [head stringByAppendingString:end];
         if (shareM3U8) {
             
             uplaodHead = [uplaodHead stringByAppendingString:end];
         }
         
         //补充最大时长
         NSInteger targetDuraion=maxDuration+1;
         head=[[NSString stringWithFormat:@"#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:%@\n",[@(targetDuraion) stringValue]] stringByAppendingString:head];
         if (shareM3U8) {
             
             uplaodHead=[[NSString stringWithFormat:@"#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:%@\n",[@(targetDuraion) stringValue]] stringByAppendingString:uplaodHead];
         }
         
         NSMutableData *writer = [[NSMutableData alloc] init];
         [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
         
         BOOL bSucc =[writer writeToFile:fullpath atomically:YES];
         if(bSucc){
             
             NSLog(@"create m3u8file succeed; fullpath:%@, content:%@",fullpath,head);
         }
         else{
             
             NSLog(@"create m3u8file failed");
         }
         
         if (shareM3U8) {
             
             NSData * dataToupload =  [uplaodHead dataUsingEncoding:NSUTF8StringEncoding];
             [dataToupload writeToFile:[fullpath stringByDeletingPathExtension] atomically:YES];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self shareMyM3U8];
             });
         }
     }
 }

@end
