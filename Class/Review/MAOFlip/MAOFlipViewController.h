//
//  MAOFlipViewController.h
//  MAOFlipViewController
//
//  Created by Mao Nishi on 2014/05/06.
//  Copyright (c) 2014年 Mao Nishi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAOFlipViewController;

@protocol MAOFlipViewControllerDelegate <NSObject>

- (UIViewController*)flipViewController:(MAOFlipViewController*)flipViewController contentIndex:(NSUInteger)contentIndex;
- (NSUInteger)numberOfFlipViewControllerContents;
- (void) reachEnd;

- (void)handleRightSwipeTapFrom: (id) sender;

@end

@interface MAOFlipViewController : UIViewController

@property (nonatomic,strong) UINavigationController *flipNavigationController;
@property (nonatomic, weak) id<MAOFlipViewControllerDelegate> delegate;

@end
