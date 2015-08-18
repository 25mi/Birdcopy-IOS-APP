//
//  SoundPlayer.h
//  TrackerApp
//
//  Created by Kevin Donnelly on 4/11/12.
//  Copyright (c) 2012 -. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECalloutLight @"calloutLight"

@interface SoundPlayer : NSObject

+ (void) soundSentence:(NSString*)sentence;
+ (void) soundEffect:(NSString *)sound;

- (void) speechWord:(NSString *) word LessonID:(NSString *) lessonID;

@end
