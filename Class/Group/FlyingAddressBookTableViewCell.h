//
//  FlyingAddressBookTableViewCell
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingGroupMemberData.h"

#define ADRESSCELL_IDENTIFIER @"addressgroupCell"


@interface FlyingAddressBookTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgvAva;


+ (FlyingAddressBookTableViewCell*) adressBookCell;

-(void)settingWithContentData:(FlyingGroupMemberData*) memberData;

@end
