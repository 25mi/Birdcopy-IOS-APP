//
//  FlyingAddressBookTableViewCell.m

#import "FlyingAddressBookTableViewCell.h"
//#import <QuartzCore/QuartzCore.h>

@implementation FlyingAddressBookTableViewCell

- (void)awakeFromNib {
    // Initialization code
//    _imgvAva.layer.masksToBounds = YES;
//    _imgvAva.layer.cornerRadius = 8.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (FlyingAddressBookTableViewCell*) adressBookCell
{
    FlyingAddressBookTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingAddressBookTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


@end
