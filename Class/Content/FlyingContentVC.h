//
//  FlyingContentVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "FlyingPubLessonData.h"
#import "FlyingCommentCell.h"
#import "TLTagsControl.h"

#import <QuickLook/QuickLook.h>

#import "FlyingMediaVC.h"
#import "FlyingCommentHeader.h"
#import "FlyingContentTitleAndTypeCell.h"
#import "FlyingCommentVC.h"
#import "FlyingViewController.h"

@interface FlyingContentVC :FlyingViewController<
                                                TLTagsControlDelegate,
                                                UITableViewDataSource,
                                                UITableViewDelegate,
                                                FlyingCommentCellDelegate,
                                                QLPreviewControllerDataSource,
                                                QLPreviewControllerDelegate,
                                                FlyingMediaVCDelegate,
                                                FlyingCommentHeaderDelegate,
                                                FlyingContentTitleAndTypeCellDelegate,
                                                FlyingCommentVCDelegate>

@property (strong, nonatomic) NSMutableArray     *currentData;

@property (strong, nonatomic) FlyingPubLessonData * thePubLesson;

@end
