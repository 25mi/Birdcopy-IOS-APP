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
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"
#import "UICKeyChainStore.h"
#import "FlyingSoundPlayer.h"
#import "AFHttpTool.h"
#import "SSZipArchive.h"
#import "AFNetworkReachabilityManager.h"

#import "FlyingDBManager.h"
#import "FlyingFileManager.h"

@interface FlyingDownloadManager ()
{
    NSURLSessionDownloadTask     *_dowloader; //公共字典下载专用
}

@property (nonatomic,strong) NSMutableDictionary *downloadingOperationList;

@end

@implementation FlyingDownloadManager


+ (FlyingDownloadManager*)shareInstance
{
    static FlyingDownloadManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        instance.downloadingOperationList = [NSMutableDictionary new];
    });
    return instance;
}

//////////////////////////////////////////////////////////////
#pragma mark - /课程本身下载管理
//////////////////////////////////////////////////////////////
- (void) startDownloaderForID:(NSString *)lessonID
{
    FlyingLessonData *lessonData =  [[[FlyingLessonDAO alloc] init] selectWithLessonID:lessonID];
    double percent=lessonData.BEDLPERCENT;
    
    if (percent==1) {
        //移出队列
        [_downloadingOperationList removeObjectForKey:lessonID];
    }
    else
    {
        FlyingDownloader * downloader = [_downloadingOperationList objectForKey:lessonID];
        
        if(!downloader){
            
            downloader=[[FlyingDownloader alloc] initWithLessonID:lessonID];
            
            
            [_downloadingOperationList setObject:downloader forKey:lessonID];
        }
        
        [downloader resumeDownload];
        
        [FlyingDownloadManager downloadRelated:[[FlyingLessonDAO new] selectWithLessonID:lessonID]];
    }
}


- (void) resumeAllDownloader
{
    [_downloadingOperationList enumerateKeysAndObjectsUsingBlock:^(NSString * lessonID,  FlyingDownloader * downloader, BOOL *stop) {
        
        [downloader resumeDownload];
    }];
}

- (void) closeAllDownloader
{
    
    if (_downloadingOperationList.count!=0) {
        
        [_downloadingOperationList enumerateKeysAndObjectsUsingBlock:^(NSString *lessonID,  FlyingDownloader *downloader, BOOL *stop) {
            
            [downloader cancelDownload];
            [_downloadingOperationList removeObjectForKey:lessonID];
        }];
    }
}


- (void) closeAndReleaseDownloaderForID:(NSString *)lessonID
{
    if (_downloadingOperationList.count!=0) {
        
        FlyingDownloader * downloader = [_downloadingOperationList objectForKey:lessonID];
        
        if (downloader) {
            [downloader cancelDownload];
            [_downloadingOperationList removeObjectForKey:lessonID];
        }
    }
    
    if (_dowloader) {
        
        [_dowloader cancel];
    }
}


//////////////////////////////////////////////////////////////
#pragma mark 课程相关辅助下载管理
//////////////////////////////////////////////////////////////
+(void) downloadRelated:(FlyingLessonData *) lessonData;
{
    dispatch_queue_t _background_queue =dispatch_queue_create("com.birdengcopy.background.downloadRelated", NULL);
    
    //保存封面图,离线已经不需要保存了
    //[UIImagePNGRepresentation(self.lessonCoverImageView.image) writeToFile:_lessonData.localURLOfCover  atomically:YES];
    
    //缓存字幕
    dispatch_async(_background_queue, ^{
        
        [FlyingDownloadManager getSrtForLessonID:lessonData.BELESSONID Title:lessonData.BETITLE];
    });
    
    //缓存课程字典
    dispatch_async(_background_queue, ^{
        
        [FlyingDownloadManager getDicWithURL:lessonData.BEPROURL LessonID:lessonData.BELESSONID];
    });
    
    //缓存课程辅助资源
    dispatch_async(_background_queue, ^{
        
        [FlyingDownloadManager getRelativeWithURL:lessonData.BERELATIVEURL LessonID:lessonData.BELESSONID];
    });
}


+ (void) getSrtForLessonID: (NSString *) lessonID
                     Title:(NSString *) title
{
    [AFHttpTool lessonResourceType:kResource_Sub
                          lessonID:lessonID
                        contentURL:nil
                             isURL:NO
                           success:^(id response) {
                               //
                               NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                               NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
                               
                               if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                                   
                                   FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
                                   [mylessonDAO setUserModle:NO];
                                   
                                   FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
                                   [response writeToFile:lessonData.localURLOfSub atomically:YES];
                               }
                               
                           } failure:^(NSError *err) {
                               //
                           }];
}

+ (void) getDicWithURL: (NSString *) baseURLStr
              LessonID: (NSString *) lessonID
{
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    [mylessonDAO setUserModle:NO];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
    
    if(lessonData.BEPROURL)
    {
        NSString *localURL = lessonData.localURLOfPro;
        NSURLSessionDownloadTask * downloadTask = [AFHttpTool downloadUrl:baseURLStr destinationPath:localURL progress:nil
                                                                  success:^(id response) {
                                                                      //
                                                                      dispatch_async(dispatch_queue_create("com.birdcopy.background.getDicWithURL", NULL), ^{
                                                                          
                                                                          NSString * outputDir = [FlyingFileManager getLessonDir:lessonID];
                                                                          
                                                                          [SSZipArchive unzipFileAtPath:lessonData.localURLOfPro toDestination:outputDir];
                                                                          
                                                                          
                                                                          //升级课程补丁
                                                                          [FlyingDBManager updateBaseDic:lessonID];
                                                                          
                                                                          [[NSFileManager defaultManager] removeItemAtPath:lessonData.localURLOfPro error:nil];
                                                                          [mylessonDAO updateProURL:nil LessonID:lessonID]; //表示已经缓存
                                                                      });
                                                                      
                                                                  } failure:^(NSError *err) {
                                                                      //
                                                                  }];
        
        [downloadTask resume];
    }
}

+ (void) getRelativeWithURL: (NSString *) relativeURLStr
                   LessonID: (NSString *) lessonID
{
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    [mylessonDAO setUserModle:NO];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
    
    if(lessonData.BERELATIVEURL)
    {
        NSString *localURL = lessonData.localURLOfRelative;
        
        NSURLSessionDownloadTask * downloadTask = [AFHttpTool downloadUrl:relativeURLStr destinationPath:localURL progress:nil
                                                                  success:^(id response) {
                                                                      //
                                                                      dispatch_async(dispatch_queue_create("com.birdcopy.background.relativeURLStr", NULL), ^{
                                                                          
                                                                          NSString * outputDir = [FlyingFileManager getLessonDir:lessonID];
                                                                          
                                                                          [SSZipArchive unzipFileAtPath:lessonData.localURLOfRelative toDestination:outputDir];
                                                                          
                                                                          [[NSFileManager defaultManager] removeItemAtPath:lessonData.localURLOfRelative error:nil];
                                                                          [mylessonDAO updateRelativeURL:nil LessonID:lessonID]; //表示已经缓存
                                                                      });
                                                                      
                                                                  } failure:^(NSError *err) {
                                                                      //
                                                                  }];
        
        [downloadTask resume];
    }
    
    if ( [lessonData.BECONTENTTYPE isEqualToString:KContentTypeText] &&
        lessonData.BEOFFICIAL)
    {
        NSString *localPath = [FlyingFileManager getLessonDir:lessonID];
        NSString  *fileName =kResource_Background_filenmae;
        
        NSString *filePath = [localPath stringByAppendingPathComponent:fileName];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if(![fm fileExistsAtPath:filePath])
        {
            [AFHttpTool lessonResourceType:kResource_Background
                                  lessonID:lessonID
                                contentURL:nil
                                     isURL:YES
                                   success:^(id response) {
                                       //
                                       NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                       NSData * audioData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tempStr]];
                                       //将数据保存到本地指定位置
                                       [audioData writeToFile:filePath atomically:YES];
                                       
                                   } failure:^(NSError *err) {
                                       //
                                   }];
        }
    }
}

+ (void) getDicForLessonID: (NSString *) lessonID   Title:(NSString *) title
{
    [AFHttpTool lessonResourceType:kResource_Pro
                          lessonID:lessonID
                        contentURL:nil
                             isURL:YES
                           success:^(id response) {
                               //
                               NSString * baseURLStr=[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                               [FlyingDownloadManager getDicWithURL:baseURLStr LessonID:lessonID];
                               
                           } failure:^(NSError *err) {
                               //
                           }];
}

//////////////////////////////////////////////////////////////
#pragma mark 公共资源文件管理
//////////////////////////////////////////////////////////////

-(void) startDownloadShareData
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everDownloadBaseDictionary"]) {
        
        if (!_dowloader) {
            
            [AFHttpTool getShareBaseZIP:KBaseDicAllType success:^(id response) {
                NSString * shareBaseURLStr=[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                
                //下载目录如果没有就创建一个
                NSString * downloadDir = [FlyingFileManager getDownloadsDir];
                BOOL isDir = NO;
                NSFileManager *fm = [NSFileManager defaultManager];
                if(!([fm fileExistsAtPath:downloadDir isDirectory:&isDir] && isDir))
                {
                    [fm createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
                }
                
                NSString * baseDir =[downloadDir stringByAppendingPathComponent:kShareBaseDir];
                NSString * shareBaseDicAllFile =[downloadDir stringByAppendingPathComponent:kShareBaseTempFile];
                
                NSString *localURL =shareBaseDicAllFile;
                
                _dowloader=[AFHttpTool downloadUrl:shareBaseURLStr
                        destinationPath:localURL
                               progress:^(NSProgress *downloadProgress) {
                                   //
                               }
                                success:^(id response) {
                                    //
                                    dispatch_async(dispatch_queue_create("com.birdcopy.background.processing", NULL), ^{
                                        
                                        [SSZipArchive unzipFileAtPath:shareBaseDicAllFile toDestination:baseDir];
                                        
                                        [fm removeItemAtPath:shareBaseDicAllFile error:nil];
                                        
                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everDownloadBaseDictionary"];
                                    });

                                } failure:^(NSError *err) {
                                    //
                                    NSLog(@"downloadUrl:%@",err.description);
                                }];
                
            } failure:^(NSError *err) {
                //
                NSLog(@"shareBaseZIP:%@",err.description);
                
            }];
        }
        else{
            
            [_dowloader resume];
        }
    }
}

-(void) closeDownloadShareData
{
    if (_dowloader) {
        
        [_dowloader cancel];
    }
}

- (void) downloadDataIfpossible
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // -- Reachable -- //
                if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
                    
                    [self resumeAllDownloader];
                }
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                
                [[[FlyingLessonDAO alloc] init] updateDowloadStateOffine];
                
                break;
            default:
                // -- Not reachable -- //
                NSLog(@"Not Reachable");
                break;
        }
        
    }];
}


@end
