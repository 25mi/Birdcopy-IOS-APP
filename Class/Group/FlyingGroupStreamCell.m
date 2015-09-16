//
//  FlyingGroupStreamCell.m
//  FlyingEnglish
//
//  Created by vincent on 9/8/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingGroupStreamCell.h"

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
        
        UIColor* mainColorLight = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:0.7f];
        UIColor* lightColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        
        NSString* fontName = @"Optima-Regular";
        NSString* boldFontName = @"Optima-ExtraBlack";
        
        _profileImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _profileImageView.layer.cornerRadius = 10.0f;
        
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
        
        _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentCountLabel.textColor = mainColorLight;
        _commentCountLabel.font = dateLabelFont;
        
        _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _likeCountLabel.textColor = mainColorLight;
        _likeCountLabel.font = dateLabelFont;
        
#define profileImageViewX (INTERFACE_IS_PAD ? 40 :20)
#define profileImageViewY (INTERFACE_IS_PAD ? 22 :11)
#define profileImageViewSize (INTERFACE_IS_PAD ? 80 :40)
        
#define nameLabelX (INTERFACE_IS_PAD ? 170 : 68)
#define nameLabelWidth (INTERFACE_IS_PAD ? 432 : 216)
#define nameLabelHeight (INTERFACE_IS_PAD ? 42 : 21)
        
        // 内容的
#define descriptionLabelY (INTERFACE_IS_PAD ? 64 : 32)
#define descriptionLabelWidth (INTERFACE_IS_PAD ? 550 : 238)
#define descriptionLabelHeight (INTERFACE_IS_PAD ? 120 : 60)
        
#define commentCountLabelY (INTERFACE_IS_PAD ? 186 : 93)
#define commentCountLabelWidth (INTERFACE_IS_PAD ? 180 : 75)
#define commentCountLabelHeight (INTERFACE_IS_PAD ? 42 : 21)
        
#define likeCountLabelSpeator (INTERFACE_IS_PAD ? 4 : 2)
        
#define dateLabelSpeator (INTERFACE_IS_PAD ? 10 : 5)
        
        if (cellType == FlyingGroupStreamCellTextType) {
            
            _profileImageView.frame = CGRectMake(profileImageViewX, profileImageViewY, profileImageViewSize, profileImageViewSize);
            
            
            _nameLabel.frame = CGRectMake(nameLabelX, _profileImageView.frame.origin.y, nameLabelWidth, nameLabelHeight);
            
            
            _descriptionLabel.frame = CGRectMake(_nameLabel.frame.origin.x, descriptionLabelY, descriptionLabelWidth, descriptionLabelHeight);
            
            _commentCountLabel.frame = CGRectMake(_nameLabel.frame.origin.x, commentCountLabelY, commentCountLabelWidth, commentCountLabelHeight);
            
            _likeCountLabel.frame = CGRectMake(_commentCountLabel.frame.origin.x + _commentCountLabel.frame.size.width + likeCountLabelSpeator, _commentCountLabel.frame.origin.y, _commentCountLabel.frame.size.width, _commentCountLabel.frame.size.height);
            
            
            _dateLabel.frame = CGRectMake(_likeCountLabel.frame.origin.x + _likeCountLabel.frame.size.width + dateLabelSpeator, _commentCountLabel.frame.origin.y, _commentCountLabel.frame.size.width, _commentCountLabel.frame.size.height);
            
        } else if (cellType == FlyingGroupStreamCellPictureType) {
            _profileImageView.frame = CGRectMake(profileImageViewX, profileImageViewY, profileImageViewSize, profileImageViewSize);
            _nameLabel.frame = CGRectMake(nameLabelX, _profileImageView.frame.origin.y, nameLabelWidth, nameLabelHeight);
            _descriptionLabel.frame = CGRectMake(_nameLabel.frame.origin.x, descriptionLabelY, descriptionLabelWidth, descriptionLabelHeight);
            
#define PicCommentCountLabelY (INTERFACE_IS_PAD ? 430 : 215)
            _commentCountLabel.frame = CGRectMake(_nameLabel.frame.origin.x, PicCommentCountLabelY, commentCountLabelWidth, commentCountLabelHeight);
            
            _likeCountLabel.frame = CGRectMake(_commentCountLabel.frame.origin.x + _commentCountLabel.frame.size.width + likeCountLabelSpeator, _commentCountLabel.frame.origin.y, _commentCountLabel.frame.size.width, _commentCountLabel.frame.size.height);
            
            _dateLabel.frame = CGRectMake(_likeCountLabel.frame.origin.x + _likeCountLabel.frame.size.width + dateLabelSpeator, _commentCountLabel.frame.origin.y, _commentCountLabel.frame.size.width, _commentCountLabel.frame.size.height);
            
#define picImageViewX (INTERFACE_IS_PAD ? 8 : 4)
#define picImageViewWidth (INTERFACE_IS_PAD ? 532 : 229)
#define picImageViewHeight (INTERFACE_IS_PAD ? 196 : 98)
            _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(picImageViewX, picImageViewX, picImageViewWidth, picImageViewHeight)];
            _picImageView.contentMode = UIViewContentModeScaleAspectFill;
            _picImageView.clipsToBounds = YES;
            _picImageView.layer.cornerRadius = 2.0f;
            
#define picImageContainerY (INTERFACE_IS_PAD ? 192 : 96)
#define picImageContainerWidth (INTERFACE_IS_PAD ? 550 : 237)
#define picImageContainerHeight (INTERFACE_IS_PAD ? 212 : 106)
            _picImageContainer = [[UIView alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, picImageContainerY, picImageContainerWidth, picImageContainerHeight)];
            _picImageContainer.backgroundColor = [UIColor whiteColor];
            _picImageContainer.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:0.6f].CGColor;
            _picImageContainer.layer.borderWidth = 1.0f;
            _picImageContainer.layer.cornerRadius = 2.0f;
            _picImageContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:_picImageContainer.bounds].CGPath;
            
            [_picImageContainer addSubview:self.picImageView];
            [self addSubview:self.picImageContainer];
        }
        
        [self addSubview:self.profileImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descriptionLabel];
        [self addSubview:self.commentCountLabel];
        [self addSubview:self.likeCountLabel];
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

-(void) setStreamCellData:(FlyingStreamData*)streamCellData
{

    self.nameLabel.text = @"John Keynetown";
    self.descriptionLabel.text = @"On the trip to San Fransisco, the Golden gate bridge looked really magnificent. This is a city I would love to visit very often.";
    
    self.dateLabel.text = @"10 小时前";
    self.likeCountLabel.text = @"134 likes";
    self.commentCountLabel.text = @"21 comments";
    
    self.profileImageView.image = [UIImage imageNamed:@"Icon"];
    
    self.picImageView.image = [UIImage imageNamed:@"Default"];
}

@end
