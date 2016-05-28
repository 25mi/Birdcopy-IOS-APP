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
        
        self.domainID = [FlyingDataManager getAppData].appID;
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
    
    return [FlyingUserRightData daysBetweenDate:nowDate andDate:self.endDate]+1;
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

-(NSString*) getMemberStateInfo
{
    NSString * infoStr= NSLocalizedString(@"Unknow erro!", nil);
    
    if([self.memberState  isEqualToString:BC_Member_Noexisted])
    {
        infoStr = NSLocalizedString(@"You are not a member of the group!", nil);
        
    }
    else if([self.memberState  isEqualToString:BC_Member_Reviewing])
    {
        infoStr = NSLocalizedString(@"Your membership is in review...", nil);
    }
    else if ([self.memberState isEqualToString:BC_Member_Verified])
    {
        //是否合格会员
        if ([self periodOK])
        {
            //离截止日期还有多久
            NSInteger alertDays = [self daysLeft];
            
            if (alertDays<=BC_GroupMember_AlertDays)
            {
                //只剩7天以内有效期就提醒用户
                infoStr =[NSString stringWithFormat: NSLocalizedString(@"%@days remaining!", nil), @(alertDays).stringValue];
            }
            else
            {
                infoStr = NSLocalizedString(@"You are a member of the group!", nil);
            }
        }
        //会员过期
        else
        {
            infoStr =NSLocalizedString(@"Membership has expired!",nil);
        }
    }
    else if ([self.memberState isEqualToString:BC_Member_Refused])
    {
        infoStr = NSLocalizedString(@"You are rejected by the group!", nil);
    }
    
    return infoStr;
}


-(NSString*) getChatTutorForMemberstate
{
    NSString * infoStr= NSLocalizedString(@"Unknow erro!", nil);
    
    if([self.memberState  isEqualToString:BC_Member_Noexisted])
    {
        infoStr = NSLocalizedString(@"Enter Chatroom", nil);
    }
    else if([self.memberState  isEqualToString:BC_Member_Reviewing])
    {
        infoStr = NSLocalizedString(@"Reviewing", nil);
    }
    else if ([self.memberState isEqualToString:BC_Member_Verified])
    {        
        //是否合格会员
        if ([self periodOK])
        {
            //离截止日期还有多久
            NSInteger alertDays = [self daysLeft];
            
            if (alertDays<=BC_GroupMember_AlertDays)
            {
                //只剩7天以内有效期就提醒用户
                infoStr =[NSString stringWithFormat: NSLocalizedString(@"%@days remaining!", nil), @(alertDays).stringValue];
            }
            else
            {
                infoStr = NSLocalizedString(@"Enter Chatroom", nil);
            }
        }
        //会员过期
        else
        {
            infoStr =NSLocalizedString(@"Membership has expired!",nil);
        }
    }
    else if ([self.memberState isEqualToString:BC_Member_Refused])
    {
        
        infoStr = NSLocalizedString(@"You are rejected by the group!", nil);
    }
    
    return infoStr;
}

-(UIColor*) getMemberTutorColor
{
    UIColor * returnColor=nil;
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
    UIColor *logoStyle  = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    if([self.memberState  isEqualToString:BC_Member_Noexisted])
    {
        returnColor = logoStyle;
    }
    else if([self.memberState  isEqualToString:BC_Member_Reviewing])
    {
        returnColor = [UIColor whiteColor];
    }
    else if ([self.memberState isEqualToString:BC_Member_Verified])
    {
        //是否合格会员
        if ([self periodOK])
        {
            //离截止日期还有多久
            NSInteger alertDays = [self daysLeft];
            if (alertDays<=BC_GroupMember_AlertDays)
            {
                returnColor = [UIColor redColor];
            }
            else
            {
                returnColor = logoStyle;
            }
        }
        //会员过期
        else
        {
            returnColor = [UIColor redColor];
        }

    }
    else if ([self.memberState isEqualToString:BC_Member_Refused])
    {
        
        returnColor = [UIColor redColor];
    }
    
    return returnColor;
}


@end
