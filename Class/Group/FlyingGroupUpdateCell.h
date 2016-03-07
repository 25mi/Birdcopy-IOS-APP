//
//  FlyingGroupTableViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 2/25/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GROUPUPDATECELL_IDENTIFIER @"groupCell"

@class FlyingGroupData;

@interface FlyingGroupUpdateCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView   * groupIconImageView;
@property (nonatomic, strong) IBOutlet UILabel       * nameLabel;

@property (nonatomic, strong) IBOutlet UILabel       * memberCountLabel;
@property (nonatomic, strong) IBOutlet UILabel       * contentCountLabel;

@property (nonatomic, strong) IBOutlet UILabel       * dateLabel;

@property (strong, nonatomic) IBOutlet UIImageView   * updateImageView;
@property (nonatomic, strong) IBOutlet UILabel       * updateContentLabel;

@property (nonatomic, strong) FlyingGroupData* groupData;

+ (FlyingGroupUpdateCell*) groupCell;

-(void)settingWithGroupData:(FlyingGroupData*) groupData;

@end
