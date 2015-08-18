//
//  FlyingSubtitleTextView.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/16/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingSubtitleTextView.h"


@implementation FlyingSubtitleTextView

@synthesize currentSubtitleIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setCurrentSubtitleIndex:NSNotFound]; //片头字幕空白区
        [self setDataDetectorTypes:UIDataDetectorTypeNone];

        self.editable=NO;
        self.selectable=YES;
        
        // Initialization code
        [self addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

    }
    return self;
}

- (void)awakeFromNib
{
    [self setCurrentSubtitleIndex:NSNotFound]; //片头字幕空白区
    [self setDataDetectorTypes:UIDataDetectorTypeNone];
    
    self.editable=NO;
    self.selectable=YES;
    
    [self addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

//屏蔽UItext各种手势操作
- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer{
    
}

//屏蔽UItext事件处理，让AIlearning处理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super.nextResponder touchesMoved:touches withEvent:event];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    [self.nextResponder touchesEnded:touches withEvent:event];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    [self.nextResponder touchesCancelled:touches withEvent:event];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentSize"];

#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}


@end
