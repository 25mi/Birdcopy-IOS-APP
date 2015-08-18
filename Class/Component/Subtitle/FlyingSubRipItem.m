//
//  FlyingSubRipItem.m
//  FlyingEnglish
//
//  Created by vincent sung on 10/31/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingSubRipItem.h"

@implementation FlyingSubRipItem

@synthesize startTime, endTime, text, uniqueID;

- (id)init {
    self = [super init];
    if (self) {
        uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
    }
    return self;
}

-(NSString *)startTimeString {
    return [self _convertCMTimeToString:self.startTime];
}

-(NSString *)endTimeString {
    return [self _convertCMTimeToString:self.endTime];
}

-(NSString *)_convertCMTimeToString:(CMTime)theTime {
    // Need a string of format "hh:mm:ss". (No milliseconds.)
    NSInteger seconds = CMTimeGetSeconds(theTime);
    NSDate *date1 = [NSDate new];
    NSDate *date2 = [NSDate dateWithTimeInterval:seconds sinceDate:date1];
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *converted = [[NSCalendar currentCalendar] components:unitFlags fromDate:date1 toDate:date2 options:0];
    
    NSMutableString *str = [NSMutableString stringWithCapacity:6];
    if ([converted hour] < 10) {
        [str appendString:@"0"];
    }
    [str appendFormat:@"%@:", [@([converted hour]) stringValue]];
    if ([converted minute] < 10) {
        [str appendString:@"0"];
    }
    [str appendFormat:@"%@:", [@([converted minute]) stringValue]];
    if ([converted second] < 10) {
        [str appendString:@"0"];
    }
    [str appendFormat:@"%@", [@([converted second]) stringValue]];
    return str;
}


-(NSTimeInterval)startTimeInSeconds {
    
    return CMTimeGetSeconds(self.startTime);
}

-(NSTimeInterval)endTimeInSeconds {
    
    
    return CMTimeGetSeconds(self.endTime);
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeCMTime:startTime forKey:@"startTime"];
    [encoder encodeCMTime:endTime forKey:@"endTime"];
    [encoder encodeObject:text forKey:@"text"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    self.startTime = [decoder decodeCMTimeForKey:@"startTime"];
    self.endTime = [decoder decodeCMTimeForKey:@"endTime"];
    self.text = [decoder decodeObjectForKey:@"text"];
    return self;
}

- (BOOL) isEqual:(id)object
{
    return [[(FlyingSubRipItem *)object text] isEqual:self.text];
}

@end