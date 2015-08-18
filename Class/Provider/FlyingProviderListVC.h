//
//  FlyingProviderListVC.h
//  FlyingEnglish
//
//  Created by vincent on 1/19/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"
#import "FlyingLoadingView.h"
#import <CoreLocation/CoreLocation.h>

typedef void (^SelectProviderBlock)();


@class FlyingFakeHUD;

@interface FlyingProviderListVC : UIViewController<PSCollectionViewDataSource,
                                                    PSCollectionViewDelegate,
                                                    FlyingLoadingViewDelegate>

@property (strong, nonatomic)          PSCollectionView   * providerCollectView;
@property (strong, nonatomic)          NSMutableArray     * currentData;
@property (strong, nonatomic)          NSString           * currentProviderID;

@property (strong, nonatomic)          CLLocation         * myLocation;

@property (strong, nonatomic)          SelectProviderBlock disclosureBlock;


- (void) downloadMore;

@end
