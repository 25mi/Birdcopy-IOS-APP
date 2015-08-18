//
//  FlyingProviderViewCell.h
//  FlyingEnglish
//
//  Created by vincent on 1/19/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class FlyingProvider;

@interface FlyingProviderViewCell : PSCollectionViewCell

+ (CGFloat)rowHeightForObject:(FlyingProvider *)detailData inColumnWidth:(CGFloat)columnWidth;

@end
