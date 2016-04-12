//
//  RCDSelectPersonViewController.h
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "FlyingAddressBookVC.h"

@interface FlyingSelectPersonViewController : FlyingAddressBookVC

typedef void(^clickDone)(FlyingSelectPersonViewController *selectPersonViewController, NSArray *seletedUsers);

@property (nonatomic,copy) clickDone clickDoneCompletion;

@property (nonatomic,strong) NSArray *seletedUsers;



@end
