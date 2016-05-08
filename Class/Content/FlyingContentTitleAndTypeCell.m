//
//  FlyingContentTitleAndTypeCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingContentTitleAndTypeCell.h"
#import "shareDefine.h"

@interface FlyingContentTitleAndTypeCell()

@property (strong, nonatomic) IBOutlet UILabel *contentTitle;
@property (strong, nonatomic) IBOutlet UIImageView *accessImageView;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@property (nonatomic,readwrite) BOOL access;

@end

@implementation FlyingContentTitleAndTypeCell

- (void)awakeFromNib {
    // Initialization code
    
    self.contentTitle.font = [UIFont boldSystemFontOfSize:KNormalFontSize];
    self.priceLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    
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

-(void) setPrice:(NSString*) price
{
    if([@"0" isEqualToString:price])
    {
        self.priceLabel.text = NSLocalizedString(@"share",nil);
    }
    else
    {
        self.priceLabel.text = price;
    }
}

-(void) setAccessRight:(BOOL) accessRight
{
    self.access=accessRight;
    
    if (self.access)
    {
        [self.accessImageView setImage:[UIImage imageNamed:@"share"]];
    }
    else
    {
        [self.accessImageView setImage:[UIImage imageNamed:@"coin"]];
    }
}

@end
