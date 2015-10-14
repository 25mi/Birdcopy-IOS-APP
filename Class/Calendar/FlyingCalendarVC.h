//
//  FlyingCalendarVC.h
//  FlyingEnglish
//
//  Created by vincent on 8/16/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlyingGroupData;
@class FlyingCalendarView;

@interface FlyingCalendarVC : UIViewController

@property (strong, nonatomic) NSMutableArray           *currentData;
@property (strong, nonatomic) FlyingGroupData          *groupData;

@property (strong, nonatomic) FlyingCalendarView        *calendarView;

@end