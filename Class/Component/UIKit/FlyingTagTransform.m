//
//  FlyingTagTransform.m
//  FlyingEnglish
//
//  Created by vincent sung on 1/23/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingTagTransform.h"
#import "shareDefine.h"
#import "UIImage+localFile.h"

@implementation FlyingTagTransform
{
    NSDictionary * _colorForTagDic;
    NSDictionary * _colorImageForTagDic;
    NSDictionary * _wordForTagDic;
    NSDictionary * _indexForTagDic;
    NSDictionary * _tagForIndexDic;
}

- (id) init
{
    self = [super init];
    if (self) {
        
        
        NSArray * TagArray = [NSArray arrayWithObjects:
                              NSLinguisticTagNoun,
                              NSLinguisticTagVerb,
                              NSLinguisticTagAdjective,
                              NSLinguisticTagAdverb,
                              NSLinguisticTagPronoun,
                              NSLinguisticTagDeterminer,
                              NSLinguisticTagPreposition,
                              NSLinguisticTagConjunction,
                              NSLinguisticTagInterjection,
                              
                              NSLinguisticTagPersonalName,
                              NSLinguisticTagPlaceName,
                              NSLinguisticTagOrganizationName,
                              
                              
                              NSLinguisticTagParticle,
                              NSLinguisticTagNumber,
                              NSLinguisticTagIdiom,
                              NSLinguisticTagOtherWord,
                              NSLinguisticTagClassifier,
                              
                              nil];
        
        NSArray * colorArray = [NSArray arrayWithObjects:
                                [UIColor redColor],
                                [UIColor orangeColor],
                                [UIColor yellowColor],
                                [UIColor greenColor],
                                [UIColor cyanColor],
                                [UIColor blueColor],
                                [UIColor purpleColor],
                                [UIColor magentaColor],
                                [UIColor brownColor],
                                
                                [UIColor redColor],
                                [UIColor redColor],
                                [UIColor redColor],


                                [UIColor lightGrayColor],
                                [UIColor blueColor],
                                [UIColor lightGrayColor],
                                [UIColor lightGrayColor],
                                [UIColor lightGrayColor],
                                
                                nil];
        
        NSArray * colorImagesArray = [NSArray arrayWithObjects:
                                      @"Red",
                                      @"Orange",
                                      @"Yellow",
                                      @"Green",
                                      @"Cyan",
                                      @"Blue",
                                      @"Purple",
                                      @"Magenta",
                                      @"Brown",
                                      
                                      @"Red",
                                      @"Red",
                                      @"Red",
                                      
                                      
                                      @"White",
                                      @"Blue",
                                      @"White",
                                      @"White",
                                      @"White",

                                      nil];
        
        NSArray * wordArray = [NSArray arrayWithObjects:
                               @"名词",
                               @"动词",
                               @"形容词",
                               @"副词",
                               @"代词",
                               @"限定词",
                               @"介词",
                               @"连词",
                               @"叹词",
                               
                               @"人名",
                               @"地名",
                               @"机构",
                               
                               @"小词",
                               @"数词",
                               @"习语",
                               @"未知",
                               @"量词",

                               nil];
        
        
        
        NSArray * indexArray = [NSArray arrayWithObjects:
                                       @(0),
                                       @(1),
                                       @(2),
                                       @(3),
                                       @(4),
                                       @(5),
                                       @(6),
                                       @(7),
                                       @(8),

                                @(0),
                                @(0),
                                @(0),
                                
                                @(9),
                                @(5),
                                @(9),
                                @(9),
                                @(9),
                                       nil];
        

        _colorForTagDic      = [NSDictionary dictionaryWithObjects:colorArray       forKeys:TagArray];
        _colorImageForTagDic = [NSDictionary dictionaryWithObjects:colorImagesArray forKeys:TagArray];
        _wordForTagDic       = [NSDictionary dictionaryWithObjects:wordArray        forKeys:TagArray];
        _indexForTagDic      = [NSDictionary dictionaryWithObjects:indexArray       forKeys:TagArray];
        
        
        NSArray * tagTempArray = [NSArray arrayWithObjects:
                                  NSLinguisticTagNoun,
                                  NSLinguisticTagVerb,
                                  NSLinguisticTagAdjective,
                                  NSLinguisticTagAdverb,
                                  NSLinguisticTagPronoun,
                                  NSLinguisticTagDeterminer,
                                  
                                  NSLinguisticTagPreposition,
                                  NSLinguisticTagConjunction,
                                  
                                  NSLinguisticTagInterjection,
                              nil];
        
        NSArray * indexTempArray = [NSArray arrayWithObjects:
                                @(0),
                                @(1),
                                @(2),
                                @(3),
                                @(4),
                                @(5),
                                @(6),
                                @(7),
                                @(8),

                                nil];

        _tagForIndexDic      = [NSDictionary dictionaryWithObjects:tagTempArray forKeys:indexTempArray];
    }
    
    return self;
    
}

-(NSString *) wordForTag:(NSString *) tag
{
    
    NSString * word = [_wordForTagDic objectForKey:tag];
    
    if(word){
        return word;
    }
    else
    {
        return @"释意";
    }
}

-(NSString *) wordForIndex:(NSInteger) index
{
    NSString * tag = [_tagForIndexDic objectForKey:@(index)];
    
    return [self wordForTag:tag];
}


- (UIImage *) corlorMagnetForTag:(NSString *) tag
{
    
    
    UIImage * result=  [UIImage imageNamed:[NSString stringWithFormat:@"Magnet%@",[_colorImageForTagDic objectForKey:tag]]];

    if (tag==nil || !result) {
        result= [UIImage imageNamed:[NSString stringWithFormat:@"Magnet%@",@"Brown"]];
    }
    
    return result;
}

- (UIImage *)  corlorMagnetForIndex:(NSInteger) index
{
    NSString * tag = [_tagForIndexDic objectForKey:@(index)];

    return [self corlorMagnetForTag:tag];
}

//建立BEtag和字典的映射
- (NSInteger) indexforTag: (NSString *) tag
{
        
    NSNumber * index = [_indexForTagDic objectForKey:tag];
    
    if(index){
        return index.intValue;
    }
    else
    {
        return KItemDefaultType;
        
    }
}

- (UIColor *) corlorForTag:(NSString *) tag
{
        
    UIColor * result = [_colorForTagDic objectForKey:tag];
    
    if (result) {
        return  result;
    }
    else{
        return  [UIColor grayColor];
    }
}

@end


