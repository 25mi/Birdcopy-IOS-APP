//
//  FlyingScrollView.m
//  FlyingEnglish
//
//  Created by vincent on 3/20/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingScrollView.h"

@implementation FlyingScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return ![view isKindOfClass:[UIButton class]];
}



@end
