//
//  FlyingGroupMemberStartView.h
//  FlyingEnglish
//
//  Created by vincent sung on 26/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingUserRightData.h"

@protocol FlyingGroupMemberStartViewDelegate <NSObject>

@optional
- (void)touchLeft;
- (void)touchRight;

@end


@interface FlyingGroupMemberStartView : UIView

@property(nonatomic,strong) UILabel* favorLabel;
@property(nonatomic,strong) UILabel* joinLabel;

@property(nonatomic,assign) id<FlyingGroupMemberStartViewDelegate> delegate;

-(void) setUserGroupRight:(FlyingUserRightData*) userRightData;
-(void) setBadge:(NSInteger) badgeCount;

-(void) setFavorText:(NSString*) favorText;

@end
