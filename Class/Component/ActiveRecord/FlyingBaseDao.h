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
- (FMDatabaseQueue *) pubUserDBQueue;
- (FMDatabaseQueue *) baseDBQueue;
- (FMDatabaseQueue *) pubBaseDBQueue;

- (NSString *) setTable: (NSString *)sql;
- (void)       setUserModle:(BOOL) userModle;

- (void)       close;

@end



