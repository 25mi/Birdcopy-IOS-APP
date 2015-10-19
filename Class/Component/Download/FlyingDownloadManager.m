//
//  FlyingDownloadManager.m
//  FlyingEnglish
//
//  Created by BE_Air on 9/8/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingDownloadManager.h"
#import "shareDefine.h"
#import "FlyingDownloader.h"
#import "FlyingNowLessonDAO.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "AFDownloadRequestOperation.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"
#import "UICKeyChainStore.h"
#import "FlyingSoundPlayer.h"
#import "AFHttpTool.h"
#import "SSZipArchive.h"

@interface FlyingDownloadManager ()
{
    NSMutableDictionary * _downloadingOperationList;
    NSMutableSet        * _waittingDownloadJobs;
    AFDownloadRequestOperation  *_dowloadShareDataOperation; //公共字典下载专用
}

@end

@implementation FlyingDownloadManager

- (void) startDownloaderForID:(NSString *)lessonID
{
        
    if (!_downloadingOperationList) {
        
        _downloadingOperationList = [[NSMutableDictionary alloc] initWithCapacity:KMaxDownloadLessonThread];
    }
    
    BOOL newJob=YES;
    
    //正在下载任务队列中没有这个课程的任务，加入等待队列
    NSArray * allDownloadingJobs=[_downloadingOperationList allKeys];
    if (allDownloadingJobs) {
        
        if ([allDownloadingJobs  indexOfObject:lessonID]!=NSNotFound)
        {
            newJob=NO;
        }
    }
    
    if (newJob) {
        
        if (!_waittingDownloadJobs) {
            
            _waittingDownloadJobs = [[NSMutableSet alloc] initWithCapacity:KMaxDownloadLessonThread];
        }
        [_waittingDownloadJobs addObject:lessonID];
    }
    
    if (_downloadingOperationList.count>0) {
        
        FlyingNowLessonDAO * dao = [FlyingNowLessonDAO new];
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
        NSString *openID = keychain[KOPENUDIDKEY];
        
        [_downloadingOperationList enumerateKeysAndObjectsUsingBlock:^(NSString * leesonID, FlyingDownloader * downloader, BOOL *stop) {
            
            if (![dao selectWithUserID:openID LessonID:leesonID]) {
                
                [downloader cancelDownload];
                [_downloadingOperationList removeObjectForKey:lessonID];
                [_waittingDownloadJobs removeObject:lessonID];
            }
        }];
    }
    
    //正在下载任务队列没有可执行任务
    if (_downloadingOperationList.count<KMaxDownloadLessonThread) {
        
        [self pushwaittingJobToWorkList];
    }
}

- (void) pushwaittingJobToWorkList
{
    
    if (!_downloadingOperationList) {
        
        _downloadingOperationList = [[NSMutableDictionary alloc] initWithCapacity:KMaxDownloadLessonThread];
    }
    
    NSString * lessonID = [_waittingDownloadJobs anyObject];
    
    if (lessonID) {
        
        FlyingLessonData *lessonData =  [[[FlyingLessonDAO alloc] init] selectWithLessonID:lessonID];

        double percent=lessonData.BEDLPERCENT;
        
        if (percent==1) {
            
            //移出队列
            [_downloadingOperationList removeObjectForKey:lessonID];
            [_waittingDownloadJobs removeObject:lessonID];
        }
        else{
        
            FlyingDownloader * downloader = [_downloadingOperationList objectForKey:lessonID];
            
            if(!downloader){

                downloader=[[FlyingDownloader alloc] init];
                [downloader  initWithLessonID:lessonID];
                [downloader setDelegate:self];

                //加入执行队列，移出等待队列
                [_downloadingOperationList setObject:downloader forKey:lessonID];
            }
            
            [_waittingDownloadJobs removeObject:lessonID];
            
            [downloader resumeDownload];
        }
    }
}

-(void)  continueDownloadingWork
{
    
    if (!_downloadingOperationList) {
        
        _downloadingOperationList = [[NSMutableDictionary alloc] initWithCapacity:KMaxDownloadLessonThread];
    }
    
    //如果下载任务没有达到最大值，添加新任务，
    if (_downloadingOperationList.count<=KMaxDownloadLessonThread) {
        
        [self pushwaittingJobToWorkList];
    }
    else{
        
        [_downloadingOperationList enumerateKeysAndObjectsUsingBlock:^(NSString * lessonID,  FlyingDownloader * downloader, BOOL *stop) {
            
            [downloader resumeDownload];
        }];
    }
}

- (BOOL) isWaitting:(NSString*) lessonID
{
    
    if (_waittingDownloadJobs) {
        
        return [_waittingDownloadJobs  containsObject:lessonID];
    }
    else{
        
        return  NO;
    }
}


- (void) resumeAllDownloader
{
    
    FlyingLessonDAO * dao=[[FlyingLessonDAO alloc] init];
    NSArray * lessonsBeResumeDownload=[dao selectWithWaittingDownload];
    [lessonsBeResumeDownload enumerateObjectsUsingBlock:^(FlyingLessonData * obj, NSUInteger idx, BOOL *stop) {
        
        if (!_waittingDownloadJobs) {
            
            _waittingDownloadJobs = [[NSMutableSet alloc] initWithCapacity:KMaxDownloadLessonThread];
        }
        [_waittingDownloadJobs addObject:obj.BELESSONID];
    }];
    
    [self continueDownloadingWork];
}

- (void) closeAllDownloader
{
    
    if (_downloadingOperationList.count!=0) {
        
        [_downloadingOperationList enumerateKeysAndObjectsUsingBlock:^(NSString *lessonID,  FlyingDownloader *downloader, BOOL *stop) {
            
            [downloader cancelDownload];
        }];
    }
}


#pragma mark - FlyingDownloadDelegate Related

- (void) closeAndReleaseDownloaderForID:(NSString *)lessonID
{
    
    if (_waittingDownloadJobs) {
        
        [_waittingDownloadJobs removeObject:lessonID];
    }
    
    if (_downloadingOperationList.count!=0) {
        
        FlyingDownloader * downloader = [_downloadingOperationList objectForKey:lessonID];
        
        if (downloader) {
            [downloader cancelDownload];
            [_downloadingOperationList removeObjectForKey:lessonID];
        }
    }
    
    [self continueDownloadingWork];
}

#pragma mark - Publice resource Related

-(void) startDownloadShareData
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everDownloadBaseDictionary"]) {
        
        if (!_dowloadShareDataOperation) {
            
            [AFHttpTool getShareBaseZIP:KBaseDicAllType success:^(id response) {
                NSString * shareBaseURLStr=[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                
                //下载目录如果没有就创建一个
                NSString * downloadDir = [iFlyingAppDelegate getDownloadsDir];
                BOOL isDir = NO;
                NSFileManager *fm = [NSFileManager defaultManager];
                if(!([fm fileExistsAtPath:downloadDir isDirectory:&isDir] && isDir))
                {
                    [fm createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                NSString * baseDir =[downloadDir stringByAppendingPathComponent:kShareBaseDir];
                NSString * shareBaseDicAllFile =[downloadDir stringByAppendingPathComponent:kShareBaseTempFile];
                
                NSString *localURL =shareBaseDicAllFile;
                NSURL *webURL = [NSURL URLWithString:shareBaseURLStr];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
                AFDownloadRequestOperation * operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:localURL shouldResume:YES];
                [operation setShouldOverwrite:YES];
                [operation setDeleteTempFileOnCancel:YES];
                
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    dispatch_async([appDelegate getBackPubQueue], ^{
                                                
                        [SSZipArchive unzipFileAtPath:shareBaseDicAllFile toDestination:baseDir];

                        [fm removeItemAtPath:shareBaseDicAllFile error:nil];
                        
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everDownloadBaseDictionary"];
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    NSLog(@"AFDownloadRequestOperation:%@",error.description);
                }];
                
                [operation start];
                
            } failure:^(NSError *err) {
                //
                NSLog(@"shareBaseZIP:%@",err.description);
                
            }];
        }
        else{
            
            [_dowloadShareDataOperation resume];
        }
    }
}

-(void) closeDownloadShareData
{
    if (_dowloadShareDataOperation) {
        
        [_dowloadShareDataOperation pause];
    }
}


@end
