//
//  FlyingAILearningViewDelegate.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/16/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FlyingAILearningViewDelegate <NSObject>

- (void) touchOnSubtileBegin: (CGPoint) touchPoint;
- (void) touchOnSubtileMoved: (CGPoint) touchPoint;
- (void) touchOnSubtileEnd:   (CGPoint) touchPoint;
- (void) touchOnSubtileCancelled: (CGPoint) touchPoint;
- (void) pauseAndDoAI;
- (void) playAndDoAI;

@optional
-(void) tapSomeWhere: (CGPoint) touchPoint;
-(BOOL) isPlayingNow;
-(BOOL) hasSubtitleContent;

@end
