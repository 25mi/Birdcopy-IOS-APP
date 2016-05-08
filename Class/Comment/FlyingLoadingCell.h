//
//  FlyingLoadingCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/21/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingLoadingCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

+ (FlyingLoadingCell*) loadingCell;
@property (strong, nonatomic) IBOutlet UILabel *indicatorText;

- (void)startAnimating:(NSString*) text;
- (void)stopAnimating:(NSString*) text;

@end
