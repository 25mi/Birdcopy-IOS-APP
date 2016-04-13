//
//  FlyingImageTextCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingImageTextCell.h"
#import "shareDefine.h"
#import <UIImageView+AFNetworking.h>

@interface FlyingImageTextCell()
@property (strong, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (strong, nonatomic) IBOutlet UILabel *cellTextlabel;

@end

@implementation FlyingImageTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.imageViewIcon setContentMode:UIViewContentModeScaleAspectFill];
    self.cellTextlabel.font= [UIFont systemFontOfSize:KNormalFontSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingImageTextCell*) imageTextCell
{
    FlyingImageTextCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingImageTextCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setImageIconURL:(NSString*) imageURL
{
    [self.imageViewIcon setImageWithURL:[NSURL URLWithString:imageURL]
                       placeholderImage:[UIImage imageNamed:@"Icon"]];
}

-(void) setImageIcon:(UIImage *)image
{
    [self.imageViewIcon setImage:image];
}

-(void) setCellText:(NSString*) cellText;
{
    self.cellTextlabel.text = cellText;
}


@end
