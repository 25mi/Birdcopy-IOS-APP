//
//  PSCollectionViewCell+delete.m
//  FlyingEnglish
//
//  Created by BE_Air on 9/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "PSCollectionViewCell+delete.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "UIImage+localFile.h"


@implementation PSCollectionViewCell (delete)

- (void) setEditing:(BOOL)editing
{
    if (!self.deleteButton) {
        
        UIImage * deleteButtonIcon = [UIImage imageNamed:@"delete"];
        if (INTERFACE_IS_PAD) {
            
            deleteButtonIcon = [UIImage imageNamed:@"delete@2x"];
        }

        
        self.deleteButton=[[UIButton alloc] initWithFrame:CGRectMake(0,
                                                  0,
                                                  deleteButtonIcon.size.width,
                                                   deleteButtonIcon.size.height)];
        
        [self.deleteButton setImage:deleteButtonIcon forState:UIControlStateNormal];
        [self.deleteButton setTitle:nil forState:UIControlStateNormal];
        [self.deleteButton setBackgroundColor:[UIColor clearColor]];
        [self.deleteButton setAlpha:0];
        
        [self.deleteButton addTarget:self action:@selector(actionDelete) forControlEvents:UIControlEventTouchUpInside];

        
        [self addSubview:self.deleteButton];
    }
    
    [self bringSubviewToFront:self.deleteButton];
    
    [UIView animateWithDuration:0.2f
                          delay:0.f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut
                     animations:^{
                         self.deleteButton.alpha = editing? 1.f : 0.f;
                     }
                     completion:nil];
    
    [self shakeStatus:editing];
}


- (void)shakeStatus:(BOOL)enabled
{
    if (enabled)
    {
        CGFloat rotation = 0.03;
        
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
        shake.duration = 0.13;
        shake.autoreverses = YES;
        shake.repeatCount  = MAXFLOAT;
        shake.removedOnCompletion = NO;
        shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-rotation, 0.0 ,0.0 ,1.0)];
        shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
        
        [self.layer addAnimation:shake forKey:@"shakeAnimation"];
    }
    else
    {
        [self.layer removeAnimationForKey:@"shakeAnimation"];
    }
}

- (void)actionDelete
{
    if (self.deleteBlock)
    {
        self.deleteBlock(self);
    }
}


@end
