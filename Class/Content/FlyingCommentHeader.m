//
//  FlyingCommentHeader.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/29/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCommentHeader.h"
#import "shareDefine.h"

@implementation FlyingCommentHeader

- (void)awakeFromNib {
    // Initialization code
    
    self.contentTitle.font = [UIFont boldSystemFontOfSize:KNormalFontSize];
    self.commentCountLabel.font = [UIFont systemFontOfSize:KLittleFontSize];
    
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

-(void) setTitle:(NSString*) title
{
    self.contentTitle.text=title;
}

-(void) setCommentCount:(NSString*) count
{
    self.commentCountLabel.text=count;
}


@end
