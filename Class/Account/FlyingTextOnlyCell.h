//
//  FlyingTextOnlyCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingTextOnlyCell : UITableViewCell


+ (FlyingTextOnlyCell*) textOnlyCell;

-(void) setItemText:(NSString*) itemText;

@end
