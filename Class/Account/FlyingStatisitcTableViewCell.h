//
//  FlyingStatisitcTableViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 4/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingStatisitcTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *currentCount;
@property (strong, nonatomic) IBOutlet UILabel *buyCount;
@property (strong, nonatomic) IBOutlet UILabel *awardCount;
@property (strong, nonatomic) IBOutlet UILabel *consumeCount;
@property (strong, nonatomic) IBOutlet UILabel *currentLabel;
@property (strong, nonatomic) IBOutlet UILabel *buyLabel;
@property (strong, nonatomic) IBOutlet UILabel *awardLabel;
@property (strong, nonatomic) IBOutlet UILabel *consumeLabel;

+ (FlyingStatisitcTableViewCell*) statisticTableCell;

-(void) setCurrent:(NSString*) current;
-(void) setBuy:(NSString*)buy;
-(void) setAward:(NSString*) award;
-(void) setConsume:(NSString*) consume;


@end
