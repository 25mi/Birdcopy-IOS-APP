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

@class FlyingFakeHUD;
@class MWFeedItem;

@interface FlyingWebViewController : UIViewController< UIWebViewDelegate,
                                                        UIGestureRecognizerDelegate,
                                                        FlyingUIWebViewDelegate>
@property (strong, nonatomic) IBOutlet FlyingUIWebView *webView;

@property (strong, nonatomic) IBOutlet FlyingFakeHUD *stateBar;
@property (strong, nonatomic) IBOutlet UILabel *tipsLabel;

@property (strong, nonatomic) NSString *webURL;
@property (strong, nonatomic) NSString *lessonID;

@end
