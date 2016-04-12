//
//  FlyingShareInAppActivity.h
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlyingShareData;

@interface FlyingShareInAppActivity : UIActivity

@property (nonatomic, strong)     NSString  *title;
@property (nonatomic, strong)     NSURL     *url;
@property (nonatomic, strong)     UIImage   *image;

@property (nonatomic, strong) FlyingShareData   *shareData;

@end
