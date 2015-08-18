//
//  FlyingSubTitle.h
//  FlyingEnglish
//
//  Created by vincent sung on 10/31/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlyingSubRipItem;

@interface FlyingSubTitle : NSObject < NSCoding > 

-(FlyingSubRipItem *) getSubItemForIndex:(NSInteger) index;//获得字幕单元
-(FlyingSubRipItem *) getFirstSubtitleItem;//获得第一个字幕单元
-(FlyingSubRipItem *) getLastSubtitleItem;//获得最后一个字幕单元
-(NSString *)         getSubtitleTextOnly;//获得字幕显示内容
-(NSString *)         getTextFromTime:(NSTimeInterval ) startTime;

-(NSTimeInterval )    getStartSubtitleTime;//获得字幕开始时间
-(NSTimeInterval )    getEndSubtitleTime;//获得字幕结束时间

-(NSUInteger)idxAfterCurrentSubTime:(NSTimeInterval)theTimeInSeconds;//得到字幕index
-(NSUInteger)idxOfSubItemWithSubTime:(NSTimeInterval)theTimeInSeconds;//空白区取得下一个字幕的index

-(NSUInteger)         countOfSubItems;//所有字幕的个数

-(FlyingSubTitle *)   initWithFile:(NSString *)filePath;
-(FlyingSubTitle *)   initWithData:(NSData *)data;
-(FlyingSubTitle *)   initWithString:(NSString *)str;

-(BOOL) isDialog;
-(id) shareItems;

-(void) encodeWithCoder:(NSCoder *)encoder;
-(id) initWithCoder:(NSCoder *)decoder;

@end