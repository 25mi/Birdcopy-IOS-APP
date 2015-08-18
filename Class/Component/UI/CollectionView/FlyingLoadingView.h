//
//  FlyingLoadingView.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/5/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlyingLoadingViewDelegate;


@interface FlyingLoadingView : UIView

- (void) showTitle:(NSString * )str;
- (void) showIndicator;

@property (weak,nonatomic) id <FlyingLoadingViewDelegate> loadingViewDelegate;

@end


#pragma mark - Delegate

@protocol FlyingLoadingViewDelegate <NSObject>

@optional

- (BOOL) downloadMore;
-(void)  doSearch;

@end
