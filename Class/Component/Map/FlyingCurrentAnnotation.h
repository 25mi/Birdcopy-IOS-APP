//
//  FlyingCurrentAnnotation.h
//  FlyingEnglish
//
//  Created by vincent on 1/17/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//
#import <MapKit/MapKit.h>

@interface FlyingCurrentAnnotation : NSObject <MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
