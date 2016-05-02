//
//  FlyingMyGroupsVC.h
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"
#import "YALSunnyRefreshControl.h"

@interface FlyingMyGroupsVC : FlyingViewController<UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    YALSunnyRefreshControlDelegate>

@property (strong, atomic)    NSMutableArray     *currentData;
@property (strong, nonatomic) UITableView        *groupTableView;

@end
