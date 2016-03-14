//
//  FlyingGroupCoverView.m
//  FlyingEnglish
//
//  Created by vincent sung on 2/29/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingGroupCoverView.h"

#import "XHWaterDropRefresh.h"

#import <Accelerate/Accelerate.h>
#import <float.h>
#import "UIImageView+WebCache.h"
#import "shareDefine.h"

@interface FlyingGroupCoverView () {
    BOOL normal, paste, hasStop;
    BOOL isrefreshed;
}

@property (nonatomic, strong) UIView *bannerView;

@property (nonatomic, strong) UIView *showView;

@property (nonatomic, strong) XHWaterDropRefresh *waterDropRefresh;

@property (nonatomic, assign) CGFloat showUserInfoViewOffsetHeight;

@end

@implementation FlyingGroupCoverView


-(void)settingWithContentData:(FlyingPubLessonData*) contentData
{
    [self.bannerImageView  sd_setImageWithURL:[NSURL URLWithString:contentData.imageURL] placeholderImage:[UIImage imageNamed:@"Default"]];

    self.contentNameLabel.text = contentData.title;
    self.contentDescLabel.text = contentData.desc;
}


#pragma mark - Publish Api

- (void)stopRefresh {
    [_waterDropRefresh stopRefresh];
    if(_touching == NO) {
        [self resetTouch];
    } else {
        hasStop = YES;
    }
}

// background
- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (backgroundImage) {
        _bannerImageView.image = backgroundImage;
    }
}

- (void)setBackgroundImageUrlString:(NSString *)backgroundImageUrlString {
    if (backgroundImageUrlString) {
        
    }
}

// avatar
- (void)setAvatarImage:(UIImage *)avatarImage {
    if (avatarImage) {
        [_avatarButton setImage:avatarImage forState:UIControlStateNormal];
    }
}

- (void)setAvatarUrlString:(NSString *)avatarUrlString {
    if (avatarUrlString) {
        
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.touching = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.offsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate == NO) {
        self.touching = NO;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.touching = NO;
}

#pragma mark - Propertys

- (void)setTouching:(BOOL)touching {
    if(touching) {
        if(hasStop) {
            [self resetTouch];
        }
        
        if(normal) {
            paste = YES;
        } else if (paste == NO && _waterDropRefresh.isRefreshing == NO) {
            normal = YES;
        }
    } else if(_waterDropRefresh.isRefreshing == NO) {
        [self resetTouch];
    }
    _touching = touching;
}

- (void)setOffsetY:(CGFloat)y {
    CGFloat fixAdaptorPadding = 0;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 7.0) {
        fixAdaptorPadding = 64;
    }
    y += fixAdaptorPadding;
    _offsetY = y;
    CGRect frame = _showView.frame;
    if(y < 0) {
        if((_waterDropRefresh.isRefreshing) || hasStop) {
            if(normal && paste == NO) {
                frame.origin.y = self.showUserInfoViewOffsetHeight + y;
                _showView.frame = frame;
            } else {
                if(frame.origin.y != self.showUserInfoViewOffsetHeight) {
                    frame.origin.y = self.showUserInfoViewOffsetHeight;
                    _showView.frame = frame;
                }
            }
        } else {
            frame.origin.y = self.showUserInfoViewOffsetHeight + y;
            _showView.frame = frame;
        }
    } else {
        if(normal && _touching && isrefreshed) {
            paste = YES;
        }
        if(frame.origin.y != self.showUserInfoViewOffsetHeight) {
            frame.origin.y = self.showUserInfoViewOffsetHeight;
            _showView.frame = frame;
        }
    }
    if (hasStop == NO) {
        _waterDropRefresh.currentOffset = y;
    }
    
    UIView *bannerSuper = _bannerImageView.superview;
    CGRect bframe = bannerSuper.frame;
    if(y < 0) {
        bframe.origin.y = y;
        bframe.size.height = -y + bannerSuper.superview.frame.size.height;
        bannerSuper.frame = bframe;
        
        CGPoint center =  _bannerImageView.center;
        center.y = bannerSuper.frame.size.height / 2;
        _bannerImageView.center = center;
        
        if (self.isZoomingEffect) {
            _bannerImageView.center = center;
            CGFloat scale = fabs(y) / self.parallaxHeight;
            _bannerImageView.transform = CGAffineTransformMakeScale(1+scale, 1+scale);
        }
    } else {
        if(bframe.origin.y != 0) {
            bframe.origin.y = 0;
            bframe.size.height = bannerSuper.superview.frame.size.height;
            bannerSuper.frame = bframe;
        }
        if(y < bframe.size.height) {
            CGPoint center =  _bannerImageView.center;
            center.y = bannerSuper.frame.size.height/2 + 0.5 * y;
            _bannerImageView.center = center;
        }
    }
    
    if (self.isLightEffect) {
        if(y < 0 && y >= -self.lightEffectPadding) {
            float percent = (-y / (self.lightEffectPadding * self.lightEffectAlpha));
            self.bannerImageViewWithImageEffects.alpha = percent;
            
        } else if (y <= -self.lightEffectPadding) {
            self.bannerImageViewWithImageEffects.alpha = self.lightEffectPadding / (self.lightEffectPadding * self.lightEffectAlpha);
        } else if (y > self.lightEffectPadding) {
            self.bannerImageViewWithImageEffects.alpha = 0;
        }
    }
}

#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.parallaxHeight = 170;
    self.isLightEffect = YES;
    self.lightEffectPadding = 80;
    self.lightEffectAlpha = 1.15;
    
    _bannerView = [[UIView alloc] initWithFrame:self.bounds];
    _bannerView.clipsToBounds = YES;
    UITapGestureRecognizer *tapGestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecongnizerHandle:)];
    [_bannerView addGestureRecognizer:tapGestureRecongnizer];
    
    _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -self.parallaxHeight, CGRectGetWidth(_bannerView.frame), CGRectGetHeight(_bannerView.frame) + self.parallaxHeight * 2)];
    _bannerImageView.contentMode = UIViewContentModeScaleToFill;
    [_bannerView addSubview:self.bannerImageView];
    
    _bannerImageViewWithImageEffects = [[UIImageView alloc] initWithFrame:_bannerImageView.frame];
    _bannerImageViewWithImageEffects.alpha = 0.;
    [_bannerView addSubview:self.bannerImageViewWithImageEffects];
    
    [self addSubview:self.bannerView];
    
    CGFloat waterDropRefreshHeight = 100;
    CGFloat waterDropRefreshWidth = 20;
    _waterDropRefresh = [[XHWaterDropRefresh alloc] initWithFrame:CGRectMake(33, CGRectGetHeight(self.bounds) - waterDropRefreshHeight, waterDropRefreshWidth, waterDropRefreshHeight)];
    _waterDropRefresh.refreshCircleImage = [UIImage imageNamed:@"circle"];
    _waterDropRefresh.offsetHeight = 20; // 线条的长度
    [self addSubview:self.waterDropRefresh];
    
    CGFloat avatarButtonHeight = 66;
    self.showUserInfoViewOffsetHeight = CGRectGetHeight(self.frame) - waterDropRefreshHeight / 3 - avatarButtonHeight;
    _showView = [[UIView alloc] initWithFrame:CGRectMake(0, self.showUserInfoViewOffsetHeight, CGRectGetWidth(self.bounds), waterDropRefreshHeight)];
    _showView.backgroundColor = [UIColor clearColor];
    
    _avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 0, avatarButtonHeight, avatarButtonHeight)];
    
    _contentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 0, 207, 42)];
    _contentNameLabel.textColor = [UIColor blackColor];
    _contentNameLabel.backgroundColor = [UIColor clearColor];
    _contentNameLabel.font = [UIFont boldSystemFontOfSize:KLargeFontSize];
    _contentDescLabel.numberOfLines=0;
    
    _contentDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 42, 207, 48)];
    _contentDescLabel.textColor = [UIColor blackColor];
    _contentDescLabel.backgroundColor = [UIColor clearColor];
    _contentDescLabel.font = [UIFont systemFontOfSize:KSmallFontSize];
    _contentDescLabel.numberOfLines=3;
    
    [_showView addSubview:self.avatarButton];
    [_showView addSubview:self.contentNameLabel];
    [_showView addSubview:self.contentDescLabel];
    
    [self addSubview:self.showView];
}

- (void)dealloc {
    self.bannerImageView = nil;
    self.bannerImageViewWithImageEffects = nil;
    
    self.avatarButton = nil;
    self.contentNameLabel = nil;
    self.contentDescLabel = nil;
    
    self.bannerView = nil;
    self.showView = nil;
    
    self.waterDropRefresh = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if(newSuperview) {
        [self initWaterView];
    }
}

- (void)initWaterView {
    __weak FlyingGroupCoverView *wself =self;
    [_waterDropRefresh setHandleRefreshEvent:^{
        [wself setIsRefreshed:YES];
        if(wself.handleRefreshEvent) {
            wself.handleRefreshEvent();
        }
    }];
}

#pragma mark - previte method

- (void)tapGestureRecongnizerHandle:(UITapGestureRecognizer *)tapGestureRecongnizer {
    if (self.handleTapBackgroundImageEvent) {
        self.handleTapBackgroundImageEvent();
    }
}

- (void)setIsRefreshed:(BOOL)b {
    isrefreshed = b;
}

- (void)refresh {
    if(_waterDropRefresh.isRefreshing) {
        [_waterDropRefresh startRefreshAnimation];
    }
}

- (void)resetTouch {
    normal = NO;
    paste = NO;
    hasStop = NO;
    isrefreshed = NO;
}

@end
