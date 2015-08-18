//
//  FlyingMyLessonsViewController.h
//  FlyingEnglish
//
//  Created by vincent sung on 11/19/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "shareDefine.h"
#import "PSCollectionView.h"

@class FlyingFakeHUD;
@class FlyingHelpLabel;

@interface FlyingMyLessonsViewController : UIViewController<PSCollectionViewDataSource,
                                                            PSCollectionViewDelegate,
                                                            UIScrollViewDelegate>

@property (strong, nonatomic)          PSCollectionView      *lessonsCollectView;
@property (nonatomic, assign)          NSInteger              lastUpDownOffset;
@property (strong, nonatomic)          NSMutableArray        *currentData;

- (void) loadDataSource;
+ (void) updataDBForLocal;

+ (void) getSrtForLessonID: (NSString *) lessonID
                     Title:(NSString *) title;

+ (void) getDicForLessonID: (NSString *) lessonID
                     Title:(NSString *) title;
+ (void) getDicWithURL: (NSString *) baseURLStr
              LessonID: (NSString *) lessonID;

+ (void) getRelativeWithURL: (NSString *) relativeURLStr
                   LessonID: (NSString *) lessonID;

+ (UIImage*) thumbnailImageForVideo:(NSURL *)url
                             atTime:(NSTimeInterval)time;
+ (void)expandNormalZipFile:(NSString *) zipFile
                  OutputDir:(NSString *) outputDir;

+ (UIImage*) thumbnailImageForPDF:(NSURL *)pdfURL
                         passWord:(NSString*) password;

@end
