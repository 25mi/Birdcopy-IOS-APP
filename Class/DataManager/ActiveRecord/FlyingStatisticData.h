//
//  FlyingStatisticData.h
//  FlyingEnglish
//
//  Created by vincent sung on 3/4/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingStatisticData : NSObject

@property (nonatomic, strong) NSString  *BEUSERID;         //用户ID
@property (nonatomic, assign) NSInteger  BEMONEYCOUNT;     //苹果渠道金币总数量
@property (nonatomic, assign) NSInteger  BETOUCHCOUNT;     //点击单词总次数
@property (nonatomic, assign) NSInteger  BETIMES;          //学习总次数
@property (nonatomic, assign) NSInteger  BEGIFTCOUNT;      //奖励金币总数量
@property (nonatomic, assign) NSInteger  BEQRCOUNT;        //BE学习币充值总数
@property (nonatomic, assign) NSString  *BETIMESTAMP;      //时间戳

- (id)initWithUserID:    (NSString *) userID
          MoneyCount:    (NSInteger)  moneyCount
          TouchCount:    (NSInteger)  touchCount
        LearnedTimes:    (NSInteger)  times
           GiftCount:    (NSInteger)  giftCount
             QRCount:    (NSInteger)  qrCount
           TimeStamp:    (NSString *) timeStamp;
@end
