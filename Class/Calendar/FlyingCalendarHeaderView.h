//
//  FlyingCalendarHeaderView.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FlyingCalendarHeaderView;

@protocol FlyingCalendarHeaderViewDataSource <NSObject>

- (NSString *)titleForHeader:(FlyingCalendarHeaderView *)header;

- (NSUInteger)numberOfColumnsForHeader:(FlyingCalendarHeaderView *)header;
- (NSString *)header:(FlyingCalendarHeaderView *)header titleForColumnAtIndex:(NSInteger)index;

- (BOOL)headerShouldHighlightTitle:(FlyingCalendarHeaderView *)header;
- (BOOL)headerShouldDisableForwardButton:(FlyingCalendarHeaderView *)header;
- (BOOL)headerShouldDisableBackwardButton:(FlyingCalendarHeaderView *)header;

@end

@protocol FlyingCalendarHeaderViewDelegate <NSObject>

- (void)forwardTapped;
- (void)backwardTapped;

@end

@interface FlyingCalendarHeaderView : UIView

@property (nonatomic, assign) id<FlyingCalendarHeaderViewDataSource> dataSource;
@property (nonatomic, assign) id<FlyingCalendarHeaderViewDelegate> delegate;


@end
