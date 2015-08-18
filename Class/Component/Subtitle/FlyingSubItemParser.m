//
//  FlyingSubItemParser.m
//  FlyingEnglish
//
//  Created by vincent on 5/2/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingSubItemParser.h"

// string contants found in the RSS feed
static NSString* const KFontStr        = @"font";

@interface FlyingSubItemParser () <NSXMLParserDelegate>
@property (nonatomic, strong) NSData *dataToParse;
@property (nonatomic, strong) NSMutableString *resultString;
@property (nonatomic, strong) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
@end

@implementation FlyingSubItemParser

- (id)initWithData:(NSData *)data
{
    if ((self = [super init]))
    {
        self.dataToParse = data;
        self.elementsToParse = [NSArray arrayWithObjects:KFontStr,nil];
    }
    return self;
}

- (void) SetData:(NSData *)data
{
    
    self.dataToParse = data;
    self.elementsToParse = [NSArray arrayWithObjects:KFontStr,nil];
}


- (void)parse
{
    @autoreleasepool
    {
        self.resultString = [NSMutableString string];
        
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.dataToParse];
        [parser setDelegate:self];
        [parser parse];
        
        if (self.completionBlock != nil)
        {
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                          {
                              self.completionBlock(self.resultString);
                          });
        }
        
        self.dataToParse = nil;
    }
}

#pragma mark - RSS Processing

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
    attributes:(NSDictionary*)attributeDict
{
    self.storingCharacterData = [self.elementsToParse containsObject:elementName];
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName
  namespaceURI:(NSString*)namespaceURI
 qualifiedName:(NSString*)qName
{
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    if (self.storingCharacterData)
        [self.resultString appendString:string];
}

@end
