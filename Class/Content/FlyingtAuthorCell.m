//
//  FlyingtAuthorCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 20/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingtAuthorCell.h"
#import "shareDefine.h"
#import <UIImageView+AFNetworking.h>

@interface FlyingtAuthorCell()

@property (strong, nonatomic) IBOutlet UIImageView *authorImageView;
@property (strong, nonatomic) IBOutlet UILabel  *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *chatNow;

@end

@implementation FlyingtAuthorCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self.authorImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.authorLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    
    self.chatNow.font = [UIFont systemFontOfSize:KLittleFontSize];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.authorImageView.layer setCornerRadius:(self.authorImageView.frame.size.height/2)];
    [self.authorImageView.layer setMasksToBounds:YES];
    [self.authorImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.authorImageView setClipsToBounds:YES];
    self.authorImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.authorImageView.layer.shadowOffset = CGSizeMake(4, 4);
    self.authorImageView.layer.shadowOpacity = 0.5;
    self.authorImageView.layer.shadowRadius = 2.0;
    self.authorImageView.userInteractionEnabled = YES;
    self.authorImageView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (FlyingtAuthorCell*) authorCell
{
    FlyingtAuthorCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingtAuthorCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void) setAuthorText:(NSString*) author
{
    self.authorLabel.text = author;
}

-(void) setAuthorIcon:(UIImage*) icon
{
    [self.authorImageView setImage:icon];
}

-(void) setAuthorIconWithURL:(NSString*) iconURL
{
    [self.authorImageView setImageWithURL:[NSURL URLWithString:iconURL]];
}


@end
