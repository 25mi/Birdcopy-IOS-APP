//
//  FlyingLessonParser.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/27/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

typedef void (^LessonParserCompletionBlock)(NSArray *LessonList,NSInteger allRecordCount);
typedef void (^LessonParserFailureBlock)(NSError *error);

#import <Foundation/Foundation.h>

@interface FlyingLessonParser : NSObject

@property (nonatomic, copy)   LessonParserCompletionBlock completionBlock;
@property (nonatomic, copy)   LessonParserFailureBlock failureBlock;

- (id)   initWithData:(NSData *)data;
- (void) SetData:(NSData *)data;
- (void) parse;

@end
