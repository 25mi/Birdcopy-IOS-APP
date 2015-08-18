//
//  FlyingProviderParser.h
//  FlyingEnglish
//
//  Created by vincent on 11/8/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

typedef void (^ProviderParserCompletionBlock)(NSArray *LessonList,NSInteger allRecordCount);
typedef void (^ProviderParserFailureBlock)(NSError *error);

#import <Foundation/Foundation.h>

@interface FlyingProviderParser : NSObject

@property (nonatomic, copy)   ProviderParserCompletionBlock completionBlock;
@property (nonatomic, copy)   ProviderParserFailureBlock failureBlock;

- (id)   initWithData:(NSData *)data;
- (void) SetData:(NSData *)data;
- (void) parse;

@end
