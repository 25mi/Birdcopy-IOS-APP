//
//  FlyingCalendarVC.m
//  FlyingEnglish
//
//  Created by vincent on 8/16/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingCalendarVC.h"
#import "CalendarKit.h"
#import "NSDate+Components.h"
#import "NSDateComponents+AllComponents.h"


@interface FlyingCalendarVC ()<CKCalendarViewDelegate,CKCalendarViewDataSource>
{
    CKCalendarView *_calendarView;
}

@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation FlyingCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initCalendar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initCalendar
{
    // 1. Instantiate a CKCalendarView
    if(!_calendarView)
    {
        _calendarView = [CKCalendarView new];
        
        // 2. Optionally, set up the datasource and delegates
        [_calendarView setDelegate:self];
        [_calendarView setDataSource:self];
        
        // 3. Present the calendar
        [[self view] addSubview:_calendarView];
    }
    
    //  An event for the new MBCalendarKit release.
    NSString *title = NSLocalizedString(@"Release MBCalendarKit 2.2.4", @"");
    NSDate *date = [NSDate dateWithDay:28 month:11 year:2014];
    CKCalendarEvent *releaseUpdatedCalendarKit = [CKCalendarEvent eventWithTitle:title andDate:date andInfo:nil];
    
    //  An event for the new Hunger Games movie.
    NSString *title2 = NSLocalizedString(@"The Hunger Games: Mockingjay, Part 1", @"");
    NSDate *date2 = [NSDate dateWithDay:21 month:11 year:2014];
    CKCalendarEvent *mockingJay = [CKCalendarEvent eventWithTitle:title2 andDate:date2 andInfo:nil];
    
    //  Integrate MBCalendarKit
    NSString *integrationTitle = NSLocalizedString(@"Integrate MBCalendarKit", @"");
    NSDate *integrationDate = date2;
    CKCalendarEvent *integrationEvent = [CKCalendarEvent eventWithTitle:integrationTitle andDate:integrationDate andInfo:nil];
    
    //  An event for the new MBCalendarKit release.
    NSString *title3 = NSLocalizedString(@"Fix bug where events don't show up immediately.", @"");
    NSDate *date3 = [NSDate dateWithDay:29 month:11 year:2014];
    CKCalendarEvent *fixBug = [CKCalendarEvent eventWithTitle:title3 andDate:date3 andInfo:nil];
    
    
    /**
     *  Add the events to the data source.
     *
     *  The key is the date that the array of events appears on.
     */
    
    self.data[date] = @[releaseUpdatedCalendarKit];
    self.data[date2] = @[mockingJay, integrationEvent];
    self.data[date3] = @[fixBug];

}

#pragma mark - CKCalendarViewDataSource

- (NSArray *)calendarView:(CKCalendarView *)CalendarView eventsForDate:(NSDate *)date
{
    return [self data][date];
}

#pragma mark - CKCalendarViewDelegate

// Called before/after the selected date changes
- (void)calendarView:(CKCalendarView *)calendarView willSelectDate:(NSDate *)date
{
}

- (void)calendarView:(CKCalendarView *)calendarView didSelectDate:(NSDate *)date
{

}

//  A row is selected in the events table. (Use to push a detail view or whatever.)
- (void)calendarView:(CKCalendarView *)calendarView didSelectEvent:(CKCalendarEvent *)event
{
}


@end
