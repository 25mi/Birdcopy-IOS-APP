//
//  FlyingContentTitleAndTypeCell.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FlyingContentTitleAndTypeCellDelegate <NSObject>

@optional
- (void)accessButtonPressed;
@end

@interface FlyingContentTitleAndTypeCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *accessButton;
@property (strong, nonatomic) IBOutlet UILabel *contentTitle;

+ (FlyingContentTitleAndTypeCell*) contentTitleAndTypeCell;

@property(nonatomic,assign) id<FlyingContentTitleAndTypeCellDelegate> delegate;

-(void) setTitle:(NSString*) title;
-(void) setAccessRight:(BOOL) accessRight;

@end
