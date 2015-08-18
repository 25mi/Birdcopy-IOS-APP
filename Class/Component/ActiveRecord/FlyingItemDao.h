//
//  FlyingItemDao.h
//  FlyingEnglish
//
//  Created by BE_Air on 10/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingBaseDao.h"


@class FlyingItemData;


@interface FlyingItemDao : FlyingBaseDao


- (id) selectWithWord: (NSString *) word;

- (id) selectWithWord: (NSString *) word
                index: (NSInteger)        index;

- (void) insertWithData: (FlyingItemData *)   itemData;


@end
