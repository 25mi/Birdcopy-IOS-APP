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
    NSURLSessionDownloadTask     *_dicDowloader; //公共字典下载专用
}

@property (nonatomic,strong) AFURLSessionManager *manager;
@property (nonatomic,strong) NSMutableDictionary *downloadingOperationList;

@property (nonatomic,strong) dispatch_queue_t     background_queue;

@end

@implementation FlyingDownloadManager


+ (FlyingDownloadManager*)shareInstance
{
    static FlyingDownloadManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        instance.downloadingOperationList = [NSMutableDictionary new];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        instance.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    });
    return instance;
}

- (AFURLSessionManager*) getAFURLSessionManager
{
    if (!self.manager) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    
    return self.manager;
}

- (dispatch_queue_t) getBackgroudQueue
{
    if (!self.background_queue) {
        
        self.background_queue =dispatch_queue_create("com.birdengcopy.background.downloadRelated", NULL);
    }
    
    return self.background_queue;
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
}


//////////////////////////////////////////////////////////////
#pragma mark 课程相关辅助下载管理
//////////////////////////////////////////////////////////////
+(void) downloadRelated:(FlyingLessonData *) lessonData;
{
    
    dispatch_queue_t background_queue =[FlyingDownloadManager shareInstance].getBackgroudQueue;

    //保存封面图,离线已经不需要保存了
    //[UIImagePNGRepresentation(self.lessonCoverImageView.image) writeToFile:_lessonData.localURLOfCover  atomically:YES];
    
    //缓存字幕
    dispatch_async(background_queue, ^{
        
        [FlyingDownloadManager getSrtForLessonID:lessonData.BELESSONID Title:lessonData.BETITLE];
    });
    
    //缓存课程字典
    dispatch_async(background_queue, ^{
        
        [FlyingDownloadManager getDicForLessonID:lessonData.BELESSONID Title:lessonData.BETITLE];
    });
    
    
    //缓存背景音乐
    dispatch_async(background_queue, ^{
        
        [FlyingDownloadManager getBackMp3ForLessonID:lessonData.BELESSONID Title:lessonData.BETITLE];
    });
    
    //缓存课程辅助资源
    dispatch_async(background_queue, ^{
        
        [FlyingDownloadManager getRelativeForLessonID:lessonData.BELESSONID Title:lessonData.BETITLE];
    });
}

+ (void) getSrtForLessonID: (NSString *) lessonID Title:(NSString *) title
{
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
    
    if(lessonData.BESUBURL)
    {
        NSURLSessionDownloadTask * downloadTask = [AFHttpTool downloadUrl:lessonData.BESUBURL destinationPath:lessonData.localURLOfSub progress:nil
                                                                  success:^(id response) {
                                                                      //
                                                                      
                                                                  } failure:^(NSError *err) {
                                                                      //
                                                                  }];
        
        [downloadTask resume];
    }
    
}

+ (void) getDicForLessonID: (NSString *) lessonID   Title:(NSString *) title
{
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];

    if (lessonData.BEPROURL) {
        
        NSURLSessionDownloadTask * downloadTask = [AFHttpTool downloadUrl:lessonData.BEPROURL destinationPath:lessonData.localURLOfPro progress:nil
                                                                  success:^(id response) {
                                                                      //
                                                                      dispatch_async(dispatch_queue_create("com.birdcopy.background.getDicWithURL", NULL), ^{
                                                                          
                                                                          NSString * outputDir = [FlyingFileManager getMyLessonDir:lessonID];
                                                                          
                                                                          [SSZipArchive unzipFileAtPath:lessonData.localURLOfPro toDestination:outputDir];
                                                                          
                                                                          //升级课程补丁
                                                                          [FlyingDBManager updateBaseDic:lessonID];
                                                                          [mylessonDAO updateProURL:nil LessonID:lessonID]; //表示已经缓存
                                                                      });
                                                                      
                                                                  } failure:^(NSError *err) {
                                                                      //
                                                                  }];
        
        [downloadTask resume];
    }
}

+ (void) getRelativeForLessonID:  (NSString *) lessonID   Title:(NSString *) title
{
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
    
    if(lessonData.BERELATIVEURL)
    {
        NSURLSessionDownloadTask * downloadTask = [AFHttpTool downloadUrl:lessonData.BERELATIVEURL destinationPath:lessonData.localURLOfRelative progress:nil
                                                                  success:^(id response) {
                                                                      //
                                                                      dispatch_async(dispatch_queue_create("com.birdcopy.background.relativeURLStr", NULL), ^{
                                                                          
                                                                          NSString * outputDir = [FlyingFileManager getMyLessonDir:lessonID];
                                                                          
                                                                          [SSZipArchive unzipFileAtPath:lessonData.localURLOfRelative toDestination:outputDir];
                                                                          [mylessonDAO updateRelativeURL:nil LessonID:lessonID]; //表示已经缓存
                                                                      });
                                                                      
                                                                  } failure:^(NSError *err) {
                                                                      //
                                                                  }];
        
        [downloadTask resume];
    }
}

+ (void) getBackMp3ForLessonID:  (NSString *) lessonID   Title:(NSString *) title
{
    
    FlyingLessonDAO *  mylessonDAO =[[FlyingLessonDAO alloc] init];
    FlyingLessonData * lessonData = [mylessonDAO selectWithLessonID: lessonID];
    
    if ( [lessonData.BECONTENTTYPE isEqualToString:KContentTypeText] &&
        lessonData.BEOFFICIAL)
    {
        NSString *localPath = [FlyingFileManager getMyLessonDir:lessonID];
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

//////////////////////////////////////////////////////////////
#pragma mark 公共资源文件管理
//////////////////////////////////////////////////////////////

-(void) startDownloadShareData
{
    
    NSString * shareBaseDicAllFile =[[FlyingFileManager getMyDictionaryDir] stringByAppendingPathComponent:kShareBaseTempFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:shareBaseDicAllFile])
    {
        if (!_dicDowloader) {
            
            [AFHttpTool getShareBaseZIP:KBaseDicAllType success:^(id response) {
                
                NSString * shareBaseURLStr=[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                
                
                _dicDowloader=[AFHttpTool downloadUrl:shareBaseURLStr
                                   destinationPath:shareBaseDicAllFile
                                          progress:^(NSProgress *downloadProgress) {
                                              //
                                          }
                                           success:^(id response) {
                                               //
                                               dispatch_async(dispatch_queue_create("com.birdcopy.background.processing", NULL), ^{
                                                   
                                                   [SSZipArchive unzipFileAtPath:shareBaseDicAllFile toDestination:[FlyingFileManager getMyDictionaryDir]];
                                                   
                                                   [[NSFileManager defaultManager] removeItemAtPath:shareBaseDicAllFile error:nil];
                                               });
                                               
                                           } failure:^(NSError *err) {
                                               //
                                               [[NSFileManager defaultManager] removeItemAtPath:shareBaseDicAllFile error:nil];

                                               NSLog(@"downloadUrl:%@",err.description);
                                           }];
                [_dicDowloader resume];
                
            } failure:^(NSError *err) {
                //
                NSLog(@"shareBaseZIP:%@",err.description);
            }];
        }
        else{
            
            [_dicDowloader resume];
        }
    }
    else
    {
        [SSZipArchive unzipFileAtPath:shareBaseDicAllFile toDestination:[FlyingFileManager getMyDictionaryDir]];
    }
}

-(void) closeDownloadShareData
{
    if (_dicDowloader) {
        
        [_dicDowloader cancel];
    }
}

- (void) downloadDataIfpossible
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
        
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                // -- Reachable -- //
                [self resumeAllDownloader];
                
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
