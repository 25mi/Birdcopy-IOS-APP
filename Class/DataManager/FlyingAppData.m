//
//  FlyingAppData.m
//  FlyingEnglish
//
//  Created by vincent sung on 8/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingAppData.h"
#import "shareDefine.h"

@implementation FlyingAppData

-(void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.appID        forKey:@"appID"];
    [encoder encodeObject:self.boundleID    forKey:@"boundleID"];
    [encoder encodeObject:self.domainID     forKey:@"domainID"];
    [encoder encodeObject:self.domainType   forKey:@"domainType"];
    [encoder encodeObject:self.appNname     forKey:@"appNname"];
    [encoder encodeObject:self.logo         forKey:@"logo"];
    [encoder encodeObject:self.authors      forKey:@"authors"];
    [encoder encodeObject:self.webaddress   forKey:@"webaddress"];
    [encoder encodeObject:self.wexinID      forKey:@"wexinID"];
    [encoder encodeObject:self.rongAppKey   forKey:@"rongAppKey"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [self init]) {
        
        self.appID       = [decoder decodeObjectForKey:@"appID"];
        self.boundleID   = [decoder decodeObjectForKey:@"boundleID"];
        self.domainID    = [decoder decodeObjectForKey:@"domainID"];
        self.domainType  = [decoder decodeObjectForKey:@"domainType"];
        self.appNname    = [decoder decodeObjectForKey:@"appNname"];
        self.logo        = [decoder decodeObjectForKey:@"logo"];
        self.authors     = [decoder decodeObjectForKey:@"authors"];
        self.webaddress  = [decoder decodeObjectForKey:@"webaddress"];
        self.wexinID     = [decoder decodeObjectForKey:@"wexinID"];
        self.rongAppKey  = [decoder decodeObjectForKey:@"rongAppKey"];
    }
    
    return self;
}

- (id)init {
    
    if (self = [super init]) {
        
        self.appID        = @"";
        self.boundleID    = @"";
        self.domainID     = @"";
        self.domainType   = BC_Domain_Business;
        self.appNname     = @"";
        self.logo         = @"";
        self.authors      = @"";
        self.webaddress   = @"";
        self.wexinID      = @"";
        self.rongAppKey   = @"";
    }
    
    return self;
}


@end
