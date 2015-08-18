//
//  FlyingNavigationController.m
//  FlyingEnglish
//
//  Created by vincent on 3/15/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingNavigationController.h"

@implementation FlyingNavigationController

-(NSUInteger)supportedInterfaceOrientations
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

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *retViewController = [[FlyingNavigationController alloc] init];
    return retViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = @"FlyingNavigationController";
    self.restorationClass      = [self class];
}

@end
