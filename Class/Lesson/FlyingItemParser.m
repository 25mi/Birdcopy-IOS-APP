//
//  FlyingXMLParser.m
//  FlyingEnglish
//
//  Created by BE_Air on 10/6/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingItemParser.h"
#import "FlyingItemData.h"
#import "shareDefine.h"

static NSString* const kItemList     = @"word_list";
static NSString* const kBEItem       = @"word";
static NSString* const kBEWord       = @"beword";
static NSString* const kBEIndex      = @"beindex";


@interface FlyingItemParser () <NSXMLParserDelegate>
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) FlyingItemData  *workingEntry;
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, assign) BOOL storingCharacterData;


@property (nonatomic, strong) NSString  *BEWORD;
@property (nonatomic, assign) NSInteger  BEINDEX;

@property (nonatomic, strong) NSArray *baseElements;
@property (nonatomic, strong) NSArray *mainElements;
@property (nonatomic, strong) NSArray *tagEments;

@property (nonatomic, strong) NSDictionary *indexTagDic;

-(int) indexForTag:(NSString *) tag;


@end

@implementation FlyingItemParser

- (id)initWithData:(NSData *)data
{
	if ((self = [super init]))
	{
		self.dataToParse = data;
        
        self.baseElements=@[kBEWord,kBEIndex];
        self.mainElements = @[@"ref",@"description",@"source",@"target",@"img"];
        self.tagEments =@[@"hyph",@"phonetic",@"variant",@"usage",@"<style>",@"field",@"gram"];
        self.indexTagDic=@{@"n":@(0),@"v":@(1),@"vt":@(1),@"vi":@(1),@"aux v":@(1),
                           @"adj":@(2),@"adv":@(3),@"pron":@(4),
                           @"art":@(5), @"num":@(5),@"prep":@(6),@"conj":@(7),@"int":@(8)};
        
	}
	return self;
}

- (void) SetData:(NSData *)data
{
    self.dataToParse = data;
    
    self.baseElements=@[kBEWord,kBEIndex];
    self.mainElements = @[@"ref",@"description",@"source",@"target",@"img"];
    self.tagEments =@[@"hyph",@"phonetic",@"variant",@"usage",@"<style>",@"field",@"gram",@"fre"];
    self.indexTagDic=@{@"n":@(0),@"v":@(1),@"vt":@(1),@"vi":@(1),@"aux v":@(1),
                       @"adj":@(2),@"adv":@(3),@"pron":@(4),
                       @"art":@(5), @"num":@(5),@"prep":@(6),@"conj":@(7),@"int":@(8)};
}

-(int) indexForTag:(NSString *) tag
{
    
    NSNumber * num=[self.indexTagDic objectForKey:tag];
    if (num) {
        
        return num.intValue;
    }
    else{
        
        return  9;
    }
}

- (void)parse
{
	@autoreleasepool
	{
		self.workingArray = [NSMutableArray array];
		self.workingPropertyString = [NSMutableString string];
        
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
        
		[parser setDelegate:self];
		[parser parse];
        
		if (self.completionBlock != nil)
		{
            self.completionBlock(self.workingArray,0);
		}
        
		self.workingArray = nil;
		self.workingPropertyString = nil;
		self.dataToParse = nil;
	}
}

- (void) parser:(NSXMLParser*)parser
didStartElement:(NSString*)elementName
   namespaceURI:(NSString*)namespaceURI
  qualifiedName:(NSString*)qName
     attributes:(NSDictionary*)attributeDict
{
    
    if ([elementName isEqualToString:kBEItem])
    {
        
        self.BEINDEX=KItemDefaultType;
        self.BEWORD=nil;
        
        self.workingEntry = [[FlyingItemData alloc] init];
        [self.workingArray addObject:self.workingEntry];
        
        self.workingEntry.BEWORD=self.BEWORD;
        self.workingEntry.BEINDEX=self.BEINDEX;
        
    }
    
	self.storingCharacterData = ([self.baseElements containsObject:elementName] || [self.mainElements containsObject:elementName] || [self.tagEments containsObject:elementName]);
}

- (void)parser:(NSXMLParser*)parser
 didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
{
    
    if (self.storingCharacterData){
        
        NSString* trimmedString = [self.workingPropertyString
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        [self.workingPropertyString setString:@""];  // clear for next time
        
        
        NSString * aStr=[NSString stringWithFormat:@"<%@>",elementName];
        NSString * bStr=[NSString stringWithFormat:@"</%@>",elementName];
        NSString * tempContent=[NSString stringWithFormat:@"%@%@%@",aStr,trimmedString,bStr];
        
        
        if ([elementName isEqualToString:kBEWord]){
            self.BEWORD=trimmedString;
            self.workingEntry.BEWORD=self.BEWORD;
            
        }
        else if ([elementName isEqualToString:kBEIndex]){
            
            self.BEINDEX=[trimmedString integerValue];
            self.workingEntry.BEINDEX=self.BEINDEX;
        }
        else if ([self.mainElements  containsObject:elementName]) {
            
            if (self.workingEntry.BEENTRY) {
                
                NSMutableString *tempEntry=[NSMutableString stringWithString:self.workingEntry.BEENTRY];
                
                self.workingEntry.BEENTRY=[tempEntry  stringByAppendingString:tempContent];
            }
            else{
                
                self.workingEntry.BEENTRY=[NSMutableString stringWithString:tempContent];
            }
        }
        else if ([self.tagEments  containsObject:elementName]) {
            
            if (self.workingEntry.BETAG) {
                
                NSMutableString * tempTag=[NSMutableString stringWithString:self.workingEntry.BETAG];
                
                self.workingEntry.BETAG=[tempTag  stringByAppendingString:tempContent];
            }
            else{
                
                self.workingEntry.BETAG=[NSMutableString stringWithString:tempContent];
            }
        }
    }
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
	if (self.storingCharacterData)
		[self.workingPropertyString appendString:string];
}

@end