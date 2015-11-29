//
//  FlyingCoverViewCell.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/7/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class FlyingCoverData;

@interface FlyingCoverViewCell : PSCollectionViewCell

+ (CGFloat)rowHeightForObject:(FlyingCoverData *)coverData inColumnWidth:(CGFloat)columnWidth;


@end
