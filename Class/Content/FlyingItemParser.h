//
//  FlyingItemParser.h
//  FlyingEnglish
//
//  Created by BE_Air on 10/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

typedef void (^ItemParserCompletionBlock)(NSArray *itemList,NSInteger allRecordCount);
typedef void (^ItemParserFailureBlock)(NSError *error);

#import <Foundation/Foundation.h>

@interface FlyingItemParser : NSObject

@property (nonatomic, copy)   ItemParserCompletionBlock  completionBlock;
@property (nonatomic, copy)   ItemParserFailureBlock     failureBlock;

- (id)   initWithData:(NSData *)data;
- (void) SetData:(NSData *)data;
- (void) parse;

@end
