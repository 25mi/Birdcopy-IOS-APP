//
//  FlyingWordAbstractVC.h
//  FlyingEnglish
//
//  Created by vincent on 4/3/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FlyingTaskWordData;
@class FlyingItemParser;

@interface FlyingWordAbstractVC : UIViewController

@property (strong, nonatomic) FlyingTaskWordData * taskWord;

@property (strong, nonatomic) FlyingItemParser   *itemParser;
@property (strong, nonatomic) NSMutableArray     *itemList;

- (id)initWithTaskWord:(FlyingTaskWordData*) taskWord;

@end
