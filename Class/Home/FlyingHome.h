//
//  FlyingHome.h
//  FlyingEnglish
//
//  Created by BE_Air on 9/13/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"
#import "FlyingCoverView.h"
#import "FlyingLoadingView.h"


@interface FlyingHome : UIViewController<FlyingCoverViewDelegate,
                                        PSCollectionViewDataSource,
                                        PSCollectionViewDelegate,
                                        FlyingLoadingViewDelegate>

@property (strong, nonatomic) NSMutableArray     *currentTagData;

@property (strong, nonatomic) PSCollectionView   *homeFeatureTagPSColeectionView;


@end
