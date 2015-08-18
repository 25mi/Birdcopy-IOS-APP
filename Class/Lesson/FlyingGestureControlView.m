//
//  FlyingGestureControlView.m
//  FlyingEnglish
//
//  Created by vincent sung on 10/20/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingGestureControlView.h"

@implementation FlyingGestureControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//只是为了防止事件继续传递
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}


- (void)dealloc
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
    
}

@end
