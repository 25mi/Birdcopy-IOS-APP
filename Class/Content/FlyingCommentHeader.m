//
//  FlyingCommentHeader.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/29/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCommentHeader.h"

@implementation FlyingCommentHeader

- (void)awakeFromNib {
    // Initialization code
    
    self.contentTitle.font = [UIFont systemFontOfSize:(INTERFACE_IS_PAD ? 26.0f : 13.0f)];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingCommentHeader*) commentHeaderCell
{
    FlyingCommentHeader * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingCommentHeader" owner:self options:nil] objectAtIndex:0];
    
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

- (IBAction)toCommentVC:(id)sender
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentHeaderPressed)])
    {
        [self.delegate commentHeaderPressed];
    }
}

-(void) setTitle:(NSString*) title
{
    self.contentTitle.text=title;
}


@end
