//
//  UIView+Autosizing.m
//  FlyingEnglish
//
//  Created by vincent sung on 3/18/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "UIView+Autosizing.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Autosizing)

- (void) adjustForAutosizing
{
    [self setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
}


-(void) setRoundLine
{
    self.layer.cornerRadius = 6;
    if (INTERFACE_IS_PAD ) {
        self.layer.cornerRadius = 14;
    }
    
    self.layer.masksToBounds = YES;
    
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor= [[UIColor colorWithRed:207.0f/255.0f green:207.0f/255.0f blue:207.0f/255.0f alpha:1] CGColor];
}

-(void) setRound
{
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
}

-(void) setShadow
{
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f); // [水平偏移, 垂直偏移]
    self.layer.shadowOpacity = 0.5f; // 0.0 ~ 1.0 的值
    self.layer.shadowRadius = 5.0f; // 陰影發散的程度
}

-(void) setLittleShadow
{
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f); // [水平偏移, 垂直偏移]
    self.layer.shadowOpacity = 0.5f; // 0.0 ~ 1.0 的值
    self.layer.shadowRadius = 1.0f; // 陰影發散的程度
}

-(void) setMiniShadow
{
    
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0.5f, 0.5f); // [水平偏移, 垂直偏移]
    self.layer.shadowOpacity = 0.5f; // 0.0 ~ 1.0 的值
    self.layer.shadowRadius = 0.5f; // 陰影發散的程度
}

@end
