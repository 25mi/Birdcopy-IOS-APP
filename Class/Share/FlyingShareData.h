//
//  FlyingShareData.h
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingShareData : NSObject

@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSURL     *webURL;
@property (nonatomic, strong) UIImage   *image;

@property (nonatomic, strong) NSString  *digest;
@property (nonatomic, strong) NSString  *imageURL;

@end
