//
//  FlyingStatisitcTableViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 4/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingStatisitcTableViewCell.h"
#import "shareDefine.h"

@implementation FlyingStatisitcTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    
    self.currentCount.font= [UIFont systemFontOfSize:KNormalFontSize];
    self.buyCount.font= [UIFont systemFontOfSize:KNormalFontSize];
    self.awardCount.font= [UIFont systemFontOfSize:KNormalFontSize];
    self.consumeCount.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    self.currentLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    self.buyLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    self.awardLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    self.consumeLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    
    
    self.currentLabel.text = NSLocalizedString(@"currentCount", nil);
    self.buyLabel.text = NSLocalizedString(@"buyCount", nil);
    self.awardLabel.text = NSLocalizedString(@"awardCount", nil);
    self.consumeLabel.text = NSLocalizedString(@"consumeCount", nil);

    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingStatisitcTableViewCell*) statisticTableCell
{
    FlyingStatisitcTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingStatisitcTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setCurrent:(NSString*) current
{
    self.currentCount.text = current;
}

-(void) setBuy:(NSString*)buy
{
    self.buyCount.text = buy;
}

-(void) setAward:(NSString*) award
{
    self.awardCount.text = award;
}

-(void) setConsume:(NSString*) consume
{
    self.consumeCount.text = consume;
}



@end
