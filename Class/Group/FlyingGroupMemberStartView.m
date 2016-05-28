//
//  FlyingGroupMemberStartView.m
//  FlyingEnglish
//
//  Created by vincent sung on 26/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingGroupMemberStartView.h"
#import "UIColor+RCColor.h"
#import "shareDefine.h"
#import "iFlyingAppDelegate.h"
#import <GIBadgeView.h>

@interface FlyingGroupMemberStartView()

@property(nonatomic,strong) UIView *leftView;
@property(nonatomic,strong) UIView *rightView;

@end


@implementation FlyingGroupMemberStartView

-(void) setUserGroupRight:(FlyingUserRightData*) userRightData;
{
    self.joinLabel.text = [userRightData getChatTutorForMemberstate];
    
    UIColor *newColor = [userRightData getMemberTutorColor];
    
    if (newColor)
    {
        self.rightView.backgroundColor = newColor;
    }
    
    UIColor *textColor=  [UIColor readableForegroundColorForBackgroundColor:self.rightView.backgroundColor];
    
    self.joinLabel.textColor = textColor;
}

-(void) setBadge:(NSInteger) badgeCount;
{
    
    GIBadgeView *badge = [GIBadgeView new];
    [self.joinLabel addSubview:badge];
    
    // Manually set your badge value to whatever number you want.
    badge.badgeValue = badgeCount;
}

-(void) setFavorText:(NSString*) favorText
{
    self.favorLabel.text = favorText;
}


#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    self.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.000];

    CGRect leftFrame=self.frame;

    leftFrame.origin.x    = 0;
    leftFrame.origin.y    = 0;
    leftFrame.size.width  = self.frame.size.width/2.0;
    leftFrame.size.height = self.frame.size.height;
    
    self.leftView = [[UIView alloc] initWithFrame:leftFrame];
    self.leftView.backgroundColor =[UIColor clearColor];
    self.leftView.layer.borderColor = [UIColor grayColor].CGColor;
    self.leftView.layer.borderWidth = .5f;
    
    UITapGestureRecognizer *leftRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchLeft)];
    leftRecognizer.numberOfTapsRequired = 1; // 单击
    [self.leftView addGestureRecognizer:leftRecognizer];
    [self addSubview:self.leftView];
    
    
    CGRect rightFrame=leftFrame;

    rightFrame.origin.x    = self.frame.size.width/2.0;
    rightFrame.size.width  = self.frame.size.width/2.0;

    self.rightView = [[UIView alloc] initWithFrame:rightFrame];
    self.rightView.backgroundColor =[UIColor clearColor];
    self.rightView.layer.borderColor = [UIColor grayColor].CGColor;
    self.rightView.layer.borderWidth = 0.5f;
    
    UITapGestureRecognizer *rightRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchRight)];
    rightRecognizer.numberOfTapsRequired = 1; // 单击
    [self.rightView addGestureRecognizer:rightRecognizer];
    [self addSubview:self.rightView];
    
    if (!self.favorLabel)
    {
        CGRect favorIconFrame=leftFrame;

        favorIconFrame.origin.x = leftFrame.size.width/4.0;
        favorIconFrame.origin.y = (leftFrame.size.height-24)/2.0;
        favorIconFrame.size.width =24;
        favorIconFrame.size.height =24;

        UIImageView* favorIcon= [[UIImageView alloc] initWithFrame:favorIconFrame];
        favorIcon.image = [UIImage imageNamed:@"Favorite"];
        
        [self.leftView addSubview:favorIcon];
        
        CGRect favorLabelFrame=leftFrame;
        
        favorLabelFrame.origin.x = favorIcon.frame.origin.x+24;
        favorLabelFrame.origin.y = 0;
        favorLabelFrame.size.width =leftFrame.size.width/2-24;
        favorLabelFrame.size.height =leftFrame.size.height;
        
        self.favorLabel = [[UILabel alloc] initWithFrame:favorLabelFrame];
        self.favorLabel.font = [UIFont systemFontOfSize:KLargeFontSize];
        self.favorLabel.textAlignment = NSTextAlignmentCenter;
        self.favorLabel.text = NSLocalizedString(@"Featured",nil);
        
        [self.leftView addSubview:self.favorLabel];
    }
    
    if (!self.joinLabel)
    {
        CGRect joinLabelFrame=self.rightView.frame;
        joinLabelFrame.origin.x = 0;
        
        self.joinLabel = [[UILabel alloc] initWithFrame:joinLabelFrame];
        self.joinLabel.font = [UIFont systemFontOfSize:KLargeFontSize];
        self.joinLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.rightView addSubview:self.joinLabel];
    }
}

-(void) touchLeft
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchLeft)])
    {
        [self.delegate touchLeft];
    }
}

-(void) touchRight
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchRight)])
    {
        [self.delegate touchRight];
    }
}

@end
