//
//  FlyingCalendarVC.m
//  FlyingEnglish
//
//  Created by vincent on 8/16/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingCalendarVC.h"
#import "FlyingCalendarView.h"
#import "NSDate+Components.h"
#import "NSDateComponents+AllComponents.h"
#import "iFlyingAppDelegate.h"

#import "FlyingCalendarEvent.h"
#import "FlyingEventVC.h"
#import "FlyingGroupData.h"
#import "StoryBoardUtilities.h"

@interface FlyingCalendarVC ()<FlyingCalendarViewDelegate,FlyingCalendarViewDataSource>
{
}

@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation FlyingCalendarVC

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addBackFunction];
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    image= [UIImage imageNamed:@"back"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem,menuBarButtonItem,nil];
    
    image= [UIImage imageNamed:@"refresh"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* resetButton= [[UIButton alloc] initWithFrame:frame];
    [resetButton setBackgroundImage:image forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(doReset) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* doResetButtonItem= [[UIBarButtonItem alloc] initWithCustomView:resetButton];
    
    self.navigationItem.rightBarButtonItem = doResetButtonItem;
    
    self.title=self.groupData.gp_name;
    
    [self initCalendar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initCalendar
{
    // 1. Instantiate a FlyingCalendarView
    if(!_calendarView)
    {
        _calendarView = [[FlyingCalendarView alloc] init];
        
        // 2. Optionally, set up the datasource and delegates
        [_calendarView setDelegate:self];
        [_calendarView setDataSource:self];
        
        [_calendarView setDisplayMode:FlyingCalendarViewModeWeek animated:NO];
        _calendarView.firstWeekDay = 2;
        
        // 3. Present the calendar
        [[self view] addSubview:_calendarView];
    }
    
    self.data = [[NSMutableDictionary alloc] init];
    
    
    //测试代码
    //  An event for the new MBCalendarKit release.
    NSString *title = NSLocalizedString(@"Release MBCalendarKit 2.2.4", @"");
    NSDate *date = [NSDate dateWithDay:21 month:9 year:2015];
    FlyingCalendarEvent *releaseUpdatedCalendarKit = [FlyingCalendarEvent eventWithTitle:title andDate:date andInfo:nil];
    releaseUpdatedCalendarKit.eventID=@"123";
    
    //  An event for the new Hunger Games movie.
    NSString *title2 = NSLocalizedString(@"The Hunger Games: Mockingjay, Part 1", @"");
    NSDate *date2 = [NSDate dateWithDay:22 month:9 year:2015];
    FlyingCalendarEvent *mockingJay = [FlyingCalendarEvent eventWithTitle:title2 andDate:date2 andInfo:nil];
    mockingJay.eventID=@"123";
    
    //  Integrate MBCalendarKit
    NSString *integrationTitle = NSLocalizedString(@"Integrate MBCalendarKit", @"");
    NSDate *integrationDate = date2;
    FlyingCalendarEvent *integrationEvent = [FlyingCalendarEvent eventWithTitle:integrationTitle andDate:integrationDate andInfo:nil];
    
    //  An event for the new MBCalendarKit release.
    NSString *title3 = NSLocalizedString(@"Fix bug where events don't show up immediately.", @"");
    NSDate *date3 = [NSDate dateWithDay:21 month:9 year:2015];
    FlyingCalendarEvent *fixBug = [FlyingCalendarEvent eventWithTitle:title3 andDate:date3 andInfo:nil];
    fixBug.eventID=@"123";
    
    /**
     *  Add the events to the data source.
     *
     *  The key is the date that the array of events appears on.
     */
    
    self.data[date] = @[releaseUpdatedCalendarKit];
    self.data[date2] = @[mockingJay, integrationEvent];
    self.data[date3] = @[fixBug];
    
    [self loadEvents];
}

-(void) loadEvents
{
    [self.calendarView reload];
}

#pragma mark - FlyingCalendarViewDataSource

- (NSArray *)calendarView:(FlyingCalendarView *)CalendarView eventsForDate:(NSDate *)date
{
    return self.data[date];
}

#pragma mark - FlyingCalendarViewDelegate

// Called before/after the selected date changes
- (void)calendarView:(FlyingCalendarView *)calendarView willSelectDate:(NSDate *)date
{
}

- (void)calendarView:(FlyingCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    
}

//  A row is selected in the events table. (Use to push a detail view or whatever.)
- (void)calendarView:(FlyingCalendarView *)calendarView didSelectEvent:(FlyingCalendarEvent *)event
{
    FlyingEventVC* eventVC = [[FlyingEventVC alloc] init];
    
    eventVC.eventData=event;
    
    [self.navigationController pushViewController:eventVC animated:YES];
}

#pragma mark
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

//LogoDone functions
- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) doReset
{
    [_calendarView setDate:[NSDate date] animated:NO];
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

-(BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shakeNow];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void) addBackFunction
{
    
    //在一个函数里面（初始化等）里面添加要识别触摸事件的范围
    UISwipeGestureRecognizer *recognizer= [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}



@end
