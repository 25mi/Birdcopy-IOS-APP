//
//  FlyingGroupUpdateData.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlyingGroupData.h"
#import "FlyingPubLessonData.h"

@interface FlyingGroupUpdateData : NSObject

@property (nonatomic, strong) FlyingGroupData       *groupData;
@property (nonatomic, strong) FlyingPubLessonData   *recentLessonData;

@end
