//
//  UIAlertController+Window.h
//  FlyingEnglish
//
//  Created by vincent sung on 2/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Window)

- (void)show;
- (void)show:(BOOL)animated;
@end


@interface UIAlertController (Private)

@property (nonatomic, strong) UIWindow *alertWindow;

@end