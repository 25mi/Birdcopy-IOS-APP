//
//  KMPhotoTimelineMapCellCell.m
//  TheMovieDB
//
//  Created by Kevin Mindeguia on 04/02/2014.
//  Copyright (c) 2014 iKode Ltd. All rights reserved.
//

#import "FlyingEventScheduleCell.h"

@implementation FlyingEventScheduleCell

#pragma mark -
#pragma mark Cell Init Methods

+ (FlyingEventScheduleCell *) eventScheduleCell
{
    FlyingEventScheduleCell  * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingEventScheduleCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -
#pragma mark Cell Methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end