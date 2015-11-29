//
//  FlyingSeparateView.m
//  FlyingEnglish
//
//  Created by vincent on 3/13/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingSeparateView.h"
#import "shareDefine.h"

@interface FlyingSeparateView ()
{
    CGFloat            _margin;
    float              _width;
}

@property (strong, nonatomic) UILabel *titlelabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

@end

@implementation FlyingSeparateView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code.
        [self commonInit];
    }
    return self;
}

-(void) commonInit
{
    if (INTERFACE_IS_PAD)
    {
        
        _margin=MARGIN_ipad;
    }
    else{
        _margin=MARGIN_iphone;
    }
    _width=self.bounds.size.width-2*_margin;
    
    
    UIFont *titleFont,*subtitleFont;
    
    if (INTERFACE_IS_PAD)
    {
        titleFont = [UIFont boldSystemFontOfSize:font_ipad_size];
        subtitleFont = [UIFont systemFontOfSize:font_ipad_size];
    }
    else
    {
        titleFont = [UIFont boldSystemFontOfSize:font_iphone_size];
        subtitleFont = [UIFont systemFontOfSize:font_iphone_size];
    }

    //self.backgroundColor = [UIColor colorWithRed:0.98 green:0.99 blue:0.99 alpha:1];
    
    self.titlelabel =[[UILabel alloc] initWithFrame:CGRectMake(_margin,
                                                               0,
                                                               _width/2,
                                                               self.frame.size.height)];
    self.titlelabel.font=titleFont;
    self.titlelabel.textAlignment=NSTextAlignmentLeft;
    self.titlelabel.textColor=[UIColor blackColor];
    [self addSubview:self.titlelabel];
    
    self.subtitleLabel =[[UILabel alloc] initWithFrame:CGRectMake(self.titlelabel.frame.origin.x+self.titlelabel.frame.size.width,
                                                                  0,
                                                                  _width/2,
                                                                  self.frame.size.height)];
    self.subtitleLabel.font=subtitleFont;
    self.subtitleLabel.textAlignment=NSTextAlignmentRight;
    self.subtitleLabel.textColor=[UIColor blackColor];
    [self addSubview:self.subtitleLabel];
}

-(void) setTitle: (NSString *)title
{
    self.titlelabel.text=title;
}

-(void) setsubTitle: (NSString *)subtitle
{
    self.subtitleLabel.text=subtitle;
}



@end
