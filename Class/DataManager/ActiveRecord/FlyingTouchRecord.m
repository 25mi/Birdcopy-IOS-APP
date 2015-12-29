//
//  FlyingTouchRecord.m
//  FlyingEnglish
//
//  Created by BE_Air on 2/20/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingTouchRecord.h"

@implementation FlyingTouchRecord

- (id)initWithUserID: (NSString *) userID
            LessonID: (NSString *) lessonID
          TouchTimes: (double)     touchTimes
{

    if(self = [super init]){
        
        self.BEUSERID    = userID;
        self.BELESSONID  = lessonID;
        self.BETOUCHTIMES= touchTimes;
    }
    return self;
}

@end
