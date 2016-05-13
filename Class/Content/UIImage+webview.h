//
//  UIImage+webview.h
//  FlyingEnglish
//
//  Created by vincent sung on 10/5/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (webview)

/* Navigation Buttons */
+ (instancetype) backButton;
+ (instancetype) forwardButton;
+ (instancetype) refreshButton;
+ (instancetype) stopButton;
+ (instancetype) actionButton;

+ (instancetype) readButton;

@end
