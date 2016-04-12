//
//  UIImageView+thumnail.m
//  FlyingEnglish
//
//  Created by BE_Air on 12/3/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "UIImageView+thumnail.h"
#import "UIImage+localFile.m"
#import "shareDefine.h"

@implementation UIImageView (thumnail)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
