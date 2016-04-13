//
//  FlyingGroupData.m
//  FlyingEnglish
//
//  Created by vincent on 9/10/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingGroupData.h"

@implementation FlyingGroupData

-(void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.gp_id                forKey:@"gp_id"];
    [encoder encodeObject:self.gp_name              forKey:@"gp_name"];
    [encoder encodeObject:self.gp_owner             forKey:@"gp_owner"];
    [encoder encodeObject:self.gp_author            forKey:@"gp_author"];
    [encoder encodeObject:self.gp_desc              forKey:@"gp_desc"];
    [encoder encodeObject:self.logo                 forKey:@"logo"];
    [encoder encodeObject:self.cover                forKey:@"cover"];
    
    [encoder encodeBool:self.is_audit_join          forKey:@"is_audit_join"];
    [encoder encodeBool:self.is_rc_gp               forKey:@"is_rc_gp"];
    [encoder encodeBool:self.is_audit_rcgp          forKey:@"is_audit_rcgp"];
    [encoder encodeBool:self.owner_recom            forKey:@"owner_recom"];
    [encoder encodeBool:self.sys_recom              forKey:@"sys_recom"];
    [encoder encodeBool:self.is_public_access       forKey:@"is_public_access"];
    
    [encoder encodeObject:self.gp_member_sum        forKey:@"gp_member_sum"];
    [encoder encodeObject:self.gp_ln_sum            forKey:@"gp_ln_sum"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [self init]) {
        
        self.gp_id              = [decoder decodeObjectForKey:@"gp_id"];
        self.gp_name            = [decoder decodeObjectForKey:@"gp_name"];
        self.gp_owner           = [decoder decodeObjectForKey:@"gp_owner"];
        self.gp_author          = [decoder decodeObjectForKey:@"gp_author"];
        self.gp_desc            = [decoder decodeObjectForKey:@"gp_desc"];
        self.logo               = [decoder decodeObjectForKey:@"logo"];
        self.cover              = [decoder decodeObjectForKey:@"cover"];

        self.is_audit_join      = [decoder decodeBoolForKey:@"is_audit_join"];
        self.is_rc_gp           = [decoder decodeBoolForKey:@"is_rc_gp"];
        self.is_audit_rcgp      = [decoder decodeBoolForKey:@"is_audit_rcgp"];
        self.owner_recom        = [decoder decodeBoolForKey:@"owner_recom"];
        self.sys_recom          = [decoder decodeBoolForKey:@"sys_recom"];
        self.is_public_access   = [decoder decodeBoolForKey:@"is_public_access"];

        self.gp_member_sum      = [decoder decodeObjectForKey:@"gp_member_sum"];
        self.gp_ln_sum          = [decoder decodeObjectForKey:@"gp_ln_sum"];
    }
    
    return self;
}

- (BOOL) isEqual:(id)object
{
    return [[(FlyingGroupData*)object gp_id] isEqualToString:self.gp_id];
}

@end
