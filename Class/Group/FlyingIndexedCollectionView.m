//
//  FlyingIndexedCollectionView.m
//  FlyingEnglish
//
//  Created by vincent sung on 22/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingIndexedCollectionView.h"

@implementation FlyingIndexedCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    if (self.supportTouch)
    {
        return [super hitTest:point withEvent:event];
    }
    else
    {
        return nil;

    }
    /*
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if ([hitView isKindOfClass:[FlyingIndexedCollectionView class]])
    {
        // If it is class UICollectionView,just return nil.
        return nil;
    }
    // else return super implementation.
    return [super hitTest:point withEvent:event];
     */
}



@end