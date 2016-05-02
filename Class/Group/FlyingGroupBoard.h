//
//  FlyingGroupBoard.h
//  FlyingEnglish
//
//  Created by vincent sung on 30/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingPubLessonData.h"
#import "FlyingGroupData.h"


@protocol FlyingGroupBoardDelegate <NSObject>

@optional
- (void) touchBoardNews;
-(void)  touchGroupLogo;

@end


@interface FlyingGroupBoard : UIView

@property (strong, nonatomic) IBOutlet UIImageView  *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView  *logoImageview;

@property (strong, nonatomic) IBOutlet UIView       *boardNewsView;
@property (strong, nonatomic) IBOutlet UIImageView  *boardBackgroundImageview;

@property (strong, nonatomic) IBOutlet UIImageView  *newsImageview;
@property (strong, nonatomic) IBOutlet UILabel      *newsBoardTitleLabel;

@property (strong, nonatomic) IBOutlet UILabel      *newsTitleLabel;

@property(nonatomic,assign) id<FlyingGroupBoardDelegate> delegate;

+ (FlyingGroupBoard*) groupBoard;

-(void)settingWithGroupData:(FlyingGroupData*) groupData;
-(void)settingWithContentData:(FlyingPubLessonData*) contentData;

@end
