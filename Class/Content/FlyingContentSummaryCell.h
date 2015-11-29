//
//  FlyingContentSummaryCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/20/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingContentSummaryCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *contentSummaryLabel;

+ (FlyingContentSummaryCell*) contentSummaryCell;

-(void) setSummaryText:(NSString*) text;

-(void) setTextAlignment:(NSTextAlignment) textAlignment;

@end
