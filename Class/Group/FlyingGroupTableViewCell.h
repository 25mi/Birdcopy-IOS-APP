//
//  FlyingGroupTableViewCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 2/25/16.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingIndexedCollectionView.h"

@class FlyingGroupUpdateData;

@interface FlyingGroupTableViewCell : UITableViewCell<UICollectionViewDataSource,
                                                      UICollectionViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView   * groupIconImageView;
@property (nonatomic, strong) IBOutlet UILabel       * nameLabel;

@property (nonatomic, strong) IBOutlet UILabel       * memberCountLabel;
@property (nonatomic, strong) IBOutlet UILabel       * contentCountLabel;

@property (nonatomic, strong) IBOutlet UILabel       * dateLabel;

@property (nonatomic, strong) IBOutlet UILabel       * descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView   * isPublicIcon;

@property (strong, nonatomic) IBOutlet FlyingIndexedCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;

@property (nonatomic, strong) FlyingGroupUpdateData* groupUpdateData;

+ (FlyingGroupTableViewCell*) groupCell;

-(void)settingWithGroupData:(FlyingGroupUpdateData*) groupUpdateData;

@end
