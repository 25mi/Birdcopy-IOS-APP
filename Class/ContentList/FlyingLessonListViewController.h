//
//  FlyingLessonListViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/5/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"
#import "FlyingLoadingView.h"
#import "FlyingCoverData.h"
#import "FlyingViewController.h"

@class FlyingFakeHUD;

@interface FlyingLessonListViewController : FlyingViewController<PSCollectionViewDataSource,
                                                            PSCollectionViewDelegate,
                                                            FlyingLoadingViewDelegate>

@property (strong, nonatomic)          PSCollectionView   *lessonCollectView;
@property (strong, nonatomic)          NSMutableArray     *currentData;
@property (strong, nonatomic)          NSString           *tagString;

@property (strong, nonatomic)          NSString           *contentType;
@property (strong, nonatomic)          NSString           *downloadType;
@property (assign, nonatomic)          BOOL               sortByTime;

@property (assign, nonatomic)          BOOL               recommoned;

@property (strong, nonatomic)          NSString           *author;

- (void) downloadMore;

@end


