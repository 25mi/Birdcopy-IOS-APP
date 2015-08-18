//
//  FlyingTagTransform.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/23/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingTagTransform : NSObject

- (UIColor *) corlorForTag:(NSString *) tag;

- (NSInteger) indexforTag: (NSString *) tag;

-(NSString *) wordForTag:(NSString *) tag;

-(NSString *) wordForIndex:(NSInteger) index;

- (UIImage *) corlorMagnetForTag:(NSString *) tag;

- (UIImage *)  corlorMagnetForIndex:(NSInteger) index;

@end
