//
//  FlyingGroupStreamCell.h
//  FlyingEnglish
//
//  Created by vincent on 9/8/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingStreamData.h"

#define GROUPSTREAMCELL_IDENTIFIER @"groiupStreamCell"

typedef NS_ENUM(NSInteger, FlyingGroupStreamCellType) {
    FlyingGroupStreamCellPictureType,
    FlyingGroupStreamCellTextType,
    FlyingGroupStreamCellEventType
};



@protocol FlyingGroupStreamCellDelegate <NSObject>

@optional

- (void)profileImageViewPressed:(FlyingStreamData*)groupData;

- (void)commentCountButtonPressed:(FlyingStreamData*)streamData;
- (void)likeCountButtonPressed:(FlyingStreamData*)streamData;

- (void)coverImageViewPressed:(FlyingStreamData*)groupData;

@end


@interface FlyingGroupStreamCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    ReuseIdentifier:(NSString *)reuseIdentifier
     StreamCellType:(FlyingGroupStreamCellType)cellType;

@property (nonatomic, strong) UIImageView* profileImageView;

@property (nonatomic, strong) UIImageView* coverImageView;

@property (nonatomic, strong) UIView* picImageContainer;

@property (nonatomic, strong) UILabel* nameLabel;

@property (nonatomic, strong) UILabel* descriptionLabel;

@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, strong) UIButton* commentCountButton;

@property (nonatomic, strong) UIButton* likeCountButton;

-(void) loadingStreamCellData:(FlyingStreamData*)streamCellData;

@property (nonatomic,assign) id<FlyingGroupStreamCellDelegate> delegate;


@end
