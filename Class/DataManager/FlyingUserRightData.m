//
//  FlyingUserRightData.m
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingUserRightData.h"
#import "FlyingDataManager.h"

@implementation FlyingUserRightData


-(void)encodeWithCoder:(NSCoder *)encoder
{
    
    [encoder encodeObject:self.domainID    forKey:@"domainID"];
    [encoder encodeObject:self.domainType  forKey:@"domainType"];
    [encoder encodeObject:self.memberState forKey:@"memberState"];
    [encoder encodeObject:self.startDate   forKey:@"startDate"];
    [encoder encodeObject:self.endDate     forKey:@"endDate"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    
    if (self = [self init]) {
        
        self.domainID       = [decoder decodeObjectForKey:@"domainID"];
        self.domainType     = [decoder decodeObjectForKey:@"domainType"];
        self.memberState    = [decoder decodeObjectForKey:@"memberState"];
        self.startDate      = [decoder decodeObjectForKey:@"startDate"];
        self.endDate        = [decoder decodeObjectForKey:@"endDate"];
    }
    
    return self;
}

- (id)init
{
    
    if (self = [super init]) {
        
        self.domainID = [FlyingDataManager getBusinessID];
        self.domainType = BC_Domain_Business;
        self.memberState = BC_Member_Noexisted;
        self.startDate   = [NSDate date];
        self.endDate = [NSDate date];
    }
    
    return self;
}

-(BOOL) checkRightPresent
{

    if ([self.memberState isEqualToString:BC_Member_Verified]) {
        
        NSDate *nowDate = [NSDate date];
        
        if ([nowDate compare:self.endDate] == NSOrderedAscending ||
            [nowDate compare:self.startDate] == NSOrderedDescending)
        {

            return YES;
        }
    }
    
    return NO;
}


@end
