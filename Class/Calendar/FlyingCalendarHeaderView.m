//
//  FlyingCalendarHeaderView.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCalendarHeaderView.h"
#import "shareDefine.h"
#import "NSString+Color.h"

@interface FlyingCalendarHeaderView ()
{
    NSUInteger _columnCount;
    CGFloat _columnTitleHeight;
}

@property (nonatomic, strong) UILabel *monthTitle;

@property (nonatomic, strong) NSMutableArray *columnTitles;
@property (nonatomic, strong) NSMutableArray *columnLabels;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightGesture;


@end

@implementation FlyingCalendarHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _monthTitle = [UILabel new];
        //[_monthTitle setShadowColor:kCalendarColorHeaderMonthShadow];
        //[_monthTitle setShadowOffset:CGSizeMake(0, 1)];
        [_monthTitle setBackgroundColor:[UIColor clearColor]];
        [_monthTitle setTextAlignment:NSTextAlignmentLeft];
        [_monthTitle setFont:[UIFont boldSystemFontOfSize:16]];
        
        _columnTitles = [NSMutableArray new];
        _columnLabels = [NSMutableArray new];
        
        _columnTitleHeight = 10;
        
        self.swipeLeftGesture  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [self.swipeLeftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:self.swipeLeftGesture];
        
        self.swipeRightGesture  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        [self.swipeRightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:self.swipeRightGesture];
    }
    return self;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self setNeedsLayout];
    //[self setBackgroundColor:kCalendarColorHeaderGradientDark];
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /* Show & position the title Label */
    
    CGFloat upperRegionHeight = [self frame].size.height - _columnTitleHeight;
    CGFloat titleLabelHeight = 27;
    
    if ([[self dataSource] numberOfColumnsForHeader:self] == 0) {
        titleLabelHeight = [self frame].size.height;
        upperRegionHeight = titleLabelHeight;
    }
    
    CGFloat yOffset = upperRegionHeight/2 - titleLabelHeight/2;
    
    CGRect frame = CGRectMake(yOffset*3, yOffset, [self frame].size.width, titleLabelHeight);
    [[self monthTitle] setFrame:frame];
    [self addSubview:[self monthTitle]];
    
    /* Update the month title. */
    
    NSString *title = [[self dataSource] titleForHeader:self];
    [[self monthTitle] setText:title];
    
    /* Highlight the title color as appropriate */
    
    if ([self shouldHighlightTitle])
    {
        [[self monthTitle] setTextColor:kCalendarColorHeaderTitleHighlightedBlue];
    }
    else
    {
        [[self monthTitle] setTextColor:[UIColor blackColor]];
    }
        
    /*  Check for a data source for the header to be installed */
    if (![self dataSource]) {
        @throw [NSException exceptionWithName:@"FlyingCalendarViewHeaderException" reason:@"Header can't be installed without a data source" userInfo:@{@"Header": self}];
    }
    
    /* Query the data source for the number of columns. */
    _columnCount = [[self dataSource] numberOfColumnsForHeader:self];
    
    
    /* Remove old labels */
    
    for (UILabel *label in [self columnLabels]) {
        [label removeFromSuperview];
    }
    
    [[self columnLabels] removeAllObjects];
    
    /* Query the datasource for the titles.*/
    [[self columnTitles] removeAllObjects];
    
    for (NSUInteger column = 0; column < _columnCount; column++) {
        NSString *title = [[self dataSource] header:self titleForColumnAtIndex:column];
        [[self columnTitles] addObject:title];
    }
    
    /* Convert title strings into labels and lay them out */
    
    if(_columnCount > 0){
        CGFloat labelWidth = [self frame].size.width/_columnCount;
        CGFloat labelHeight = _columnTitleHeight;
        
        for (NSUInteger i = 0; i < [[self columnTitles] count]; i++) {
            NSString *title = [self columnTitles][i];
            
            UILabel *label = [self _columnLabelWithTitle:title];
            [[self columnLabels] addObject:label];
            
            CGRect frame = CGRectMake(i*labelWidth, [self frame].size.height-labelHeight, labelWidth, labelHeight);
            [label setFrame:frame];
            
            [self addSubview:label];
        }
    }
}

#pragma mark - Convenience Methods

/* Creates and configures a label for a column title */

- (UILabel *)_columnLabelWithTitle:(NSString *)title
{
    UILabel *l = [UILabel new];
    [l setBackgroundColor:[UIColor clearColor]];
    [l setTextColor:kCalendarColorHeaderWeekdayTitle];
    //[l setShadowColor:kCalendarColorHeaderWeekdayShadow];
    [l setTextAlignment:NSTextAlignmentCenter];
    [l setFont:[UIFont boldSystemFontOfSize:10]];
    //[l setShadowOffset:CGSizeMake(0, 1)];
    [l setText:title];
    
    return l;
}

#pragma mark - Touch Handling

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction==UISwipeGestureRecognizerDirectionRight)
    {
        [self backwardButtonTapped];
    }
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft)
    {
        [self forwardButtonTapped];
    }
}

#pragma mark - Button Handling

- (void)forwardButtonTapped
{
    if ([[self delegate] respondsToSelector:@selector(forwardTapped)]) {
        [[self delegate] forwardTapped];
    }
}

- (void)backwardButtonTapped
{
    if ([[self delegate] respondsToSelector:@selector(backwardTapped)]) {
        [[self delegate] backwardTapped];
    }
}

#pragma mark - Title Highlighting

- (BOOL)shouldHighlightTitle
{
    if ([[self delegate] respondsToSelector:@selector(headerShouldHighlightTitle:)]) {
        return [[self dataSource] headerShouldHighlightTitle:self];
    }
    return NO;  //  Default is no.
}

#pragma mark - Button Disabling

- (BOOL)shouldDisableForwardButton
{
    if ([[self dataSource] respondsToSelector:@selector(headerShouldDisableForwardButton:)]) {
        return [[self dataSource] headerShouldDisableForwardButton:self];
    }
    return NO;  //  Default is no.
}

- (BOOL)shouldDisableBackwardButton
{
    if ([[self dataSource] respondsToSelector:@selector(headerShouldDisableBackwardButton:)]) {
        return [[self dataSource] headerShouldDisableBackwardButton:self];
    }
    return NO;  //  Default is no.
}


@end
