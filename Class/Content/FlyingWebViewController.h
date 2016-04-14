//
//  FlyingWebViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 8/26/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIWebView.h>
#import "FlyingUIWebView.h"
#import "FlyingViewController.h"
#import <NJKWebViewProgress.h>

@class FlyingFakeHUD;
@class MWFeedItem;
@class FlyingPubLessonData;

@interface FlyingWebViewController : FlyingViewController< UIWebViewDelegate,
                                                        UIGestureRecognizerDelegate,
                                                        FlyingUIWebViewDelegate,
                                                        NJKWebViewProgressDelegate>
@property (strong, nonatomic) NSString *webURL;
@property (strong, nonatomic) FlyingPubLessonData * thePubLesson;


@end
