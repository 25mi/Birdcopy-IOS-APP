//
//  FlyingLessonViewCell.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/5/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingLessonViewCell.h"
#import "FlyingPubLessonData.h"
#import "shareDefine.h"
#import "PSCollectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "UIImage+localFile.h"


@interface FlyingLessonViewCell ()
{
    UIImageView             *_coverImageView;
    UIImageView             *_contentTypeImageView;
    
    UILabel                 *_titleLabel;
    UILabel                 *_descriptionLable;
    UIActivityIndicatorView *_activityIndicator;
}
@end


@implementation FlyingLessonViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _coverImageView   = [[UIImageView alloc] initWithFrame:CGRectZero];
        _contentTypeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        _titleLabel       = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLable = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _titleLabel.textAlignment   = NSTextAlignmentCenter;
        _titleLabel.textColor       = [UIColor darkTextColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        if (INTERFACE_IS_PAD)
        {
            _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        }
        else{
            _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        }

        
        if (INTERFACE_IS_PAD){
            _descriptionLable.font = [UIFont systemFontOfSize:15];
        }
        else{
            _descriptionLable.font = [UIFont systemFontOfSize:10];
        }

        _descriptionLable.numberOfLines     = 0;
        _descriptionLable.textAlignment     = NSTextAlignmentLeft;
        _descriptionLable.backgroundColor   = [UIColor clearColor];
        _descriptionLable.textColor         = [UIColor blackColor];
        _descriptionLable.lineBreakMode     = NSLineBreakByTruncatingTail;
        
        [self addSubview:_titleLabel];
        [self addSubview:_coverImageView];
        [self addSubview:_descriptionLable];
        [self addSubview:_contentTypeImageView];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)prepareForReuse
{
    
    [super prepareForReuse];
    
    _coverImageView.image = nil;
    _titleLabel.text = nil;
    _descriptionLable.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //标题
    CGFloat columnWidth = self.frame.size.width;
    
    CGFloat titleHeight;
    
    if (INTERFACE_IS_PAD){

        titleHeight=TileHeight_ipad;
    }
    else{
        
        titleHeight=TileHeight_iphone;
    }
    //标题
    [_titleLabel setFrame:CGRectMake(0, 0, columnWidth, titleHeight)];
    
    //课程封面
    [_coverImageView setFrame:CGRectMake(0, titleHeight, columnWidth, columnWidth*9/16)];
    [_contentTypeImageView setFrame:CGRectMake(0, titleHeight, columnWidth*9/(16*4), columnWidth*9/(16*4))];
    
    //释意
    CGFloat margin;
    if (INTERFACE_IS_PAD){

        margin=MARGIN_ipad;
    }
    else{
        margin=MARGIN_iphone;
    }
    
    CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font =_descriptionLable. font;
    gettingSizeLabel.text = _descriptionLable.text;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];

    
    CGFloat temHight=expectSize.height;

    if (temHight>columnWidth) {
        
        temHight=columnWidth;
    }
    
    [_descriptionLable setFrame:CGRectMake(margin/2.0,
                                           _titleLabel.frame.size.height+_coverImageView.frame.size.height+margin/2.0,
                                           columnWidth-margin,
                                           temHight+margin/2)];
    
    if (!_coverImageView.image) {
        
        if (INTERFACE_IS_PAD) {
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        else{
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhite];
        }
    }
}

+ (CGFloat)rowHeightForObject:(FlyingPubLessonData *)detailData inColumnWidth:(CGFloat)columnWidth
{
    CGFloat height = 0;
    
    //标题
    if (INTERFACE_IS_PAD)
    {
        height += TileHeight_ipad;
    }
    else{
    
        height += TileHeight_iphone;
    }
    
    //课程封面
    height +=(columnWidth*9/16);

    //简述
    CGFloat margin;
    if (INTERFACE_IS_PAD)
    {
        margin=MARGIN_ipad;
    }
    else
    {
        margin=MARGIN_iphone;
    }
    
    height += margin;
    
    
    UIFont *font = [UIFont systemFontOfSize:10];

    if (INTERFACE_IS_PAD){
        font = [UIFont systemFontOfSize:15];
    }
    
    
    CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = font;
    gettingSizeLabel.text = detailData.desc;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
    
    CGFloat temHight=expectSize.height;
    
    if (temHight>columnWidth) {
        
        temHight=columnWidth;
    }
    
    height+=temHight;
    
    return height;
}


- (void)collectionView:(PSCollectionView *)collectionView
    fillCellWithObject:(id)object
               atIndex:(NSInteger)index
{
    
    @autoreleasepool {
        
        [super collectionView:collectionView fillCellWithObject:object atIndex:index];
        
        FlyingPubLessonData * detailData =(FlyingPubLessonData *)object;
        _titleLabel.text=detailData.title;
        
        __weak typeof(self) weakSelf = self;
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
                
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:detailData.imageURL]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weakSelf removeActivityIndicator];
        }];
        
        _descriptionLable.text=detailData.desc;
        
        
        if ([detailData.contentType isEqualToString:KContentTypeText])
        {
            [_contentTypeImageView setImage:[UIImage imageNamed:PlayDocIcon]];
        }
        else if ([detailData.contentType isEqualToString:KContentTypeVideo])
        {
            [_contentTypeImageView setImage:[UIImage imageNamed:PlayVideoIcon]];
        }
        else  if ([detailData.contentType isEqualToString:KContentTypeAudio])
        {
            [_contentTypeImageView setImage:[UIImage imageNamed:PlayAudioIcon]];
        }
        else  if ([detailData.contentType isEqualToString:KContentTypePageWeb])
        {
            [_contentTypeImageView setImage:[UIImage imageNamed:PlayWebIcon]];
        }
    }
}

-(void) createActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle) activityStyle
{
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityStyle];
    
    //calculate the correct position
    float width = _activityIndicator.frame.size.width;
    float height = _activityIndicator.frame.size.height;
    float x = (_coverImageView.frame.size.width / 2.0) - width/2;
    float y = (_coverImageView.frame.size.height / 2.0) - height/2;
    _activityIndicator.frame = CGRectMake(x, y, width, height);
    _activityIndicator.color=[UIColor grayColor];

    _activityIndicator.hidesWhenStopped = YES;
    [_coverImageView addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
}

-(void) removeActivityIndicator
{
    
    [[_coverImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
@end