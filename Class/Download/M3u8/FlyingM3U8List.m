//
//  FlyingM3U8List.m
//  FlyingEnglish
//
//  Created by BE_Air on 5/27/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingM3U8List.h"
#import "FlyingM3U8List.h"


@interface FlyingM3U8List ()
{
    NSMutableArray *_toBeDownloadsegments;
}
@end

@implementation FlyingM3U8List

- (id)initWithSegments:(NSMutableArray *)segmentList
{
    self = [super init];
    if(self != nil)
    {
        self.segments = segmentList;
        _toBeDownloadsegments = [segmentList mutableCopy];
        self.length = [segmentList count];
    }
    return self;
}
- (FlyingM3U8Segment *)getSegment:(NSInteger)index
{
    if( index >=0 && index < self.length)
    {
        return (FlyingM3U8Segment *)[self.segments objectAtIndex:index];
    }
    else
    {
        return nil;
    }
}

- (FlyingM3U8Segment *)getOneSegment
{

    if (_toBeDownloadsegments.count!=0) {
        
        FlyingM3U8Segment * result =[_toBeDownloadsegments  objectAtIndex:0];
        [_toBeDownloadsegments removeObjectAtIndex:0];
        
        return result;
    }
    else
    {
        return nil;
    }
}


@end
