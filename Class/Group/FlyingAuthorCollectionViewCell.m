//
//  FlyingAuthorCollectionViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 22/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingAuthorCollectionViewCell.h"
#import <UIImageView+AFNetworking.h>
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"

@interface FlyingAuthorCollectionViewCell()

@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UIImageView *theImageView;


@end

@implementation FlyingAuthorCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.itemLabel.font= [UIFont systemFontOfSize:KSmallFontSize];
    [self.theImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.theImageView.layer.cornerRadius = self.theImageView.frame.size.width/2;
    self.theImageView.clipsToBounds = YES;
        
    self.theImageView.backgroundColor = [UIColor clearColor];
}

+ (FlyingAuthorCollectionViewCell *) authorCollectionViewCell
{
    FlyingAuthorCollectionViewCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingAuthorCollectionViewCell" owner:self options:nil] objectAtIndex:0];
    
    return cell;
}

-(void) setItemText:(NSString*) itemText;
{
    if ([itemText isBlankString])
    {
        self.itemLabel.text = @"未命名";
    }
    else
    {
        self.itemLabel.text = itemText;
    }
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
