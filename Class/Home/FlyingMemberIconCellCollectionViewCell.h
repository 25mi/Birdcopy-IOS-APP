//
//  FlyingMemberIconCellCollectionViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 5/5/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingMemberIconCellCollectionViewCell : UICollectionViewCell

+ (FlyingMemberIconCellCollectionViewCell*) memberIconCell;

-(void) setImageIconURL:(NSString*) imageURL;
-(void) setImageIcon:(UIImage *)image;

@end
