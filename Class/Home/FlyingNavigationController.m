//
//  FlyingNavigationController.m
//  FlyingEnglish
//
//  Created by vincent on 3/15/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingNavigationController.h"
#import "shareDefine.h"


@interface FlyingNavigationController()<UIViewControllerRestoration>
@end

@implementation FlyingNavigationController


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}


- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationClass = [self class];
    }
    return self;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
