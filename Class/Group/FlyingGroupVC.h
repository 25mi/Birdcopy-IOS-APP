//
//  FlyingGroupVC.h
//  FlyingEnglish
//
//  Created by vincent on 9/8/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingGroupDetailsView.h"


@class FlyingGroupData;

@interface FlyingGroupVC : UIViewController<UITableViewDataSource,
                                            UITableViewDelegate,
                                            FlyingGroupDetailsViewDelegate,
                                            UICollectionViewDataSource,
                                            UICollectionViewDelegate>

@property (strong, nonatomic) UIView *navigationBarView;
@property (weak, nonatomic) UIView *networkLoadingContainerView;
@property (weak, nonatomic) UILabel *navBarTitleLabel;

@property (strong, nonatomic) NSMutableArray           *currentData;

@property (strong, nonatomic) FlyingGroupDetailsView   *detailsGroupView;

@property (strong, nonatomic) FlyingGroupData* groupData;


@end
