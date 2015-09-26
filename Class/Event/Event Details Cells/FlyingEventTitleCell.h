//
//  KMPhotoTimelineViewAllCommentsCell.h
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingEventTitleCell : UITableViewCell

+ (FlyingEventTitleCell*) eventTitleCell;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
