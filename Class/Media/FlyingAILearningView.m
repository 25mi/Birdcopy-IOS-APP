 //
//  FlyingAILearningView.m
//  FlyingEnglish
//
//  Created by vincent sung on 10/17/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingAILearningView.h"

@implementation FlyingAILearningView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    //默认关闭放大镜功能
    [self setAImagnifyEnabled:NO];
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if( [self.delegate respondsToSelector:@selector(isPlayingNow)] ) {

        if ([self.delegate isPlayingNow]) {
            
            [self.delegate pauseAndDoAI];
        }
        else{
        
            if( [self.delegate respondsToSelector:@selector(hasSubtitleContent)] ) {
                
                if (![self.delegate hasSubtitleContent]) {
                    
                    [self.delegate playAndDoAI];
                }
            }
        }
    }
    
    if (self.AImagnifyEnabled)
    {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];

        if (CGRectContainsPoint(self.subtitleTextView.frame, touchPoint) &&
            !INTERFACE_IS_PAD)
        {
            [super  touchesBegan:touches withEvent:event];
        }
        
        [self.delegate touchOnSubtileBegin:touchPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.AImagnifyEnabled)
    {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        
        if (CGRectContainsPoint(self.subtitleTextView.frame, touchPoint) &&
            !INTERFACE_IS_PAD)
        {
            
            [super touchesMoved:touches withEvent:event];
        }
        
        [self.delegate touchOnSubtileMoved:touchPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.AImagnifyEnabled)
    {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        
        if (CGRectContainsPoint(self.subtitleTextView.frame, touchPoint) &&
            !INTERFACE_IS_PAD)
        {
            
            [super touchesEnded:touches withEvent:event];
        }
        
        [self.delegate touchOnSubtileEnd:touchPoint];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.AImagnifyEnabled) {

        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        
        if (CGRectContainsPoint(self.subtitleTextView.frame, touchPoint) &&
            !INTERFACE_IS_PAD)
        {
            
            [super touchesEnded:touches withEvent:event];
        }
        
        [self.delegate touchOnSubtileCancelled:touchPoint];
    }
}

- (void)dealloc
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif

}

@end
