//
//  FlyingCoverViewCell.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/7/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingCoverViewCell.h"
#import "FlyingCoverData.h"
#import "shareDefine.h"
#import "PSCollectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "UIImage+localFile.h"

@interface FlyingCoverViewCell ()
{
    
    UIImageView        *_coverImageView;

    UILabel            *_titleLabel;
    UILabel            *_descriptionLable;

    UIActivityIndicatorView *_activityIndicator;
}
@end


@implementation FlyingCoverViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _coverImageView   = [[UIImageView alloc] initWithFrame:CGRectZero];

        _titleLabel       = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLable = [[UILabel alloc] initWithFrame:CGRectZero];
        
        _titleLabel.textAlignment   = NSTextAlignmentLeft;
        _titleLabel.textColor       = [UIColor blackColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        if (INTERFACE_IS_PAD)
        {
            _titleLabel.font = [UIFont systemFontOfSize:15];
        }
        else{
            _titleLabel.font = [UIFont systemFontOfSize:10];
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

        
        [self addSubview:_coverImageView];
        [self addSubview:_titleLabel];
        [self addSubview:_descriptionLable];
        
        self.backgroundColor = [UIColor whiteColor];
        
        //self.layer.borderWidth = 0.5f;
        //self.layer.borderColor= [[UIColor colorWithRed:207.0f/255.0f green:207.0f/255.0f blue:207.0f/255.0f alpha:1] CGColor];
        //self.layer.cornerRadius = 10.0f;
        //self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)prepareForReuse
{
    
    [super prepareForReuse];
    
    _coverImageView.image  = nil;
    _titleLabel.text       = nil;
    _descriptionLable.text = nil;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat columnWidth = self.frame.size.width;
        
       //[_coverBackView setFrame:_coverImageView.frame];
    
    
    CGFloat titleHeight;
    
    if (INTERFACE_IS_PAD){
        
        titleHeight=TileHeight_ipad;
    }
    else{
        
        titleHeight=TileHeight_iphone;
    }

    //标题
    [_titleLabel setFrame:CGRectMake(0, 0, columnWidth,titleHeight)];
    
    //视频截图
    [_coverImageView setFrame:CGRectMake(0, titleHeight, columnWidth, columnWidth*9/16)];
    
    //释意
    CGFloat margin;
    if (INTERFACE_IS_PAD){
        
        margin=MARGIN_ipad;
    }
    else{
        margin=MARGIN_iphone;
    }
    
    if (_descriptionLable.text.length>0){
        
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
    }
    
    if (!_coverImageView.image) {

        if (INTERFACE_IS_PAD) {
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        else{
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhite];
        }
    }
}

+ (CGFloat)rowHeightForObject:(FlyingCoverData *)detailData inColumnWidth:(CGFloat)columnWidth
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
    
    
    UIFont *font = [UIFont systemFontOfSize:10];
    
    if (INTERFACE_IS_PAD){
        font = [UIFont systemFontOfSize:15];
    }
    
    CGFloat temHight=0;

    if (detailData.desc.length>0) {
        
        CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = font;
        gettingSizeLabel.text = detailData.desc;
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
        
        temHight=expectSize.height;
        
        if (temHight>columnWidth) {
            
            temHight=columnWidth;
        }
        
        height += margin/2;
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
        
        FlyingCoverData * detailData =(FlyingCoverData *)object;
        _titleLabel.text=[NSString stringWithFormat:@"%@(%@)",detailData.tagString,[@(detailData.count) stringValue]];
        _titleLabel.textAlignment=NSTextAlignmentCenter;
        
        __weak typeof(self) weakSelf = self;
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:detailData.imageURL]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weakSelf removeActivityIndicator];
        }];
        
        _descriptionLable.text=detailData.desc;
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
    
    _activityIndicator.hidesWhenStopped = YES;
    [_coverImageView addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
}

-(void) removeActivityIndicator
{
    [[_coverImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
