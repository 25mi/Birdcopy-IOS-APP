//
//  FlyingWordDetailVC.h
//  FlyingEnglish
//
//  Created by vincent on 3/6/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"
#import "FlyingViewController.h"

@class FlyingItemParser;

@interface FlyingWordDetailVC : FlyingViewController<PSCollectionViewDataSource,
                                                PSCollectionViewDelegate>

@property (strong, nonatomic)     PSCollectionView   *wordDetailCollectView;

@property (strong, nonatomic)      NSMutableArray     *itemList;
@property (strong, nonatomic)      FlyingItemParser   *itemParser;

@property (strong, nonatomic)      NSString   *theWord;
@property (assign, nonatomic)      NSString   *showingModle;

@end
