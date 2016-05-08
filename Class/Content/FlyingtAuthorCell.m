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
    
    self.authorImageView.layer.cornerRadius = self.authorImageView.frame.size.width/2;
    self.authorImageView.clipsToBounds = YES;
    
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


-(void) setHelpText:(NSString*) helpText
{
    [self.chatNow setText:helpText];
}


@end
