//
//  FlyingCalendarEvent.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingCalendarEvent : NSObject

@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSDate   *date;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *coverURL;

@property (nonatomic, strong) NSDictionary *info;

@property (nonatomic, strong) UIColor *color;


@property NSData* image;

+(FlyingCalendarEvent *)eventWithTitle:(NSString *)title andDate:(NSDate *)date andInfo:(NSDictionary *)info;
+(FlyingCalendarEvent *)eventWithTitle:(NSString *)title andDate:(NSDate *)date andInfo:(NSDictionary *)info andColor:(UIColor *)color;
+(FlyingCalendarEvent *)eventWithTitle:(NSString *)title andDate:(NSDate *)date andInfo:(NSDictionary *)info andImage:(NSData *)image;

@end
