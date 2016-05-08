//
//  FlyingLoadingCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingLoadingCell.h"
#import "shareDefine.h"

@implementation FlyingLoadingCell

- (void)awakeFromNib {
    // Initialization code
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.indicator.hidesWhenStopped = YES;
    self.indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|
    UIViewAutoresizingFlexibleBottomMargin;
    
    self.indicatorText.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingLoadingCell*) loadingCell
{
    FlyingLoadingCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingLoadingCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)startAnimating:(NSString*) text
{
    if (!text) {
        text=@"正在努力加载中...";
    }
    self.indicatorText.text=text;

    [self.indicator startAnimating];
}

- (void)stopAnimating:(NSString*) text
{
    if (!text) {
        text=@"加载完毕...";
    }

    self.indicatorText.text=text;
    [self.indicator stopAnimating];
}

@end
