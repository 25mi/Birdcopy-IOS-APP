//
//  FlyingWordItemCell.h
//  FlyingEnglish
//
//  Created by vincent on 3/5/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class FlyingItemData;

@interface FlyingWordItemCell : PSCollectionViewCell

@property  (strong, nonatomic) FlyingItemData *detailData;

+ (CGFloat)rowHeightForObject:(FlyingItemData *)detailData inColumnWidth:(CGFloat)columnWidth;

@end



