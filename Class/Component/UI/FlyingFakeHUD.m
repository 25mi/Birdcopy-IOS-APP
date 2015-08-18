//
//  FlyingFakeHUD.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/15/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingFakeHUD.h"
#import <QuartzCore/QuartzCore.h>


@implementation FlyingFakeHUD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        self.backgroundColor=[UIColor blackColor];
        self.alpha=0.5;
        
        self.layer.shouldRasterize = NO;
        // No setting rasterizationScale, will cause blurry images on retina.
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

        [self setRoundStyle];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        // Initialization code
        [self setRoundStyle];
    }

    return self;
}

- (void) setRoundStyle
{
    //self.layer.borderWidth = 0.5f;
    //self.layer.borderColor= [[UIColor colorWithRed:207.0f/255.0f green:207.0f/255.0f blue:207.0f/255.0f alpha:1] CGColor];
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
}


- (void)dismissViewAnimated:(BOOL)animated {
    
    if (animated) {
        
        [UIView animateWithDuration:2 animations:^{
            
            self.alpha=0;
        } completion:^(BOOL finished) {
            
        }];
        
    }
    else{
        
        self.alpha=0;
    }
}

@end
