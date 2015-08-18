//
//  FlyingMyLessonCell.h
//  FlyingEnglish
//
//  Created by BE_Air on 9/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class FlyingNowLessonData;


@interface FlyingMyLessonCell : PSCollectionViewCell

+ (CGFloat)rowHeightForObject:(FlyingNowLessonData *)detailData inColumnWidth:(CGFloat)columnWidth;

@end
