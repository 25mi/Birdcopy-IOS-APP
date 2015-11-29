//
//  FlyingCommentCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/20/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlyingCommentData.h"

@protocol FlyingCommentCellDelegate <NSObject>

@optional
- (void)profileImageViewPressed:(FlyingCommentData*)commentData;
@end


@interface FlyingCommentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;


@property (strong, nonatomic) FlyingCommentData *commentData;

@property(nonatomic,assign) id<FlyingCommentCellDelegate> delegate;


+ (FlyingCommentCell*) commentCell;

@end
