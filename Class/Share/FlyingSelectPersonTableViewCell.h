//
//  RCDSelectPersonTableViewCell.h
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RCUserInfo.h>

@interface FlyingSelectPersonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivSelected;
@property (weak, nonatomic) IBOutlet UIImageView *ivAva;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

+ (FlyingSelectPersonTableViewCell*) selectPersonCell;

-(void)settingWithContentData:(RCUserInfo*) userInfo;

@end
