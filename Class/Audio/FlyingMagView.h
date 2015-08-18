//
//  FlyingMagView.h
//  FlyingEnglish
//
//  Created by BE_Air on 11/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "ACMagnifyingView.h"
#import "FlyingAILearningViewDelegate.h"


@interface FlyingMagView : ACMagnifyingView

@property (nonatomic, weak)   id<FlyingAILearningViewDelegate>  myDelegate;
@property (nonatomic, assign) BOOL AImagnifyEnabled;


@end
