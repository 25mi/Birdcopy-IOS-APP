//
//  FlyingDownloader.m
//  FlyingEnglish
//
//  Created by BE_Air on 9/8/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingDownloader.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "AFDownloadRequestOperation.h"
#import "FlyingM3U8Downloader.h"
#import "FlyingM3U8Parser.h"
#import "FlyingM3U8List.h"
#import "UIWebView+Clean.h"
#import "NSString+FlyingExtention.h"
#import "FlyingSoundPlayer.h"
#import "iFlyingAppDelegate.h"
#import "SIAlertView.h"

@interface FlyingDownloader ()
{
    NSMutableDictionary * _downloadingOperationList;
    NSMutableSet        * _waittingDownloadJobs;
    
    dispatch_source_t   _source;
    
    UIWebView          *_webView;
    
    NSString           * _downloadType;
    
    FlyingLessonDAO    * _dao;
}
@end

@implementation FlyingDownloader


- (void) initWithLessonID:(NSString *)lessonID
{
    
    self.lessonID=lessonID;
    _dao=[[FlyingLessonDAO  alloc] init];
    FlyingLessonData * lessonData = [_dao  selectWithLessonID:lessonID];

    
    _downloadType = lessonData.BEDOWNLOADTYPE;
    
    NSString * contentURL=lessonData.BECONTENTURL;
    
    if ([_downloadType isEqualToString:KDownloadTypeNormal]){
        
        __block float percent=0;
        __block float percentDone=0;
        NSURL *webURL = [NSURL URLWithString:contentURL];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:webURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
        AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:lessonData.localURLOfContent shouldResume:YES];
        [operation setShouldOverwrite:YES];
        [operation setDeleteTempFileOnCancel:YES];
        
        [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            
            percentDone = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
            
            if (!_source) {
                
                _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
                
                dispatch_source_set_event_handler(_source, ^{
                    
                    @autoreleasepool {
                        
                        [_dao setUserModle:NO];
                        [_dao updateDowloadPercent:percentDone LessonID:lessonID];
                        [_dao updateDowloadState:YES LessonID:lessonID];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KlessonStateChange object:nil userInfo:[NSDictionary dictionaryWithObject:lessonID forKey:@"lessonID"]];
                    }
                    
                });
                dispatch_resume(_source);
            }
            
            if (percentDone-percent>=0.01) {
                dispatch_source_merge_data(_source, 1);
                percent=percentDone;
            }
        }];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            FlyingLessonDAO * dao=[[FlyingLessonDAO  alloc] init];
            
            [dao updateDowloadPercent:1 LessonID:lessonID];
            [dao updateDowloadState:YES LessonID:lessonID];

            [[NSNotificationCenter defaultCenter] postNotificationName:KlessonFinishTask object:nil userInfo:[NSDictionary dictionaryWithObject:lessonID forKey:@"lessonID"]];
            
            [self.delegate closeAndReleaseDownloaderForID:lessonID];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self.delegate closeAndReleaseDownloaderForID:lessonID];
        }];
        
        [operation start];
        _downloader=operation;
    }
    else if ([_downloadType isEqualToString:KDownloadTypeMagnet]) {
        
        
            /*
            FlyingMagnetDownloader * magnetDownloader= [[FlyingMagnetDownloader alloc] init];
            
            [magnetDownloader setThelessonID:lessonID];
            
            NSError* err=[magnetDownloader addTorrentFromManget:contentURL];
            
            if(!err){
                
                _downloader=magnetDownloader;
            }
            else{
                
                _downloader=nil;
            }
             */
        
        NSString *title = @"版本提醒";
        NSString *message = [NSString stringWithFormat:@"请使用专业版!"];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
    }
    else if ([_downloadType isEqualToString:KDownloadTypeM3U8]) {
     
        if ([NSString checkM3U8URL:contentURL]) {
            
            [self initDownloadM3u8Content];
        }
        else{

            [self getM8U8AndDownload];
        }
    }
}

-(void) resumeDownload
{
    
    if([_downloadType isEqualToString:KDownloadTypeNormal]){
    
        [(AFDownloadRequestOperation *)_downloader  resume];
    }
    else if([_downloadType isEqualToString:KDownloadTypeM3U8]){
        
        [(FlyingM3U8Downloader *)_downloader  startDownloadVideo];
    }
    else if ([_downloadType isEqualToString:KDownloadTypeMagnet]){
        
        //[(FlyingMagnetDownloader *)_downloader  startDownloadVideo];
        NSString *title = @"版本提醒";
        NSString *message = [NSString stringWithFormat:@"请使用专业版!"];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];

    }
}

-(void) cancelDownload
{
    
    if([_downloadType isEqualToString:KDownloadTypeNormal]){
        
        [(AFDownloadRequestOperation *)_downloader  pause];
    }
    else if([_downloadType isEqualToString:KDownloadTypeM3U8]){
        
        [(FlyingM3U8Downloader *)_downloader  cancelDownloadVideo];
    }
    else if ([_downloadType isEqualToString:KDownloadTypeMagnet]){
        
        //[(FlyingMagnetDownloader *)_downloader  cancelDownload];
        
        NSString *title = @"版本提醒";
        NSString *message = [NSString stringWithFormat:@"请使用专业版!"];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"知道了"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - M3U8 Related
//////////////////////////////////////////////////////////////

-(void) getM8U8AndDownload
{
    
    //动态获取M3U8
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!_webView) {
            // Create server using our custom MyHTTPServer class
            _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
            _webView.scalesPageToFit   = NO;
            _webView.delegate          = self;
            _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        }
        else{
            
            if ([_webView isLoading]) {
                
                [_webView stopLoading];
            }
        }
        FlyingLessonDAO * dao=[[FlyingLessonDAO alloc] init];
        [dao setUserModle:NO];
        
        NSURL *url =[[NSURL alloc] initWithString:[(FlyingLessonData*)[dao selectWithLessonID:self.lessonID] BECONTENTURL]];
        NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
        [_webView loadRequest:request];
    });
}


- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    
    //取页面M3U8
    NSString * lJs2 = @"(document.getElementsByTagName(\"video\")[0]).src";  // youku,tudou,ku6 ,souhu
    NSString * lm3u8 = [webView stringByEvaluatingJavaScriptFromString:lJs2];
    
    NSRange textRange;
    NSString * substring= @"m3u8";
    textRange =[lm3u8 rangeOfString:substring];
    
    if(textRange.location != NSNotFound)
    {
        FlyingLessonDAO * dao=[[FlyingLessonDAO alloc] init];
        [dao setUserModle:NO];
        
        [dao updateContentURL:lm3u8 LessonID:_lessonID];
        [self initDownloadM3u8Content];
        if (_webView) {
            
            [_webView stopLoading];
            _webView=nil;
        }
    }
}

- (UIView*) getWebView
{
    if (!_webView) {
        // Create server using our custom MyHTTPServer class
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.scalesPageToFit   = NO;
        _webView.delegate          = self;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    }
    else{
        [_webView stopLoading];
    }
    
    return  _webView;
}

- (void) closeWebView
{
    if (_webView) {
        
        [_webView cleanForDealloc];
        _webView=nil;
    }
}

-(void) initDownloadM3u8Content
{
    
    _downloadType=KDownloadTypeM3U8;
    
    FlyingM3U8Parser *m3u8Parser= [[FlyingM3U8Parser alloc] init];
    
    FlyingLessonData * lessonData = [[[FlyingLessonDAO alloc] init]  selectWithLessonID:_lessonID];
    [m3u8Parser praseUrl:lessonData.BECONTENTURL];
    [m3u8Parser.playlist setLessonID:_lessonID];
    
    FlyingM3U8Downloader * m3u8Downloader= [[FlyingM3U8Downloader alloc] initWithM3U8List:m3u8Parser.playlist];
    [m3u8Downloader startDownloadVideo];
    _downloader=m3u8Downloader;
}

@end
