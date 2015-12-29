//
//  FlyingItemData.h
//  FlyingEnglish
//
//  Created by BE_Air on 10/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shareDefine.h"

@interface FlyingItemData : NSObject

@property   (nonatomic, strong)  NSString *BEWORD;        //词条名称
@property   (nonatomic, assign)  NSInteger  BEINDEX;       //词性索引
@property   (nonatomic, strong)  NSString *BEENTRY;       //词条释意
@property   (nonatomic, strong)  NSString *BETAG;         //词条属性列表


- (id) initWithWord:(NSString *)word
              Index:(int) index
              Entry:(NSString *)entry
                Tag:(NSString *) tag;

-(BE_Item_Content_Type) contentType;

-(NSString*) descriptionOnly;
-(NSString*) sentenceOnly;

-(NSString*) textContent;
-(NSString*) imageURLOnly;
-(NSString*) vedioURLOnly;
-(NSString*) audioURLOnly;

-(NSString*) tagContent;

@end
