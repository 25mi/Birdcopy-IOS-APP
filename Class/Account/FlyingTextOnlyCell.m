//
//  FlyingTextOnlyCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingTextOnlyCell.h"
#import "shareDefine.h"


@interface FlyingTextOnlyCell()

@property (strong, nonatomic) IBOutlet UILabel *itemLabel;

@end

@implementation FlyingTextOnlyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingTextOnlyCell*) textOnlyCell
{
    FlyingTextOnlyCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingTextOnlyCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setItemText:(NSString*) itemText;
{
    self.itemLabel.text = itemText;
}

@end
