//
//  FlyingContentCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 2/28/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingContentCell.h"
#import "shareDefine.h"
#import "FlyingPubLessonData.h"
#import <UIImageView+AFNetworking.h>
#import "NSString+FlyingExtention.h"

@implementation FlyingContentCell

- (void)awakeFromNib
{
    // Initialization code
    self.titleLabel.font        = [UIFont systemFontOfSize:KLargeFontSize];

    self.dateLabel.font         = [UIFont systemFontOfSize:KSmallFontSize];
    self.commentCountLable.font = [UIFont systemFontOfSize:KSmallFontSize];
    
    [self.coverImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingContentCell*) contentCell
{
    FlyingContentCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingContentCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)settingWithContentData:(FlyingPubLessonData*) contentData
{
    self.contentData = contentData;
    
    self.titleLabel.text = contentData.title;
    self.dateLabel.text = @"10小时前";
    
    if([contentData.timeLamp containsString:@"-"] &&
       [contentData.timeLamp containsString:@":"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *Date = [dateFormatter dateFromString:contentData.timeLamp];
        
        self.dateLabel.text =[NSString stringFromTimeInterval:-[Date timeIntervalSinceNow]];
    }
    else
    {
        NSDate *now = [NSDate date];
        self.dateLabel.text = [NSString stringFromTimeInterval:-[now timeIntervalSinceNow]];
    }
    
    self.commentCountLable.text = contentData.commentCount;
    
    self.detailTextLabel.text =contentData.desc;
    
    if (contentData.imageURL.length!=0) {
        
        [self.coverImageView  setImageWithURL:[NSURL URLWithString:contentData.imageURL] placeholderImage:[UIImage imageNamed:@"Default"]];
    }
    else
    {
        [self.coverImageView setImage:[UIImage imageNamed:@"Default"]];
    }
    
    if ([contentData.contentType isEqualToString:KContentTypeText])
    {
        [_contentTypeImageView setImage:[UIImage imageNamed:PlayDocIcon]];
    }
    else if ([contentData.contentType isEqualToString:KContentTypeVideo])
    {
        [_contentTypeImageView setImage:[UIImage imageNamed:PlayVideoIcon]];
    }
    else  if ([contentData.contentType isEqualToString:KContentTypeAudio])
    {
        [_contentTypeImageView setImage:[UIImage imageNamed:PlayAudioIcon]];
    }
    else  if ([contentData.contentType isEqualToString:KContentTypePageWeb])
    {
        [_contentTypeImageView setImage:[UIImage imageNamed:PlayWebIcon]];
    }
}

@end
