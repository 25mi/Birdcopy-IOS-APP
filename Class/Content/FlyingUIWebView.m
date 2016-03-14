//
//  FlyingUIWebView.m
//  FlyingEnglish
//
//  Created by BE_Air on 2/13/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingUIWebView.h"

@implementation FlyingUIWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self initContextMenu];
        UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapOne.numberOfTouchesRequired = 1;
        singleTapOne.numberOfTapsRequired = 1;
        singleTapOne.delegate=self;
        [self addGestureRecognizer:singleTapOne];
        
        UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapOne.numberOfTouchesRequired = 1;
        doubleTapOne.numberOfTapsRequired = 2;
        doubleTapOne.delegate=self;

        [self addGestureRecognizer:doubleTapOne];
        
        [singleTapOne requireGestureRecognizerToFail:doubleTapOne];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

    
-(void) initContextMenu
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *menuItemDefine = [[UIMenuItem alloc] initWithTitle:@"互动一下" action:@selector(showDefine:)];
    NSArray *mArray = [NSArray arrayWithObjects:menuItemDefine,nil];
    [menuController setMenuItems:mArray];
}


-(void)showDefine:(id)sender;
{
    NSString* selection = [self stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];

    if (self.flyingwebviewdelegate &&
        [self.flyingwebviewdelegate respondsToSelector:@selector(willShowWordView:)]) {
    
        [self.flyingwebviewdelegate willShowWordView:selection];
    }
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action == @selector(showDefine:)){
        
        return YES;
    }
    
    return NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.flyingwebviewdelegate &&
        [self.flyingwebviewdelegate respondsToSelector:@selector(handleSingleTap:)]) {
        
        [self.flyingwebviewdelegate handleSingleTap:recognizer];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer;
{
    if (self.flyingwebviewdelegate &&
        [self.flyingwebviewdelegate respondsToSelector:@selector(handleDoubleTap:)]) {
        
        [self.flyingwebviewdelegate handleDoubleTap:recognizer];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
