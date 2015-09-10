//
//  FlyingMemberCollectionViewCell.h
//  FlyingEnglish
//
//  Created by vincent on 9/10/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingMemberCollectionViewCell : UICollectionViewCell


+ (FlyingMemberCollectionViewCell*) memberCollectionViewCell;


@property (weak, nonatomic) IBOutlet UIView *cellBackgroundView;

@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;


@end
