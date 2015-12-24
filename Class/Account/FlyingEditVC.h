//
//  FlyingEditVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingEditVC : UITableViewController

@property (strong, nonatomic) NSString *someText;

@property(assign,readwrite)  BOOL isNickName;

@end
