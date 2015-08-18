//
//  FlyingImagePreivewVC.h
//  FlyingEnglish
//
//  Created by vincent on 6/30/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingImagePreivewVC : UIViewController

/** 实际图片URL */
@property(nonatomic, strong) NSString *imageUrl;
/** 原始图 */
@property(nonatomic, strong) UIImage *originalImage;


@end
