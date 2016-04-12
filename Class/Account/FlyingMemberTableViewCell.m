//
//  FlyingMemberTableViewCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 4/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingMemberTableViewCell.h"
#import "shareDefine.h"
#import <UIImageView+AFNetworking.h>


@interface FlyingMemberTableViewCell()

@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (strong, nonatomic) IBOutlet UILabel *memberLabel;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;

@end


@implementation FlyingMemberTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.memberLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    self.startLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    self.endLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    
    self.memberLabel.text = NSLocalizedString(@"Member User", nil);
    
    [self.portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [_portraitImageView.layer setCornerRadius:(_portraitImageView.frame.size.height/2)];
    [_portraitImageView.layer setMasksToBounds:YES];
    [_portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_portraitImageView setClipsToBounds:YES];
    _portraitImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _portraitImageView.layer.shadowOffset = CGSizeMake(4, 4);
    _portraitImageView.layer.shadowOpacity = 0.5;
    _portraitImageView.layer.shadowRadius = 2.0;
    _portraitImageView.userInteractionEnabled = YES;
    _portraitImageView.backgroundColor = [UIColor clearColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (FlyingMemberTableViewCell*) memberTableCell
{
    FlyingMemberTableViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingMemberTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setPortraitURL:(NSString*) portraitURL
{
    [self.portraitImageView setImageWithURL:[NSURL URLWithString:portraitURL]
                  placeholderImage:[UIImage imageNamed:@"Account"]];
}


-(void) setStart:(NSDate*) start
{
    
    NSString *startStr = @"";

    
    if (start) {

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        startStr  = [formatter stringFromDate:start];
    }

    self.startLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Member Start:%@", nil),startStr];
}

-(void) setEnd:(NSDate*) end
{
    
    NSString *endStr = @"";
    
    if (end) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        endStr = [formatter stringFromDate:end];
    }
    
    self.endLabel.text = [NSString stringWithFormat:NSLocalizedString(@"member end:%@", nil),endStr];
}


@end
