//
//  FlyingItemData.m
//  FlyingEnglish
//
//  Created by BE_Air on 10/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingItemData.h"
#import "FlyingTagTransform.h"

@implementation FlyingItemData

- (id) initWithWord:(NSString *)word
              Index:(int) index
              Entry:(NSString *)entry
                Tag:(NSString *) tag
{
    if(self = [super init]){
        self.BEWORD  = word;
        self.BEINDEX = index;
        self.BEENTRY = entry;
        self.BETAG   = tag;
    }
    
    return self;
}

-(BE_Item_Content_Type) contentType
{
    if (self.BEENTRY) {

        NSRange textRange;
        NSString * substring= @"description";
        textRange =[self.BEENTRY rangeOfString:substring];
        
        if(textRange.location == NSNotFound)
        {
            substring= @"img";
            textRange =[self.BEENTRY rangeOfString:substring];
            if(textRange.location == NSNotFound)
            {
                substring= @"vedio";
                textRange =[self.BEENTRY rangeOfString:substring];
                if(textRange.location == NSNotFound)
                {
                    substring= @"audio";
                    textRange =[self.BEENTRY rangeOfString:substring];
                    if(textRange.location == NSNotFound)
                    {
                        
                        return BEUnknown;
                    }
                    else{
                        
                        return BEAudio;
                    }
                }
                else{
                
                    return BEVedio;
                }
            }
            else{
                
                return BEImage;
            }
        }
        else{
            
            return BEText;
        }
    }
    else{
        
        return  BEUnknown;
    }
}

-(NSString*) descriptionOnly
{
    
    NSRange aRange = [self.BEENTRY rangeOfString:@"<description>"];
    NSRange bRange = [self.BEENTRY rangeOfString:@"</description>"];

    NSRange range;
    
    range.location=aRange.location+aRange.length;
    range.length=bRange.location-aRange.location-aRange.length;
    
    if (range.length!=0) {
        
        return [self.BEENTRY substringWithRange:range];
    }
    else{
        return nil;
    }
}

-(NSString*) sentenceOnly
{
    NSRange aRange = [self.BEENTRY rangeOfString:@"<source>"];
    NSRange bRange = [self.BEENTRY rangeOfString:@"</source>"];
    
    NSRange range;
    
    range.location=aRange.location+aRange.length;
    range.length=bRange.location-aRange.location-aRange.length;
    
    if (range.length!=0) {
        
        return [self.BEENTRY substringWithRange:range];
    }
    else{
        return nil;
    }
}


-(NSString*) textContent;
{

    NSArray * itemTagArray =@[@"description",@"source",@"target",@"usage",@"ref"];
    NSArray * subtitleArray=@[@"[释意]",@"[例句]",@"[中文]",@"[用法]",@"[参见]"];
    
    if (self.BEENTRY) {

        NSMutableString * result = [NSMutableString stringWithString:self.BEENTRY];
        
        [itemTagArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
            
            NSString * aStr=[NSString stringWithFormat:@"<%@>",obj];
            NSString * bStr=[NSString stringWithFormat:@"</%@>",obj];
            
            NSRange rangA={0,result.length};
            [result replaceOccurrencesOfString:aStr withString:subtitleArray[idx] options:NSCaseInsensitiveSearch range:rangA];
            
            NSRange rangB={0,result.length};
            [result replaceOccurrencesOfString:bStr withString:@"\r\n" options:NSCaseInsensitiveSearch range:rangB];
        }];
        
        return  result;
    }
    else{

        return  nil;
    }
}

-(NSString*) imageURLOnly
{
    
    NSRange aRange = [self.BEENTRY rangeOfString:@"<img>"];
    NSRange bRange = [self.BEENTRY rangeOfString:@"</img>"];
    
    NSRange range;
    
    range.location=aRange.location+aRange.length;
    range.length=bRange.location-aRange.location-aRange.length;
    
    if (range.length!=0) {
        
        return [self.BEENTRY substringWithRange:range];
    }
    else{
        return nil;
    }
}

-(NSString*) vedioURLOnly
{
    
    NSRange aRange = [self.BEENTRY rangeOfString:@"<vedio>"];
    NSRange bRange = [self.BEENTRY rangeOfString:@"</vedio>"];
    
    NSRange range;
    
    range.location=aRange.location+aRange.length;
    range.length=bRange.location-aRange.location-aRange.length;
    
    if (range.length!=0) {
        
        return [self.BEENTRY substringWithRange:range];
    }
    else{
        return nil;
    }
}

-(NSString*) audioURLOnly
{
    
    NSRange aRange = [self.BEENTRY rangeOfString:@"<audio>"];
    NSRange bRange = [self.BEENTRY rangeOfString:@"</audio>"];
    
    NSRange range;
    
    range.location=aRange.location+aRange.length;
    range.length=bRange.location-aRange.location-aRange.length;
    
    if (range.length!=0) {
        
        return [self.BEENTRY substringWithRange:range];
    }
    else{
        return nil;
    }
}


-(NSString*) tagContent
{
    
    NSArray * itemTagArray =@[@"hyph",@"phonetic",@"variant",@"usage",@"<style>",@"derivative",@"field",@"gram",@"fre"];
    NSArray * subtitleArray=@[@"[发音]",@"[音标]",@"[变形]",@"[用法]",@"[文体]",@"[衍生]",@"[使用领域]",@"[语法]",@"[词频]"];
    
    if (self.BETAG) {
        
        NSMutableString * tempResult = [NSMutableString stringWithString:self.BETAG];
        
        [itemTagArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
            
            NSString * aStr=[NSString stringWithFormat:@"<%@>",obj];
            NSString * bStr=[NSString stringWithFormat:@"</%@>",obj];
            
            NSRange rangA={0,tempResult.length};
            [tempResult replaceOccurrencesOfString:aStr withString:subtitleArray[idx] options:NSCaseInsensitiveSearch range:rangA];
            
            NSRange rangB={0,tempResult.length};
            [tempResult replaceOccurrencesOfString:bStr withString:@"" options:NSCaseInsensitiveSearch range:rangB];
        }];
        
        
        NSArray * someArr=@[@"[C]",@"[U]",@"[C, 常用单]",@"[C, 常用复]"];
        NSArray * aimArr=@[@"[可数]",@"[不可数]",@"[虽为可数，但常用做单数]",@"[可数名词，但常用做单数]"];
        
        [someArr enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
            
            NSRange rang={0,tempResult.length};
            [tempResult replaceOccurrencesOfString:someArr[idx] withString:aimArr[idx] options:NSCaseInsensitiveSearch range:rang];
        }];
        
        
        return tempResult;
    }
    else{
        
        return  nil;
    }
}


@end
