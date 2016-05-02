//
//  NSString+FlyingExtention.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/22/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "NSString+FlyingExtention.h"
#import <CommonCrypto/CommonDigest.h>
#import "shareDefine.h"
#import "iFlyingAppDelegate.h"
#import "UICKeyChainStore.h"
#import "FlyingFileManager.h"
#import "FlyingDataManager.h"

@implementation NSString (FlyingExtention)

+ (NSURL *) wordListStrByTag:(NSString *) word
{
    NSString * urlStr =[NSString stringWithFormat:kWordListStr_URL,[FlyingDataManager getServerAddress],word];
    
    NSString * utf8String = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:utf8String];
}

+ (BOOL) checkReadAbilityURL:(NSString *) webpageURL
{
    
    NSRange textRange;
    NSString * substring= @"birdengish";
    textRange =[webpageURL rangeOfString:substring];
    
    if(textRange.location == NSNotFound)
    {
        
        return NO;
    }
    else{
        
        return YES;
    }
}

+(NSString*) picPathForWord:(NSString*) word
{
    NSString *dbDir = [FlyingFileManager  getMyDictionaryDir];
    NSString* coverImageFileName     = [word stringByAppendingPathExtension:KJPGType];
    
    return [dbDir stringByAppendingPathComponent:coverImageFileName];
}

//////////////////////////////////////////////////////////////
#pragma judage content URL
//////////////////////////////////////////////////////////////

+ (BOOL) isInMainland
{
    BOOL result = NO;
    
    if([[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Chongqing"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Harbin"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Macau"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Shanghai"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Taipei"].location == 0)
    {
        result = YES;
    }
    return result;
}

+ (BOOL) checkHtmlURL:(NSString *) contentURL
{
    
    NSRange textRange;
    textRange =[contentURL rangeOfString:@"http"];
    
    if(contentURL==nil)
    {
        return NO;
    }
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }

}

+ (BOOL) checkPDFURL:(NSString *) contentURL
{
    if ([contentURL.pathExtension.lowercaseString isEqualToString:@"pdf"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) checkDocumentURL:(NSString *) contentURL
{
    if ([contentURL.pathExtension.lowercaseString isEqualToString:@"pdf"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"doc"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"docx"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"ppt"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"pptx"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"xls"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"xlsx"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"rtf"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"txt"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"csv"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"pages"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"numbers"]
        ||[contentURL.pathExtension.lowercaseString isEqualToString:@"keys"]
        )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+ (BOOL) checkMp3URL:(NSString *) contentURL
{
    if ([contentURL.pathExtension.lowercaseString isEqualToString:kLessonAudioType]) {
        
        return YES;
    }
    else{
        
        return NO;
    }
}

+ (BOOL) checkMp4URL:(NSString *) contentURL
{
    if ([contentURL.pathExtension.lowercaseString isEqualToString:kLessonVedioType]) {
        
        return YES;
    }
    else{
        
        return NO;
    }
}

+ (BOOL) checkOtherVedioURL:(NSString *) contentURL
{
    NSString * fileExtenion = contentURL.pathExtension.lowercaseString;
    
    if ([fileExtenion isEqualToString:@"avi"] || [fileExtenion isEqualToString:@"mkv"]) {
        return YES;
    }
    else{
        
        return NO;
    }
}

+ (NSString*) getLessonIDFromOfficalURL: (NSString *) webURL;
{
    NSRange range;
    range = [webURL rangeOfString:KBELesssonIDFlag];
    if (range.location != NSNotFound)
    {
        range.location = range.location+range.length;
        range.length=32;
        return [webURL substringWithRange:range];
    }
    else
    {
        range = [webURL rangeOfString:KBELesssonIDFlag1];
        if (range.location != NSNotFound)
        {
            range.location = range.location+range.length;
            range.length=32;
            return [webURL substringWithRange:range];
        }
        else
        {
            range = [webURL rangeOfString:KBELesssonIDFlag2];
            if (range.location != NSNotFound)
            {
                range.location = range.location+range.length;
                range.length=32;
                return [webURL substringWithRange:range];
            }
        }
    }
    
    return nil;
}

+ (NSString*) getLoginIDFromQR: (NSString *) qrStr
{
    NSRange range;
    
    range = [qrStr rangeOfString:KBELoginFlag];
    if (range.location != NSNotFound)
    {
        NSUInteger length = qrStr.length-range.location-range.length;
        
        range.location = range.location+range.length;
        range.length=length;
        return [qrStr substringWithRange:range];
    }
    
    return nil;
}

+ (NSString*) getboundCodeFromQR: (NSString *) qrStr
{
    NSRange range;
    
    range = [qrStr rangeOfString:KBEboundFlag];
    if (range.location != NSNotFound)
    {
        NSUInteger length = qrStr.length-range.location-range.length;
        
        range.location = range.location+range.length;
        range.length=length;
        return [qrStr substringWithRange:range];
    }
    
    return nil;
}

+ (BOOL) checkWeixinSchem:  (NSString *) contentURL
{
    NSRange textRange;
    textRange =[contentURL rangeOfString:KBEWeixinAPPID];
    
    if(contentURL==nil)
    {
        return NO;
    }
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}

+ (NSString*) judgeScanType: (NSString *) scanStr
{
    
    NSString * resultType=nil;
    
    if([NSString checkLoginToken:scanStr]){
        
        resultType = KQRTypeLogin;
    }
    else
    {
        if([NSString checkMagnetURL:scanStr]){
            
            resultType =  KQRTypemagnet;
        }
        else
        {
            if ([NSString checkBoundToken:scanStr])
            {
                
                resultType = KQRTypeBound;
            }
            else
            {
                if([NSString checkIsURL:scanStr]){
                    
                    resultType =  KQRTyepeWebURL;
                }
                else
                {
                    NSString * string = [scanStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSCharacterSet *numberOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                    NSCharacterSet *pureStr = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"];
                    
                    NSString * numOnlyString = [string stringByTrimmingCharactersInSet:[numberOnly invertedSet]];
                    NSString * pureString = [string stringByTrimmingCharactersInSet:[pureStr invertedSet]];
                    
                    if(pureString.length==33 && string.length==33)
                    {
                        
                        return KQRTyepeChargeCard;
                    }
                    else if(numOnlyString.length==string.length){
                        
                        return KQRTyepeCode;
                    }
                }
            }
        }
    }
    
    return resultType;
}

+ (BOOL) checkLoginToken: (NSString *) contentURL
{
    
    NSRange textRange;
    textRange =[contentURL rangeOfString:KBELoginFlag];
    
    if(contentURL==nil)
    {
        return NO;
    }
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}

+ (BOOL) checkBoundToken:   (NSString *) contentURL
{
    
    NSRange textRange;
    textRange =[contentURL rangeOfString:KBEboundFlag];
    
    if(contentURL==nil)
    {
        return NO;
    }
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}

+ (BOOL) checkMagnetURL:(NSString *) contentURL
{
    NSRange textRange;
    NSString * substring= @"magnet:?";
    textRange =[contentURL rangeOfString:substring];
    
    if(contentURL==nil)
    {
        return NO;
    }
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}

+ (BOOL) checkM3U8URL:(NSString *) contentURL
{
    NSRange textRange;
    NSString * substring= @"m3u8";
    textRange =[contentURL rangeOfString:substring];
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}

+ (BOOL) checkYoukuURL:(NSString *) contentURL
{
    NSRange textRange;
    NSString * substring= @"youku";
    textRange =[contentURL rangeOfString:substring];
    
    if(textRange.location == NSNotFound)
    {
        
        return NO;
    }
    else{
        
        return YES;
    }
}

+ (BOOL) checkOfficialURL:(NSString *) contentURL
{
    NSRange textRange;
    NSString * substring= [FlyingDataManager getServerAddress];
    textRange =[contentURL rangeOfString:substring];
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}


+ (BOOL) checkIsURL:(NSString *) contentURL
{
    if ([contentURL hasPrefix :@"http://" ]) {
        return YES ;
    }
    return NO;
}

+(NSString*)StringByAddingPercentEscapes:(NSString *)string
{

    NSString * result =[string stringByReplacingOccurrencesOfString:@"%255B" withString:@"["];
    return [result stringByReplacingOccurrencesOfString:@"%255D" withString:@"]"];
}

+ (BOOL)isPureInt:(NSString*)toCheck
{
    NSScanner* scan = [NSScanner scannerWithString:toCheck];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    NSInteger days = (ti / (3600*24));
    
    if (days>0)
    {
        
        return [NSString stringWithFormat:NSLocalizedString(@"%@ days ago", nil), @(days)];
    }
    else if(hours>0)
    {

        return [NSString stringWithFormat:NSLocalizedString(@"%@ hours ago", nil), @(hours)];
    }
    else if(minutes>0)
    {

        return [NSString stringWithFormat:NSLocalizedString(@"%@ minutes ago", nil), @(minutes)];
    }
    else
    {
        return [NSString stringWithFormat:NSLocalizedString(@"%@ seconds ago", nil), @(seconds)];
    }
}

+ (NSString *)transformToPinyin:(NSString *)hanZi
{
    if (hanZi)
    {
        NSMutableString *mutableString = [NSMutableString stringWithString:hanZi];
        CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
        mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
        return [mutableString stringByReplacingOccurrencesOfString:@"'" withString:@""];
    }
    
    return nil;
}


+ (BOOL) isBlankString:(NSString *)string {
    
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

- (BOOL) isBlankString
{

    if (self == nil || self == NULL) {
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;

}


- (NSUInteger)numberOfWordsInString
{
    NSString * str = [self mutableCopy];
    
    __block NSUInteger count = 0;
    [str enumerateSubstringsInRange:NSMakeRange(0, [str length])
                            options:NSStringEnumerationByWords|NSStringEnumerationSubstringNotRequired
                         usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                             count++;
                         }];
    return count;
}

- (NSString*) getSentence
{
    NSString * sentence = [self mutableCopy];
    
    sentence = [sentence stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    sentence = [sentence stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    return sentence;
}

- (NSString*) SentenceID
{
    NSString * sentence = [self mutableCopy];
    
    sentence = [sentence stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    sentence = [sentence stringByReplacingOccurrencesOfString:@"\r" withString:@""];

    
    return [sentence MD5];
}

- (NSString*) WordIDWithLemma: (NSString*) lemma
{
    
    NSString * temp = [[NSString stringWithFormat:@"%@.",self]  stringByAppendingString:lemma];
    
    return [temp MD5];
}

- (NSString*) MD5 {
	unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
	CC_MD5(self.UTF8String, [self UTF8Length], output);
	return [self toHexString:output length:outputLength];;
}

- (NSString*) SHA1 {
	unsigned int outputLength = CC_SHA1_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
	CC_SHA1(self.UTF8String, [self UTF8Length], output);
	return [self toHexString:output length:outputLength];;
}

- (NSString*) SHA256 {
	unsigned int outputLength = CC_SHA256_DIGEST_LENGTH;
	unsigned char output[outputLength];
	
	CC_SHA256(self.UTF8String, [self UTF8Length], output);
	return [self toHexString:output length:outputLength];;
}

- (unsigned int) UTF8Length {
	return (unsigned int) [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*) toHexString:(unsigned char*) data length: (unsigned int) length {
	NSMutableString* hash = [NSMutableString stringWithCapacity:length * 2];
	for (unsigned int i = 0; i < length; i++) {
		[hash appendFormat:@"%02x", data[i]];
		data[i] = 0;
	}
	return hash;
}

- (NSString *) localSrtURL
{
    NSString* subtitleFileName    = [self stringByAppendingPathExtension:kLessonSubtitleType];
    
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return [documentDirectory stringByAppendingPathComponent:subtitleFileName];
}

- (NSString *) localCoverURL
{
    NSString* tempcover  = [self stringByAppendingPathExtension:kLessonCoverType];
    
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return [documentDirectory stringByAppendingPathComponent:tempcover];
}

@end


