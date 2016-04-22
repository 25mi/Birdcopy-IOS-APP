//
//  NSString+FlyingExtention.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FlyingExtention)

+ (NSURL *) wordListStrByTag:(NSString *) word;

+ (BOOL) checkReadAbilityURL:(NSString *) webpageURL;

+ (BOOL) checkHtmlURL:      (NSString *) contentURL;
+ (BOOL) checkPDFURL:       (NSString *) contentURL;
+ (BOOL) checkDocumentURL:  (NSString *) contentURL;

+ (BOOL) checkOfficialURL:  (NSString *) contentURL;
+ (BOOL) checkYoukuURL:     (NSString *) contentURL;
+ (BOOL) checkM3U8URL:      (NSString *) contentURL;
+ (BOOL) checkMagnetURL:    (NSString *) contentURL;
+ (BOOL) checkMp3URL:       (NSString *) contentURL;
+ (BOOL) checkMp4URL:       (NSString *) contentURL;
+ (BOOL) checkOtherVedioURL:(NSString *) contentURL;
+ (BOOL) checkWeixinSchem:  (NSString *) contentURL;
+ (BOOL) checkLoginToken:   (NSString *) contentURL;
+ (BOOL) checkBoundToken:   (NSString *) contentURL;


+ (BOOL) checkIsURL:        (NSString *) contentURL;

+ (NSString*) StringByAddingPercentEscapes:(NSString *)string;


+ (NSString*) getLessonIDFromOfficalURL: (NSString *) webURL;
+ (NSString*) getLoginIDFromQR: (NSString *) qrStr;
+ (NSString*) getboundCodeFromQR: (NSString *) qrStr;

+ (NSString*) judgeScanType: (NSString *) scanStr;

+ (BOOL) isInMainland;

+(NSString*) picPathForWord:(NSString*) word;

+ (BOOL)     isPureInt:(NSString*)toCheck;


+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;
+ (NSString *)transformToPinyin:(NSString *)hanZi;
+ (BOOL) isBlankString:(NSString *)string;

- (BOOL) isBlankString;

- (NSUInteger) numberOfWordsInString;
- (NSString *) localSrtURL;
- (NSString *) localCoverURL;

- (NSString*) getSentence;
- (NSString*) SentenceID;
- (NSString*) WordIDWithLemma: (NSString*) lemma;

- (NSString*) MD5;

- (NSString*) SHA1;

- (NSString*) SHA256;

@end
