//
//  FlyingGroupTableViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 2/25/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingGroupTableViewCell.h"
#import "shareDefine.h"
#import "FlyingGroupData.h"
#import "UIImageView+WebCache.h"

@implementation FlyingGroupTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    self.nameLabel.font= [UIFont boldSystemFontOfSize:KLargeFontSize];
    
    self.memberCountLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.contentCountLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.dateLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.descriptionLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    [self.groupIconImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (FlyingGroupTableViewCell*) groupCell
{
    FlyingGroupTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingGroupTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)settingWithGroupData:(FlyingGroupData*) groupData
{
    self.groupData = groupData;
    
    if (groupData.logo.length!=0) {
        [self.groupIconImageView sd_setImageWithURL:[NSURL URLWithString:groupData.logo] placeholderImage:[UIImage imageNamed:@"Icon"]];
    }
    else
    {
        [self.groupIconImageView setImage:[UIImage imageNamed:@"Icon"]];
    }
    
    self.nameLabel.text = groupData.gp_name;
    //self.memberCountLabel.text = groupData.gp_member_sum;
    
    self.dateLabel.text = @"9月5日14点32分";
    
    self.descriptionLabel.text = groupData.gp_desc;
}
@end
