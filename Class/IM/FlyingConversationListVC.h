//
//  FlyingConversationListVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/25/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface FlyingConversationListVC : RCConversationListViewController

@property (strong, nonatomic)   NSString    *domainID;
@property (strong, nonatomic)   NSString    *domainType;

@end
