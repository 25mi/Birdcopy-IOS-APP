//
//  FlyingM3U8Parser.m
//  FlyingEnglish
//
//  Created by BE_Air on 5/27/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingM3U8Parser.h"
#import "FlyingM3U8Segment.h"
#import "FlyingM3U8List.h"

@implementation FlyingM3U8Parser

//解析m3u8的内容
-(void)praseUrl:(NSString *)urlstr
{    
    NSURL *url = [[NSURL alloc] initWithString:urlstr];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *data = [[NSString alloc] initWithContentsOfURL:url
                                                usedEncoding:&encoding
                                                       error:&error];
    
    if(data == nil)
    {
        NSLog(@"data is nil");
        if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Failed:)])
        {
            [self.delegate praseM3U8Failed:self];
        }
        return;
    }
        
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    NSString* remainData =data;
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    while (segmentRange.location != NSNotFound)
    {
        @autoreleasepool {
            
            FlyingM3U8Segment  * segment = [[FlyingM3U8Segment alloc]init];
            // 读取片段时长
            NSRange commaRange = [remainData rangeOfString:@","];
            NSString* value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
            segment.duration = [value doubleValue];
            
            remainData = [remainData substringFromIndex:commaRange.location];
            // 读取片段url
            NSRange linkRangeBegin = [remainData rangeOfString:@"http"];
            NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
            NSString* linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
            segment.locationUrl = linkurl;
            
            [segments addObject:segment];
            remainData = [remainData substringFromIndex:linkRangeEnd.location];
            
            //特殊标记
            NSRange discontinuityRange = [remainData rangeOfString:@"#EXT-X-DISCONTINUITY"];
            if (discontinuityRange.location==0) {
                
                FlyingM3U8Segment  * fakeSegment = [[FlyingM3U8Segment alloc]init];
                
                fakeSegment.duration=0;
                fakeSegment.locationUrl=@"#EXT-X-DISCONTINUITY";
                [segments addObject:fakeSegment];
            }
            
            segmentRange = [remainData rangeOfString:@"#EXTINF:"];
        }
    }
    
    FlyingM3U8List * thePlaylist = [[FlyingM3U8List alloc] initWithSegments:segments];
    self.playlist = thePlaylist;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(praseM3U8Finished:)])
    {
        [self.delegate praseM3U8Finished:self];
    }
}

@end
