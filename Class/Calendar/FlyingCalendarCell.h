//
//  FlyingCalendarCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    FlyingCalendarMonthCellStateTodaySelected = 0,      //  Today's cell, selected
    FlyingCalendarMonthCellStateTodayDeselected = 1,    //  Today's cell, unselected
    FlyingCalendarMonthCellStateNormal,                 //  Cells that are part of this month, unselected
    FlyingCalendarMonthCellStateSelected,               //  Cells that are part of this month, selected
    FlyingCalendarMonthCellStateInactive,               //  Cells that are not part of this month
    FlyingCalendarMonthCellStateInactiveSelected,       //  Transient state for out of month cells
    FlyingCalendarMonthCellStateOutOfRange              //  A state for cells that are bounded my min/max constraints on the calendar picker
    
} FlyingCalendarMonthCellState;

@interface FlyingCalendarCell : UIView

@property (nonatomic, assign) FlyingCalendarMonthCellState state;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, assign) BOOL showDot;

@property (nonatomic, assign) NSUInteger index;

// Background colors
@property (nonatomic, strong) UIColor *normalBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *inactiveSelectedBackgroundColor UI_APPEARANCE_SELECTOR;

//  Overrides normalBackgroundColor and selectedBackgroundColor for cell representing today
@property (nonatomic, strong) UIColor *todayBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *todaySelectedBackgroundColor UI_APPEARANCE_SELECTOR;

//  Text colors for today override the default text colors
@property (nonatomic, strong) UIColor *todayTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *todayTextShadowColor UI_APPEARANCE_SELECTOR;

// Text color and shadow color
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textShadowColor UI_APPEARANCE_SELECTOR;

// Selected text color and shadow color
@property (nonatomic, strong) UIColor *textSelectedColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textSelectedShadowColor UI_APPEARANCE_SELECTOR;

// Color for the event dot
@property (nonatomic, strong) UIColor *dotColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedDotColor UI_APPEARANCE_SELECTOR;

// Border colors
@property (nonatomic, strong) UIColor *cellBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedCellBorderColor UI_APPEARANCE_SELECTOR;


- (id)initWithSize:(CGSize)size;

-(void)prepareForReuse;

- (void)setSelected;    //  Select a given cell
- (void)setDeselected;  //  Deselect the cell
- (void)setOutOfRange;  //  Deselect and style to show that the cell isn't selectable

@end