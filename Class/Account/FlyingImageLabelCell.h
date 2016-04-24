//
//  FlyingImageLabelCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingImageLabelCell : UITableViewCell


+ (FlyingImageLabelCell*) imageLabelCell;


-(void) setItemText:(NSString*) itemText;

-(void) setImageIconURL:(NSString*) imageURL;
-(void) setImageIcon:(UIImage *)image;

@end
