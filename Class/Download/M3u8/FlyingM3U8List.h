//
//  FlyingM3U8List.h
//  FlyingEnglish
//
//  Created by BE_Air on 5/27/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlyingM3U8Segment;

@interface FlyingM3U8List : NSObject

@property (strong,nonatomic) NSMutableArray *segments;
@property (assign,nonatomic) NSInteger       length;
@property (strong,nonatomic) NSString       *lessonID;

- (id)initWithSegments:(NSMutableArray *)segmentList;
- (FlyingM3U8Segment *)getSegment:(NSInteger)index;
- (FlyingM3U8Segment *)getOneSegment;


@end
