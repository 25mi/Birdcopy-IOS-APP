//
//  FlyingGroupStreamCell.h
//  FlyingEnglish
//
//  Created by vincent on 9/8/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GROUPSTREAMCELL_IDENTIFIER @"groiupStreamCell"


typedef NS_ENUM(NSInteger, FlyingGroupStreamCellType) {
    FlyingGroupStreamCellPictureType,
    FlyingGroupStreamCellTextType,
    FlyingGroupStreamCellEventType
};

@interface FlyingGroupStreamCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style
    ReuseIdentifier:(NSString *)reuseIdentifier
     StreamCellType:(FlyingGroupStreamCellType)cellType;
@property (nonatomic, strong) UIImageView* profileImageView;

@property (nonatomic, strong) UIImageView* picImageView;

@property (nonatomic, strong) UIView* picImageContainer;

@property (nonatomic, strong) UILabel* nameLabel;

@property (nonatomic, strong) UILabel* updateLabel;

@property (nonatomic, strong) UILabel* dateLabel;

@property (nonatomic, strong) UILabel* commentCountLabel;

@property (nonatomic, strong) UILabel* likeCountLabel;


-(void) setStreamCellData:(id)streamCellData;

@end
