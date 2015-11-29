//
//  FlyingMediaVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/26/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlyingAILearningView.h"


@protocol FlyingMediaVCDelegate<NSObject>

@required
- (void)doSwitchToFullScreen:(BOOL) toFullScreen;

@end

@class FlyingPubLessonData;

@interface FlyingMediaVC : UIViewController<FlyingAILearningViewDelegate,UIWebViewDelegate>

@property (strong, nonatomic) FlyingPubLessonData * theLesson;

@property (nonatomic, weak, readwrite) id <FlyingMediaVCDelegate> delegate;

-(void)play;
-(void)pause;

-(void)adjustRelayout;

- (void)dismiss;

@end
