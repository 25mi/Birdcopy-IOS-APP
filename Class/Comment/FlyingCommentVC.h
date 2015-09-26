//
//  FlyingCommentVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlyingCommentCell.h"
#import "SLKTextViewController.h"

@class FlyingStreamData;

@interface FlyingCommentVC : SLKTextViewController<FlyingCommentCellDelegate>

@property (strong, nonatomic) NSMutableArray     *currentData;

@end
