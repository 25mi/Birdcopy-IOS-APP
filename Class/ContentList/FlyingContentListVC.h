//
//  FlyingMyGroupsVC.h
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"

@interface FlyingContentListVC : FlyingViewController<
                                                    UITableViewDataSource,
                                                    UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray     *currentData;
@property (strong, nonatomic) NSString           *tagString;

@property (strong, nonatomic) NSString           *contentType;
@property (strong, nonatomic) NSString           *downloadType;

@property (assign, nonatomic) BOOL               isOnlyFeatureContent;

@property (strong, nonatomic) NSString           *domainID;
@property (assign, nonatomic) BC_Domain_Type     domainType;

@property (strong, nonatomic) UITableView        *contentTableView;

@end
