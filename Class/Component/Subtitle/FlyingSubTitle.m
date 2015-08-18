//
//  FlyingSubTitle.m
//  FlyingEnglish
//
//  Created by vincent sung on 10/31/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingSubTitle.h"
#import "FlyingSubRipItem.h"
#import <CoreMedia/CMTime.h>
#import "FlyingSubItemParser.h"

@interface  FlyingSubTitle()
@property (strong, nonatomic) NSMutableArray *subtitleItems;
@end

@implementation  FlyingSubTitle

//获得字幕单元
-(FlyingSubRipItem *) getSubItemForIndex:(NSInteger) index
{
    if (index<self.countOfSubItems ) {
        return [self.subtitleItems objectAtIndex:index];
    }
    
    return nil;
}

//获得第一个字幕单元
-(FlyingSubRipItem *) getFirstSubtitleItem{
    
    if (self.subtitleItems.count!=0) {
        return [self.subtitleItems objectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

//获得最后一个字幕单元
-(FlyingSubRipItem *) getLastSubtitleItem{
    
    if (self.subtitleItems.count!=0) {
        return [self.subtitleItems objectAtIndex:(self.subtitleItems.count-1)];
    }
    else
    {
        return nil;
    }
}

//获得字幕显示内容
-(NSString *) getSubtitleTextOnly
{
    NSMutableString * result = [[NSMutableString alloc] initWithCapacity:(self.subtitleItems.count*12)];
    
    for (int i=0; i<self.countOfSubItems;i++) {
        FlyingSubRipItem * obj = [self.subtitleItems objectAtIndex:i];
        [result appendString:@" "];
        [result appendString:obj.text];
    }
    return result;
}


- (NSString *) getTextFromTime:(NSTimeInterval ) startTime
{
    
    NSUInteger begin = [self idxOfSubItemWithSubTime:startTime];
    
    if (begin==NSNotFound) {
        begin=[self idxAfterCurrentSubTime:startTime];
    }
    
    if (begin<self.countOfSubItems) {
        NSMutableString * result = [[NSMutableString alloc] initWithCapacity:(self.subtitleItems.count*12)];
        
        for (NSUInteger i=begin; i<self.countOfSubItems;i++) {
            FlyingSubRipItem * obj = [self.subtitleItems objectAtIndex:i];
            [result appendString:@" "];
            [result appendString:obj.text];
        }
        return result;
    }
    
    return nil;
}

//获得字幕开始时间
- (NSTimeInterval ) getStartSubtitleTime
{
    return  [[self getFirstSubtitleItem] startTimeInSeconds];
}

//获得字幕结束时间
-(NSTimeInterval ) getEndSubtitleTime
{
    return  [[self getLastSubtitleItem] endTimeInSeconds];
}

-(FlyingSubTitle *)initWithFile:(NSString *)filePath {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        return [self initWithData:data];
    }
    else {
       
        return Nil;
    }
}

-(FlyingSubTitle *)initWithData:(NSData *)data
{
    
    if (data.length!=0) {
        
        Byte first4Bytes[4];
        [data getBytes:&first4Bytes length:4];
        
        //判断字幕文件格式
        NSString *srt;
        if ( first4Bytes[0] == (Byte) 0xFF && first4Bytes[1] == (Byte) 0xFE ) {
            //"UTF-16LE";
            srt = [[NSString alloc] initWithData:data encoding:NSUTF16LittleEndianStringEncoding];
        }
        else if ( first4Bytes[0] == (Byte) 0xFE && first4Bytes[1] == (Byte) 0xFF ) {
            //"UTF-16BE";
            srt = [[NSString alloc] initWithData:data encoding:NSUTF16BigEndianStringEncoding];
            
        }
        else if ( first4Bytes[0] == (Byte) 0xFF && first4Bytes[1] == (Byte) 0xFE && first4Bytes[2] == (Byte) 0x00 && first4Bytes[3] == (Byte) 0x00){
            //"UTF-32LE";
            srt = [[NSString alloc] initWithData:data encoding:NSUTF32LittleEndianStringEncoding];
        }
        else if ( first4Bytes[0] == (Byte) 0x00 && first4Bytes[1] == (Byte) 0x00 && first4Bytes[2] == (Byte) 0xFE && first4Bytes[3] == (Byte) 0xFF) {
            //"UTF-32BE";
            srt = [[NSString alloc] initWithData:data encoding:NSUTF32BigEndianStringEncoding];
            
        }
        else if ( first4Bytes[0] == (Byte) 0xEF && first4Bytes[1] == (Byte) 0xBB && first4Bytes[2] == (Byte) 0xBF ) {
            //"UTF-8";
            srt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        else{
            //ASCII
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            srt = [[NSString alloc] initWithData:data encoding:enc];
            
            if (srt==nil) {
                
                srt = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            }
        }
        
        self = [super init];
        if (self) {
            
            self.subtitleItems = [NSMutableArray arrayWithCapacity:100];
            BOOL success = [self _populateFromString:srt];
            if (!success) {
                return Nil;
            }
        }
        return self;
    }
    else {
        
        return Nil;
    }
}

-(FlyingSubTitle *)initWithString:(NSString *)str {
    self = [super init];
    if (self) {
        self.subtitleItems = [NSMutableArray arrayWithCapacity:100];
        BOOL success = [self _populateFromString:str];
        if (!success) {
            return NULL;
        }
    }
    return self;
}

// returns YES if successful, NO if not succesful.
// assumes that str is a correctly-formatted SRT file.
-(BOOL)_populateFromString:(NSString *)str {
    
    FlyingSubRipItem __block *cur;
    SubRipScanPosition __block scanPosition = SubRipScanPositionArrayIndex;
    BOOL __block actionAlreadyTaken = NO;
    
    [str enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        
        SubRipScanPosition nextScanPostion = SubRipScanPositionArrayIndex;
        
        // skip over blank lines.
        NSRange r = [line rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];

        if (r.location == NSNotFound){
            nextScanPostion = SubRipScanPositionArrayIndex; // skip past the array index number.
        }
        else{
            
            if (scanPosition == SubRipScanPositionArrayIndex) {
                nextScanPostion = SubRipScanPositionTimes; // skip past the array index number.
                cur =[[FlyingSubRipItem alloc] init];
                actionAlreadyTaken = NO;
            }
            if (scanPosition == SubRipScanPositionTimes) {
                
                NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                NSString * newLine = [line stringByTrimmingCharactersInSet:whitespace];

                NSArray *times = [newLine componentsSeparatedByString:@"-->"];
                
                if (times.count==2) {
                    
                    NSString *beginning = [times objectAtIndex:0];
                    NSString *ending = [times objectAtIndex:1];
                    
                    // working with the beginning first...
                    NSArray *timeComponents = [beginning componentsSeparatedByString:@":"];
                    NSInteger hours = [(NSString *)[timeComponents objectAtIndex:0] integerValue];
                    NSInteger minutes = [(NSString *)[timeComponents objectAtIndex:1] integerValue];
                    NSArray *secondsComponents = [(NSString *)[timeComponents objectAtIndex:2] componentsSeparatedByString:@","];
                    NSInteger seconds = [(NSString *)[secondsComponents objectAtIndex:0] integerValue];
                    NSInteger milliseconds = [(NSString *)[secondsComponents objectAtIndex:1] integerValue];
                    NSInteger totalNumSeconds = (hours * 3600) + (minutes * 60) + seconds;
                    CMTime startSeconds = CMTimeMake(totalNumSeconds*1000, 1000);
                    CMTime millisecondsCMTime = CMTimeMake(milliseconds, 1000);
                    cur.startTime = CMTimeAdd(startSeconds, millisecondsCMTime);
                    
                    // and then the end:
                    timeComponents = [ending componentsSeparatedByString:@":"];
                    hours = [(NSString *)[timeComponents objectAtIndex:0] integerValue];
                    minutes = [(NSString *)[timeComponents objectAtIndex:1] integerValue];
                    secondsComponents = [(NSString *)[timeComponents objectAtIndex:2] componentsSeparatedByString:@","];
                    seconds = [(NSString *)[secondsComponents objectAtIndex:0] integerValue];
                    milliseconds = [(NSString *)[secondsComponents objectAtIndex:1] integerValue];
                    totalNumSeconds = (hours * 3600) + (minutes * 60) + seconds;
                    CMTime endSeconds = CMTimeMake(totalNumSeconds, 1);
                    millisecondsCMTime = CMTimeMake(milliseconds, 1000);
                    cur.endTime = CMTimeAdd(endSeconds, millisecondsCMTime);
                    nextScanPostion = SubRipScanPositionText;
                }
                else{
                    
                    nextScanPostion = SubRipScanPositionArrayIndex;
                }
            }
            if (scanPosition == SubRipScanPositionText) {
                
                BOOL isEnglishContent = [line canBeConvertedToEncoding:NSASCIIStringEncoding];

                if (isEnglishContent) {
                    
                    if (actionAlreadyTaken == NO) {
                        cur.text = [[NSMutableString alloc] initWithCapacity:80];
                        [cur.text appendString:line];
                        [self.subtitleItems addObject:cur];
                        actionAlreadyTaken = YES;
                    }
                    else{
                        
                        [((FlyingSubRipItem *)[self.subtitleItems lastObject]).text appendString:@"\n"];
                        
                        [((FlyingSubRipItem *)[self.subtitleItems lastObject]).text appendString:line];
                    }
                }
                nextScanPostion = SubRipScanPositionText;
            }
        }
        scanPosition = nextScanPostion;
        
    }];
    
    
    NSRange textRange;
    NSString * substring= @"<font";
    textRange =[str rangeOfString:substring];
    
    if(textRange.location != NSNotFound)
    {
        FlyingSubItemParser * parser = [[FlyingSubItemParser alloc] init];
        
        [self.subtitleItems enumerateObjectsUsingBlock:^(FlyingSubRipItem * obj, NSUInteger idx, BOOL *stop) {
            
            [parser SetData:[obj.text dataUsingEncoding:NSUTF8StringEncoding]];
            
            __weak typeof(self) weakSelf = self;
            
            parser.completionBlock = ^(NSMutableString *resultString)
            {
                obj.text= resultString;
                
                [weakSelf.subtitleItems replaceObjectAtIndex:idx withObject:obj];
            };
            
            parser.failureBlock = ^(NSError *error)
            {
                //[weakSelf handleError:error];
            };
            
            [parser parse];
        }];
    }
    
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"SRT file: %@", self.subtitleItems];
}

//得到字幕index（字幕时间）
-(NSUInteger)idxOfSubItemWithSubTime:(NSTimeInterval)theTimeInSeconds {
    
    return [self.subtitleItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ((theTimeInSeconds >= [(FlyingSubRipItem *)obj startTimeInSeconds])&&
            (theTimeInSeconds <= [(FlyingSubRipItem *)obj endTimeInSeconds])) {
            return true;
        }
        else {
            return false;
        }
    }];
}

//空白区取得下一个字幕的index（字幕时间）
-(NSUInteger)idxAfterCurrentSubTime:(NSTimeInterval)theTimeInSeconds{
    
    return [self.subtitleItems indexOfObjectPassingTest:^BOOL(FlyingSubRipItem * obj, NSUInteger idx, BOOL *stop) {
        if (theTimeInSeconds < obj.startTimeInSeconds) {
            return true;
        }
        else {
            return false;
        }
    }];
}

//所有字幕的个数
-(NSUInteger)countOfSubItems{
    
    return self.subtitleItems.count;
}


-(id) shareItems
{
    return self.subtitleItems;
}

-(BOOL) isDialog
{

    if(   [[self getFirstSubtitleItem].text componentsSeparatedByString:@":"].count==2
       && [[self getLastSubtitleItem].text  componentsSeparatedByString:@":"].count==2 ){
        return YES;
    }
    else{
        return NO;
    }
}


-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.subtitleItems forKey:@"subtitleItems"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    self.subtitleItems = [decoder decodeObjectForKey:@"subtitleItems"];
    return self;
}

@end


