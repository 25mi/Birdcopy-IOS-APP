//
//  FlyingMemberIconCellCollectionViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 5/5/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingMemberIconCellCollectionViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "shareDefine.h"

@interface FlyingMemberIconCellCollectionViewCell()

@property (strong, nonatomic) IBOutlet UIImageView *theImageView;


@end


@implementation FlyingMemberIconCellCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.theImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    //self.theImageView.layer.cornerRadius = self.theImageView.frame.size.width/2;
    //self.theImageView.clipsToBounds = YES;
    
    self.theImageView.backgroundColor = [UIColor clearColor];
}

+ (FlyingMemberIconCellCollectionViewCell *) memberIconCell
{
    FlyingMemberIconCellCollectionViewCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingMemberIconCellCollectionViewCell" owner:self options:nil] objectAtIndex:0];
    
    return cell;
}

-(void) setImageIconURL:(NSString*) imageURL
{
    [self.theImageView setImageWithURL:[NSURL URLWithString:imageURL]
                      placeholderImage:[UIImage imageNamed:@"Account"]];
}


-(void) setImageIcon:(UIImage *)image
{
    [self.theImageView setImage:image];
}


@end
