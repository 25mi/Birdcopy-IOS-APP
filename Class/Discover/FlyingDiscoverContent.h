//
//  FlyingDiscoverContent.h
//  FlyingEnglish
//
//  Created by vincent on 9/5/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PSCollectionView.h"
#import "FlyingCoverView.h"
#import "FlyingLoadingView.h"


@interface FlyingDiscoverContent : UIViewController<FlyingCoverViewDelegate,
                                                    PSCollectionViewDataSource,
                                                    PSCollectionViewDelegate,
                                                    FlyingLoadingViewDelegate>

@property (strong, nonatomic) NSMutableArray     *currentData;

@property (strong, nonatomic) PSCollectionView   *homeFeatureTagPSColeectionView;

@property (strong, nonatomic) NSString           *author;

@end