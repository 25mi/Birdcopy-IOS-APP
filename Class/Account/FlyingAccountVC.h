//
//  FlyingAccountVC.h
//  FlyingEnglish
//
//  Created by vincent on 5/25/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

typedef void (^ChangeNameBlock)();


#import "FlyingViewController.h"

@interface FlyingAccountVC : FlyingViewController

@property (strong, nonatomic)   ChangeNameBlock disclosureBlock;

@end
