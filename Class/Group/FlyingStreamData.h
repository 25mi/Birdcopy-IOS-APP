//
//  FlyingStreamData.h
//  FlyingEnglish
//
//  Created by vincent sung on 9/11/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StreamFilter) {
    StreamFilterAllType,
    StreamFilterNewsOnly
};

@interface FlyingStreamData : NSObject

@property (nonatomic, strong) NSString* contentType;
@property (nonatomic, strong) NSString* contentID;

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* contentSummary;
@property (nonatomic, strong) NSString* coverURL;

@property (nonatomic, strong) NSString* updateTime;
@property (nonatomic, strong) NSString* commentNumber;
@property (nonatomic, strong) NSString* magicNumber;

@property (nonatomic, strong) NSString* authorName;
@property (nonatomic, strong) NSString* authorImageUrl;
@property (nonatomic, strong) NSString* openID;

@end
