//
//  FlyingAddressBookTableViewCell.m

#import "FlyingAddressBookTableViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"

@implementation FlyingAddressBookTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.lblName.font= [UIFont boldSystemFontOfSize:KLargeFontSize];
    [self.imgvAva setContentMode:UIViewContentModeScaleAspectFill];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingAddressBookTableViewCell*) adressBookCell
{
    FlyingAddressBookTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingAddressBookTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)settingWithContentData:(RCUserInfo*) userInfo
{
    
    self.lblName.text = userInfo.name;

    if (![NSString isBlankString:userInfo.portraitUri]) {
        
        [self.imgvAva setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]
                     placeholderImage:[UIImage imageNamed:@"Account"]];
    }
    else
    {
        [self.imgvAva setImage:[UIImage imageNamed:@"Account"]];
    }
}


@end
