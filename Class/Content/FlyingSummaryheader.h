//
//  FlyingSummaryheader.h
//  FlyingEnglish
//
//  Created by vincent sung on 28/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingSummaryheader : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *contentTitle;

+ (FlyingSummaryheader*) summaryHeaderCell;

-(void) setTitle:(NSString*) title;

@end
