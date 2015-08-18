//
//  FlyingWordLinguisticData.h
//  FlyingEnglish
//
//  Created by vincent sung on 10/28/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlyingWordLinguisticData : NSObject
{
    NSString *trueLemma;
}

@property (assign, nonatomic) NSRange   tokenRange;
@property (assign, nonatomic) NSRange   sentenceRange;
@property (strong, nonatomic) NSString *tag;
@property (strong, nonatomic) NSString *word;

- (id) initWithTag: (NSString *) tag tokenRange:(NSRange) tokenRange sentenceRange:(NSRange) sentenceRange;

- (void) setLemma:(NSString *) lemma;
- (NSString *) getLemma;

- (NSString *) getIDKey;
@end
