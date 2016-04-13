//
//  FlyingPubLessonData.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/21/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingPubLessonData.h"
#import "FlyingLessonData.h"

@implementation FlyingPubLessonData

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.lessonID         = [decoder decodeObjectForKey:@"lessonID"];
        self.title            = [decoder decodeObjectForKey:@"title"];
        self.desc             = [decoder decodeObjectForKey:@"desc"];
        self.imageURL         = [decoder decodeObjectForKey:@"imageURL"];
        self.contentURL       = [decoder decodeObjectForKey:@"contentURL"];
        self.subtitleURL      = [decoder decodeObjectForKey:@"subtitleURL"];
        self.pronunciationURL = [decoder decodeObjectForKey:@"pronunciationURL"];
        self.level            = [decoder decodeObjectForKey:@"level"];

        self.duration         = [decoder decodeIntegerForKey:@"duration"];
        
        self.contentType      = [decoder decodeObjectForKey:@"contentType"];
        self.downloadType     = [decoder decodeObjectForKey:@"downloadType"];
        self.tag              = [decoder decodeObjectForKey:@"tag"];
        self.weburl           = [decoder decodeObjectForKey:@"weburl"];
        self.coinPrice        = [decoder decodeIntForKey:@"coinPrice"];
        
        self.ISBN             = [decoder decodeObjectForKey:@"ISBN"];
        self.relativeURL      = [decoder decodeObjectForKey:@"relativeURL"];
        
        self.relativeURL      = [decoder decodeObjectForKey:@"relativeURL"];
        
        self.canDownloaded    = [decoder decodeBoolForKey:@"canDownloaded"];
        self.author           = [decoder decodeObjectForKey:@"author"];
        self.timeLamp         = [decoder decodeObjectForKey:@"timeLamp"];
        self.commentCount     = [decoder decodeObjectForKey:@"commentCount"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.lessonID         forKey:@"lessonID"];
    [encoder encodeObject:self.title            forKey:@"title"];
    [encoder encodeObject:self.desc             forKey:@"desc"];
    [encoder encodeObject:self.imageURL         forKey:@"imageURL"];
    [encoder encodeObject:self.contentURL       forKey:@"contentURL"];
    [encoder encodeObject:self.subtitleURL      forKey:@"subtitleURL"];
    [encoder encodeObject:self.pronunciationURL forKey:@"pronunciationURL"];
    [encoder encodeObject:self.level            forKey:@"level"];
    
    [encoder encodeInteger:self.duration        forKey:@"duration"];
    
    [encoder encodeObject:self.contentType      forKey:@"contentType"];
    [encoder encodeObject:self.downloadType     forKey:@"downloadType"];
    [encoder encodeObject:self.tag              forKey:@"tag"];
    [encoder encodeObject:self.weburl           forKey:@"weburl"];
    [encoder encodeInteger:self.coinPrice       forKey:@"coinPrice"];
    
    [encoder encodeObject:self.ISBN             forKey:@"ISBN"];
    [encoder encodeObject:self.relativeURL      forKey:@"relativeURL"];
    
    
    [encoder encodeBool:self.canDownloaded             forKey:@"canDownloaded"];
    [encoder encodeObject:self.author      forKey:@"author"];
    [encoder encodeObject:self.timeLamp             forKey:@"timeLamp"];
    [encoder encodeObject:self.commentCount      forKey:@"commentCount"];
}


- (id)initWithLessonData:(FlyingLessonData*) lessonData
{
    if (self = [super init]) {
        // Custom initialization
        
        [self getValueFromLessonData:lessonData];
    }
    return self;
}


-(void) getValueFromLessonData:(FlyingLessonData*) lessonData;
{
    self.lessonID         = lessonData.BELESSONID;
    self.title            = lessonData.BETITLE;
    self.desc             = lessonData.BEDESC;
    self.imageURL         = lessonData.BEIMAGEURL;
    self.contentURL       = lessonData.BECONTENTURL;
    self.subtitleURL      = lessonData.BESUBURL;
    self.pronunciationURL = lessonData.BEPROURL;
    self.level            = lessonData.BELEVEL;
    
    self.duration         = lessonData.BEDURATION;
    self.contentType      = lessonData.BECONTENTTYPE;
    self.downloadType     = lessonData.BEDOWNLOADTYPE;
    self.tag              = lessonData.BETAG;
    self.weburl           = lessonData.BEWEBURL;
    self.coinPrice        = lessonData.BECoinPrice;
    
    self.ISBN             = lessonData.BEISBN;
    self.relativeURL      = lessonData.BERELATIVEURL;
    
    self.canDownloaded    = YES;
}


- (BOOL) isEqual:(id)object
{
    return [[(FlyingPubLessonData *)object lessonID] isEqualToString:self.lessonID];
}

@end
