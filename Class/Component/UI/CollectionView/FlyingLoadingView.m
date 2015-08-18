//
//  FlyingLoadingView.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/5/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingLoadingView.h"
#import "shareDefine.h"

@interface FlyingLoadingView()
{
    UILabel * wordLabel;
    UIView * indicatorBackView;
    UIActivityIndicatorView *indicatorView;
}
@end

@implementation FlyingLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect  indicatorrect = CGRectMake(kMargin, 0, self.frame.size.width-2*kMargin, 44);
        
        UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hitLoadingView)];
        singleRecognizer.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:singleRecognizer];

        //白底黑字
        indicatorBackView =[[UIView alloc] initWithFrame:indicatorrect];
        indicatorBackView.backgroundColor=[UIColor whiteColor];
        
        wordLabel           = [[UILabel alloc] initWithFrame:indicatorBackView.frame];
        wordLabel.textAlignment=NSTextAlignmentCenter;
        wordLabel.backgroundColor=[UIColor clearColor];
        wordLabel.text      = @"没有更多内容！";
        
        wordLabel.font = [UIFont boldSystemFontOfSize:12.0];
        if (INTERFACE_IS_PAD ) {
            wordLabel.font = [UIFont boldSystemFontOfSize:20.0];
        }
        wordLabel.textColor = [UIColor blackColor];
        
        [self addSubview:indicatorBackView];
        [indicatorBackView addSubview:wordLabel];
    }
    return self;
}

-(void)hitLoadingView
{
    if (self.loadingViewDelegate)
    {
        if ([wordLabel.text isEqualToString:@"加载更多内容"]  && [self.loadingViewDelegate respondsToSelector:@selector(downloadMore)])
        {
            if ([self.loadingViewDelegate downloadMore])
            {
                [self showIndicator];
            }
        }
        else if ([wordLabel.text isEqualToString:@"点击右上角搜索更多内容!"]  && [self.loadingViewDelegate respondsToSelector:@selector(doSearch)])
        {
            [self.loadingViewDelegate doSearch];
        }
    }
}

-(void) showTitle:(NSString *) str
{
    if (indicatorView)
    {
        [indicatorView removeFromSuperview];
        indicatorView=nil;
    }
    
    if (!wordLabel)
    {
        wordLabel           = [[UILabel alloc] initWithFrame:indicatorBackView.frame];
        wordLabel.textAlignment=NSTextAlignmentCenter;
        wordLabel.backgroundColor=[UIColor clearColor];
        
        wordLabel.font = [UIFont boldSystemFontOfSize:12.0];
        if (INTERFACE_IS_PAD ) {
            wordLabel.font = [UIFont boldSystemFontOfSize:20.0];
        }
        wordLabel.textColor = [UIColor blackColor];
    }
    wordLabel.text      = str;
    
    [indicatorBackView addSubview:wordLabel];
}

-(void)showIndicator
{
    if (wordLabel)
    {
        [wordLabel removeFromSuperview];
        wordLabel=nil;
    }
    
    //指定进度轮的大小
    if (!indicatorView)
    {
        indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    }
    //指定进度轮中心点
    [indicatorView setCenter:indicatorBackView.center];
    
    //设置进度轮显示类型
    [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    [indicatorBackView addSubview:indicatorView];
    [indicatorView startAnimating];
}

@end
