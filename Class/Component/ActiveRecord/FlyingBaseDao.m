//
//  FlyingBaseDao.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/18/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"
#import "iFlyingAppDelegate.h"
#import "FMDatabaseQueue.h"

@implementation FlyingBaseDao


- (id)init{
    if(self = [super init]){
        
        self.workDbQueue           = nil;
    }
    return self;
}

- (FMDatabaseQueue *) userDBQueue
{

    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate shareUserDBQueue];
}

- (FMDatabaseQueue *) pubUserDBQueue
{

    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate sharePubUserDBQueue];
}

- (FMDatabaseQueue *) baseDBQueue
{
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate shareBaseDBQueue];
}

- (FMDatabaseQueue *) pubBaseDBQueue
{

    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate sharePubBaseDBQueue];
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


