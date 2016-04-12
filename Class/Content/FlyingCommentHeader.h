//
//  FlyingCommentHeader.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/29/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyingCommentHeader : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *contentTitle;
@property (strong, nonatomic) IBOutlet UILabel *commentCountLabel;

+ (FlyingCommentHeader*) commentHeaderCell;

-(void) setTitle:(NSString*) title;
-(void) setCommentCount:(NSString*) count;


@end
