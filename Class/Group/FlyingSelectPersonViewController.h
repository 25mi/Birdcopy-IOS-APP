//
//  RCDSelectPersonViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "FlyingAddressBookViewController.h"

@interface FlyingSelectPersonViewController : FlyingAddressBookViewController<UIActionSheetDelegate>

typedef void(^clickDone)(FlyingSelectPersonViewController *selectPersonViewController, NSArray *seletedUsers);

@property (nonatomic,copy) clickDone clickDoneCompletion;


@end
