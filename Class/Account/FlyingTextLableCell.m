//
//  FlyingTextLableCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingTextLableCell.h"
#import "shareDefine.h"

@interface FlyingTextLableCell()

@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UILabel *cellTextlabel;

@end

@implementation FlyingTextLableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.itemLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    self.cellTextlabel.font= [UIFont systemFontOfSize:KNormalFontSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingTextLableCell*) textLabelCell
{
    FlyingTextLableCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingTextLableCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setItemText:(NSString*) itemText;
{
    self.itemLabel.text = itemText;
}

-(void) setCellText:(NSString*) cellText;
{
    self.cellTextlabel.text = cellText;
}


@end
