//
//  UIImage+webview.m
//  FlyingEnglish
//
//  Created by vincent sung on 10/5/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "UIImage+webview.h"

@implementation UIImage (webview)

/* Navigation Buttons */
#pragma mark - Navigation Buttons -
+ (instancetype) backButton
{
    UIImage *backButtonImage = nil;
    UIGraphicsBeginImageContextWithOptions((CGSize){12,21}, NO, [[UIScreen mainScreen] scale]);
    {
        //// Color Declarations
        UIColor* backColor = [UIColor blackColor];
        
        //// BackButton Drawing
        UIBezierPath* backButtonPath = [UIBezierPath bezierPath];
        [backButtonPath moveToPoint: CGPointMake(10.9, 0)];
        [backButtonPath addLineToPoint: CGPointMake(12, 1.1)];
        [backButtonPath addLineToPoint: CGPointMake(1.1, 11.75)];
        [backButtonPath addLineToPoint: CGPointMake(0, 10.7)];
        [backButtonPath addLineToPoint: CGPointMake(10.9, 0)];
        [backButtonPath closePath];
        [backButtonPath moveToPoint: CGPointMake(11.98, 19.9)];
        [backButtonPath addLineToPoint: CGPointMake(10.88, 21)];
        [backButtonPath addLineToPoint: CGPointMake(0.54, 11.21)];
        [backButtonPath addLineToPoint: CGPointMake(1.64, 10.11)];
        [backButtonPath addLineToPoint: CGPointMake(11.98, 19.9)];
        [backButtonPath closePath];
        [backColor setFill];
        [backButtonPath fill];
        
        backButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return backButtonImage;
}

+ (instancetype) forwardButton
{
    UIImage *forwardButtonImage = nil;
    UIGraphicsBeginImageContextWithOptions((CGSize){12,21}, NO, [[UIScreen mainScreen] scale]);
    {
        //// Color Declarations
        UIColor* forwardColor = [UIColor blackColor];
        
        //// BackButton Drawing
        UIBezierPath* forwardButtonPath = [UIBezierPath bezierPath];
        [forwardButtonPath moveToPoint: CGPointMake(1.1, 0)];
        [forwardButtonPath addLineToPoint: CGPointMake(0, 1.1)];
        [forwardButtonPath addLineToPoint: CGPointMake(10.9, 11.75)];
        [forwardButtonPath addLineToPoint: CGPointMake(12, 10.7)];
        [forwardButtonPath addLineToPoint: CGPointMake(1.1, 0)];
        [forwardButtonPath closePath];
        [forwardButtonPath moveToPoint: CGPointMake(0.02, 19.9)];
        [forwardButtonPath addLineToPoint: CGPointMake(1.12, 21)];
        [forwardButtonPath addLineToPoint: CGPointMake(11.46, 11.21)];
        [forwardButtonPath addLineToPoint: CGPointMake(10.36, 10.11)];
        [forwardButtonPath addLineToPoint: CGPointMake(0.02, 19.9)];
        [forwardButtonPath closePath];
        [forwardColor setFill];
        [forwardButtonPath fill];
        
        forwardButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return forwardButtonImage;
}

+ (instancetype) refreshButton
{
    UIImage *refreshButtonImage = nil;
    UIGraphicsBeginImageContextWithOptions((CGSize){19,22}, NO, [[UIScreen mainScreen] scale]);
    {
        //// Color Declarations
        UIColor* refreshColor = [UIColor blackColor];
        
        //// RefreshButton Drawing
        UIBezierPath* refreshIconPath = [UIBezierPath bezierPath];
        [refreshIconPath moveToPoint: CGPointMake(18.98, 12)];
        [refreshIconPath addCurveToPoint: CGPointMake(19, 12.8) controlPoint1: CGPointMake(18.99, 12.11) controlPoint2: CGPointMake(19, 12.69)];
        [refreshIconPath addCurveToPoint: CGPointMake(9.5, 22) controlPoint1: CGPointMake(19, 17.88) controlPoint2: CGPointMake(14.75, 22)];
        [refreshIconPath addCurveToPoint: CGPointMake(0, 12.8) controlPoint1: CGPointMake(4.25, 22) controlPoint2: CGPointMake(0, 17.88)];
        [refreshIconPath addCurveToPoint: CGPointMake(10, 3.5) controlPoint1: CGPointMake(0, 7.72) controlPoint2: CGPointMake(4.75, 3.5)];
        [refreshIconPath addCurveToPoint: CGPointMake(10, 5) controlPoint1: CGPointMake(10.02, 3.5) controlPoint2: CGPointMake(10.02, 5)];
        [refreshIconPath addCurveToPoint: CGPointMake(1.69, 12.8) controlPoint1: CGPointMake(5.69, 5) controlPoint2: CGPointMake(1.69, 8.63)];
        [refreshIconPath addCurveToPoint: CGPointMake(9.5, 20.36) controlPoint1: CGPointMake(1.69, 16.98) controlPoint2: CGPointMake(5.19, 20.36)];
        [refreshIconPath addCurveToPoint: CGPointMake(17.31, 12) controlPoint1: CGPointMake(13.81, 20.36) controlPoint2: CGPointMake(17.31, 16.18)];
        [refreshIconPath addCurveToPoint: CGPointMake(17.28, 12) controlPoint1: CGPointMake(17.31, 11.89) controlPoint2: CGPointMake(17.28, 12.11)];
        [refreshIconPath addLineToPoint: CGPointMake(18.98, 12)];
        [refreshIconPath closePath];
        [refreshIconPath moveToPoint: CGPointMake(10, 0)];
        [refreshIconPath addLineToPoint: CGPointMake(17.35, 4.62)];
        [refreshIconPath addLineToPoint: CGPointMake(10, 9.13)];
        [refreshIconPath addLineToPoint: CGPointMake(10, 0)];
        [refreshIconPath closePath];
        [refreshColor setFill];
        [refreshIconPath fill];
        
        refreshButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return refreshButtonImage;
}

+ (instancetype) stopButton
{
    UIImage *stopButtonImage = nil;
    UIGraphicsBeginImageContextWithOptions((CGSize){19,19}, NO, [[UIScreen mainScreen] scale]);
    {
        //// Color Declarations
        UIColor* stopColor = [UIColor blackColor];
        
        //// StopButton Drawing
        UIBezierPath* stopButtonPath = [UIBezierPath bezierPath];
        [stopButtonPath moveToPoint: CGPointMake(19, 17.82)];
        [stopButtonPath addLineToPoint: CGPointMake(17.82, 19)];
        [stopButtonPath addLineToPoint: CGPointMake(9.5, 10.68)];
        [stopButtonPath addLineToPoint: CGPointMake(1.18, 19)];
        [stopButtonPath addLineToPoint: CGPointMake(0, 17.82)];
        [stopButtonPath addLineToPoint: CGPointMake(8.32, 9.5)];
        [stopButtonPath addLineToPoint: CGPointMake(0, 1.18)];
        [stopButtonPath addLineToPoint: CGPointMake(1.18, 0)];
        [stopButtonPath addLineToPoint: CGPointMake(9.5, 8.32)];
        [stopButtonPath addLineToPoint: CGPointMake(17.82, 0)];
        [stopButtonPath addLineToPoint: CGPointMake(19, 1.18)];
        [stopButtonPath addLineToPoint: CGPointMake(10.68, 9.5)];
        [stopButtonPath addLineToPoint: CGPointMake(19, 17.82)];
        [stopButtonPath closePath];
        [stopColor setFill];
        [stopButtonPath fill];
        
        stopButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return stopButtonImage;
}

+ (instancetype) actionButton
{
    UIImage *actionButtonImage = nil;
    UIGraphicsBeginImageContextWithOptions((CGSize){19,30}, NO, [[UIScreen mainScreen] scale]);
    {
        //// Color Declarations
        UIColor* actionColor = [UIColor blackColor];
        
        //// ActionButton Drawing
        UIBezierPath* actionButtonPath = [UIBezierPath bezierPath];
        [actionButtonPath moveToPoint: CGPointMake(1, 9)];
        [actionButtonPath addLineToPoint: CGPointMake(1, 26.02)];
        [actionButtonPath addLineToPoint: CGPointMake(18, 26.02)];
        [actionButtonPath addLineToPoint: CGPointMake(18, 9)];
        [actionButtonPath addLineToPoint: CGPointMake(12, 9)];
        [actionButtonPath addLineToPoint: CGPointMake(12, 8)];
        [actionButtonPath addLineToPoint: CGPointMake(19, 8)];
        [actionButtonPath addLineToPoint: CGPointMake(19, 27)];
        [actionButtonPath addLineToPoint: CGPointMake(0, 27)];
        [actionButtonPath addLineToPoint: CGPointMake(0, 8)];
        [actionButtonPath addLineToPoint: CGPointMake(7, 8)];
        [actionButtonPath addLineToPoint: CGPointMake(7, 9)];
        [actionButtonPath addLineToPoint: CGPointMake(1, 9)];
        [actionButtonPath closePath];
        [actionButtonPath moveToPoint: CGPointMake(9, 0.98)];
        [actionButtonPath addLineToPoint: CGPointMake(10, 0.98)];
        [actionButtonPath addLineToPoint: CGPointMake(10, 17)];
        [actionButtonPath addLineToPoint: CGPointMake(9, 17)];
        [actionButtonPath addLineToPoint: CGPointMake(9, 0.98)];
        [actionButtonPath closePath];
        [actionButtonPath moveToPoint: CGPointMake(13.99, 4.62)];
        [actionButtonPath addLineToPoint: CGPointMake(13.58, 5.01)];
        [actionButtonPath addCurveToPoint: CGPointMake(13.25, 5.02) controlPoint1: CGPointMake(13.49, 5.1) controlPoint2: CGPointMake(13.34, 5.11)];
        [actionButtonPath addLineToPoint: CGPointMake(9.43, 1.27)];
        [actionButtonPath addCurveToPoint: CGPointMake(9.44, 0.94) controlPoint1: CGPointMake(9.34, 1.18) controlPoint2: CGPointMake(9.35, 1.04)];
        [actionButtonPath addLineToPoint: CGPointMake(9.85, 0.56)];
        [actionButtonPath addCurveToPoint: CGPointMake(10.18, 0.55) controlPoint1: CGPointMake(9.94, 0.46) controlPoint2: CGPointMake(10.09, 0.46)];
        [actionButtonPath addLineToPoint: CGPointMake(14, 4.29)];
        [actionButtonPath addCurveToPoint: CGPointMake(13.99, 4.62) controlPoint1: CGPointMake(14.09, 4.38) controlPoint2: CGPointMake(14.08, 4.53)];
        [actionButtonPath closePath];
        [actionButtonPath moveToPoint: CGPointMake(5.64, 4.95)];
        [actionButtonPath addLineToPoint: CGPointMake(5.27, 4.56)];
        [actionButtonPath addCurveToPoint: CGPointMake(5.26, 4.23) controlPoint1: CGPointMake(5.18, 4.47) controlPoint2: CGPointMake(5.17, 4.32)];
        [actionButtonPath addLineToPoint: CGPointMake(9.46, 0.07)];
        [actionButtonPath addCurveToPoint: CGPointMake(9.79, 0.07) controlPoint1: CGPointMake(9.55, -0.02) controlPoint2: CGPointMake(9.69, -0.02)];
        [actionButtonPath addLineToPoint: CGPointMake(10.16, 0.47)];
        [actionButtonPath addCurveToPoint: CGPointMake(10.17, 0.8) controlPoint1: CGPointMake(10.25, 0.56) controlPoint2: CGPointMake(10.26, 0.71)];
        [actionButtonPath addLineToPoint: CGPointMake(5.97, 4.96)];
        [actionButtonPath addCurveToPoint: CGPointMake(5.64, 4.95) controlPoint1: CGPointMake(5.88, 5.05) controlPoint2: CGPointMake(5.74, 5.05)];
        [actionButtonPath closePath];
        [actionColor setFill];
        [actionButtonPath fill];
        
        actionButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return actionButtonImage;
}

+ (instancetype) readButton
{
    UIImage *actionButtonImage = nil;
    UIGraphicsBeginImageContextWithOptions((CGSize){20,20}, NO, [[UIScreen mainScreen] scale]);
    {
        CGFloat scale =0.3;
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(scale*10, scale*17, scale*80, scale*4)];
        [UIColor.blackColor setFill];
        [rectanglePath fill];
        
        
        //// Rectangle 2 Drawing
        UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(scale*10, scale*38, scale*80, scale*4)];
        [UIColor.blackColor setFill];
        [rectangle2Path fill];
        
        
        //// Rectangle 3 Drawing
        UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(scale*10, scale*59, scale*80, scale*4)];
        [UIColor.blackColor setFill];
        [rectangle3Path fill];
        
        
        //// Rectangle 4 Drawing
        UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(scale*10, scale*80, scale*50, scale*4)];
        [UIColor.blackColor setFill];
        [rectangle4Path fill];

        actionButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return actionButtonImage;
}


@end
