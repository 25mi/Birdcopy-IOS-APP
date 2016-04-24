//
//  FlyingImageLabelCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingImageLabelCell.h"
#import "shareDefine.h"
#import <UIImageView+AFNetworking.h>

@interface FlyingImageLabelCell()

@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UIImageView *theImageView;

@end

@implementation FlyingImageLabelCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.itemLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    [self.theImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingImageLabelCell*) imageLabelCell
{
    FlyingImageLabelCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingImageLabelCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setItemText:(NSString*) itemText;
{
    self.itemLabel.text = itemText;
}

-(void) setImageIconURL:(NSString*) imageURL
{
    [self.theImageView setImageWithURL:[NSURL URLWithString:imageURL]
                       placeholderImage:[UIImage imageNamed:@"Icon"]];
}


-(void) setImageIcon:(UIImage *)image
{
    [self.theImageView setImage:image];
}

@end
