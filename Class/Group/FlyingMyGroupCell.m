//
//  FlyingMyGroupCell.m
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingMyGroupCell.h"
#import "FlyingGroupData.h"
#import "UIImageView+WebCache.h"

@implementation FlyingMyGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        _feedContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _feedContainer.backgroundColor = [UIColor whiteColor];
        _feedContainer.layer.cornerRadius = 3.0f;
        _feedContainer.clipsToBounds = YES;
        _feedContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:_feedContainer.bounds].CGPath;
        
        UIColor* mainColor = [UIColor colorWithRed:100.0/255 green:35.0/255 blue:87.0/255 alpha:1.0f];
        UIColor* countColor = [UIColor colorWithRed:116.0/255 green:99.0/255 blue:113.0/255 alpha:1.0f];
        UIColor* neutralColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        
        NSString* fontName = @"Avenir-Book";
        NSString* boldFontName = @"Avenir-Black";
        
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        _profileImageView.clipsToBounds = YES;
        _profileImageView.userInteractionEnabled=YES;
        
        UIFont *nameLabelFont = [UIFont fontWithName:boldFontName size:(INTERFACE_IS_PAD ? 35.0f : 17.0f)];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor =  mainColor;
        _nameLabel.font = nameLabelFont;

        UIFont *dateLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 24.0f : 12.0f)];
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.textColor = neutralColor;
        _dateLabel.font = dateLabelFont;

        
        UIFont *descriptionLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 26.0f : 13.0f)];
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        _descriptionLabel.textColor =  neutralColor;
        _descriptionLabel.font = descriptionLabelFont;
        
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.userInteractionEnabled=YES;
        
        UIFont *countLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 28.0f : 14.0f)];
        _memberCountButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _memberCountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _memberCountButton.titleLabel.textColor = countColor;
        _memberCountButton.backgroundColor = [UIColor clearColor];
        _memberCountButton.titleLabel.font = countLabelFont;
        
        [_memberCountButton addTarget:self action:@selector(memberCountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        _lessonCountButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _lessonCountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _lessonCountButton.titleLabel.textColor = countColor;
        _lessonCountButton.backgroundColor = [UIColor clearColor];
        _lessonCountButton.titleLabel.font = countLabelFont;
        
        [_lessonCountButton addTarget:self action:@selector(memberCountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        _socialContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _socialContainer.backgroundColor = [UIColor colorWithRed:220.0/255 green:214.0/255 blue:219.0/255 alpha:1.0f];
        
        
#define feedContainerX (INTERFACE_IS_PAD ? 40 : 20)
#define feedContainerWidth (INTERFACE_IS_PAD ? 688 : 280)
#define feedContainerHieght (INTERFACE_IS_PAD ? 608 : 304)
        
#define profileImageViewX (INTERFACE_IS_PAD ? 22 : 11)
#define profileImageViewSize (INTERFACE_IS_PAD ? 70 : 35)
        
#define nameLabelX (INTERFACE_IS_PAD ? 102 : 51)
#define nameLabelWidth (INTERFACE_IS_PAD ? 380 : 190)
#define nameLabelHeight (INTERFACE_IS_PAD ? 42 : 21)
        
#define dateLabelSpeatorY (INTERFACE_IS_PAD ? 32 : 16)
#define dateLabelWidth (INTERFACE_IS_PAD ? 448 : 224)
        
#define descriptionLabelX (INTERFACE_IS_PAD ? 22 : 11)
#define descriptionLabelY (INTERFACE_IS_PAD ? 362 : 181)
#define descriptionLabelWidth (INTERFACE_IS_PAD ? 661 : 263)
#define descriptionLabelHeight (INTERFACE_IS_PAD ? 160 : 80)
        
        
#define memberCountLabelX (INTERFACE_IS_PAD ? 38 : 17)
#define memberCountLabelY (INTERFACE_IS_PAD ? 16 : 8)
#define memberCountLabelWidth (INTERFACE_IS_PAD ? 260 : 130)
        
#define lessonCountLabelSpeator (INTERFACE_IS_PAD ? 40 : 20)
#define lessonCountLabelWidth (INTERFACE_IS_PAD ? 192 : 96)
        
#define coverImageViewSpeatorY (INTERFACE_IS_PAD ? 64 : 32)
#define coverImageViewHeight (INTERFACE_IS_PAD ? 226 : 113)
        
#define socialContainerSepatorY (INTERFACE_IS_PAD ? 12 : 6)
#define socialContainerHeight (INTERFACE_IS_PAD ? 74 : 37)
        
        _feedContainer.frame = CGRectMake(feedContainerX, feedContainerX, feedContainerWidth, feedContainerHieght);
        _profileImageView.frame = CGRectMake(profileImageViewX, profileImageViewX, profileImageViewSize, profileImageViewSize);
        _nameLabel.frame = CGRectMake(nameLabelX, _profileImageView.frame.origin.y, nameLabelWidth, nameLabelHeight);
        _dateLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y + dateLabelSpeatorY, dateLabelWidth, _nameLabel.frame.size.height);
        
        _descriptionLabel.frame = CGRectMake(descriptionLabelX, descriptionLabelY, descriptionLabelWidth, descriptionLabelHeight);
        
        _coverImageView.frame = CGRectMake(0, _dateLabel.frame.origin.y + coverImageViewSpeatorY, _feedContainer.frame.size.width, coverImageViewHeight);
        
        _socialContainer.frame = CGRectMake(0, _descriptionLabel.frame.origin.y + _descriptionLabel.frame.size.height + socialContainerSepatorY, _feedContainer.frame.size.width, socialContainerHeight);
        
        _memberCountButton.frame = CGRectMake(0, memberCountLabelY, memberCountLabelWidth, _nameLabel.frame.size.height);
        _lessonCountButton.frame = CGRectMake(_memberCountButton.frame.origin.x + _memberCountButton.frame.size.width + lessonCountLabelSpeator, _memberCountButton.frame.origin.y, lessonCountLabelWidth, _nameLabel.frame.size.height);

        
        [_feedContainer addSubview:self.coverImageView];
        [_feedContainer addSubview:self.profileImageView];
        [_feedContainer addSubview:self.nameLabel];
        [_feedContainer addSubview:self.dateLabel];
        [_feedContainer addSubview:self.descriptionLabel];
        
        [_socialContainer addSubview:self.memberCountButton];
        [_socialContainer addSubview:self.lessonCountButton];
        [_feedContainer addSubview:self.socialContainer];
        
        [self addSubview:self.feedContainer];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void) loadingGroupData:(FlyingGroupData *)groupData
{
    self.groupData=groupData;
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:groupData.logo] placeholderImage:[UIImage imageNamed:@"Icon"]];
    
    UITapGestureRecognizer *profileRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewPressed:)];
    profileRecognizer.numberOfTapsRequired = 1; // 单击
    [self.profileImageView addGestureRecognizer:profileRecognizer];
    
    self.nameLabel.text = groupData.gp_name;
    self.descriptionLabel.text = groupData.gp_desc;
    
    self.dateLabel.text = @"9月5日  14点32分";
    
    NSMutableAttributedString *membercontent = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"成员:33"]];
    NSRange membercontentRange = {0,[membercontent length]};
    [membercontent addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:membercontentRange];
    [self.memberCountButton setAttributedTitle:membercontent forState:UIControlStateNormal];    
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"课程:235"]];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    [self.lessonCountButton setAttributedTitle:content forState:UIControlStateNormal];
    [self.lessonCountButton addTarget:self action:@selector(lessonCountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:groupData.cover] placeholderImage:[UIImage imageNamed:@"Default"]];
    
    UITapGestureRecognizer *coverRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverImageViewPressed:)];
    coverRecognizer.numberOfTapsRequired = 1; // 单击
    [self.coverImageView addGestureRecognizer:coverRecognizer];
}

- (void)memberCountButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(memberCountButtonPressed:)])
    {
        [self.delegate memberCountButtonPressed:self.groupData];
    }
}

- (void)lessonCountButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(lessonCountButtonPressed:)])
    {
        [self.delegate lessonCountButtonPressed:self.groupData];
    }
}

- (void)profileImageViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileImageViewPressed:)])
    {
        [self.delegate profileImageViewPressed:self.groupData];
    }
}

- (void)coverImageViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(coverImageViewPressed:)])
    {
        [self.delegate coverImageViewPressed:self.groupData];
    }
}

@end
