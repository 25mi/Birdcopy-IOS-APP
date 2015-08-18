//
//  FlyingCoverDataParser.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/7/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//
//
#import "FlyingCoverDataParser.h"
#import "FlyingCoverData.h"

// string contants found in the RSS feed
static NSString* const kTagList     = @"tag_list";
static NSString* const kEntryStr    = @"tag";
static NSString* const kTagStr      = @"tagString";
static NSString* const kCount       = @"tagCount";
static NSString* const kDescripStr  = @"tag_desc";
static NSString* const kImageURLStr = @"coverImageURL";
static NSString* const kTagOwnerStr = @"tag_owner";

@interface FlyingCoverDataParser () <NSXMLParserDelegate>
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) FlyingCoverData *workingEntry;
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, strong) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;

@property (nonatomic,assign) NSInteger allRecordCount;

@end

@implementation FlyingCoverDataParser

- (id)initWithData:(NSData *)data
{
	if ((self = [super init]))
	{
        [self SetData:data];
	}
	return self;
}

- (void) SetData:(NSData *)data
{
    //NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    self.dataToParse = data;
    self.elementsToParse = [NSArray arrayWithObjects:kTagStr,kCount,kDescripStr,kImageURLStr,kTagOwnerStr,nil];
}

- (void)parse
{
    self.workingArray = [NSMutableArray array];
    self.workingPropertyString = [[NSMutableString alloc] initWithCapacity:100];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
    
    [parser setDelegate:self];
    [parser parse];
    
    if (self.completionBlock != nil)
    {
        self.completionBlock(self.workingArray,self.allRecordCount);
    }
    
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
}

#pragma mark - RSS Processing

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
    attributes:(NSDictionary*)attributeDict
{
    
    if ([elementName isEqualToString:kTagList])
    {
        self.allRecordCount = [[attributeDict objectForKey:@"allRecordCount"] integerValue];
    }
    
    if ([elementName isEqualToString:kEntryStr])
    {
        self.workingEntry = [[FlyingCoverData alloc] init];
        [self.workingArray addObject:self.workingEntry];
    }
    
    if ([elementName isEqualToString:kTagStr])
    {
        self.workingEntry.tagtype = [attributeDict objectForKey:@"res_type"];
    }
    
	self.storingCharacterData = [self.elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
{
    if (self.storingCharacterData){
        
        NSString* trimmedString = [self.workingPropertyString
                                   stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //[self.workingPropertyString setString:@""];  // clear for next time
        self.workingPropertyString = [NSMutableString string];

        
        if ([elementName isEqualToString:kTagStr])
            self.workingEntry.tagString= trimmedString;
        
        else if ([elementName isEqualToString:kCount])
            self.workingEntry.count= [trimmedString integerValue];
        
        else if ([elementName isEqualToString:kDescripStr])
            self.workingEntry.desc = trimmedString;
        
        else if ([elementName isEqualToString:kImageURLStr]){
            
            self.workingEntry.imageURL = trimmedString;
        }
        else if ([elementName isEqualToString:kTagOwnerStr]){
            
            self.workingEntry.author = trimmedString;
        }

    }
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
	if (self.storingCharacterData)
		[self.workingPropertyString appendString:string];
}

@end
