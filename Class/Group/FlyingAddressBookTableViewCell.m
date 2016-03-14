//
//  FlyingAddressBookTableViewCell.m

#import "FlyingAddressBookTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "shareDefine.h"

@implementation FlyingAddressBookTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    self.lblName.font= [UIFont boldSystemFontOfSize:KLargeFontSize];
    [self.imgvAva setContentMode:UIViewContentModeScaleAspectFill];
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


-(void)settingWithContentData:(FlyingGroupMemberData*) memberData
{
    
    self.lblName.text = memberData.name;

    if (memberData.portrait_url.length!=0) {
        [self.imgvAva  sd_setImageWithURL:[NSURL URLWithString:memberData.portrait_url] placeholderImage:[UIImage imageNamed:@"Account"]];
    }
    else
    {
        [self.imgvAva setImage:[UIImage imageNamed:@"Account"]];
    }

}


@end
