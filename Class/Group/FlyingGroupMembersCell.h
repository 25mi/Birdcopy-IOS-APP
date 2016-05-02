//
//  FlyingGroupMembersCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/5/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingIndexedCollectionView.h"
#import "FlyingGroupData.h"

@interface FlyingGroupMembersCell : UITableViewCell<UICollectionViewDataSource,
                                                    UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet FlyingIndexedCollectionView *collectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;

@property (nonatomic, strong) FlyingGroupData* groupData;

+ (FlyingGroupMembersCell*) groupMembersCell;

-(void)settingWithGroupData:(FlyingGroupData*) groupData;

@end
