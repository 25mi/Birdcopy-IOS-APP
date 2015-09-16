//
//  FlyingProviderViewCell.m
//  FlyingEnglish
//
//  Created by vincent on 1/19/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingProviderViewCell.h"
#import "FlyingProvider.h"
#import "shareDefine.h"
#import "PSCollectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "UIImage+localFile.h"

@interface FlyingProviderViewCell ()
{
    
    UIImageView             *_coverImageView;
    UILabel                 *_titleLabel;
    UILabel                 *_distanceLabel;
    UILabel                 *_descriptionLable;
    UIActivityIndicatorView *_activityIndicator;
}
@end


@implementation FlyingProviderViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _coverImageView   = [[UIImageView alloc] initWithFrame:CGRectZero];
        _titleLabel       = [[UILabel alloc] initWithFrame:CGRectZero];
        _distanceLabel       = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLable = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _titleLabel.textAlignment   = NSTextAlignmentLeft;
        _titleLabel.textColor       = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];

        _distanceLabel.textAlignment   = NSTextAlignmentRight;
        _distanceLabel.textColor       = [UIColor blackColor];
        _distanceLabel.backgroundColor = [UIColor clearColor];

        if (INTERFACE_IS_PAD)
        {
            _titleLabel.font = [UIFont boldSystemFontOfSize:16];
            _distanceLabel.font = [UIFont boldSystemFontOfSize:12];
        }
        else{
            _titleLabel.font = [UIFont boldSystemFontOfSize:12];
            _distanceLabel.font = [UIFont boldSystemFontOfSize:8];
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
        [self addSubview:_distanceLabel];

        [self addSubview:_coverImageView];
        [self addSubview:_descriptionLable];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)prepareForReuse
{
    
    [super prepareForReuse];
    
    _coverImageView.image = nil;
    _titleLabel.text = nil;
    _distanceLabel.text = nil;
    _descriptionLable.text = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
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
    [_distanceLabel setFrame:CGRectMake(0, 0, columnWidth, titleHeight)];
    
    //课程封面
    [_coverImageView setFrame:CGRectMake(0, titleHeight, columnWidth, columnWidth*9/16)];
   
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
    gettingSizeLabel.font = _descriptionLable.font;
    gettingSizeLabel.text = _descriptionLable.text;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
    
    CGFloat temHight=expectSize.height;
    
    if (temHight>columnWidth) {
        
        temHight=columnWidth;
    }
    
    [_descriptionLable setFrame:CGRectMake(margin/2.0,
                                           _titleLabel.frame.size.height+_coverImageView.frame.size.height,
                                           columnWidth-margin,
                                           temHight)];
    
    if (!_coverImageView.image) {
        
        if (INTERFACE_IS_PAD) {
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        else{
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhite];
        }
    }
}

+ (CGFloat)rowHeightForObject:(FlyingProvider *)detailData inColumnWidth:(CGFloat)columnWidth
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
    
    height += margin/2;
    
    
    
    UIFont *font = [UIFont systemFontOfSize:10];
    
    if (INTERFACE_IS_PAD){
        font = [UIFont systemFontOfSize:15];
    }
    
    CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = font;
    gettingSizeLabel.text = detailData.providerDesc;
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
        
        FlyingProvider * detailData =(FlyingProvider *)object;
        _titleLabel.text=detailData.providerName;
        _distanceLabel.text=[NSString stringWithFormat:@"%@km",detailData.distance];
        
        __weak typeof(self) weakSelf = self;
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:detailData.logoURL]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      [weakSelf removeActivityIndicator];
                                  }];
        
        _descriptionLable.text=detailData.providerDesc;
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
