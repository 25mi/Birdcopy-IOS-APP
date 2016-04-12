//
//  FlyingViewController.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/25/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingViewController : UIViewController

@property (strong, nonatomic)   NSString    *domainID;
@property (strong, nonatomic)   NSString    *domainType;

- (void) dismissNavigation;

@end
