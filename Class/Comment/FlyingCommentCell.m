//
//  FlyingCommentCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/20/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCommentCell.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import <UIImageView+AFNetworking.h>

@implementation FlyingCommentCell

- (void)awakeFromNib {
    // Initialization code
    
    self.nameLabel.font= [UIFont boldSystemFontOfSize:KNormalFontSize];
    self.dateLabel.font= [UIFont systemFontOfSize:KLittleFontSize];
    self.commentLabel.font= [UIFont systemFontOfSize:KLittleFontSize];
    
    [self.profileImageView.layer setCornerRadius:(self.profileImageView.frame.size.height/2)];
    [self.profileImageView.layer setMasksToBounds:YES];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.profileImageView setClipsToBounds:YES];
    self.profileImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.profileImageView.layer.shadowOffset = CGSizeMake(4, 4);
    self.profileImageView.layer.shadowOpacity = 0.5;
    self.profileImageView.layer.shadowRadius = 2.0;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingCommentCell*) commentCell
{
    FlyingCommentCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingCommentCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)setCommentData:(FlyingCommentData*)commentData
{
    if (commentData.portraitURL.length!=0) {
        
        [self.profileImageView setImageWithURL:[NSURL URLWithString:commentData.portraitURL] placeholderImage:[UIImage imageNamed:@"Icon"]];
    }
    else{
        
        [self.profileImageView setImage:[UIImage imageNamed:@"Icon"]];
    }
    
    UITapGestureRecognizer *profileRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewPressed:)];
    profileRecognizer.numberOfTapsRequired = 1; // 单击
    [self.profileImageView addGestureRecognizer:profileRecognizer];
    
    self.nameLabel.text = commentData.nickName;
    
    if([commentData.commentTime containsString:@"-"] && [commentData.commentTime containsString:@":"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *Date = [dateFormatter dateFromString:commentData.commentTime];
        
        self.dateLabel.text =[NSString stringFromTimeInterval:-[Date timeIntervalSinceNow]];
    }
    else
    {
        self.dateLabel.text = commentData.commentTime;
    }
    
    self.commentLabel.text = commentData.commentContent;
}

- (void)profileImageViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileImageViewPressed:)])
    {
        [self.delegate profileImageViewPressed:self.commentData];
    }
}

@end
