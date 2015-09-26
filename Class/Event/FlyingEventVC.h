//
//  FlyingEventVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/23/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMNetworkLoadingViewController.h"
#import "FlyingCalendarEvent.h"

@interface FlyingEventVC : UIViewController<UITableViewDataSource,
                                            UITableViewDelegate,
                                            UICollectionViewDataSource,
                                            UICollectionViewDelegate,
                                            KMNetworkLoadingViewDelegate>


@property(strong,nonatomic)  FlyingCalendarEvent * eventData;

@end
