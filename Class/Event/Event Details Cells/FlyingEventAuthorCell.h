//
//  KMPhotoTimelineCommentsCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingEventAuthorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;

+ (FlyingEventAuthorCell*) eventAuthorCell;

@end
