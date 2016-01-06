//
//  FlyingLessonData.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingLessonData.h"
#import "FlyingPubLessonData.h"
#import "FlyingLessonDAO.h"
#import "FlyingM3U8Downloader.h"
#import "NSString+FlyingExtention.h"

#import "FlyingFileManager.h"

@implementation FlyingLessonData

//数据库数据初始化
- (id)initWithLessonID:  (NSString *)lessonID
                 Title:  (NSString *) title
                  DESC:  (NSString *) description
              IMageURL:  (NSString *) imageURL
            ContentURL:  (NSString *) contentURL
           SubtitleURL:  (NSString *) subtitleURL
      PronunciationURL:  (NSString *) pronunciationURL
                 Level:  (NSString *) level
              Duration:  (double)     duration
       DownloadPercent:  (double)     downloadPercent
          DownloadSate:  (BOOL)       downloadState
          officialFlag:  (BOOL)       official
           ContentType:  (NSString *) contentType
          DownloadType:  (NSString *) downloadType
                   Tag:  (NSString *) tag
             coinPrice:  (int)        coinPrice
                webURL:  (NSString *) webURL
                  ISBN:  (NSString *) ISBN
           relativeURL:  (NSString *) relativeURL
{
    if(self = [super init]){
        
        self.BELESSONID  = lessonID;
        self.BETITLE     = title;
        self.BEDESC      = description;
        self.BEIMAGEURL  = imageURL;
        self.BECONTENTURL= contentURL;
        self.BESUBURL    = subtitleURL;
        self.BEPROURL    = pronunciationURL;
        self.BELEVEL     = level;
        self.BEDURATION  = duration;
        
        self.BEDLPERCENT = downloadPercent;
        self.BEDLSTATE   = downloadState;
        self.BEOFFICIAL  = official;
        self.BECONTENTTYPE  = contentType;
        self.BEDOWNLOADTYPE = downloadType;
        self.BETAG          = tag;
        self.BECoinPrice    = coinPrice;
        self.BEWEBURL       = webURL;
        self.BEISBN         = ISBN;
        self.BERELATIVEURL  = relativeURL;
                
        [self setlocalData];
    }
    return self;
}


//从网络下载内容的初始化
- (id)initWithPubData:(FlyingPubLessonData *)pubLessonData
{
    if(self = [super init]){
        
        self.BELESSONID  = pubLessonData.lessonID;
        self.BETITLE     = pubLessonData.title;
        self.BEDESC      = pubLessonData.desc;
        self.BEIMAGEURL  = pubLessonData.imageURL;
        self.BECONTENTURL= pubLessonData.contentURL;
        self.BESUBURL    = pubLessonData.subtitleURL;
        self.BEPROURL    = pubLessonData.pronunciationURL;
        self.BELEVEL     = pubLessonData.level;
        self.BEDURATION  = pubLessonData.duration;
        
        self.BEDLPERCENT = 0;
        self.BEDLSTATE   = NO;
        self.BEOFFICIAL  = YES;
        self.BECONTENTTYPE  = pubLessonData.contentType;
        self.BEDOWNLOADTYPE = pubLessonData.downloadType;
        self.BETAG          = pubLessonData.tag;
        self.BECoinPrice    = pubLessonData.coinPrice;
        self.BEWEBURL       = pubLessonData.weburl;
        self.BEISBN         = pubLessonData.ISBN;
        self.BERELATIVEURL  = pubLessonData.relativeURL;
        
        [self setlocalData];
    }
    return self;
}


//从本地内容初始化，从网络补充内容
- (id)initWithLessonID:  (NSString *) lessonID
            LocalTitle:  (NSString *) localTitle
       LocalContentURL:  (NSString *) localContentURL
           LocalSubURL:  (NSString *) localSubURL
         LocalCoverURL:  (NSString *) localCoverURL
           ContentType:  (NSString *) contentType
          DownloadType:  (NSString *) downloadType
                   Tag:  (NSString *) tag;
{
    if(self = [super init]){
        
        self.BECONTENTURL= localContentURL;
        self.BESUBURL    = localSubURL;
        
        self.BEDURATION  = 0;
        self.BEDLPERCENT = 1;
        self.BEDLSTATE   = NO;
        
        self.BELESSONID  = lessonID;
        self.BETITLE     = localTitle;
        self.BEDESC      = @"无简介";
        self.BEIMAGEURL  = localCoverURL;
        
        self.BEOFFICIAL  = NO;
        self.BECONTENTTYPE  = contentType;
        self.BEDOWNLOADTYPE = downloadType;
        self.BETAG          = tag;
        
        self.BECoinPrice    = 0;
        self.BEWEBURL       = nil;
        self.BEISBN         = nil;
        self.BERELATIVEURL  = nil;
        
        [self setlocalData];
    }
    return self;
}

//创建课程本地相关信息
- (void) setlocalData
{

    if (self.BEOFFICIAL)
    {
        NSString *dbDir = [FlyingFileManager  getLessonDir:self.BELESSONID];
        
        NSString* contentFileName;
        
        if ([self.BEDOWNLOADTYPE isEqual:KDownloadTypeM3U8])
        {
            contentFileName = [self.BELESSONID stringByAppendingPathExtension:kLessonVedioLivingType];
            self.localURLOfContent = [dbDir stringByAppendingPathComponent:contentFileName];
        }
        else if ([self.BEDOWNLOADTYPE isEqual:KDownloadTypeMagnet])
        {
            //如果是原始下载地址
            if([NSString checkMagnetURL:self.BECONTENTURL]){
                
                NSFileManager* fileManager = [NSFileManager defaultManager];
                
                NSString * dir = [FlyingFileManager getLessonDir:self.BELESSONID];
                
                NSDirectoryEnumerator* directoryEnumerator = [fileManager enumeratorAtPath:dir];
                
                NSString *fileName;
                NSString *sourePath;
                while (fileName = [directoryEnumerator nextObject])
                {
                    if([NSString checkMp4URL:fileName] || [NSString checkOtherVedioURL:fileName]){
                        
                        sourePath=[dir stringByAppendingPathComponent:fileName];
                        
                        NSDictionary *attrs = [fileManager attributesOfItemAtPath:sourePath error: NULL];
                        unsigned long long result = [attrs fileSize];
                        if (result/1024/1024>50) {
                            break;
                        }
                    }
                }
                
                if(sourePath)
                {
                
                    self.BECONTENTURL = sourePath;
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        //更新下载Magnet地址为本地视频内容地址
                        [[[FlyingLessonDAO alloc] init] updateContentURL:sourePath LessonID:self.BELESSONID];
                    });
                }
            }
            
            self.localURLOfContent = self.BECONTENTURL;
        }
        else
        {
            if([NSString checkMp4URL:self.BECONTENTURL])
            {
                contentFileName = [self.BELESSONID stringByAppendingPathExtension:kLessonVedioType];
                self.localURLOfContent = [dbDir stringByAppendingPathComponent:contentFileName];
            }
            else if ([self.BECONTENTTYPE isEqualToString:KContentTypeAudio])
            {
                contentFileName = [self.BELESSONID stringByAppendingPathExtension:kLessonAudioType];
                self.localURLOfContent = [dbDir stringByAppendingPathComponent:contentFileName];
            }
            else if ( [self.BECONTENTTYPE isEqualToString:KContentTypeText])
            {
                NSString *extention = [[NSURL URLWithString:self.BECONTENTURL] pathExtension];
                contentFileName = [self.BELESSONID stringByAppendingPathExtension:extention];
                self.localURLOfContent = [dbDir stringByAppendingPathComponent:contentFileName];
            }
            else if ([self.BECONTENTTYPE isEqualToString:KContentTypePageWeb])
            {
                contentFileName = [self.BELESSONID stringByAppendingPathExtension:kLessonHtmlType];
                self.localURLOfContent = [dbDir stringByAppendingPathComponent:contentFileName];
            }
            else
            {
                //Try the last chance，补充搜索本地目录再确定
                contentFileName = [self.BELESSONID stringByAppendingPathExtension:kLessonUnkownType];
                self.localURLOfContent = [dbDir stringByAppendingPathComponent:contentFileName];
            }
        }
        
        NSString* subtitleFileName       = [self.BELESSONID stringByAppendingPathExtension:kLessonSubtitleType];
        NSString* pronunciationFileName  = [self.BELESSONID stringByAppendingPathExtension:kLessonProType];
        NSString* coverImageFileName     = [self.BELESSONID stringByAppendingPathExtension:kLessonCoverType];
        
        NSString* relativeFileName       = [@"relative" stringByAppendingPathExtension:kLessonRelativeType];
        
        NSString* subtitleFilePath      = [dbDir stringByAppendingPathComponent:subtitleFileName];
        NSString* coverImageFilePath    = [dbDir stringByAppendingPathComponent:coverImageFileName];
        NSString* pronunciationFilePath = [dbDir stringByAppendingPathComponent:pronunciationFileName];
        NSString* relativeFilePath      = [dbDir stringByAppendingPathComponent:relativeFileName];

        
        self.localURLOfSub     = subtitleFilePath;
        self.localURLOfCover   = coverImageFilePath;
        self.localURLOfPro     = pronunciationFilePath;
        self.localURLOfRelative= relativeFilePath;
    }
    else
    {
        self.localURLOfContent = self.BECONTENTURL;
        self.localURLOfSub     = self.BESUBURL;
        self.localURLOfCover   = self.BEIMAGEURL;
        self.localURLOfPro     = self.BEPROURL;
        self.localURLOfRelative= self.BERELATIVEURL;
    }
}

@end


