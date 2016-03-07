//
//  FlyingProviderMapVC.m
//  FlyingEnglish
//
//  Created by vincent on 1/16/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingProviderMapVC.h"
#import "FlyingCurrentAnnotation.h"
#import "SVPulsingAnnotationView.h"
#import "INTULocationManager.h"
#import "JPSThumbnailAnnotation.h"
#include "china_shift.h"
#import "FlyingProvider.h"
#import "FlyingProviderParser.h"
#import "shareDefine.h"
#import <AFNetworking.h>
#import "SIAlertView.h"
#import "JPSThumbnail.h"
#import "NSString+FlyingExtention.h" 
#import "FlyingWebViewController.h"

#import "FlyingProviderListVC.h"
#import "UICKeyChainStore.h"
#import "FlyingHttpTool.h"
#import "UIView+Toast.h"

@interface FlyingProviderMapVC ()
{
    FlyingProviderParser  *_parser;
    
    BOOL   _reselect;
}

@property (nonatomic, copy)   ReturnBlock returnBlock;

@end

@implementation FlyingProviderMapVC

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    //self.mapView.clusterSize = kDEFAULTCLUSTERSIZE;
    
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackNow)];
    singleTapOne.numberOfTouchesRequired = 1;
    singleTapOne.numberOfTapsRequired = 1;
    [self.backNowIMageView addGestureRecognizer:singleTapOne];

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLocationNow)];
    singleTap.numberOfTouchesRequired = 1;
    singleTap.numberOfTapsRequired = 1;
    [self.locationNowIMageview addGestureRecognizer:singleTap];

    
    self.locationManager = [INTULocationManager sharedInstance];
    [self locationNow];
    [self getProviderList];
    
    _reselect=NO;
}

- (void)returnSelectBlock:(ReturnBlock)block
{
    self.returnBlock = block;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    if (self.returnBlock != nil) {
        
        self.returnBlock(_reselect);
    }
}

- (void) handleBackNow
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) handleLocationNow
{
    [self locationNow];
}

- (void) locationNow
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];

    [self.locationManager requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                                     timeout:2.0
                                        delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                                       block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                           
                                                           if (status == INTULocationStatusSuccess ||
                                                               status == INTULocationStatusTimedOut)
                                                           {
                                                               Location gc={currentLocation.coordinate.longitude,currentLocation.coordinate.latitude};
                                                               
                                                               Location normal= transformFromWGSToGCJ(gc);
                                                               
                                                               self.myLocation=[[CLLocation alloc] initWithLatitude:normal.lat longitude:normal.lng];
                                                               
                                                               // 设置地图缩放比例
                                                               MKCoordinateSpan span;
                                                               // 设置纬度方向的缩放比例
                                                               span.latitudeDelta = 0.05;
                                                               // 设置经度方向的缩放比例
                                                               span.longitudeDelta = 0.05;
                                                               
                                                               // 组装地图的视图控制
                                                               MKCoordinateRegion region = {self.myLocation.coordinate, span};
                                                               // 设置地图的视图控制
                                                               [self.mapView setRegion:region];
                                                               
                                                               
                                                               FlyingCurrentAnnotation *annotation = [[FlyingCurrentAnnotation alloc] initWithCoordinate:self.myLocation.coordinate];
                                                               annotation.title = @"当前位置";
                                                               [self.mapView addAnnotation:annotation];
                                                               
                                                               [self getProviderList];
                                                           }
                                                           else
                                                           {
                                                               [self.view makeToast:@"获取地址位置失败"];
                                                           }
                                                       }];
   }


- (void)getProviderList
{
    
    if (!_currentData) {
        _currentData = [NSMutableArray new];
    }
    
    NSNumber *latitude = [NSNumber numberWithDouble:self.myLocation.coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:self.myLocation.coordinate.longitude];
    
    
    [FlyingHttpTool getProviderListForlatitude:[latitude stringValue]
                                     longitude:[longitude stringValue]
                                    PageNumber:1
                                    Completion:^(NSArray *providerList,NSInteger allRecordCount) {
                                        //
                                        [self.currentData addObjectsFromArray:providerList];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self finishLoadingData];
                                        });
                                    }];
}


- (void)finishLoadingData
{
    [self.currentData enumerateObjectsUsingBlock:^(FlyingProvider* providerData, NSUInteger idx, BOOL *stop) {
        
        JPSThumbnail *providerThumnail = [[JPSThumbnail alloc] init];
        providerThumnail.imageURL = providerData.logoURL;
        providerThumnail.title = providerData.providerName;
        providerThumnail.subtitle = providerData.providerDesc;
        providerThumnail.coordinate = CLLocationCoordinate2DMake([providerData.latitude doubleValue], [providerData.longitude doubleValue]);
        providerThumnail.disclosureBlock = ^{
            
            //[UICKeyChainStore keyChainStore][KLessonOwner] = providerData.providerID;
            //[UICKeyChainStore keyChainStore][KLessonOwnerNickname] = providerData.providerName;
            
            _reselect=YES;
            
            [self handleBackNow];
        };
        
        [self.mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:providerThumnail]];
    }];
 }

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)])
    {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)])
    {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)])
    {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    else if([annotation isKindOfClass:[FlyingCurrentAnnotation class]])
    {
        
        static NSString *identifier = @"currentLocation";
        SVPulsingAnnotationView *pulsingView = (SVPulsingAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if(pulsingView == nil) {
            pulsingView = [[SVPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
            pulsingView.canShowCallout = YES;
        }
        
        return pulsingView;
    }
    
    return nil;
}



@end
