//
//  FlyingM3U8Parser.h
//  FlyingEnglish
//
//  Created by BE_Air on 5/27/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlyingM3U8List;
@class FlyingM3U8Parser;
@protocol M3U8HandlerDelegate <NSObject>
@optional
-(void)praseM3U8Finished:(FlyingM3U8Parser*)handler;
-(void)praseM3U8Failed:(FlyingM3U8Parser*)handler;
@end


@interface FlyingM3U8Parser : NSObject

@property(nonatomic,retain)         id<M3U8HandlerDelegate>      delegate;
@property(nonatomic,retain)         FlyingM3U8List             * playlist;

-(void) praseUrl:(NSString*)urlstr;

@end
