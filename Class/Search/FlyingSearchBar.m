//
//  FlyingSearchBar.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingSearchBar.h"

@implementation FlyingSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    //self.backgroundColor=[UIColor clearColor];

    //[self setShowsCancelButton:NO animated:NO];
    
    double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
    
    if(version <7.0)
    {
        for (UIView *subview in self.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }  
        } 
    }
}


@end
