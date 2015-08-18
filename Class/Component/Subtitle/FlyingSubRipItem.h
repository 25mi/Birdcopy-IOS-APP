//
//  FlyingSubRipItem.h
//  FlyingEnglish
//
//  Created by vincent sung on 10/31/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVTime.h>


typedef enum {
    SubRipScanPositionArrayIndex,
    SubRipScanPositionTimes,
    SubRipScanPositionText
} SubRipScanPosition;

@interface FlyingSubRipItem : NSObject  < NSCoding >

@property (nonatomic, assign) CMTime startTime;
@property (nonatomic, assign) CMTime endTime;
@property (nonatomic, strong) NSMutableString *text;

@property(nonatomic, readonly) NSString *uniqueID;

-(NSString *) startTimeString;
-(NSString *) endTimeString;

-(NSTimeInterval)startTimeInSeconds;
-(NSTimeInterval)endTimeInSeconds;

-(void)encodeWithCoder:(NSCoder *)encoder;
-(id)initWithCoder:(NSCoder *)decoder;

- (BOOL) isEqual:(id)object;

@end
