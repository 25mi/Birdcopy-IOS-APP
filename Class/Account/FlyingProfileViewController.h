//
//  FlyingProfileViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 8/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlyingFakeHUD;
@class CERoundProgressView;
@class FlyingRoundView;

@interface FlyingProfileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *coinTitleLabel;
@property (strong, nonatomic) IBOutlet UIView  *coinDataView;

@property (strong, nonatomic) IBOutlet UILabel *coinLabel2;
@property (strong, nonatomic) IBOutlet UILabel *coinLabel3;
@property (strong, nonatomic) IBOutlet UILabel *coinLabel4;
@property (strong, nonatomic) IBOutlet UILabel *giftCountNow;
@property (strong, nonatomic) IBOutlet UILabel *touchCountNow;
@property (strong, nonatomic) IBOutlet UILabel *totalCoinNow;
@property (strong, nonatomic) IBOutlet CERoundProgressView *coinProgressView;

@property (nonatomic, strong) UIImageView * line;

@end
