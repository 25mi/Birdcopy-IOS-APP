//
//  FlyingCommentCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCommentCell.h"
#import "UIImageView+WebCache.h"

@implementation FlyingCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        UIColor* mainColor = [UIColor colorWithRed:28.0/255 green:158.0/255 blue:121.0/255 alpha:1.0f];
        UIColor* neutralColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        
        UIColor* lightColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        
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
        
        UIFont *descriptionLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 26.0f : 13.0f)];
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _descriptionLabel.textColor =  neutralColor;
        _descriptionLabel.font = descriptionLabelFont;
        
        UIFont *dateLabelFont = [UIFont fontWithName:fontName size:(INTERFACE_IS_PAD ? 24.0f : 12.0f)];
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.textColor = lightColor;
        _dateLabel.font =  dateLabelFont;
        
#define profileImageViewX (INTERFACE_IS_PAD ? 40 :10)
#define profileImageViewY (INTERFACE_IS_PAD ? 22 :11)
#define profileImageViewSize (INTERFACE_IS_PAD ? 80 :40)
        
#define nameLabelX (INTERFACE_IS_PAD ? 170 : 58)
#define nameLabelWidth (INTERFACE_IS_PAD ? 216 : 108)
#define nameLabelHeight (INTERFACE_IS_PAD ? 42 : 21)
        
        // 内容的
#define descriptionLabelY (INTERFACE_IS_PAD ? 64 : 32)
#define descriptionLabelWidth (INTERFACE_IS_PAD ? 550 : 238)
#define descriptionLabelHeight (INTERFACE_IS_PAD ? 120 : 60)
        
#define commentCountLabelY (INTERFACE_IS_PAD ? 186 : 93)
#define commentCountLabelWidth (INTERFACE_IS_PAD ? 160 : 77)
#define commentCountLabelHeight (INTERFACE_IS_PAD ? 42 : 21)
#define dateLabelSpeator (INTERFACE_IS_PAD ? 10 : 5)

        
        _profileImageView.frame = CGRectMake(profileImageViewX, profileImageViewY, profileImageViewSize, profileImageViewSize);
        _nameLabel.frame = CGRectMake(nameLabelX, _profileImageView.frame.origin.y, nameLabelWidth, nameLabelHeight);
        _descriptionLabel.frame = CGRectMake(_nameLabel.frame.origin.x, descriptionLabelY, descriptionLabelWidth, descriptionLabelHeight);
        
        _dateLabel.frame = CGRectMake(_nameLabel.frame.origin.x + _nameLabel.frame.size.width,
                                      _nameLabel.frame.origin.y,
                                      CGRectGetWidth(self.frame)-_nameLabel.frame.origin.x - _nameLabel.frame.size.width-dateLabelSpeator,
                                      _nameLabel.frame.size.height);

        [self addSubview:self.profileImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.descriptionLabel];
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

-(void) loadingCommentData:(FlyingCommentData *)commentData
{
    self.commentData=commentData;
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:commentData.portraitURL] placeholderImage:[UIImage imageNamed:@"Icon"]];
    UITapGestureRecognizer *profileRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageViewPressed:)];
    profileRecognizer.numberOfTapsRequired = 1; // 单击
    [self.profileImageView addGestureRecognizer:profileRecognizer];

    
    self.nameLabel.text = commentData.nickName;
    self.descriptionLabel.text = commentData.commentContent;
    
    self.dateLabel.text = @"14分钟前";
}

- (void)profileImageViewPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(profileImageViewPressed:)])
    {
        [self.delegate profileImageViewPressed:self.commentData];
    }
}


@end
