//
//  MAOFlipInteraction.m
//  MAOFlipViewController
//
//  Created by Mao Nishi on 2014/05/06.
//  Copyright (c) 2014年 Mao Nishi. All rights reserved.
//

#import "MAOFlipInteraction.h"
#import "MAOPanGestureRecognizer.h"

@implementation MAOFlipInteraction

- (void)setView:(UIView *)view
{
    _view = view;
    for (UIPanGestureRecognizer *r in view.gestureRecognizers) {
        if ([r isKindOfClass:[MAOPanGestureRecognizer class]]) {
            [view removeGestureRecognizer:r];
        }
    }
    
    UIPanGestureRecognizer *gesture =[[MAOPanGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(handlePan:)];
    
    // 右划的 Recognizer
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleRightSwipeTapFrom:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    
    // 关键在这一行，如果双击确定偵測失败才會触发单击
    [gesture requireGestureRecognizerToFail:rightSwipe];
    
    [self.view addGestureRecognizer:gesture];
}

- (void)handleRightSwipeTapFrom: (id) sender

{
    if ([self.delegate respondsToSelector:@selector(handleRightSwipeTapFrom:)]) {
        
        [self.delegate handleRightSwipeTapFrom:sender];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint nowPoint = [gesture locationInView:self.view];
            //CGFloat boundary = CGRectGetMidY(self.view.frame);
            CGPoint velocity = [gesture velocityInView:self.view];
            
            BOOL isDownwards = (velocity.y > 0);
            
            if (isDownwards) {
                //NSLog(@"Downwards...");
            } else {
                //NSLog(@"Upwards...");
            }
            
            if (!isDownwards) {
                self.isPushMode = YES;
                [self.delegate interactionPushBeganAtPoint:nowPoint];
            } else {
                self.isPushMode = NO;
                [self.delegate interactionPopBeganAtPoint:nowPoint];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGRect viewRect = self.view.bounds;
            CGPoint translation = [gesture translationInView:self.view];
            CGFloat percent = translation.y / viewRect.size.height;
            percent = fabsf([@(percent) floatValue]);
            percent = MIN(1.0, MAX(0.0, percent));
            [self updateInteractiveTransition:percent];
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGPoint nowPoint = [gesture locationInView:self.view];
            CGFloat boundary = (self.view.frame.origin.y + (self.view.frame.size.height / 2));
            
            if (self.isPushMode)
            {
                if (boundary > nowPoint.y)
                {
                    [self finishInteractiveTransition];
                }
                else
                {
                    [self cancelInteractiveTransition];
                }
            }
            else
            {
                if (boundary < nowPoint.y)
                {
                    [self finishInteractiveTransition];
                    
                    [self.delegate completePopInteraction];
                }
                else
                {
                    [self cancelInteractiveTransition];
                }
            }
            break;
        }
        default:
            break;
    }
}

@end
