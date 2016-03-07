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
#import "UIImageView+WebCache.h"

@implementation FlyingContentCell

- (void)awakeFromNib
{
    // Initialization code
    self.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    self.titleLabel.font        = [UIFont boldSystemFontOfSize:KLargeFontSize];
    self.descriptionLable.font  = [UIFont systemFontOfSize:KLittleFontSize];

    self.dateLabel.font         = [UIFont systemFontOfSize:KSmallFontSize];
    self.commentCountLable.font = [UIFont systemFontOfSize:KSmallFontSize];
    
    [self.coverImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
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
    self.descriptionLable.text = contentData.desc;
    self.dateLabel.text = @"10小时前";
    
    self.detailTextLabel.text =contentData.desc;
    
    if (contentData.imageURL.length!=0) {
        [self.coverImageView  sd_setImageWithURL:[NSURL URLWithString:contentData.imageURL] placeholderImage:[UIImage imageNamed:@"Default"]];
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
