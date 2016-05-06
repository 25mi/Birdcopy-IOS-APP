//
//  FlyingWebViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 8/26/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIWebView.h>
#import "FlyingViewController.h"
#import "FlyingPubLessonData.h"

@interface FlyingWebViewController : FlyingViewController
@property (strong, nonatomic) NSString *webURL;
@property (strong, nonatomic) FlyingPubLessonData * thePubLesson;


@end
