//
//  FlyingAuthorCollectionViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 22/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlyingAuthorCollectionViewCell : UICollectionViewCell

+ (FlyingAuthorCollectionViewCell*) authorCollectionViewCell;

-(void) setItemText:(NSString*) itemText;

-(void) setImageIconURL:(NSString*) imageURL;
-(void) setImageIcon:(UIImage *)image;


@end
