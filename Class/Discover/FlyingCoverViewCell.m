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
#import <UIImageView+AFNetworking.h>
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
        
        _titleLabel.font = [UIFont boldSystemFontOfSize:KNormalFontSize];
        _descriptionLable.font = [UIFont systemFontOfSize:KNormalFontSize];
        
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
    
    
    [_descriptionLable setFrame:CGRectMake(margin/2.0,
                                           _titleLabel.frame.size.height+_coverImageView.frame.size.height,
                                           columnWidth-margin,
                                           columnWidth-_titleLabel.frame.size.height-_coverImageView.frame.size.height)];
}

+ (CGFloat)rowHeightForObject:(FlyingCoverData *)detailData inColumnWidth:(CGFloat)columnWidth
{
    return columnWidth;
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
        
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
        [_coverImageView setImageWithURL:[NSURL URLWithString:detailData.imageURL]];
        
        _descriptionLable.text=detailData.desc;
    }
}

@end
