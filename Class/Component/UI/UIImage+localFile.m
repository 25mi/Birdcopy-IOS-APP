//
//  UIImage+localFile.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "UIImage+localFile.h"

@implementation UIImage (localFile)

+ (UIImage *)thumnailImageWithName:(NSString *)name Type:(NSString *)type  withSize:(CGSize) newSize
{

    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSData *image = [NSData dataWithContentsOfFile:filePath];
    
    return [[UIImage imageWithData:image]  makeThumbnailOfSize:newSize];
}

+ (UIImage *)thumnailImageWithPath:(NSString *)filePath withSize:(CGSize) newSize
{

    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    if(image){
        
        return [image  makeThumbnailOfSize:newSize];
    }
    else{
    
        return nil;
    }
}

- (UIImage*) makeThumbnailOfSize: (CGSize) newSize
{
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

