//
//  FlyingTextLableCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingTextLableCell : UITableViewCell

+ (FlyingTextLableCell*) textLabelCell;

-(void) setItemText:(NSString*) itemText;
-(void) setCellText:(NSString*) cellText;

@end
