//
//  FlyingGroupStreamCell.m
//  FlyingEnglish
//
//  Created by vincent on 9/8/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingGroupStreamCell.h"

@interface FlyingGroupStreamCell()
{
    FlyingStreamData* _streamCellData;
}
@end


@implementation FlyingGroupStreamCell

- (id)initWithStyle:(UITableViewCellStyle)style
    ReuseIdentifier:(NSString *)reuseIdentifier
     StreamCellType:(FlyingGroupStreamCellType)cellType
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIColor* mainColor = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
        UIColor* neutralColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        
        UIColor* lightColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        
        NSString* fontName = @"Optima-Regular";
        NSString* boldFontName = @"Optima-ExtraBlack";
        
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _profileImageView.layer.cornerRadius = 10.0f;
        _profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        _profileImageView.clipsToBounds = YES;
        _profileImageView.userInteractionEnabled=YES;
        
        UIFont *nameLabelFont = [UIFont fontWithName:boldFontName size:(INTERFACE_IS_PAD ? 35.0f : 17.0f)];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor =  mainColor;
        _nameLabel.font = nameLabelFont;
        
        UIFont *descriptionLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 26.0f : 13.0f)];
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.textColor =  neutralColor;
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _descriptionLabel.font = descriptionLabelFont;
        
        UIFont *dateLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 24.0f : 12.0f)];
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.textColor = lightColor;
        _dateLabel.font = dateLabelFont;
        
        UIFont *countLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 24.0f : 12.0f)];
        _commentCountButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _commentCountButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _commentCountButton.titleLabel.textColor =  [UIColor darkTextColor];
        _commentCountButton.backgroundColor = [UIColor  clearColor];
        _commentCountButton.titleLabel.font = countLabelFont;
        
        [_commentCountButton addTarget:self action:@selector(commentCountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _likeCountButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _likeCountButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _likeCountButton.titleLabel.textColor = [UIColor darkTextColor];
        _likeCountButton.backgroundColor = [UIColor clearColor];
        _likeCountButton.titleLabel.font = countLabelFont;
        
        [_likeCountButton addTarget:self action:@selector(likeCountButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
#define profileImageViewX (INTERFACE_IS_PAD ? 40 :10)
#define profileImageViewY (INTERFACE_IS_PAD ? 22 :11)
#define profileImageViewSize (INTERFACE_IS_PAD ? 80 :40)
        
#define nameLabelX (INTERFACE_IS_PAD ? 170 : 58)
#define nameLabelWidth (INTERFACE_IS_PAD ? 432 : 216)
#define nameLabelHeight (INTERFACE_IS_PAD ? 42 : 21)
        
        // 内容的
#define descriptionLabelY (INTERFACE_IS_PAD ? 64 : 32)
#define descriptionLabelWidth (INTERFACE_IS_PAD ? 550 : 238)
#define descriptionLabelHeight (INTERFACE_IS_PAD ? 120 : 60)
        
#define commentCountButtonY (INTERFACE_IS_PAD ? 186 : 93)
#define commentCountButtonWidth (INTERFACE_IS_PAD ? 180 : 75)
#define commentCountButtonHeight (INTERFACE_IS_PAD ? 42 : 21)
        
#define likeCountButtonSpeator (INTERFACE_IS_PAD ? 4 : 2)
        
#define dateLabelSpeator (INTERFACE_IS_PAD ? 10 : 5)
        
        if (cellType == FlyingGroupStreamCellTextType)
        {
            
            _profileImageView.frame = CGRectMake(profileImageViewX, profileImageViewY, profileImageViewSize, profileImageViewSize);
            
            
            _nameLabel.frame = CGRectMake(nameLabelX, _profileImageView.frame.origin.y, nameLabelWidth, nameLabelHeight);
            
            
            _descriptionLabel.frame = CGRectMake(_nameLabel.frame.origin.x, descriptionLabelY, descriptionLabelWidth, descriptionLabelHeight);
            
            _commentCountButton.frame = CGRectMake(_nameLabel.frame.origin.x, commentCountButtonY, commentCountButtonWidth, commentCountButtonHeight);
            
            _likeCountButton.frame = CGRectMake(_commentCountButton.frame.origin.x + _commentCountButton.frame.size.width + likeCountButtonSpeator, _commentCountButton.frame.origin.y, _commentCountButton.frame.size.width, _commentCountButton.frame.size.height);
            
            
            _dateLabel.frame = CGRectMake(_likeCountButton.frame.origin.x + _likeCountButton.frame.size.width + dateLabelSpeator, _commentCountButton.frame.origin.y, _commentCountButton.frame.size.width, _commentCountButton.frame.size.height);
            
        }
        else if (cellType == FlyingGroupStreamCellPictureType)
        {
            _profileImageView.frame = CGRectMake(profileImageViewX, profileImageViewY, profileImageViewSize, profileImageViewSize);
            _nameLabel.frame = CGRectMake(nameLabelX, _profileImageView.frame.origin.y, nameLabelWidth, nameLabelHeight);
            _descriptionLabel.frame = CGRectMake(_nameLabel.frame.origin.x, descriptionLabelY, descriptionLabelWidth, descriptionLabelHeight);
            
#define PiccommentCountButtonY (INTERFACE_IS_PAD ? 430 : 215)
            _commentCountButton.frame = CGRectMake(_nameLabel.frame.origin.x, PiccommentCountButtonY, commentCountButtonWidth, commentCountButtonHeight);
            
            _likeCountButton.frame = CGRectMake(_commentCountButton.frame.origin.x + _commentCountButton.frame.size.width + likeCountButtonSpeator, _commentCountButton.frame.origin.y, _commentCountButton.frame.size.width, _commentCountButton.frame.size.height);
            
            _dateLabel.frame = CGRectMake(_likeCountButton.frame.origin.x + _likeCountButton.frame.size.width + dateLabelSpeator, _commentCountButton.frame.origin.y, _commentCountButton.frame.size.width, _commentCountButton.frame.size.height);
            
#define coverImageViewX (INTERFACE_IS_PAD ? 8 : 4)
#define coverImageViewWidth (INTERFACE_IS_PAD ? 532 : 229)
#define coverImageViewHeight (INTERFACE_IS_PAD ? 196 : 98)
            _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(coverImageViewX, coverImageViewX, coverImageViewWidth, coverImageViewHeight)];
            _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
            _coverImageView.clipsToBounds = YES;
            _coverImageView.layer.cornerRadius = 2.0f;
            _coverImageView.userInteractionEnabled=YES;
            
#define picImageContainerY (INTERFACE_IS_PAD ? 192 : 96)
#define picImageContainerWidth (INTERFACE_IS_PAD ? 550 : 237)
#define picImageContainerHeight (INTERFACE_IS_PAD ? 212 : 106)
            _picImageContainer = [[UIView alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, picImageContainerY, picImageContainerWidth, picImageContainerHeight)];
            _picImageContainer.backgroundColor = [UIColor whiteColor];
            _picImageContainer.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:0.6f].CGColor;
            _picImageContainer.layer.borderWidth = 1.0f;
            _picImageContainer.layer.cornerRadius = 2.0f;
            _picImageContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:_picImageContainer.bounds].CGPath;
            
            [_picImageContainer addSubview:self.coverImageView];
            [self addSubview:self.picImageContainer];
        }
        
        [self addSubview:self.profileImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.commentCountButton];
        [self addSubview:self.likeCountButton];
        [self addSubview:self.dateLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) loadingStreamCellData:(FlyingStreamData*)streamCellData
{
    
    self.profileImageView.image = [UIImage imageNamed:@"Icon"];
    
    UITapGestureRecognizer *profileRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewPressed:)];
    profileRecognizer.numberOfTapsRequired = 1; // 单击
    [self.profileImageView addGestureRecognizer:profileRecognizer];
    
    self.nameLabel.text = @"John Keynetown";
    self.descriptionLabel.text = @"On the trip to San Fransisco, the Golden gate bridge looked really magnificent. This is a city I would love to visit very often.";
    
    self.dateLabel.text = @"10 小时前";
    
    self.commentCountButton.titleLabel.text = @"21 comments";
    self.likeCountButton.titleLabel.text = @"134 likes";
    
    NSMutableAttributedString *commentcontent = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"21 comments"]];
    NSRange commentcontentRange = {0,[commentcontent length]};
    [commentcontent addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:commentcontentRange];
    [self.commentCountButton setAttributedTitle:commentcontent forState:UIControlStateNormal];

    NSMutableAttributedString *likecontent = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"134 likes"]];
    NSRange likecontentRange = {0,[likecontent length]};
    [likecontent addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:likecontentRange];
    [self.likeCountButton setAttributedTitle:likecontent forState:UIControlStateNormal];

    
    self.coverImageView.image = [UIImage imageNamed:@"Default"];
    UITapGestureRecognizer *coverRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverImageViewPressed:)];
    coverRecognizer.numberOfTapsRequired = 1; // 单击
    [self.coverImageView addGestureRecognizer:coverRecognizer];
}

- (void)commentCountButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCountButtonPressed:)])
    {
        [self.delegate commentCountButtonPressed:_streamCellData];
    }
}

- (void)likeCountButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(likeCountButtonPressed:)])
    {
        [self.delegate likeCountButtonPressed:_streamCellData];
    }
}

- (void)profileImageViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileImageViewPressed:)])
    {
        [self.delegate profileImageViewPressed:_streamCellData];
    }
}


- (void)coverImageViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(coverImageViewPressed:)])
    {
        [self.delegate coverImageViewPressed:_streamCellData];
    }
}

@end
