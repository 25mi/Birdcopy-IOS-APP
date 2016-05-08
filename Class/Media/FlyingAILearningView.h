//
//  FlyingAILearningView.h
//  FlyingEnglish
//
//  Created by vincent sung on 10/17/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlyingAILearningViewDelegate.h"

#import "ACMagnifyingView.h"

@interface FlyingAILearningView : ACMagnifyingView

@property (nonatomic, assign) BOOL AImagnifyEnabled;
@property (nonatomic, weak)   id<FlyingAILearningViewDelegate>  delegate;

@property (nonatomic, weak)   UIView   *subtitleTextView;

@end
