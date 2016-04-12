//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"
#import "FlyingGroupCoverView.h"

@interface FlyingGroupVC : FlyingViewController<
                                                UITableViewDataSource,
                                                UITableViewDelegate>

@property (strong, nonatomic) FlyingGroupData    *groupData;

@end
