//
//  FlyingMyGroupCell.h
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GROUPCELL_IDENTIFIER @"groiupCell"

@class FlyingGroupData;

@protocol FlyingMyGroupCellDelegate <NSObject>

@optional
- (void)profileImageViewPressed:(FlyingGroupData*)groupData;

- (void)memberCountButtonPressed:(FlyingGroupData*)groupData;
- (void)lessonCountButtonPressed:(FlyingGroupData*)groupData;
- (void)coverImageViewPressed:(FlyingGroupData*)groupData;

@end

@interface FlyingMyGroupCell : UITableViewCell

@property (nonatomic, strong) UIView* feedContainer;
@property (nonatomic, strong) UIImageView* profileImageView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, strong) UIImageView  * coverImageView;
@property (nonatomic, strong) UILabel      * descriptionLabel;

@property (nonatomic, strong) UIView* socialContainer;

@property (nonatomic, strong) UIButton* memberCountButton;
@property (nonatomic, strong) UIButton* lessonCountButton;

@property (nonatomic, strong) FlyingGroupData* groupData;

@property(nonatomic,assign) id<FlyingMyGroupCellDelegate> delegate;


-(void) loadingGroupData:(FlyingGroupData *)groupData;


@end
