//
//  FlyingCoverDataParser.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/7/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

typedef void (^ParserCompletionBlock)(NSArray *tagCoverList,NSInteger allRecordCount);
typedef void (^ParserFailureBlock)(NSError *error);

#import <Foundation/Foundation.h>

@interface FlyingCoverDataParser : NSObject

@property (nonatomic, copy) ParserCompletionBlock completionBlock;
@property (nonatomic, copy) ParserFailureBlock failureBlock;

- (id)   initWithData:(NSData *)data;
- (void) SetData:(NSData *)data;
- (void) parse;

@end
