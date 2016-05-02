//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"
#import "FlyingCoverView.h"
#import "YALSunnyRefreshControl.h"

@interface FlyingHomeVC : FlyingViewController<UITableViewDataSource,
                                                UITableViewDelegate,
                                                FlyingCoverViewDelegate,
                                                YALSunnyRefreshControlDelegate>

@property (strong, nonatomic) FlyingCoverView    *coverFlow;
@property (strong, atomic)    NSMutableArray     *currentData;
@property (strong, nonatomic) UITableView        *groupTableView;

@end
