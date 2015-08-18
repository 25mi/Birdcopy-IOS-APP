//
//  FlyingMyLessonCell.m
//  FlyingEnglish
//
//  Created by BE_Air on 9/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingMyLessonCell.h"
#import "FlyingNowLessonData.h"
#import "FlyingLessonData.h"
#import "FlyingLessonDAO.h"

#import "shareDefine.h"
#import "PSCollectionView.h"
#import "iFlyingAppDelegate.h"
#import "UIImage+localFile.h"
#import "UIImageView+thumnail.h"
#import "UIImageView+WebCache.h"

@interface FlyingMyLessonCell ()
{
    
    UIImageView             *_coverImageView;
    UIActivityIndicatorView *_activityIndicator;
    
    UIImageView             *_playbuttonImageView;
    
    UILabel                 *_titleLabel;
    UILabel                 *_backGroundLabel;

}
@end


@implementation FlyingMyLessonCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _coverImageView   = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        _backGroundLabel       = [[UILabel alloc] initWithFrame:CGRectZero];
        _backGroundLabel.backgroundColor = [UIColor blackColor];
        _backGroundLabel.alpha=0.5;
        
        _titleLabel            = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment   = NSTextAlignmentCenter;
        _titleLabel.textColor       = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        if (INTERFACE_IS_PAD)
        {
            _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        }
        else{
            _titleLabel.font = [UIFont boldSystemFontOfSize:10];
        }
        
        _playbuttonImageView = [[UIImageView alloc] initWithFrame:CGRectZero];

        [self addSubview:_coverImageView];
        [self addSubview:_playbuttonImageView];
        [self addSubview:_backGroundLabel];
        [self addSubview:_titleLabel];
        
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)prepareForReuse
{
    
    [super prepareForReuse];
    
    _coverImageView.image = nil;
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGFloat columnWidth = self.frame.size.width;
    
    //课程封面
    [_coverImageView setFrame:CGRectMake(0, 0, columnWidth, columnWidth*9/16)];
    
    //添加播放按钮图片和学习进度
    [_playbuttonImageView setFrame:CGRectMake(columnWidth*4/5, 0, columnWidth/5, columnWidth/5)];
    
    //标题
    [_titleLabel setFrame:CGRectMake(0, columnWidth*7/16, columnWidth, columnWidth/8)];
    [_backGroundLabel setFrame:_titleLabel.frame];
    
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
    return columnWidth*9/16;
}

- (void)collectionView:(PSCollectionView *)collectionView
    fillCellWithObject:(id)object
               atIndex:(NSInteger)index
{
    @autoreleasepool {
        
        [super collectionView:collectionView fillCellWithObject:object atIndex:index];
        
        FlyingNowLessonData * nowLessonData =(FlyingNowLessonData *)object;
        FlyingLessonData      *lessonData = [[[FlyingLessonDAO alloc] init]  selectWithLessonID:nowLessonData.BELESSONID];
        
        __weak typeof(self) weakSelf = self;
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        if (lessonData.BEOFFICIAL) {
            
            NSURL *coverImageURL = [NSURL URLWithString:lessonData.BEIMAGEURL];
            [_coverImageView sd_setImageWithURL:coverImageURL
                               placeholderImage:[UIImage imageNamed:@"Icon"]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          [weakSelf removeActivityIndicator];
                                      }];
        }
        else
        {
            CGFloat columnWidth = collectionView.frame.size.width;
            CGSize coverSize=CGSizeMake(columnWidth, columnWidth*3/4);
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:lessonData.localURLOfCover])
            {
                UIImage *  thumbnailImage = [UIImage thumnailImageWithPath:lessonData.localURLOfCover withSize:coverSize];
                [_coverImageView setImage:thumbnailImage];
            }
            else
            {
                [_coverImageView setImage:[UIImage imageNamed:@"Icon"]];
            }
            
            [self removeActivityIndicator];
        }
        
        if ([lessonData.BECONTENTTYPE isEqualToString:KContentTypeText])
        {
            _playbuttonImageView.image =  [UIImage imageNamed:PlayDocIcon];
        }
        
        if ([lessonData.BECONTENTTYPE isEqualToString:KContentTypeVideo])
        {
            _playbuttonImageView.image =  [UIImage imageNamed:PlayVideoIcon];
        }
        
        if ([lessonData.BECONTENTTYPE isEqualToString:KContentTypeAudio])
        {
            _playbuttonImageView.image =  [UIImage imageNamed:PlayAudioIcon];
        }
        
        
        if ([lessonData.BECONTENTTYPE isEqualToString:KContentTypePageWeb])
        {
            _playbuttonImageView.image =  [UIImage imageNamed:PlayWebIcon];
        }
        
        if (lessonData.BEDLPERCENT==1)
        {
            _titleLabel.text=lessonData.BETITLE;
        }
        else{
            
            NSString * txt=@"已经进入自动下载队列";
            
            if (lessonData.BEDLPERCENT==0) {
                
                iFlyingAppDelegate *delegate = (iFlyingAppDelegate *)[UIApplication sharedApplication].delegate;
                
                if ([delegate isWaitting:nowLessonData.BELESSONID]) {
                    
                    txt=@"<下载排队中...>";
                }
            }
            else{
                
                NSNumber * downloadRate =[[NSUserDefaults standardUserDefaults] valueForKey:lessonData.BELESSONID];
                NSInteger downloadSpeed =downloadRate.floatValue;
                
                if (downloadSpeed==0) {
                    
                    txt= [NSString stringWithFormat:@"下载:%.2f%%",lessonData.BEDLPERCENT*100];
                }
                else if(downloadSpeed<1000){
                    
                    txt= [NSString stringWithFormat:@"%.2f%% %ldk/s",lessonData.BEDLPERCENT*100,(long)downloadSpeed];
                }
                else{
                    
                    txt= [NSString stringWithFormat:@"%.2f%% %.2fM/s",lessonData.BEDLPERCENT*100,downloadSpeed/1000.0];
                }
            }
            
            _titleLabel.text= txt;
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
    
    _activityIndicator.hidesWhenStopped = YES;
    [_coverImageView addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
}

-(void) removeActivityIndicator
{
    
    [[_coverImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
