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

    if ([self.memberState isEqualToString:BC_Member_Verified] &&
        [self periodOK]) {
        
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL) periodOK
{
    NSDate *nowDate = [NSDate date];
    
    if ( [nowDate compare:self.startDate] == NSOrderedAscending ||
        [nowDate compare:self.endDate] == NSOrderedDescending ){
        
        return NO;
    }
    else{
        
        return YES;
    }
}

-(NSInteger) daysLeft
{
    NSDate *nowDate = [NSDate date];
    
    return [FlyingUserRightData daysBetweenDate:nowDate andDate:self.endDate];
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
