//
//  FlyingBoardUIView.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/11/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingBoardUIView.h"

#define BOARD_ACTIVITY_INDICATOR 149462


@implementation UITouch (TouchSorting)

- (NSComparisonResult)compareTouch:(id)obj
{
    if ((__bridge void *)self < (__bridge void *)obj)
    {
        return NSOrderedAscending;
    }
    else if ((__bridge void *)self == (__bridge void *)obj)
    {
        return NSOrderedSame;
    }
    else
    {
        return NSOrderedDescending;
    }
}

@end


@interface FlyingBoardUIView ()

@property (strong,nonatomic) UIImageView * backgroundNotesImageView;

@property (strong,nonatomic) UILabel     * titleLabel;
@property (strong,nonatomic) UILabel     * typeLabel;


@property (assign,nonatomic) BOOL   fullScreenModle;

@end

@implementation FlyingBoardUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque=NO;
        self.alpha=0;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = YES;
        self.clipsToBounds=YES;
        
        self.fullScreenModle=NO;
    }
    return self;
}

-(void) setBoardData:(FlyingStreamData*)      streamData
{
    self.streamData = streamData;
    self.title=streamData.title;
    self.boardType=streamData.contentType;
    self.boardContent=streamData.contentSummary;
    
    [self presentBoardHeader];
    [self presentBoardContent];
}

- (void) presentBoardHeader
{
    CGRect thisframe = self.frame;
    CGSize thisSize =self.frame.size;
    
    //磁贴背景图
    self.backgroundNotesImageView = [[UIImageView alloc] initWithFrame:thisframe];
    self.backgroundNotesImageView.image =  [UIImage imageNamed:@"Board" ];
    
    //磁铁以及文字
    self.magnetImageView                 = [[UIImageView alloc] initWithFrame:CGRectMake(thisSize.width*2/5, 0, thisSize.width/5, thisSize.width/5)];
    
    
    NSArray * colorImagesArray = [NSArray arrayWithObjects:
                                  @"Red",
                                  @"Orange",
                                  @"Yellow",
                                  @"Green",
                                  @"Cyan",
                                  @"Blue",
                                  @"Purple",
                                  @"Magenta",
                                  @"Brown",
                                  @"White",
                                  nil];
    
    self.magnetImageView.image           = [UIImage imageNamed:[NSString stringWithFormat:@"Magnet%@",colorImagesArray[self.boardContent.length%colorImagesArray.count]]];

    self.magnetImageView.backgroundColor = [UIColor clearColor];
    
    self.typeLabel                 = [UILabel new];
    self.typeLabel.textAlignment   =  NSTextAlignmentCenter;
    self.typeLabel.backgroundColor = [UIColor clearColor];
    self.typeLabel.text            = self.boardType;
    
    CGFloat fontTagSize = 8;
    
    if (INTERFACE_IS_PAD) {
        
        if (self.fullScreenModle) {
            fontTagSize=16;
        }
        else{
            
            fontTagSize=12;
        }
    }
    else
    {
        if (self.fullScreenModle) {
            fontTagSize=14;
        }
        else
        {
            fontTagSize=10;
        }
    }
    
    self.typeLabel.font      = [UIFont systemFontOfSize:fontTagSize];
    self.typeLabel.textColor = [UIColor blackColor];
    self.typeLabel.frame     =  CGRectMake(0, thisSize.width/20, thisSize.width/5, thisSize.width/10);
    
    //组装磁贴图片和文字为磁贴
    [self.magnetImageView addSubview:self.typeLabel];
    
    //单词标题
    self.titleLabel               = [UILabel new];
    self.titleLabel.text          = self.title;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    CGFloat fontTitleSize         = 8;
    if (INTERFACE_IS_PAD) {
        
        if (self.fullScreenModle) {
            fontTitleSize=18;
        }
        else{
            
            fontTitleSize=14;
        }
    }
    else
    {
        if (self.fullScreenModle) {
            fontTitleSize=16;
        }
        else
        {
            fontTitleSize=12;
        }
    }
    
    self.titleLabel.font          = [UIFont boldSystemFontOfSize:fontTitleSize];
    self.titleLabel.textColor     = [UIColor blackColor];
    self.titleLabel.frame         =  CGRectMake(thisSize.width/10, thisSize.width*4/20, thisSize.width, thisSize.width/10);
    
    //统一组装成个性化单词解释
    [self addSubview:self.backgroundNotesImageView];
    [self addSubview:self.magnetImageView];
    [self addSubview:self.titleLabel];
}


- (void) presentBoardContent
{
    
    if (self.boardContent) {
        
        UILabel * descLabel = [UILabel new];
        
        CGSize thisSize =self.frame.size;
        
        //单词本词性中文解释
        descLabel.text       = self.boardContent;
        descLabel.textAlignment=NSTextAlignmentLeft;
        descLabel.numberOfLines=0;
        descLabel.backgroundColor = [UIColor clearColor];
        
        CGFloat fontSubtitleSize = 8;
        if (INTERFACE_IS_PAD) {
            
            if (self.fullScreenModle) {
                fontSubtitleSize=16;
            }
            else{
                
                fontSubtitleSize=12;
            }
        }
        else
        {
            if (self.fullScreenModle) {
                fontSubtitleSize=14;
            }
            else
            {
                fontSubtitleSize=10;
            }
        }
        
        descLabel.font       = [UIFont systemFontOfSize:fontSubtitleSize];
        descLabel.textColor  = [UIColor blackColor];
        
        CGSize constraint = CGSizeMake(160*thisSize.width/200, MAXFLOAT);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = descLabel.font;
        gettingSizeLabel.text = self.boardContent;
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
        
        
        CGFloat hight= expectSize.height<thisSize.height*3/5? expectSize.height:thisSize.height*3/5;
        
        descLabel.frame = CGRectMake(20*thisSize.width/200,
                                     self.titleLabel.frame.size.height+self.titleLabel.frame.origin.y,
                                     constraint.width, hight);
        
        [self addSubview:descLabel];
    }
}

- (void)dismissViewAnimated:(BOOL)animated {
    
    if (animated) {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.alpha=0;
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
        
    }
    else{
        
        [self removeFromSuperview];
    }
}

@end
