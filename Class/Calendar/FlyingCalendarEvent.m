//
//  FlyingCalendarEvent.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCalendarEvent.h"

@implementation FlyingCalendarEvent

+(FlyingCalendarEvent *)eventWithTitle:(NSString *)title andDate:(NSDate *)date andInfo:(NSDictionary *)info
{
    FlyingCalendarEvent *event = [FlyingCalendarEvent new];
    [event setTitle:title];
    [event setDate:date];
    [event setInfo:info];
    
    return event;
}

+(FlyingCalendarEvent *)eventWithTitle:(NSString *)title andDate:(NSDate *)date andInfo:(NSDictionary *)info andColor:(UIColor *)color
{
    FlyingCalendarEvent *event = [FlyingCalendarEvent new];
    [event setTitle:title];
    [event setDate:date];
    [event setInfo:info];
    [event setColor:color];
    
    return event;
}

+(FlyingCalendarEvent *)eventWithTitle:(NSString *)title andDate:(NSDate *)date andInfo:(NSDictionary *)info andImage:(NSData *)image
{
    FlyingCalendarEvent *event = [FlyingCalendarEvent new];
    [event setTitle:title];
    [event setDate:date];
    [event setInfo:info];
    [event setImage:image];
    
    return event;
}

@end
