//
//  FlyingUserData.h
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingUserData : NSObject<NSCoding>

/** 用户ID */
@property(nonatomic, strong) NSString* openUDID;
/** 用户名*/
@property(nonatomic, strong) NSString* name;
/** 头像URL*/
@property(nonatomic, strong) NSString* portraitUri;
/** 名片*/
@property(nonatomic, strong) NSString* digest;
/** email*/
@property(nonatomic, strong) NSString* mobileNumber;

@property(nonatomic, strong) NSString* email;

-(void)encodeWithCoder:(NSCoder *)encoder;
-(id) initWithCoder:(NSCoder *)decoder;

- (BOOL) isEqual:(id)object;


@end
