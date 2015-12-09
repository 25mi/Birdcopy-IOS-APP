//
//  FlyingStatisticDAO.h
//  FlyingEnglish
//
//  Created by vincent sung on 3/4/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"

@class FlyingStatisticData;
@interface FlyingStatisticDAO : FlyingBaseDao

- (NSInteger)  timesWithUserID:  (NSString *) userID;
- (void)       updateWithUserID: (NSString *) userID
                          Times:(NSInteger) times;

- (NSInteger)  appleMoneyWithUserID:  (NSString *) userID;
- (void)       updateWithUserID: (NSString *) userID
                AppleMoneyCount:(NSInteger) moneyCount;

- (NSInteger)  qrMoneyWithUserID:  (NSString *) userID;
- (void)       updateWithUserID: (NSString *) userID
                QRMoneyCount:(NSInteger) qrMoneyCount;

- (NSInteger)  touchCountWithUserID:  (NSString *) userID;
- (void)       updateWithUserID: (NSString *) userID
                     TouchCount:(NSInteger) touchCount;

- (NSInteger)  giftCountWithUserID:  (NSString *) userID;
- (void)       updateWithUserID: (NSString *) userID
                      GiftCount:(NSInteger) giftCount;

- (void)       initDataForUserID: (NSString *) userID;

- (FlyingStatisticData *) selectWithUserID: (NSString *) userID;
- (void)                  insertWithData:   (FlyingStatisticData *)   data;
- (id)                    selectAll;

- (NSInteger)  totalBuyMoneyWithUserID:  (NSString *) userID;
- (NSInteger)  finalMoneyWithUserID:  (NSString *) userID;

- (BOOL) hasQRCount;
- (BOOL) insertQRCount;
- (BOOL) insertTimeStamp;

- (void) updateUserID:(NSString*) newUserID;

-(void)  clearAll;

@end
