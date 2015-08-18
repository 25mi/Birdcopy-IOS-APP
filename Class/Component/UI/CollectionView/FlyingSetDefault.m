//
//  FlyingSetDefault.m
//  FlyingEnglish
//
//  Created by vincent on 1/30/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingSetDefault.h"
#import "shareDefine.h"

@interface FlyingSetDefault()
{
    UILabel * wordLabel;
}
@end

@implementation FlyingSetDefault

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        
        CGRect  indicatorrect = CGRectMake(kMargin, 2, self.frame.size.width-2*kMargin, 40);
        
        wordLabel           = [[UILabel alloc] initWithFrame:indicatorrect];
        wordLabel.textAlignment=NSTextAlignmentCenter;
        wordLabel.backgroundColor=[UIColor whiteColor];
        wordLabel.text      = @"点击这里恢复默认系统服务！";
        
        wordLabel.font = [UIFont boldSystemFontOfSize:12.0];
        if (INTERFACE_IS_PAD ) {
            wordLabel.font = [UIFont boldSystemFontOfSize:20.0];
        }
        wordLabel.textColor = [UIColor blackColor];
        
        [self addSubview:wordLabel];
    }
    return self;
}

@end
