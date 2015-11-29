//
//  FlyingContentTitleAndTypeCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingContentTitleAndTypeCell.h"

@implementation FlyingContentTitleAndTypeCell

- (void)awakeFromNib {
    // Initialization code
    
    self.contentTitle.font = [UIFont systemFontOfSize:(INTERFACE_IS_PAD ? 26.0f : 13.0f)];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingContentTitleAndTypeCell*) contentTitleAndTypeCell
{
    FlyingContentTitleAndTypeCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingContentTitleAndTypeCell" owner:self options:nil] objectAtIndex:0];
    
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


-(void) setTitle:(NSString*) title
{
    self.contentTitle.text=title;
}

-(void) setPrice:(NSInteger) price
{
    if (price==0) {
        
        [self.accessButton setBackgroundImage:[UIImage imageNamed:@"People"] forState:UIControlStateNormal];
    }
    else
    {
        [self.accessButton setBackgroundImage:[UIImage imageNamed:@"Price"] forState:UIControlStateNormal];
    }
}


@end
