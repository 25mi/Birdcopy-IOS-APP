//
//  FlyingPlayerView.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/13/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayerLayer;

@interface FlyingPlayerView : UIView

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

- (void)setVideoFillMode:(NSString *)fillMode;
- (void)setPlayer:(AVPlayer*)player;


@end
