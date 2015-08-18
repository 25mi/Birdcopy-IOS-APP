//
//  FlyingSubItemParser.h
//  FlyingEnglish
//
//  Created by vincent on 5/2/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

typedef void (^SubItemParserCompletionBlock)(NSMutableString *result);
typedef void (^SubItemParserFailureBlock)(NSError *error);

#import <Foundation/Foundation.h>

@interface FlyingSubItemParser : NSObject

@property (nonatomic, copy)   SubItemParserCompletionBlock  completionBlock;
@property (nonatomic, copy)   SubItemParserFailureBlock     failureBlock;

- (id)   initWithData:(NSData *)data;
- (void) SetData:(NSData *)data;
- (void) parse;

@end
