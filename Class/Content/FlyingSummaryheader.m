//
//  FlyingSummaryheader.m
//  FlyingEnglish
//
//  Created by vincent sung on 28/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingSummaryheader.h"
#import "shareDefine.h"

@implementation FlyingSummaryheader

- (void)awakeFromNib {
    // Initialization code
    
    self.contentTitle.font = [UIFont boldSystemFontOfSize:KNormalFontSize];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingSummaryheader*) summaryHeaderCell
{
    FlyingSummaryheader * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingSummaryheader" owner:self options:nil] objectAtIndex:0];
    
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

-(void) setTitle:(NSString*) title
{
    self.contentTitle.text=title;
}

@end
