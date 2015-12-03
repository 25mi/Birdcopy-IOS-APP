//
//  FlyingCommentHeader.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/29/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlyingCommentHeaderDelegate <NSObject>

@optional
- (void)commentHeaderPressed;
@end

@interface FlyingCommentHeader : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *accessButton;
@property (strong, nonatomic) IBOutlet UILabel *contentTitle;

@property(nonatomic,assign) id<FlyingCommentHeaderDelegate> delegate;

+ (FlyingCommentHeader*) commentHeaderCell;

-(void) setTitle:(NSString*) title;


@end
