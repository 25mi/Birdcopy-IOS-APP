//
//  FlyingCalendarView.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FlyingCalendarViewModeMonth = 0,
    FlyingCalendarViewModeWeek = 1,
    FlyingCalendarViewModeDay = 2
} FlyingCalendarDisplayMode;


@class FlyingCalendarView;
@class FlyingCalendarEvent;

@protocol FlyingCalendarViewDelegate <NSObject>

@optional

// Called before/after the selected date changes
- (void)calendarView:(FlyingCalendarView *)CalendarView willSelectDate:(NSDate *)date;
- (void)calendarView:(FlyingCalendarView *)CalendarView didSelectDate:(NSDate *)date;

//  A row is selected in the events table. (Use to push a detail view or whatever.)
- (void)calendarView:(FlyingCalendarView *)CalendarView didSelectEvent:(FlyingCalendarEvent *)event;

@end


@protocol FlyingCalendarViewDataSource <NSObject>

- (NSArray *)calendarView:(FlyingCalendarView *)calendarView eventsForDate:(NSDate *)date;

@end


@interface FlyingCalendarView : UIView

@property (nonatomic, assign) FlyingCalendarDisplayMode displayMode;

@property(nonatomic, strong) NSLocale       *locale;            // default is [NSLocale currentLocale]. setting nil returns to default
@property(nonatomic, copy)   NSCalendar     *calendar;          // default is [NSCalendar currentCalendar]. setting nil returns to default
@property(nonatomic, strong) NSTimeZone     *timeZone;          // default is nil. use current time zone or time zone from calendar

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic, assign) NSUInteger firstWeekDay;  //  Proxies to the calendar's firstWeekDay so we can update the UI immediately.

@property (nonatomic, weak) id<FlyingCalendarViewDataSource> dataSource;
@property (nonatomic, weak) id<FlyingCalendarViewDelegate> delegate;

/* Initializer */

- (instancetype)init;
- (instancetype)initWithMode:(FlyingCalendarDisplayMode)CalendarDisplayMode;

/* Reload calendar and events. */

- (void)reload;
- (void)reloadAnimated:(BOOL)animated;

/* Setters */

- (void)setCalendar:(NSCalendar *)calendar;
- (void)setCalendar:(NSCalendar *)calendar animated:(BOOL)animated;

- (void)setDate:(NSDate *)date;
- (void)setDate:(NSDate *)date animated:(BOOL)animated;

- (void)setDisplayMode:(FlyingCalendarDisplayMode)displayMode;
- (void)setDisplayMode:(FlyingCalendarDisplayMode)displayMode animated:(BOOL)animated;

- (void)setLocale:(NSLocale *)locale;
- (void)setLocale:(NSLocale *)locale animated:(BOOL)animated;

- (void)setTimeZone:(NSTimeZone *)timeZone;
- (void)setTimeZone:(NSTimeZone *)timeZone animated:(BOOL)animated;

- (void)setMinimumDate:(NSDate *)minimumDate;
- (void)setMinimumDate:(NSDate *)minimumDate animated:(BOOL)animated;

- (void)setMaximumDate:(NSDate *)maximumDate;
- (void)setMaximumDate:(NSDate *)maximumDate animated:(BOOL)animated;

/* Visible Dates */

- (NSDate *)firstVisibleDate;
- (NSDate *)lastVisibleDate;

@end
