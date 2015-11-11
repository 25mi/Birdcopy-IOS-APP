//
//  FlyingCalendarCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//
#import "FlyingCalendarCell.h"
#import "NSString+Color.h"
#import "shareDefine.h"

@interface FlyingCalendarCell (){
    CGSize _size;
}

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIView *dotView;

@end

@implementation FlyingCalendarCell

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        _state = FlyingCalendarMonthCellStateNormal;
        
        //  Normal Cell Colors
        _normalBackgroundColor = kCalendarColorLightGray;
        _selectedBackgroundColor = kCalendarColorBlue;
        _inactiveSelectedBackgroundColor = kCalendarColorDarkGray;
        
        //  Today Cell Colors
        _todayBackgroundColor = kCalendarColorBluishGray;
        _todaySelectedBackgroundColor = kCalendarColorBlue;
        _todayTextShadowColor = kCalendarColorTodayShadowBlue;
        _todayTextColor = [UIColor whiteColor];
        
        //  Text Colors
        _textColor = kCalendarColorDarkTextGradient;
        _textShadowColor = [UIColor whiteColor];
        _textSelectedColor = [UIColor whiteColor];
        _textSelectedShadowColor = kCalendarColorSelectedShadowBlue;
        
        _dotColor = kCalendarColorDarkTextGradient;
        _selectedDotColor = [UIColor whiteColor];
        
        _cellBorderColor = kCalendarColorCellBorder;
        _selectedCellBorderColor = kCalendarColorSelectedCellBorder;
        
        // Label
        _label = [UILabel new];
        
        //  Dot
        _dotView = [UIView new];
        [_dotView setHidden:NO];
        _showDot = NO;
    }
    return self;
}

- (id)initWithSize:(CGSize)size
{
    self = [self init];
    if (self) {
        _size = size;
    }
    return self;
}

#pragma mark - View Hierarchy

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    CGPoint origin = [self frame].origin;
    [self setFrame:CGRectMake(origin.x, origin.y, _size.width, _size.height)];
    [self layoutSubviews];
    [self applyColors];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [self configureLabel];
    [self configureDot];
    
    [self addSubview:[self label]];
    [self addSubview:_dotView];
}

#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.label.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
}


- (void)setState:(FlyingCalendarMonthCellState)state
{
    if (state > FlyingCalendarMonthCellStateOutOfRange || state < FlyingCalendarMonthCellStateTodaySelected) {
        return;
    }
    
    _state = state;
    
    [self applyColorsForState:_state];
}

- (void)setNumber:(NSNumber *)number
{
    _number = number;
    
    //  TODO: Locale support?
    NSString *stringVal = [number stringValue];
    [[self label] setText:stringVal];
}

- (void)setShowDot:(BOOL)showDot
{
    _showDot = showDot;
    [_dotView setHidden:!showDot];
}

#pragma mark - Recycling Behavior

-(void)prepareForReuse
{
    //  Alpha, by default, is 1.0
    [[self label]setAlpha:1.0];
    
    [self setState:FlyingCalendarMonthCellStateNormal];
    
    [self applyColors];
}

#pragma mark - Label

- (void)configureLabel
{
    UILabel *label = [self label];
    
    [label setFont:[UIFont boldSystemFontOfSize:13]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFrame:CGRectMake(0, 0, [self frame].size.width, [self frame].size.height)];
}

#pragma mark - Dot

- (void)configureDot
{
    CGFloat dotRadius = 3;
    CGFloat selfHeight = [self frame].size.height;
    CGFloat selfWidth = [self frame].size.width;
    
    [[_dotView layer] setCornerRadius:dotRadius/2];
    
    CGRect dotFrame = CGRectMake(selfWidth/2 - dotRadius/2, (selfHeight - (selfHeight/5)) - dotRadius/2, dotRadius, dotRadius);
    [_dotView setFrame:dotFrame];
}

#pragma mark - UI Coloring

- (void)applyColors
{
    [self applyColorsForState:[self state]];
}

//  TODO: Make the cell states bitwise, so we can use masks and clean this up a bit
- (void)applyColorsForState:(FlyingCalendarMonthCellState)state
{
    //  Default colors and shadows
    [[self label] setTextColor:[self textColor]];
    [[self label] setShadowColor:[self textShadowColor]];
    [[self label] setShadowOffset:CGSizeMake(0, 0.5)];

    [self setBackgroundColor:[self normalBackgroundColor]];
    
    //  Today cell
    if(state == FlyingCalendarMonthCellStateTodaySelected)
    {
        [self setBackgroundColor:[self todaySelectedBackgroundColor]];
        [[self label] setShadowColor:[self todayTextShadowColor]];
        [[self label] setTextColor:[self todayTextColor]];
    }
    
    //  Today cell, selected
    else if(state == FlyingCalendarMonthCellStateTodayDeselected)
    {
        [self setBackgroundColor:[self todayBackgroundColor]];
        [[self label] setShadowColor:[self todayTextShadowColor]];
        [[self label] setTextColor:[self todayTextColor]];
    }
    
    //  Selected cells in the active month have a special background color
    else if(state == FlyingCalendarMonthCellStateSelected)
    {
        [self setBackgroundColor:[self selectedBackgroundColor]];
        [[self label] setTextColor:[self textSelectedColor]];
        [[self label] setShadowColor:[self textSelectedShadowColor]];
        [[self label] setShadowOffset:CGSizeMake(0, -0.5)];
    }
    
    if (state == FlyingCalendarMonthCellStateInactive) {
        [[self label] setAlpha:0.5];    //  Label alpha needs to be lowered
        [[self label] setShadowOffset:CGSizeZero];
    }
    else if (state == FlyingCalendarMonthCellStateInactiveSelected)
    {
        [[self label] setAlpha:0.5];    //  Label alpha needs to be lowered
        [[self label] setShadowOffset:CGSizeZero];
        [self setBackgroundColor:[self inactiveSelectedBackgroundColor]];
    }
    else if(state == FlyingCalendarMonthCellStateOutOfRange)
    {
        [[self label] setAlpha:0.01];    //  Label alpha needs to be lowered
        [[self label] setShadowOffset:CGSizeZero];
    }
    
    //  Make the dot follow the label's style
    [_dotView setBackgroundColor:[UIColor redColor]];
    //[_dotView setAlpha:[[self label] alpha]];
}

#pragma mark - Selection State

- (void)setSelected
{
    FlyingCalendarMonthCellState state = [self state];
    
    if (state == FlyingCalendarMonthCellStateInactive) {
        [self setState:FlyingCalendarMonthCellStateInactiveSelected];
    }
    else if(state == FlyingCalendarMonthCellStateNormal)
    {
        [self setState:FlyingCalendarMonthCellStateSelected];
    }
    else if(state == FlyingCalendarMonthCellStateTodayDeselected)
    {
        [self setState:FlyingCalendarMonthCellStateTodaySelected];
    }
}

- (void)setDeselected
{
    FlyingCalendarMonthCellState state = [self state];
    
    if (state == FlyingCalendarMonthCellStateInactiveSelected) {
        [self setState:FlyingCalendarMonthCellStateInactive];
    }
    else if(state == FlyingCalendarMonthCellStateSelected)
    {
        [self setState:FlyingCalendarMonthCellStateNormal];
    }
    else if(state == FlyingCalendarMonthCellStateTodaySelected)
    {
        [self setState:FlyingCalendarMonthCellStateTodayDeselected];
    }
}

- (void)setOutOfRange
{
    [self setState:FlyingCalendarMonthCellStateOutOfRange];
}

@end
