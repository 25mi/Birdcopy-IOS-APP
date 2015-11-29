//
//  FlyingStytleView.h
//  FlyingEnglish
//
//  Created by BE_Air on 6/17/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "shareDefine.h"

@interface FlyingStytleView : UIView

@property (nonatomic)  BE_AI_SubStytle subStyle;

-(void) changeStytle;

-(void) reDrawStytle;

@end
