//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingViewController.h"
#import "FlyingGroupBoard.h"
#import "FlyingGroupMemberStartView.h"
#import "YALSunnyRefreshControl.h"

@interface FlyingGroupVC : FlyingViewController<
                                                UITableViewDataSource,
                                                UITableViewDelegate,
                                                FlyingGroupMemberStartViewDelegate,
                                                YALSunnyRefreshControlDelegate,
                                                FlyingGroupBoardDelegate>

@property (strong, nonatomic) FlyingGroupData    *groupData;

@property (strong, atomic)    NSMutableArray     *currentData;

+(void) contactAdminWithGroupID:(NSString*) groupID
                         message:(NSString*) message
                           inVC:(UIViewController*) vc;

+(void) contactAppServiceWithMessage:(NSString*) message
                                inVC:(UIViewController*) vc;

+(void) doMemberRightInVC:(UIViewController*) vc
                   GroupID:(NSString*)groupID
                Completion:(void (^)(FlyingUserRightData *userRightData)) completion;

@end



