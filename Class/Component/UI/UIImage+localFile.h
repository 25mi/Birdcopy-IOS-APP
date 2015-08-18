//
//  UIImage+localFile.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (localFile)

+ (UIImage *)thumnailImageWithName:(NSString *)name Type:(NSString *)type  withSize:(CGSize) newSize;
+ (UIImage *)thumnailImageWithPath:(NSString *)filePath withSize:(CGSize) newSize;

- (UIImage *) makeThumbnailOfSize:(CGSize) newSize;

@end
