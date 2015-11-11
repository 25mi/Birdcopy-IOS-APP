//
//  FlyingMyGroupsVC.h
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingMyGroupCell.h"

@interface FlyingMyGroupsVC : UIViewController<UITableViewDataSource,
                                                UITableViewDelegate,
                                                FlyingMyGroupCellDelegate>


@property (strong, nonatomic) NSMutableArray     *currentData;
@property (strong, nonatomic) UITableView        *groupTableView;

@end
