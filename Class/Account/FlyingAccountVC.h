//
//  FlyingAccountVC.h
//  FlyingEnglish
//
//  Created by vincent on 5/25/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

typedef void (^ChangeNameBlock)();


#import <UIKit/UIKit.h>

@interface FlyingAccountVC : UITableViewController

@property(nonatomic, strong) NSString* domainID;
@property(nonatomic, strong) NSString* domainType;

@property (strong, nonatomic)   ChangeNameBlock disclosureBlock;

@end
