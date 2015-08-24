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
#import "iFlyingAppDelegate.h"


@interface FlyingCalendarVC ()<CKCalendarViewDelegate,UIViewControllerRestoration>
{
    CKCalendarView *_calendarView;
    UISegmentedControl *_modePicker;
}

@property (nonatomic, strong) NSMutableDictionary *eventDataList;

@end

@implementation FlyingCalendarVC

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *retViewController = [[FlyingCalendarVC alloc] initWithNibName:nil bundle:nil];
    return retViewController;
}

-(void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.eventDataList forKey:@"eventDataList"];
}

-(void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.eventDataList = [coder decodeObjectForKey:@"eventDataList"];
    
    [self initCalendar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = @"FlyingLessonVC";
    self.restorationClass      = [self class];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIImage *image= [UIImage imageNamed:@"back"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    NSString *todayTitle =@"今天";
    UIBarButtonItem *todayButtonItem = [[UIBarButtonItem alloc] initWithTitle:todayTitle style:UIBarButtonItemStyleBordered target:self action:@selector(todayButtonTapped:)];
    
    _modePicker=[[UISegmentedControl alloc] initWithItems:@[@"日",@"周",@"月"]];
    [_modePicker addTarget:self action:@selector(modeChangedUsingControl:) forControlEvents:UIControlEventValueChanged];
    [_modePicker setSelectedSegmentIndex:0];

    self.navigationItem.titleView = _modePicker;
    
    self.navigationItem.rightBarButtonItem = todayButtonItem;
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
    NSDate *date = [NSDate dateWithDay:16 month:8 year:2015];
    CKCalendarEvent *releaseUpdatedCalendarKit = [CKCalendarEvent eventWithTitle:title andDate:date andInfo:nil];
    
    //  An event for the new Hunger Games movie.
    NSString *title2 = NSLocalizedString(@"The Hunger Games: Mockingjay, Part 1", @"");
    NSDate *date2 = [NSDate dateWithDay:16 month:8 year:2015];
    CKCalendarEvent *mockingJay = [CKCalendarEvent eventWithTitle:title2 andDate:date2 andInfo:nil];
    
    //  An event for the new MBCalendarKit release.
    NSString *title3 = NSLocalizedString(@"Fix bug where events don't show up immediately.", @"");
    NSDate *date3 = [NSDate dateWithDay:16 month:8 year:2015];
    CKCalendarEvent *fixBug = [CKCalendarEvent eventWithTitle:title3 andDate:date3 andInfo:nil];
    
    /**
     *  Add the events to the data source.
     *
     *  The key is the date that the array of events appears on.
     */
    
    self.eventDataList = [NSMutableDictionary new];
    
    self.eventDataList[date] = @[releaseUpdatedCalendarKit];
    self.eventDataList[date2] = @[mockingJay, fixBug];
    
    [_calendarView setDisplayMode:CKCalendarViewModeWeek];
}

#pragma mark - CKCalendarViewDataSource

- (NSArray *)calendarView:(CKCalendarView *)CalendarView eventsForDate:(NSDate *)date
{
    return self.eventDataList[date];
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


#pragma mark - Toolbar Items

- (void)modeChangedUsingControl:(id)sender
{
    [_calendarView setDisplayMode:(CKCalendarDisplayMode)[_modePicker selectedSegmentIndex]];
}

- (void)todayButtonTapped:(id)sender
{
    [_calendarView setDate:[NSDate date] animated:NO];
}


#pragma mark - Orientation Support

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [_calendarView reloadAnimated:NO];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_calendarView reloadAnimated:NO];
}


//LogoDone functions
- (void)dismiss{
    
    [self.navigationController popViewControllerAnimated:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shakeNow];
    }
}

- (void)viewDidDisappear:(BOOL)animated
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
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

-(void) handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if ((recognizer.state ==UIGestureRecognizerStateEnded) || (recognizer.state ==UIGestureRecognizerStateCancelled)) {
        
        [self dismiss];
    }
}

#pragma only portart events
//////////////////////////////////////////////////////////////
-(BOOL)shouldAutorotate
{
    return NO;
}

@end
