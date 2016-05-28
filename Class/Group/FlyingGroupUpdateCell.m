//
//  FlyingGroupTableViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 2/25/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingGroupUpdateCell.h"
#import "shareDefine.h"
#import "FlyingGroupUpdateData.h"
#import <UIImageView+AFNetworking.h>
#import "NSString+FlyingExtention.h"

@implementation FlyingGroupUpdateCell

- (void)awakeFromNib
{
    // Initialization code
    self.nameLabel.font         = [UIFont boldSystemFontOfSize:KLargeFontSize];
    
    self.memberCountLabel.font  = [UIFont systemFontOfSize:KSmallFontSize];
    self.contentCountLabel.font = [UIFont systemFontOfSize:KSmallFontSize];
    self.dateLabel.font         = [UIFont systemFontOfSize:KSmallFontSize];
    
    self.updateContentLabel.font= [UIFont systemFontOfSize:KLittleFontSize];
    
    [self.groupIconImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingGroupUpdateCell*) groupCell
{
    FlyingGroupUpdateCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingGroupUpdateCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)settingWithGroupData:(FlyingGroupUpdateData*) updateGroupData;
{
    self.updateGroupData = updateGroupData;
    
    if (updateGroupData.groupData.logo.length!=0)
    {
        [self.groupIconImageView setImageWithURL:[NSURL URLWithString:updateGroupData.groupData.logo]
                                placeholderImage:[UIImage imageNamed:@"Icon"]];
    }
    else
    {
        [self.groupIconImageView setImage:[UIImage imageNamed:@"Icon"]];
    }
    
    self.nameLabel.text =updateGroupData.groupData.gp_name;
    self.memberCountLabel.text = updateGroupData.groupData.gp_member_sum;
    self.contentCountLabel.text = updateGroupData.groupData.gp_ln_sum;
    
    if([updateGroupData.recentLessonData.timeLamp containsString:@"-"] &&
       [updateGroupData.recentLessonData.timeLamp containsString:@":"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *Date = [dateFormatter dateFromString:updateGroupData.recentLessonData.timeLamp];
        
        self.dateLabel.text =[NSString stringFromTimeInterval:-[Date timeIntervalSinceNow]];
    }
    else
    {
        self.dateLabel.text = updateGroupData.recentLessonData.timeLamp;
    }
    
    if (updateGroupData.recentLessonData.imageURL.length!=0)
    {
        [self.updateImageView setImageWithURL:[NSURL URLWithString:updateGroupData.recentLessonData.imageURL]
                             placeholderImage:[UIImage imageNamed:@"Default"]];
    }
    else
    {
        [self.updateImageView setImage:[UIImage imageNamed:@"Icon"]];
    }
    
    self.updateContentLabel.text = updateGroupData.recentLessonData.desc;
}
@end
