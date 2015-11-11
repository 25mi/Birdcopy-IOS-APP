//
//  FlyingBoardUIView.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/11/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FlyingStreamData.h"

@interface UITouch (TouchCompare)

- (NSComparisonResult)compareTouch:(id)obj;

@end


@interface FlyingBoardUIView : UIView


@property (strong, nonatomic)  UIImageView * magnetImageView;

@property (strong, nonatomic)  NSString        *title;
@property (strong, nonatomic)  NSString        *boardType;
@property (strong, nonatomic)  NSString        *boardContent;

@property (strong, nonatomic)  FlyingStreamData  *streamData; //冗余信息

@property (strong, nonatomic)  NSString        *groupID; //冗余信息


-(void) setBoardData:(FlyingStreamData*)      streamData;

@end
