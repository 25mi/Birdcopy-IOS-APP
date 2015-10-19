//
//  FlyingSysWithCenter.h
//  FlyingEnglish
//
//  Created by BE_Air on 2/7/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingSysWithCenter : NSObject

-(void) chargingCrad:(NSString*) cardID;

+(void) uploadUserCenter;
+(void) activeAccount;

+(void) sysMembershipWithCenter;
+(void) uploadMembershipWithCenter;

+(void) sysWithCenter;
+(void) lowCointAlert;

+(void) loginWithQR:(NSString*)loginID;

@end
