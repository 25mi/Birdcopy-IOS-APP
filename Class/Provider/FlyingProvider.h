//
//  FlyingProvider.h
//  FlyingEnglish
//
//  Created by vincent on 11/8/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlyingProvider : NSObject

@property (nonatomic, strong) NSString *providerID;
@property (nonatomic, copy)   NSString *providerName;
@property (nonatomic, copy)   NSString *providerDesc;
@property (nonatomic, copy)   NSString *providerType;
@property (nonatomic, copy)   NSString *providerAddr;
@property (nonatomic, copy)   NSString *latitude;
@property (nonatomic, copy)   NSString *longitude;
@property (nonatomic, copy)   NSString *distance;
@property (nonatomic, copy)   NSString *tagString;
@property (nonatomic, copy)   NSString *logoURL;
@property (nonatomic, copy)   NSString *broadURL;
@property (nonatomic, copy)   NSString *website;

@end
