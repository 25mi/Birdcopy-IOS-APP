//
//  FlyingProviderParser.m
//  FlyingEnglish
//
//  Created by vincent on 11/8/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingProviderParser.h"
#import "FlyingProvider.h"


// string contants found in the RSS feed
static NSString* const kProviderList  = @"puser_list";
static NSString* const kEntryStr      = @"puser";
static NSString* const kProviderID    = @"user_id";
static NSString* const kProviderName  = @"user_title";
static NSString* const kProviderDesc  = @"user_desc";
static NSString* const kProviderType  = @"user_type";
static NSString* const kProviderAddr  = @"contact_addr";
static NSString* const kLatitudeStr   = @"latitude";
static NSString* const kLongitudeStr  = @"longitude";
static NSString* const kDistanceeStr  = @"distance";
static NSString* const KTagStr        = @"user_tag";
static NSString* const kLogoURLStr    = @"logo_file";
static NSString* const kBroadURLURLStr= @"img1_file";
static NSString* const KWebsiteStr    = @"default_mp_dn";


@interface FlyingProviderParser () <NSXMLParserDelegate>
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) FlyingProvider *workingEntry;
@property (nonatomic, strong) NSMutableString *workingPropertyString;
@property (nonatomic, strong) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;

@property (nonatomic,assign) NSInteger allRecordCount;

@end

@implementation FlyingProviderParser

- (id)initWithData:(NSData *)data
{
	if ((self = [super init]))
	{
		self.dataToParse = data;
        self.elementsToParse = [NSArray arrayWithObjects:kProviderID,kProviderName,kProviderDesc,kProviderType,kProviderAddr,kLatitudeStr,kLongitudeStr,kDistanceeStr,KTagStr,kLogoURLStr,kBroadURLURLStr,KWebsiteStr,nil];
	}
	return self;
}

- (void) SetData:(NSData *)data
{
 
    self.dataToParse = data;
    self.elementsToParse = [NSArray arrayWithObjects:kProviderID,kProviderName,kProviderDesc,kProviderType,kProviderAddr,kLatitudeStr,kLongitudeStr,kDistanceeStr,KTagStr,kLogoURLStr,kBroadURLURLStr,KWebsiteStr,nil];
}


- (void)parse
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

#pragma mark - RSS Processing

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
    attributes:(NSDictionary*)attributeDict
{
    
    if ([elementName isEqualToString:kProviderList])
    {
        self.allRecordCount = [[attributeDict objectForKey:@"allRecordCount"] integerValue];
    }
    
    if ([elementName isEqualToString:kEntryStr])
    {
        self.workingEntry = [[FlyingProvider alloc] init];
        [self.workingArray addObject:self.workingEntry];
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
            
			if ([elementName isEqualToString:kProviderID])
				self.workingEntry.providerID= trimmedString;
            
			else if ([elementName isEqualToString:kProviderName])
                self.workingEntry.providerName = trimmedString;

            else if ([elementName isEqualToString:kProviderDesc])
                self.workingEntry.providerDesc = trimmedString;

            else if ([elementName isEqualToString:kProviderType])
                self.workingEntry.providerType = trimmedString;
            
            else if ([elementName isEqualToString:kLatitudeStr])
                self.workingEntry.latitude = trimmedString;
            
            else if ([elementName isEqualToString:kLongitudeStr])
                self.workingEntry.longitude = trimmedString;
            
            else if ([elementName isEqualToString:kDistanceeStr])
                self.workingEntry.distance = trimmedString;
            
            else if ([elementName isEqualToString:KTagStr])
                self.workingEntry.tagString = trimmedString;
            
            else if ([elementName isEqualToString:kLogoURLStr])
                self.workingEntry.logoURL = trimmedString;

            else if ([elementName isEqualToString:kBroadURLURLStr])
                self.workingEntry.broadURL = trimmedString;

            else if ([elementName isEqualToString:KWebsiteStr])
                self.workingEntry.website = trimmedString;
		}
	}
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
	if (self.storingCharacterData)
		[self.workingPropertyString appendString:string];
}

@end
