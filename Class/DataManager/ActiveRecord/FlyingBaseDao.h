//
//  FlyingBaseDao.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/18/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabaseQueue;

@interface FlyingBaseDao : NSObject

@property (nonatomic, strong) FMDatabaseQueue *workDbQueue;//使用时的dbQueue

- (FMDatabaseQueue *) userDBQueue;
- (FMDatabaseQueue *) dicDBQueue;

- (NSString *) setTable: (NSString *)sql;

- (void)       close;

@end



