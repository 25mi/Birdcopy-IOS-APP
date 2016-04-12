//
//  FlyingBaseDao.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/18/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"
#import "FlyingDBManager.h"

@implementation FlyingBaseDao


- (id)init{
    if(self = [super init]){
        
        self.workDbQueue           = nil;
    }
    return self;
}

- (FMDatabaseQueue *) userDBQueue
{
    return [[FlyingDBManager shareInstance] shareUserDBQueue];
}

- (FMDatabaseQueue *) dicDBQueue
{
    return [[FlyingDBManager shareInstance] shareDicDBQueue];
}

// 子类中实现
-(NSString *)setTable:(NSString *)sql
{
    return NULL;
}

// 子类中实现
-(void)       setUserModle:(BOOL) userModle;
{
    self.workDbQueue           = nil;
}

-(void) close
{
    if (self.workDbQueue) {
        [self.workDbQueue close];
    }
}

@end


