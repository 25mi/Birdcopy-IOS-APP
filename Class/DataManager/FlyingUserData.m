//
//  FlyingUserData.m
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingUserData.h"

@implementation FlyingUserData

-(void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.openUDID     forKey:@"openUDID"];
    
    [encoder encodeObject:self.name         forKey:@"name"];
    [encoder encodeObject:self.portraitUri  forKey:@"portraitUri"];
    [encoder encodeObject:self.digest       forKey:@"digest"];
    [encoder encodeObject:self.mobileNumber forKey:@"mobileNumber"];
    [encoder encodeObject:self.email        forKey:@"email"];

}

-(id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [self init]) {
        
        self.openUDID       = [decoder decodeObjectForKey:@"openUDID"];
        self.name           = [decoder decodeObjectForKey:@"name"];
        self.portraitUri    = [decoder decodeObjectForKey:@"portraitUri"];
        self.digest         = [decoder decodeObjectForKey:@"digest"];
        self.mobileNumber   = [decoder decodeObjectForKey:@"mobileNumber"];
        self.email          = [decoder decodeObjectForKey:@"email"];
    }

    return self;
}

- (id)init {
    
    if (self = [super init]) {
        
        self.openUDID       = @"";
        self.name           = @"";
        self.portraitUri    = @"";
        self.digest         = @"";
        self.mobileNumber   = @"";
        self.email          = @"";
    }
    
    return self;
}


- (BOOL) isEqual:(id)object
{
    return [[(FlyingUserData *)object openUDID] isEqualToString:self.openUDID];
}

@end
