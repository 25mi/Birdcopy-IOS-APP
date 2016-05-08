//
//  FlyingAppData.h
//  FlyingEnglish
//
//  Created by vincent sung on 8/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingAppData : NSObject<NSCoding>

@property(nonatomic, strong) NSString* appID;
@property(nonatomic, strong) NSString* boundleID;
@property(nonatomic, strong) NSString* ownerID;
@property(nonatomic, strong) NSString* appNname;
@property(nonatomic, strong) NSString* logo;
@property(nonatomic, strong) NSString* authors;
@property(nonatomic, strong) NSString* webaddress;

@property(nonatomic, strong) NSString* wexinID;
@property(nonatomic, strong) NSString* rongAppKey;


-(void)encodeWithCoder:(NSCoder *)encoder;
-(id) initWithCoder:(NSCoder *)decoder;


@end
