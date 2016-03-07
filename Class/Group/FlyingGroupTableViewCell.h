//
//  FlyingGroupTableViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 2/25/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GROUPCELL_IDENTIFIER @"groupCell"

@class FlyingGroupData;

@interface FlyingGroupTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView   * groupIconImageView;
@property (nonatomic, strong) IBOutlet UILabel       * nameLabel;

@property (nonatomic, strong) IBOutlet UILabel       * memberCountLabel;
@property (nonatomic, strong) IBOutlet UILabel       * contentCountLabel;

@property (nonatomic, strong) IBOutlet UILabel       * dateLabel;

@property (nonatomic, strong) IBOutlet UILabel       * descriptionLabel;

@property (nonatomic, strong) FlyingGroupData* groupData;

+ (FlyingGroupTableViewCell*) groupCell;

-(void)settingWithGroupData:(FlyingGroupData*) groupData;

@end
