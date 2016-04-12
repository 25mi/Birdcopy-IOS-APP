//
//  FlyingWordItemCell.m
//  FlyingEnglish
//
//  Created by vincent on 3/5/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingWordItemCell.h"
#import "FlyingItemData.h"
#import "shareDefine.h"
#import "PSCollectionView.h"
#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking.h>
#import "FlyingTagTransform.h"
#import "NSString+FlyingExtention.h"

#import "FlyingItemDao.h"
#import "FlyingItemData.h"
#import "UIImage+localFile.h"

#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import <AFNetworking.h>

#import <MediaPlayer/MPMoviePlayerController.h>

@interface FlyingWordItemCell ()
{
    UIImageView             *_categoryImageView;
    UILabel                 *_categoryLabel;

    UIView                  *_contentView;

    UILabel                 *_tagContentlable;
    FlyingTagTransform      *_tagTrasform;
}
@end

@implementation FlyingWordItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        _categoryLabel                  = [[UILabel alloc] initWithFrame:CGRectZero];
        _categoryLabel.textAlignment    =  NSTextAlignmentCenter;
        _categoryLabel.backgroundColor  = [UIColor clearColor];
        _categoryLabel.textColor        = [UIColor blackColor];
        if (INTERFACE_IS_PAD)
        {
            _categoryLabel.font = [UIFont systemFontOfSize:14];
        }
        else{
            _categoryLabel.font = [UIFont systemFontOfSize:8];
        }
        
        _categoryImageView   = [[UIImageView alloc] initWithFrame:CGRectZero];
        _categoryImageView.backgroundColor= [UIColor clearColor];
        
        //组装磁贴图片和文字为磁贴
        [_categoryImageView addSubview:_categoryLabel];
        [self addSubview:_categoryImageView];
        
        _contentView   = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor  = [UIColor clearColor];

        //主体内容
        [self addSubview:_contentView];
        
        //补充解释内容
        _tagContentlable        = [[UILabel alloc] initWithFrame:CGRectZero];
        _tagContentlable.textAlignment   =  NSTextAlignmentLeft;
        _tagContentlable.backgroundColor = [UIColor clearColor];
        _tagContentlable.textColor       = [UIColor blackColor];
                
        if (INTERFACE_IS_PAD){
            _tagContentlable.font = [UIFont systemFontOfSize:14];
        }
        else{
            _tagContentlable.font = [UIFont systemFontOfSize:10];
        }
        [self addSubview:_tagContentlable];
        
        self.backgroundColor = [UIColor whiteColor];
        
        _tagTrasform = [[FlyingTagTransform alloc] init];
    }
    return self;
}

- (void)prepareForReuse
{
    
    [super prepareForReuse];
    
    _categoryLabel.text = nil;
    _categoryImageView.image=nil;
    
    [[_contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _tagContentlable.frame =  CGRectZero;
    [_tagContentlable setHidden:YES];
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGFloat columnWidth = self.frame.size.width;
    
    //词性图片以及文字
    _categoryImageView.frame  = CGRectMake(columnWidth*2/5, 0, columnWidth/5, columnWidth/5);
    _categoryLabel.frame      = CGRectMake(0, 0, _categoryImageView.frame.size.width, _categoryImageView.frame.size.height);

    CGFloat margin;
    if (INTERFACE_IS_PAD){
        
        margin=MARGIN_ipad;
    }
    else{
        margin=MARGIN_iphone;
    }

    //主体信息
    //内容
    switch ([self.detailData contentType]) {
            
        case BEText:
        case BEUnknown:
        {
            
            UIFont *font = [UIFont systemFontOfSize:10];
            
            if (INTERFACE_IS_PAD){
                font = [UIFont systemFontOfSize:15];
            }
            
            CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
            UILabel *gettingSizeLabel = [[UILabel alloc] init];
            gettingSizeLabel.font = font;
            gettingSizeLabel.text = [self.detailData textContent];
            gettingSizeLabel.numberOfLines = 0;
            gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];


            UIView *mainDataView = (UIView *)[_contentView subviews][0];
            mainDataView.frame= CGRectMake(margin/2, 0, columnWidth-margin, expectSize.height);
            
            _contentView.frame   = CGRectMake(0, _categoryImageView.frame.size.height+margin/2, columnWidth, expectSize.height);
        }
            break;
            
        case BEImage:
        case BEVedio:
        case BEAudio:
        {
            _contentView.frame   = CGRectMake(0, _categoryImageView.frame.size.height+margin/2, columnWidth, columnWidth*9/16);
            UIView *mainDataView = (UIView *)[_contentView subviews][0];
            mainDataView.frame   = CGRectMake(0, 0, columnWidth, columnWidth*9/16);
            
       }
            break;
            
        default:
            break;
    }
    
    if ([self.detailData tagContent])
    {
        
        UIFont *font = [UIFont systemFontOfSize:10];
        
        if (INTERFACE_IS_PAD){
            font = [UIFont systemFontOfSize:15];
        }
        
        CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = font;
        gettingSizeLabel.text = [self.detailData tagContent];
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        gettingSizeLabel.textAlignment = NSTextAlignmentLeft;
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
        
        _tagContentlable.frame   = CGRectMake(margin/2, _contentView.frame.origin.y+_contentView.frame.size.height,columnWidth, expectSize.height);
        
        [_tagContentlable setHidden:NO];
    }
}

+ (CGFloat)rowHeightForObject:(FlyingItemData *)detailData inColumnWidth:(CGFloat)columnWidth
{
    
    CGFloat height = 0;
    
    //分类
    height += columnWidth/5;
    
    //间隔
    CGFloat margin;
    if (INTERFACE_IS_PAD){
        
        margin=MARGIN_ipad;
    }
    else{
        margin=MARGIN_iphone;
    }
    
    height += margin/2;

    //内容
    switch ([detailData contentType]) {
            
        case BEText:
        case BEUnknown:
        {
            
            UIFont *font = [UIFont systemFontOfSize:10];
            
            if (INTERFACE_IS_PAD){
                font = [UIFont systemFontOfSize:15];
            }
            
            CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
            UILabel *gettingSizeLabel = [[UILabel alloc] init];
            gettingSizeLabel.font = font;
            gettingSizeLabel.text = [detailData textContent];
            gettingSizeLabel.numberOfLines = 0;
            gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            gettingSizeLabel.textAlignment = NSTextAlignmentLeft;
            
            CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];

            height +=expectSize.height;
        }
            break;
            
        case BEImage:
        {
            height +=columnWidth*9/16;
        }
            break;
            
        case BEVedio:
        {
            height +=columnWidth*9/16;
        }
            break;
            
        case BEAudio:
        {
            height +=columnWidth*9/16;
        }
            break;
            
        default:
            break;
    }
    
    //补充
    if ([detailData tagContent])
    {
        
        UIFont *font = [UIFont systemFontOfSize:10];
        
        if (INTERFACE_IS_PAD){
            font = [UIFont systemFontOfSize:15];
        }
        
        CGSize constraint = CGSizeMake(columnWidth-margin, MAXFLOAT);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = font;
        gettingSizeLabel.text = [detailData tagContent];
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        gettingSizeLabel.textAlignment = NSTextAlignmentLeft;
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
        
        height +=expectSize.height;
    }
    
    height += margin/2;

    return height;
}


- (void)collectionView:(PSCollectionView *)collectionView
    fillCellWithObject:(id)object
               atIndex:(NSInteger)index
{
    @autoreleasepool
    {
        
        [super collectionView:collectionView fillCellWithObject:object atIndex:index];
        
        FlyingItemData * itemData = (FlyingItemData *)object;
        
        _categoryImageView.image     = [[[FlyingTagTransform alloc] init] corlorMagnetForIndex:itemData.BEINDEX];
        _categoryLabel.text            = [_tagTrasform wordForIndex:itemData.BEINDEX];
        
        switch ([itemData contentType]) {
                
            case BEText:
            case BEUnknown:
            {
                UILabel *contentLabel        = [[UILabel alloc] initWithFrame:CGRectZero];
                contentLabel.textAlignment   =  NSTextAlignmentLeft;
                contentLabel.backgroundColor = [UIColor clearColor];
                contentLabel.textColor       = [UIColor blackColor];
                contentLabel.numberOfLines   = 0;
                
                if (INTERFACE_IS_PAD){
                    contentLabel.font = [UIFont systemFontOfSize:15];
                }
                else{
                    contentLabel.font = [UIFont systemFontOfSize:10];
                }
                
                contentLabel.text = [itemData textContent];
                [_contentView addSubview:contentLabel];
            }
                break;

            case BEImage:
            {
                
                UIImageView *coverImageView= [[UIImageView alloc] init];
                [coverImageView setContentMode:UIViewContentModeScaleAspectFit];
                
                [coverImageView setImageWithURL:[NSURL URLWithString:[itemData imageURLOnly]]];
                
                [_contentView addSubview:coverImageView];
            }
                break;

            case BEVedio:
            {
                // Create custom movie player
                MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[itemData vedioURLOnly]]];
                
                [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
                [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
                [moviePlayer setFullscreen:FALSE];
                
                [_contentView addSubview:moviePlayer.view];
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                 
                                                         selector:@selector(movieFinishedCallback:)
                 
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                 
                                                           object:self.detailData]; //播放完后的通知
            }
                break;

            case BEAudio:
            {
                // Create custom movie player
                MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[itemData audioURLOnly]]];
                
                [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
                [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
                [moviePlayer setFullscreen:FALSE];
                
                [_contentView addSubview:moviePlayer.view];
                
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                 
                                                         selector:@selector(movieFinishedCallback:)
                 
                                                             name:MPMoviePlayerPlaybackDidFinishNotification
                 
                                                           object:self.detailData]; //播放完后的通知

            }
                break;
                
            default:
                break;
        }
        
        if ([itemData tagContent])
        {
            _tagContentlable.text = [itemData tagContent];
        }
    }
}

-(void)movieFinishedCallback:(NSNotification*)notify {
    
    FlyingItemData* theData = [notify object];
    
    if(theData.BEINDEX==self.detailData.BEINDEX && [theData.BEENTRY isEqualToString:self.detailData.BEENTRY])
    {
        //[self removeActivityIndicator];
    }
}

@end
