//
//  FlyingWordCollectVC.h
//  FlyingEnglish
//
//  Created by vincent on 4/4/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlyingItemParser;

@interface FlyingWordCollectVC : UIViewController


@property (strong, nonatomic)      NSMutableArray     *itemList;
@property (strong, nonatomic)      FlyingItemParser   *itemParser;

@property (strong, nonatomic)      NSString   *theWord;


@end
