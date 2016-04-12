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
#import <UIImageView+AFNetworking.h>
#import "NSString+FlyingExtention.h"
#import "FlyingGroupUpdateData.h"

@implementation FlyingGroupTableViewCell

- (void)awakeFromNib
{
    // Initialization code    
    self.nameLabel.font= [UIFont boldSystemFontOfSize:KLargeFontSize];
    
    self.memberCountLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.contentCountLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.dateLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    self.descriptionLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    [self.groupIconImageView setContentMode:UIViewContentModeScaleAspectFill];
        
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingGroupTableViewCell*) groupCell
{
    FlyingGroupTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingGroupTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)settingWithGroupData:(FlyingGroupUpdateData*) groupUpdateData;
{
    self.groupUpdateData = groupUpdateData;
    
    if (groupUpdateData.groupData.logo.length!=0) {
        
        [self.groupIconImageView setImageWithURL:[NSURL URLWithString:groupUpdateData.groupData.logo] placeholderImage:[UIImage imageNamed:@"Icon"]];
    }
    else
    {
        
        [self.groupIconImageView setImage:[UIImage imageNamed:@"Icon"]];
    }
    
    self.nameLabel.text = groupUpdateData.groupData.gp_name;
    self.memberCountLabel.text = groupUpdateData.groupData.gp_member_sum;
    self.contentCountLabel.text = groupUpdateData.groupData.gp_ln_sum;
    
    if([groupUpdateData.recentLessonData.timeLamp containsString:@"-"] &&
       [groupUpdateData.recentLessonData.timeLamp containsString:@":"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *Date = [dateFormatter dateFromString:groupUpdateData.recentLessonData.timeLamp];
        
        self.dateLabel.text =[NSString stringFromTimeInterval:-[Date timeIntervalSinceNow]];
    }
    else
    {
        NSDate *now = [NSDate date];
        self.dateLabel.text = [NSString stringFromTimeInterval:-[now timeIntervalSinceNow]];
    }
    
    self.descriptionLabel.text = groupUpdateData.groupData.gp_desc;
}
@end
