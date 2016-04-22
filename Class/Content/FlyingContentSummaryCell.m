//
//  FlyingContentSummaryCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/20/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingContentSummaryCell.h"
#import "shareDefine.h"

@implementation FlyingContentSummaryCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.contentSummaryLabel.font= [UIFont systemFontOfSize:KNormalFontSize];
    
    self.contentSummaryLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentSummaryLabel.textAlignment = NSTextAlignmentLeft;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

+ (FlyingContentSummaryCell*) contentSummaryCell
{
    FlyingContentSummaryCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingContentSummaryCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void) setSummaryText:(NSString*) text
{
    if (text.length==0) {
        
        self.contentSummaryLabel.textAlignment = NSTextAlignmentCenter;
        text=@"没有简介哦，提醒作者补充吧：）";
    }
    
    self.contentSummaryLabel.text=text;
}

-(void) setTextAlignment:(NSTextAlignment) textAlignment
{
    self.contentSummaryLabel.textAlignment = textAlignment;
}


@end
