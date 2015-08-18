//
//  UIBubbleHeaderTableViewCell.m
//  UIBubbleTableViewExample
//
//  Created by Александр Баринов on 10/7/12.
//  Copyright (c) 2012 Stex Group. All rights reserved.
//

#import "UIBubbleHeaderTableViewCell.h"

@interface UIBubbleHeaderTableViewCell ()
{
    NSDateFormatter *_dateFormat;
}

@property (nonatomic, retain) UILabel *label;



@end

@implementation UIBubbleHeaderTableViewCell

@synthesize label = _label;
@synthesize date = _date;

+ (CGFloat)height
{
    return 28.0;
}

- (void)setDate:(NSDate *)value
{
    if (!_dateFormat) {
        _dateFormat = [[NSDateFormatter alloc] init];
        [_dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormat setTimeStyle:NSDateFormatterShortStyle];
    }
    
    NSString *text = [_dateFormat stringFromDate:value];
#if !__has_feature(objc_arc)
    [dateFormatter release];
#endif
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [UIBubbleHeaderTableViewCell height])];
    self.label.text = text;
    self.label.font = [UIFont systemFontOfSize:12];
    self.label.textAlignment = NSTextAlignmentCenter;
    //self.label.shadowOffset = CGSizeMake(0, 1);
    //self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

@end
