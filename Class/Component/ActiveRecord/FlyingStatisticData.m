//
//  FlyingStatisticData.m
//  FlyingEnglish
//
//  Created by vincent sung on 3/4/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingStatisticData.h"

@implementation FlyingStatisticData

- (id)initWithUserID:    (NSString *) userID
          MoneyCount:    (NSInteger)  moneyCount
          TouchCount:    (NSInteger)  touchCount
        LearnedTimes:    (NSInteger)  times
           GiftCount:    (NSInteger)  giftCount
             QRCount:    (NSInteger)  qrCount
           TimeStamp:    (NSString *) timeStamp
{
    if(self = [super init]){
        self.BEUSERID     = userID;
        self.BEMONEYCOUNT = moneyCount;
        self.BETOUCHCOUNT = touchCount;
        self.BETIMES      = times;
        self.BEGIFTCOUNT  = giftCount;
        self.BEQRCOUNT    = qrCount;
        self.BETIMESTAMP  = timeStamp;
    }
    
    return self;
}

@end
