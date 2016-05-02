//
//  FlyingGroupBoard.m
//  FlyingEnglish
//
//  Created by vincent sung on 30/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingGroupBoard.h"
#import "shareDefine.h"
#import <UIImageView+AFNetworking.h>

@implementation FlyingGroupBoard

#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialization code
    [self _setup];
}

+ (FlyingGroupBoard*) groupBoard
{
    return [[[NSBundle mainBundle] loadNibNamed:@"FlyingGroupBoard" owner:self options:nil] firstObject];
}

- (void)_setup
{
    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.logoImageview setContentMode:UIViewContentModeScaleAspectFill];
    
    [self.boardBackgroundImageview setContentMode:UIViewContentModeScaleAspectFill];
    [self.newsImageview setContentMode:UIViewContentModeScaleAspectFill];
    
    self.newsBoardTitleLabel.font = [UIFont systemFontOfSize:KNormalFontSize];
    self.newsTitleLabel.font = [UIFont systemFontOfSize:KNormalFontSize];
    
    [self.logoImageview setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *touchLogoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchGroupLogo)];
    touchLogoRecognizer.numberOfTapsRequired = 1; // 单击
    [self.logoImageview addGestureRecognizer:touchLogoRecognizer];

    UITapGestureRecognizer *touchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBoardNews)];
    touchRecognizer.numberOfTapsRequired = 1; // 单击
    [self.boardNewsView addGestureRecognizer:touchRecognizer];
}

-(void)settingWithGroupData:(FlyingGroupData*) groupData
{
    [self.backgroundImageView  setImageWithURL:[NSURL URLWithString:groupData.cover]
                              placeholderImage:[UIImage imageNamed:@"Default"]];
    
    [self.logoImageview  setImageWithURL:[NSURL URLWithString:groupData.logo]
                        placeholderImage:[UIImage imageNamed:@"Icon"]];
}

-(void)settingWithContentData:(FlyingPubLessonData*) contentData
{
    self.newsTitleLabel.text = contentData.title;
}


-(void)touchBoardNews
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchBoardNews)])
    {
        [self.delegate touchBoardNews];
    }
}

-(void)touchGroupLogo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchGroupLogo)])
    {
        [self.delegate touchGroupLogo];
    }
}

@end
