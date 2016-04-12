//
//  FlyingBuyViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 4/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingBuyViewCell : UITableViewCell

+ (FlyingBuyViewCell*) buyTableCell;

-(void) setPriceInfo:(NSString*) priceInfo;

@end
