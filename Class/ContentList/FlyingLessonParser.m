//
//  FlyingLessonParser.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/27/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.
//
#import "FlyingLessonParser.h"
#import "FlyingPubLessonData.h"

// string contants found in the RSS feed
static NSString* const kLessonList  = @"lesson_list";
static NSString* const kEntryStr    = @"lesson";
static NSString* const kTitleStr    = @"title";
static NSString* const kDescripStr  = @"description";
static NSString* const kImageURLStr = @"coverImageURL";
static NSString* const kContentURL  = @"contentURL";
static NSString* const kSubURLStr   = @"subtitleURL";
static NSString* const kProURLStr   = @"mindURL";
static NSString* const kLevelStr    = @"diffLevel";
static NSString* const kDurationStr = @"duration";
static NSString* const kStartTimeStr= @"startTime";
static NSString* const kTagStr      = @"ln_tag";
static NSString* const kPriceStr    = @"ln_price";
static NSString* const kWebUrlStr   = @"ln_url";
static NSString* const kISBNStr     = @"ln_isbn";
static NSString* const kRelativeStr= @"ln_relatve";
static NSString* const kDownloadStr= @"res_status";

@interface FlyingLessonParser () <NSXMLParserDelegate>
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) FlyingPubLessonData *workingEntry;
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, strong) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;

@property (nonatomic,assign) NSInteger allRecordCount;

@end

@implementation FlyingLessonParser

- (id)initWithData:(NSData *)data
{
	if ((self = [super init]))
	{
		self.dataToParse = data;
        self.elementsToParse = [NSArray arrayWithObjects:kTitleStr, kDescripStr,kImageURLStr, kContentURL,kSubURLStr, kLevelStr,kProURLStr,kDurationStr,kStartTimeStr,kTagStr,kPriceStr,kWebUrlStr,kISBNStr,kRelativeStr,kDownloadStr,nil];
	}
	return self;
}

- (void) SetData:(NSData *)data
{
    
    self.dataToParse = data;
    self.elementsToParse = [NSArray arrayWithObjects:kTitleStr, kDescripStr,kImageURLStr, kContentURL,kSubURLStr, kLevelStr,kProURLStr,kDurationStr,kStartTimeStr,kTagStr,kPriceStr,kWebUrlStr,kISBNStr,kRelativeStr,kDownloadStr,nil];
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
            self.completionBlock(self.workingArray,self.allRecordCount);
		}
        
		self.workingArray = nil;
		self.workingPropertyString = nil;
		self.dataToParse = nil;
	}
}

#pragma mark - RSS Processing

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
    attributes:(NSDictionary*)attributeDict
{

    if ([elementName isEqualToString:kLessonList])
    {
        self.allRecordCount = [[attributeDict objectForKey:@"allRecordCount"] integerValue];
    }
    
    if ([elementName isEqualToString:kEntryStr])
    {
        self.workingEntry = [[FlyingPubLessonData alloc] init];
        self.workingEntry.lessonID = [attributeDict objectForKey:@"id"];
        
        NSString * tempType=[attributeDict objectForKey:@"res_type"];
        
        if([tempType isEqualToString:@"pdf"])
        {
            self.workingEntry.contentType =@"docu";
        }
        else
        {
            self.workingEntry.contentType =tempType;
        }
        
        [self.workingArray addObject:self.workingEntry];
    }
    
    if ([elementName isEqualToString:kContentURL])
    {
        
        self.workingEntry.downloadType = [attributeDict objectForKey:@"type"];
        
    }
    
	self.storingCharacterData = [self.elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
{
	if (self.workingEntry != nil){
        
		if (self.storingCharacterData){
            
			NSString* trimmedString = [self.workingPropertyString
                                       stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
			[self.workingPropertyString setString:@""];  // clear for next time
            
			if ([elementName isEqualToString:kTitleStr])
				self.workingEntry.title= trimmedString;
            
			else if ([elementName isEqualToString:kDescripStr])
				self.workingEntry.desc = trimmedString;
            
			else if ([elementName isEqualToString:kImageURLStr])
                self.workingEntry.imageURL = trimmedString;
            
			else if ([elementName isEqualToString:kContentURL])
				self.workingEntry.contentURL = trimmedString;
                        
            else if ([elementName isEqualToString:kSubURLStr])
				self.workingEntry.subtitleURL = trimmedString;

            else if ([elementName isEqualToString:kProURLStr])
				self.workingEntry.pronunciationURL = trimmedString;

            else if ([elementName isEqualToString:kLevelStr])
				self.workingEntry.level  = trimmedString;
            
            else if ([elementName isEqualToString:kDurationStr])
				self.workingEntry.duration = [trimmedString doubleValue];

            else if ([elementName isEqualToString:kTagStr])
                self.workingEntry.tag = trimmedString;

            else if ([elementName isEqualToString:kPriceStr])
                self.workingEntry.coinPrice = [trimmedString intValue];
            
            else if ([elementName isEqualToString:kWebUrlStr])
                self.workingEntry.weburl  = trimmedString;

            else if ([elementName isEqualToString:kISBNStr])
                self.workingEntry.ISBN  = trimmedString;
            
            else if ([elementName isEqualToString:kRelativeStr])
                self.workingEntry.relativeURL  = trimmedString;
            
            else if ([elementName isEqualToString:kDownloadStr])
                self.workingEntry.canDownloaded  = [trimmedString boolValue];
		}
	}
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
	if (self.storingCharacterData)
		[self.workingPropertyString appendString:string];
}

@end
