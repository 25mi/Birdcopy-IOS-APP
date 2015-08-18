//
//  FlyingMagView.m
//  FlyingEnglish
//
//  Created by BE_Air on 11/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingMagView.h"
#import "shareDefine.h"

@implementation FlyingMagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    

    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:self];
    
    CGFloat deviceWith=self.frame.size.width;
    CGFloat deviceHeight=self.frame.size.height;
    
    CGFloat coinShopWith=0;
    CGFloat coinShopHeight=0;
    
    if (INTERFACE_IS_PAD ) {
        
        if (deviceWith<deviceHeight) {
            
            coinShopWith=KLandscapeShopWith*2;
            coinShopHeight=KLandscapeShopHeight*2;
        }
        else{
            
            coinShopWith=KPortraitShopWith*2;
            coinShopHeight=KPortraitShopWith*2;
        }
    }
    else{
        
        if (self.frame.size.width<self.frame.size.height) {
            
            
            coinShopWith=KLandscapeShopWith;
            coinShopHeight=KLandscapeShopHeight/2;
        }
        else{
            
            coinShopWith=KPortraitShopWith;
            coinShopHeight=KPortraitShopWith/2;
        }
    }
    CGRect frame=CGRectMake((deviceWith-coinShopWith)/2, (deviceHeight-coinShopHeight)/2, coinShopWith, coinShopHeight);
    
    if(CGRectContainsPoint(frame,touchPoint)&&self.AImagnifyEnabled) {
        
        [self.myDelegate touchOnSubtileBegin:touchPoint];
        
        [super touchesBegan:touches withEvent:event];
    }
    else{
        
        [self.myDelegate tapSomeWhere:touchPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (self.AImagnifyEnabled) {
        
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        [self.myDelegate touchOnSubtileMoved:touchPoint];
        
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.AImagnifyEnabled) {
        
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        [self.myDelegate touchOnSubtileEnd:touchPoint];
        
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.AImagnifyEnabled) {
        
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        [self.myDelegate touchOnSubtileCancelled:touchPoint];
        
        [super touchesEnded:touches withEvent:event];
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
