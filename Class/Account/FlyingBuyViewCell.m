//
//  FlyingBuyViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 4/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingBuyViewCell.h"
#import "shareDefine.h"

@interface FlyingBuyViewCell()


@property (strong, nonatomic) IBOutlet UILabel *priceLabel;


@end

@implementation FlyingBuyViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.priceLabel.font= [UIFont systemFontOfSize:KNormalFontSize];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (FlyingBuyViewCell*) buyTableCell
{
    FlyingBuyViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingBuyViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setPriceInfo:(NSString*) priceInfo
{
    self.priceLabel.text = priceInfo;
}


@end
