//
//  FlyingWordLinguisticData.m
//  FlyingEnglish
//
//  Created by vincent sung on 10/28/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//

#import "FlyingWordLinguisticData.h"
#import "NSString+FlyingExtention.h"
#import "FlyingTagTransform.h"

@implementation FlyingWordLinguisticData

- (id) initWithTag: (NSString *) tag tokenRange:(NSRange) tokenRange sentenceRange:(NSRange) sentenceRange
{
    if(self = [super init]){
        self.tag           = tag;
        self.tokenRange    = tokenRange;
        self.sentenceRange = sentenceRange;
    }
    return self;
}

-(void) setLemma:(NSString *) lemma
{    
    trueLemma = [lemma lowercaseString];
}

-(NSString *) getLemma
{
    return [trueLemma lowercaseString];
}

- (NSString *) getIDKey
{
    return [trueLemma stringByAppendingString:self.tag];
}


@end
