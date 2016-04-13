//
//  FlyingImageTextCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingImageTextCell : UITableViewCell

+ (FlyingImageTextCell*) imageTextCell;

-(void) setImageIconURL:(NSString*) imageURL;
-(void) setImageIcon:(UIImage *)image;

-(void) setCellText:(NSString*) cellText;

@end
