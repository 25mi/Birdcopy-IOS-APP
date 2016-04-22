//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"
#import "FlyingGroupCoverView.h"

@interface FlyingGroupVC : FlyingViewController<
                                                UITableViewDataSource,
                                                UITableViewDelegate>

@property (strong, nonatomic) FlyingGroupData    *groupData;

@property (strong, nonatomic) NSMutableArray     *currentData;


+(void) checkGroupMembershipWith:(FlyingGroupData*)groupData
                            inVC:(UIViewController*) vc;

+(void) enterGroup:(FlyingGroupData*)groupData
              inVC:(UIViewController*) vc;

+ (void) showMemberInfo:(FlyingUserRightData*)userRightData
                   inVC:(UIViewController*) vc;

+(void) contactAdminWithGroupGID:(NSString*) groupID
                         message:(NSString*) message;


@end



