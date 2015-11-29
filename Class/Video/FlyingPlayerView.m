//
//  FlyingPlayerView.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/13/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//
#import "FlyingPlayerView.h"
#import <AVFoundation/AVFoundation.h>


@implementation FlyingPlayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
	return (AVPlayerLayer *)self.layer;
}

- (void)setPlayer:(AVPlayer*)player
{
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode
{
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}

@end
