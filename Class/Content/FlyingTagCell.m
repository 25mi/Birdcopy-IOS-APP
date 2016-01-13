//
//  FlyingTagCell.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/20/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingTagCell.h"

@implementation FlyingTagCell

- (void)awakeFromNib {
    // Initialization code
    self.contentTagList.mode = TLTagsControlModeList;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (FlyingTagCell*) tagCell
{
    FlyingTagCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"FlyingTagCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)setTagList:(NSString*)tagList DataSourceDelegate:(id<TLTagsControlDelegate>)dataSourceDelegate
{
    [self.contentTagList setTapDelegate:dataSourceDelegate];
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *trimmedString = [regex stringByReplacingMatchesInString:tagList options:0 range:NSMakeRange(0, [tagList length]) withTemplate:@" "];
    
    NSArray * tagArray =[trimmedString componentsSeparatedByString:@" "];
    
    if (tagArray && tagArray.count>0)
    {
        [self.contentTagList setTags:[NSMutableArray arrayWithArray:tagArray]];
    }
    else
    {
        [self.contentTagList setTags:[NSMutableArray arrayWithObject:@"没有标签"]];
    }
    
    [self.contentTagList reloadTagSubviews];
}



@end
