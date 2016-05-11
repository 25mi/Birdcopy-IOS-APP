//
//  FlyingSearchViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "shareDefine.h"
#import "FlyingViewController.h"

@interface FlyingSearchViewController : FlyingViewController<UITableViewDataSource,
                                                        UITableViewDelegate>

@property (strong, nonatomic)  UITableView         *tableView;
@property (strong, nonatomic)  NSString            *searchType;

@end
