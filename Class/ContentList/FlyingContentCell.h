//
//  FlyingContentCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 2/28/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTENT_CELL_IDENTIFIER @"contetnCell"

@class FlyingPubLessonData;

@interface FlyingContentCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel                 *titleLabel;

@property (nonatomic, strong) IBOutlet UILabel                 *descriptionLable;

@property (nonatomic, strong) IBOutlet UILabel                 *dateLabel;

@property (nonatomic, strong) IBOutlet UIImageView             *contentTypeImageView;


@property (strong, nonatomic) IBOutlet UILabel *commentCountLable;
@property (nonatomic, strong) IBOutlet UIImageView             *coverImageView;

@property (nonatomic, strong) FlyingPubLessonData* contentData;

+ (FlyingContentCell*) contentCell;

-(void)settingWithContentData:(FlyingPubLessonData*) contentData;


@end
