//
//  FlyingUIWebView.h
//  FlyingEnglish
//
//  Created by BE_Air on 2/13/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlyingUIWebViewDelegate <NSObject>

@optional

- (void) willShowWordView:(NSString*) word;

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer;
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer;

@end


@interface FlyingUIWebView : UIWebView<UIGestureRecognizerDelegate>

@property(nonatomic,assign) id<FlyingUIWebViewDelegate> flyingwebviewdelegate;

-(void) initContextMenu;

@end
