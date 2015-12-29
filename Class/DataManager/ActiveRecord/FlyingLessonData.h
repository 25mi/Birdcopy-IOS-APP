//
//  FlyingLessonData.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shareDefine.h"

@class FlyingPubLessonData;

@interface FlyingLessonData : NSObject

@property (nonatomic, strong) NSString *BELESSONID;       //课程ID

@property (nonatomic, strong) NSString *BETITLE;          //课程名称
@property (nonatomic, strong) NSString *BEDESC;           //课程描述
@property (nonatomic, strong) NSString *BEIMAGEURL;       //课程截图
@property (nonatomic, strong) NSString *BECONTENTURL;     //内容连接
@property (nonatomic, strong) NSString *BESUBURL;         //课程字幕
@property (nonatomic, strong) NSString *BEPROURL;         //字典地址
@property (nonatomic, strong) NSString *BELEVEL;          //难度分布

@property (nonatomic, assign) double    BEDURATION;       //课程时长

@property (nonatomic, assign) double    BEDLPERCENT;      //本地内容下载百分比
@property (nonatomic, assign) BOOL      BEDLSTATE;        //下载状态
@property (nonatomic, assign) BOOL      BEOFFICIAL;       //官方资源
@property (nonatomic, strong) NSString *BECONTENTTYPE;    //资源类型
@property (nonatomic, strong) NSString *BEDOWNLOADTYPE;   //下载类型
@property (nonatomic, strong) NSString *BETAG;            //标签
@property (nonatomic, assign)      int  BECoinPrice;      //价格
@property (nonatomic, strong) NSString *BEWEBURL;         //官方地址
@property (nonatomic, strong) NSString *BEISBN;           //对应ISBN
@property (nonatomic, strong) NSString *BERELATIVEURL;    //内容辅助资源

@property (nonatomic, strong) NSString *localURLOfContent; //本地课程内容地址
@property (nonatomic, strong) NSString *localURLOfSub;     //本地字幕内容地址
@property (nonatomic, strong) NSString *localURLOfCover;   //本地封面地址
@property (nonatomic, strong) NSString *localURLOfPro;     //本地课程字典库地址
@property (nonatomic, strong) NSString *localURLOfRelative;//本地课程辅助资源地址

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
           relativeURL:  (NSString *) relativeURL;


- (id)initWithPubData:(FlyingPubLessonData *)pubLessonData;

//从本地内容初始化，从网络补充内容
- (id)initWithLessonID:  (NSString *) lessonID
            LocalTitle:  (NSString *) localTitle
       LocalContentURL:  (NSString *) localContentURL
           LocalSubURL:  (NSString *) localSubURL
         LocalCoverURL:  (NSString *) localCoverURL
           ContentType:  (NSString *) contentType
          DownloadType:  (NSString *) downloadType
                   Tag:  (NSString *) tag;

@end
