//
//  UIImageView+thumnail.h
//  FlyingEnglish
//
//  Created by BE_Air on 12/3/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BEImageThumnailCompletedBlock)(UIImage *thumbnailImage);


@interface UIImageView (thumnail)

- (void)setThumnailImageWithPath:(NSString *)path thumnailSize:(CGSize)size completed:(BEImageThumnailCompletedBlock)completedBlock;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
