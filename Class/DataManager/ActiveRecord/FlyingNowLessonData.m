//
//  FlyingNowLessonData.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingNowLessonData.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "UICKeyChainStore.h"
#import "OpenUDID.h"
#import "NSString+FlyingExtention.h"
#import "FlyingDataManager.h"

@implementation FlyingNowLessonData

- (id)initWithLessonData:(FlyingLessonData *) lessonData;
{
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    if(self = [super init]){
        
        self.BEUSERID    = openID;
        self.BELESSONID  = lessonData.BELESSONID;
        self.BESTAMP     = 0;
        self.BELOCALCOVER= lessonData.localURLOfCover;
        self.BEORDER     = 0;
    }
    return self;
}

- (id)initWithUserID: (NSString *) userID
            LessonID: (NSString *) lessonID
           TimeStamp: (double)     timeStamp
          LocalCover: (NSString *) localCoverURL
{
    if(self = [super init]){
        
        self.BEUSERID    = userID;
        self.BELESSONID  = lessonID;
        self.BESTAMP     = timeStamp;
        self.BELOCALCOVER= localCoverURL;
        self.BEORDER     = 0;
    }
    return self;
}


- (double)   learnedPercentage
{
    double percent = 0;
    
    FlyingLessonData * data = [[[FlyingLessonDAO alloc] init] selectWithLessonID:self.BELESSONID];
        
    if (data.BEDURATION!=0){
        
        percent = self.BESTAMP/data.BEDURATION;
    }
    
    return percent;
}

@end

