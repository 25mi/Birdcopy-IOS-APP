//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"
#import "shareDefine.h"
#import "YALSunnyRefreshControl.h"


@interface FlyingContentListVC : FlyingViewController<
                                                    UITableViewDataSource,
                                                    UITableViewDelegate,
                                                    YALSunnyRefreshControlDelegate>

@property (strong, nonatomic) NSMutableArray     *currentData;


@property (strong, nonatomic) NSString           *tagString;
@property (atomic,assign)     BOOL                NoTagWork;

@property (strong, nonatomic) NSString           *contentType;
@property (strong, nonatomic) NSString           *downloadType;
@property (assign, nonatomic) NSString           *recommend;

@property (strong, nonatomic) UITableView        *contentTableView;

@end
