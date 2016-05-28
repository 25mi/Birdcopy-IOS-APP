//
//  FlyingIndexedCollectionView.h
//  FlyingEnglish
//
//  Created by vincent sung on 22/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingIndexedCollectionView : UICollectionView

/**
 *  The `UITableViewCell` indexPath.row in which the collection view is nested in.
 */
@property (nonatomic, assign) BOOL supportTouch;

@end
