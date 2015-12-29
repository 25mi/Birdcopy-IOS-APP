//
//  FlyingTaskWordData.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingTaskWordData.h"

@implementation FlyingTaskWordData

- (id) initWithUserID:(NSString *)     userID
                 Word:(NSString*)      word
             Sentence:(NSString *)  sentence
             LessonID:(NSString*)      lessonID
                Times:(int)           times
{
    if(self = [super init]){
        self.BEUSERID=userID;
        self.BEWORD  = word;
        self.BESENTENCE= sentence;
        self.BELESSONID = lessonID;
        self.BETIMES = times;
    }
    
    return self;
}


@end
