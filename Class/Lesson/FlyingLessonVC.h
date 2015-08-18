//
//  FlyingLessonVC.h
//  FlyingEnglish
//
//  Created by vincent on 3/11/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWTagList.h"
#import <QuickLook/QuickLook.h>

#import "FlyingAILearningView.h"

@class FlyingPubLessonData;


@interface FlyingLessonVC : UIViewController<DWTagListDelegate,
                                            QLPreviewControllerDataSource,
                                            QLPreviewControllerDelegate,
                                            UIWebViewDelegate,
                                            FlyingAILearningViewDelegate,
                                            UIViewControllerRestoration>

@property (strong, nonatomic) FlyingPubLessonData * theLesson;


@end
