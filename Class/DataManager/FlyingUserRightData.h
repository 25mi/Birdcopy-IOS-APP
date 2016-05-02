//
//  FlyingUserRightData.h
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shareDefine.h"

@interface FlyingUserRightData : NSObject<NSCoding>

@property(nonatomic, strong) NSString   *domainID;
@property(nonatomic, strong) NSString   *domainType;
@property(nonatomic, strong) NSString   *memberState;
@property(nonatomic, strong) NSDate     *startDate;
@property(nonatomic, strong) NSDate     *endDate;

-(void) encodeWithCoder:(NSCoder *)encoder;
-(id)     initWithCoder:(NSCoder *)decoder;

-(BOOL) checkRightPresent;

-(BOOL) periodOK;
-(NSInteger) daysLeft;
-(NSString*) getMemberStateInfo;

-(NSString*) getChatTutorForMemberstate;
-(UIColor*) getMemberTutorColor;


@end
