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
#import "DWTagList.h"

#import "KMNetworkLoadingViewController.h"
#import <QuickLook/QuickLook.h>

#import "FlyingMediaVC.h"


@interface FlyingContentVC :  UIViewController<
                                                DWTagListDelegate,
                                                UITableViewDataSource,
                                                UITableViewDelegate,
                                                KMNetworkLoadingViewDelegate,
                                                FlyingCommentCellDelegate,
                                                QLPreviewControllerDataSource,
                                                QLPreviewControllerDelegate,
                                                FlyingMediaVCDelegate>

@property (strong, nonatomic) NSMutableArray     *currentData;

@property (strong, nonatomic) FlyingPubLessonData * theLesson;

+(void) downloadRelated:(FlyingPubLessonData *) theLesson;

+ (void) getSrtForLessonID: (NSString *) lessonID
                     Title:(NSString *) title;

+ (void) getDicWithURL: (NSString *) baseURLStr
              LessonID: (NSString *) lessonID;

+ (void) getRelativeWithURL: (NSString *) relativeURLStr
                   LessonID: (NSString *) lessonID;

+ (void) updateBaseDic:(NSString *) lessonID;

+ (void) getDicForLessonID: (NSString *) lessonID   Title:(NSString *) title;

@end
