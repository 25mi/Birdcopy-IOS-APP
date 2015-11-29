//
//  FlyingLessonViewCell.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/5/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "PSCollectionViewCell.h"
@class FlyingPubLessonData;

@interface FlyingLessonViewCell : PSCollectionViewCell

+ (CGFloat)rowHeightForObject:(FlyingPubLessonData *)detailData inColumnWidth:(CGFloat)columnWidth;

@end
