//
//  FlyingProviderMapVC.h
//  FlyingEnglish
//
//  Created by vincent on 1/16/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class INTULocationManager;

typedef void (^ReturnBlock)(BOOL reselect);


@interface FlyingProviderMapVC : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) INTULocationManager   * locationManager;
@property (strong, nonatomic) CLLocation            * myLocation;
@property (strong, nonatomic) NSMutableArray        *currentData;

@property (strong, nonatomic) IBOutlet UIImageView  * backNowIMageView;
@property (strong, nonatomic) IBOutlet UIImageView  * locationNowIMageview;

- (void)returnSelectBlock:(ReturnBlock)block;

@end
