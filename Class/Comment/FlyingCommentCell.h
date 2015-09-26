//
//  FlyingCommentCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingCommentData.h"

#define COMMENTCELL_IDENTIFIER @"commentCell"

@protocol FlyingCommentCellDelegate <NSObject>

@optional
- (void)profileImageViewPressed:(FlyingCommentData*)commentData;
@end


@interface FlyingCommentCell : UITableViewCell

@property (nonatomic, strong) UIImageView* profileImageView;

@property (nonatomic, strong) UILabel* nameLabel;

@property (nonatomic, strong) UILabel* descriptionLabel;

@property (nonatomic, strong) UILabel* dateLabel;


@property (nonatomic, strong) FlyingCommentData* commentData;

@property(nonatomic,assign) id<FlyingCommentCellDelegate> delegate;


-(void) loadingCommentData:(FlyingCommentData *)commentData;


@end
