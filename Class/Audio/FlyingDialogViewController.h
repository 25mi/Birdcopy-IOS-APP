//
//  FlyingDialogViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 11/16/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"
#import "FlyingAILearningViewDelegate.h"

static void *FlyingDialogViewControllerPlayerItemStatusObserverContext = &FlyingDialogViewControllerPlayerItemStatusObserverContext;
static void *FlyingDialogViewControllerSubtitlStatusObserverContext    = &FlyingDialogViewControllerSubtitlStatusObserverContext;
static void *FlyingDialogViewControllerRateObservationContext          = &FlyingDialogViewControllerRateObservationContext;
static void *FlyingDialogViewControllerTrackObservationContext         = &FlyingDialogViewControllerTrackObservationContext;


@class FlyingAILearningView;
@class AVPlayer;
@class AVPlayerItem;
@class AVPlayerItem;

@interface FlyingDialogViewController : UIViewController<FlyingAILearningViewDelegate,
                                                        UIBubbleTableViewDataSource,
                                                         UIGestureRecognizerDelegate>

@property (nonatomic, strong)     NSString          *lessonID;

@property (strong, nonatomic)     UIImageView       *backgroundImagview;

@property (strong, nonatomic)          AVPlayer          *player;
@property (nonatomic)                  AVPlayerItem      *playerItem;
@property (strong, nonatomic)          id                 playerObserver;

- (void)  finishLearning;

@end
