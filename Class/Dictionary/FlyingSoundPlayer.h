//
//  FlyingSoundPlayer.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/24/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SECalloutLight @"calloutLight"

@interface FlyingSoundPlayer : NSObject

+ (void) soundSentence:(NSString*)sentence;

+  (void)noticeSound;

- (void) speechWord:(NSString *) word LessonID:(NSString *) lessonID;

@end
