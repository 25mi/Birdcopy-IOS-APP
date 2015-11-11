//
//  FlyingCalendarTableViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCalendarTableViewCell.h"

@implementation FlyingCalendarTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //Moves cell text label over to make space for color square on left
    self.textLabel.frame = CGRectMake(35, 0, 260, 44);
}
@end
