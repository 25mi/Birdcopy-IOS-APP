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

@protocol FlyingCommentVCDelegate <NSObject>

@optional
- (void)reloadCommentData;
@end

@interface FlyingCommentVC : SLKTextViewController<FlyingCommentCellDelegate>

@property (strong, nonatomic) NSMutableArray     *currentData;

@property (strong, nonatomic) NSString     *contentID;
@property (strong, nonatomic) NSString     *contentType;
@property (strong, nonatomic) NSString     *commentTitle;

@property (strong, nonatomic)   NSString    *domainID;
@property (strong, nonatomic)   NSString    *domainType;

@property(nonatomic,assign) id<FlyingCommentVCDelegate> reloadDatadelegate;

@end
