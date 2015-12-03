//
//  FlyingSubtitleTextView.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/16/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingSubtitleTextView.h"
#import "shareDefine.h"


@implementation FlyingSubtitleTextView

@synthesize currentSubtitleIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self prepareForMagic];
    }
    return self;
}

- (void)awakeFromNib
{
    [self prepareForMagic];
}

-(void) prepareForMagic
{
    self.userInteractionEnabled=YES;
    self.multipleTouchEnabled=YES;
    self.backgroundColor=[UIColor blackColor];
    self.alpha=0.75;
    self.textColor= [UIColor whiteColor];
    self.textAlignment=NSTextAlignmentCenter;
    
    self.font = [UIFont systemFontOfSize:KNormalFontSize];
    
    [self setCurrentSubtitleIndex:NSNotFound]; //片头字幕空白区
    [self setDataDetectorTypes:UIDataDetectorTypeNone];
    
    self.editable=NO;
    self.selectable=YES;
        
    // Initialization code
    [self addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    UITextView *tv = object;
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}


-(void) magicStytle
{
     CAGradientLayer *l = [CAGradientLayer layer];
     self.alpha=0.9;
     l.frame = self.bounds;
     l.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,
     (id)[UIColor lightGrayColor].CGColor,
     (id)[UIColor blackColor ].CGColor,
     (id)[UIColor lightGrayColor].CGColor,
     (id)[UIColor clearColor].CGColor, nil];
     l.startPoint = CGPointMake(0.0f, 0.5f);
     l.endPoint = CGPointMake(1.0f, 0.5f);
     
     self.layer.mask = l;
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
