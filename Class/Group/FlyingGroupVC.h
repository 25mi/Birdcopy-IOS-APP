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
@class FlyingStreamData;

@interface FlyingGroupVC : UIViewController<UITableViewDataSource,
                                            UITableViewDelegate,
                                            FlyingGroupDetailsViewDelegate,
                                            UICollectionViewDataSource,
                                            UICollectionViewDelegate>

@property (strong, nonatomic) UIView *navigationBarView;
@property (weak, nonatomic)   UIView *networkLoadingContainerView;
@property (weak, nonatomic)   UILabel *navBarTitleLabel;


@property (strong, nonatomic) FlyingGroupDetailsView   *groupView;

@property (strong, nonatomic) NSMutableArray           *currentData;
@property (strong, nonatomic) FlyingGroupData          *groupData;
@property (strong, nonatomic) FlyingStreamData         *topBoardNewsData;


@end
