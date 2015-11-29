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

@implementation NSString (FlyingExtention)


+ (NSString*) getServerAddress
{
    NSString *serverNetAddress =@"www.birdcopy.com";
    
#ifdef __CLIENT__IS__ENGLISH__
    serverNetAddress=KEnglishServerAddress;
#endif
    
#ifdef __CLIENT__IS__DOCTOR__
    serverNetAddress=KDoctorServerAddress;
#endif
    
#ifdef __CLIENT__IS__IT__
    serverNetAddress=KITServerAddress;
#endif
    
#ifdef __CLIENT__IS__FD__
    serverNetAddress=KFDServerAddress;
#endif

    return serverNetAddress;
}

+ (NSString*) getWeixinID
{
    NSString* weixinAPPID=KBEWeixinAPPID;
    
#ifdef __CLIENT__IS__ENGLISH__
    
    weixinAPPID=KBEWeixinAPPID;
#endif
    
#ifdef __CLIENT__IS__IT__
    weixinAPPID =KINETWeixinAPPID;
#endif
    
#ifdef __CLIENT__IS__DOCTOR__
    weixinAPPID =KBDWeixinAPPID;
#endif
    
#ifdef __CLIENT__IS__FD__
    weixinAPPID =KFDWeixinAPPID;
#endif

    return weixinAPPID;
}


+ (NSString*) getRongAppKey
{
    NSString* rongAPPkey=nil;
    
#ifdef __CLIENT__IS__ENGLISH__
    rongAPPkey=RONGCLOUD_IM_ENGLISH_APPKEY;
#endif
    
#ifdef __CLIENT__IS__DOCTOR__
    rongAPPkey=RONGCLOUD_IM_DOCTOR_APPKEY;
#endif
    
#ifdef __CLIENT__IS__IT__
    rongAPPkey=RONGCLOUD_IM_IT_APPKEY;
#endif
    
#ifdef __CLIENT__IS__FD__
    rongAPPkey=RONGCLOUD_IM_FD_APPKEY;
#endif

    return rongAPPkey;
}

+ (NSString*) getOfficalURL
{
    NSString* officalURL=@"http://www.birdcopy.com";
    
#ifdef __CLIENT__IS__ENGLISH__
    officalURL=@"http://e.birdcopy.com";
#endif
    
#ifdef __CLIENT__IS__DOCTOR__
    officalURL=@"http://d.birdcopy.com";
#endif
    
#ifdef __CLIENT__IS__IT__
    officalURL=@"http://it.birdcopy.com";
#endif
    
#ifdef __CLIENT__IS__FD__
    officalURL=@"http://fd.birdcopy.com";
#endif
    
    return officalURL;
}

+ (NSString*) getAppID
{
    NSString* appID=nil;
    
#ifdef __CLIENT__IS__ENGLISH__
    appID=BIRDENGLISH_APPKEY;
#endif
    
#ifdef __CLIENT__IS__DOCTOR__
    appID=DOCTOR_APPKEY;
#endif
    
#ifdef __CLIENT__IS__IT__
    appID=IT_APPKEY;
#endif
    
#ifdef __CLIENT__IS__FD__
    appID=FD_APPKEY;
#endif
    
    return appID;
}

+ (NSString*) getOpenUDID
{
    UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:KKEYCHAINServiceName];
    NSString *openID = keychain[KOPENUDIDKEY];
    
    if(!openID)
    {
        openID=(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:KOPENUDIDKEY];
    }
    
    return openID;
}

+ (NSString*) getNickName
{
    NSString *nickName=[UICKeyChainStore keyChainStore][kUserNickName];
    
    if (nickName.length==0) {
        nickName =[[UIDevice currentDevice] name];
    }

    return nickName;
}

+ (NSURL *) tagListStrForAuthor:(NSString*)author
                            Tag:(NSString *) tag
                      withCount:(NSInteger) pagecount
{
    if (author==nil)
    {
        author=@"";
    }
    
    NSString * urlStr =[NSString stringWithFormat:kTagListStr_URL,[NSString getServerAddress],
                        [@(pagecount) stringValue],
                        [@(1) stringValue],
                        tag,
                        author];
    
    NSString * utf8String = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:utf8String];
}

+ (NSURL *) wordListStrByTag:(NSString *) word
{
    NSString * urlStr =[NSString stringWithFormat:kWordListStr_URL,[NSString getServerAddress],word];
    
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
    NSString *dbDir = [iFlyingAppDelegate  getLessonDir:@"shareLessonPic"];
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

+ (BOOL) checkShowPrice: (NSString *) contentURL;
{
    NSRange textRange;
    textRange =[contentURL rangeOfString:KPriceIDstr];
    
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
    NSString * substring= [NSString getServerAddress];
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
        return [NSString stringWithFormat:@"%ld天前",(long)days];
    }
    else if(hours>0)
    {
        return [NSString stringWithFormat:@"%ld小时前",(long)hours];
    }
    else if(minutes>0)
    {
        return [NSString stringWithFormat:@"%ld分钟前",(long)minutes];
    }
    else
    {
        return [NSString stringWithFormat:@"%ld秒前",(long)seconds];
    }
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

- (NSString *)absolutePathFromBaseDirPath:(NSString *)baseDirPath
{
    if ([self hasPrefix:@"~"]) {
        return [self stringByExpandingTildeInPath];
    }
    
    NSString *theBasePath = [baseDirPath stringByExpandingTildeInPath];
    
    if (![self hasPrefix:@"."]) {
        return [theBasePath stringByAppendingPathComponent:self];
    }
    
    NSMutableArray *pathComponents1 = [NSMutableArray arrayWithArray:[self pathComponents]];
    NSMutableArray *pathComponents2 = [NSMutableArray arrayWithArray:[theBasePath pathComponents]];
    
    while ([pathComponents1 count] > 0) {
        NSString *topComponent1 = [pathComponents1 objectAtIndex:0];
        [pathComponents1 removeObjectAtIndex:0];
        
        if ([topComponent1 isEqualToString:@".."]) {
            if ([pathComponents2 count] == 1) {
                // Error
                return nil;
            }
            [pathComponents2 removeLastObject];
        } else if ([topComponent1 isEqualToString:@"."]) {
            // Do nothing
        } else {
            [pathComponents2 addObject:topComponent1];
        }
    }
    
    return [NSString pathWithComponents:pathComponents2];
}

- (NSString *)relativePathFromBaseDirPath:(NSString *)baseDirPath
{
    NSString *thePath = [self stringByExpandingTildeInPath];
    NSString *theBasePath = [baseDirPath stringByExpandingTildeInPath];
    
    NSMutableArray *pathComponents1 = [NSMutableArray arrayWithArray:[thePath pathComponents]];
    NSMutableArray *pathComponents2 = [NSMutableArray arrayWithArray:[theBasePath pathComponents]];
    
    // Remove same path components
    while ([pathComponents1 count] > 0 && [pathComponents2 count] > 0) {
        NSString *topComponent1 = [pathComponents1 objectAtIndex:0];
        NSString *topComponent2 = [pathComponents2 objectAtIndex:0];
        if (![topComponent1 isEqualToString:topComponent2]) {
            break;
        }
        [pathComponents1 removeObjectAtIndex:0];
        [pathComponents2 removeObjectAtIndex:0];
    }
    
    // Create result path
    for (int i = 0; i < [pathComponents2 count]; i++) {
        [pathComponents1 insertObject:@".." atIndex:0];
    }
    if ([pathComponents1 count] == 0) {
        return @".";
    }
    return [NSString pathWithComponents:pathComponents1];
}

- (NSString *)relativePathFromDocumentDirectory:(NSString *) lessonID
{
    return [self relativePathFromBaseDirPath:[iFlyingAppDelegate getLessonDir:lessonID]];
}

- (NSString *)absolutePathFromDocumentDirectory:(NSString *) lessonID
{
    return [self absolutePathFromBaseDirPath:[iFlyingAppDelegate getLessonDir:lessonID]];
}


static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
    unsigned long ixtext, lentext;
    long ctremaining;
    unsigned char input[3], output[4];
    short i, charsonline = 0, ctcopy;
    const unsigned char *raw;
    NSMutableString *result;
    
    lentext = [data length];
    if (lentext < 1)
        return @"";
    result = [NSMutableString stringWithCapacity: lentext];
    raw = [data bytes];
    ixtext = 0;
    
    while (true) {
        ctremaining = lentext - ixtext;
        if (ctremaining <= 0)
            break;
        for (i = 0; i < 3; i++) {
            unsigned long ix = ixtext + i;
            if (ix < lentext)
                input[i] = raw[ix];
            else
                input[i] = 0;
        }
        output[0] = (input[0] & 0xFC) >> 2;
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
        output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
        output[3] = input[2] & 0x3F;
        ctcopy = 4;
        switch (ctremaining) {
            case 1:
                ctcopy = 2;
                break;
            case 2:
                ctcopy = 3;
                break;
        }
        
        for (i = 0; i < ctcopy; i++)
            [result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
        
        for (i = ctcopy; i < 4; i++)
            [result appendString: @"="];
        
        ixtext += 3;
        charsonline += 4;
        
        if ((length > 0) && (charsonline >= length))
            charsonline = 0;
    }
    return result;
}

@end


