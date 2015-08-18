//
//  FlyingHelpVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 3/2/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlyingHelpVC : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *helpTitle;

@property (strong, nonatomic) IBOutlet UILabel *aboveTitle;
@property (strong, nonatomic) IBOutlet UILabel *aboveDes;

@property (strong, nonatomic) IBOutlet UILabel *middleTitle;
@property (strong, nonatomic) IBOutlet UILabel *middleDes;

@property (strong, nonatomic) IBOutlet UILabel *lastTitle;
@property (strong, nonatomic) IBOutlet UILabel *lastDes;

@property (strong, nonatomic) IBOutlet UILabel *finalTitle;
@property (strong, nonatomic) IBOutlet UILabel *finalDes;

@property (retain, nonatomic) IBOutlet UIScrollView  *pageScroll;

@end
