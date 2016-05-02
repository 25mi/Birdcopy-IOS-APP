//
//  YALSunyRefreshControl.h
//  YALSunyPullToRefresh
//
//  Created by Konstantin Safronov on 12/24/14.
//  Copyright (c) 2014 Konstantin Safronov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YALSunnyRefreshControlDelegate <UITableViewDelegate, UITextViewDelegate>

@required
- (void)beginRefreshing;
@end

@interface YALSunnyRefreshControl : UIControl

@property (nonatomic, weak) id<YALSunnyRefreshControlDelegate> delegate;

- (void)attachToScrollView:(UIScrollView *)scrollView;
- (void)beginRefreshing;
- (void)endRefreshing;

@end
