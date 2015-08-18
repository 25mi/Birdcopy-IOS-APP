//
//  FlyingCurrentAnnotation.m
//  FlyingEnglish
//
//  Created by vincent on 1/17/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingCurrentAnnotation.h"

@implementation FlyingCurrentAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if(self = [super init])
        self.coordinate = coordinate;
    return self;
}
@end
