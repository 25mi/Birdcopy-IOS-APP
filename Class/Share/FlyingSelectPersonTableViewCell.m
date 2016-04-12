//
//  RCDSelectPersonTableViewCell.m
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "FlyingSelectPersonTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "NSString+FlyingExtention.h"
#import "shareDefine.h"

@implementation FlyingSelectPersonTableViewCell

-(void)awakeFromNib
{
    self.ivAva.clipsToBounds = YES;
    self.ivAva.layer.cornerRadius = 8.f;
    
    self.lblName.font= [UIFont boldSystemFontOfSize:KLargeFontSize];
    [self.ivAva setContentMode:UIViewContentModeScaleAspectFill];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _ivSelected.image = [UIImage imageNamed:@"select"];
    }else{
        _ivSelected.image = [UIImage imageNamed:@"unselect"];
    }
}


+ (FlyingSelectPersonTableViewCell*) selectPersonCell
{
    FlyingSelectPersonTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingSelectPersonTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)settingWithContentData:(RCUserInfo*) userInfo
{
    self.lblName.text = userInfo.name;
    
    if (![NSString isBlankString:userInfo.portraitUri]) {
        
        [self.ivAva setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]
                     placeholderImage:[UIImage imageNamed:@"Account"]];
    }
    else
    {
        [self.ivAva setImage:[UIImage imageNamed:@"Account"]];
    }
}


@end
