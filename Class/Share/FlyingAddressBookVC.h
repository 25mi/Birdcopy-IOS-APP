//
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "shareDefine.h"
#import "FlyingViewController.h"
#import <RongIMLib/RCUserInfo.h>

@interface FlyingAddressBookVC: FlyingViewController<UITableViewDataSource,
                                                        UITableViewDelegate>

-(RCUserInfo*) getUserIofo:(NSIndexPath *)indexPath;


-(void) setallowsMultipleSelection:(BOOL) allowsMultipleSelection;

-(NSArray*) indexPathsForSelectedRows;

@end
