//
//  FlyingItemView.m
//  FlyingEnglish
//
//  Created by BE_Air on 10/1/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingItemView.h"
#import "FlyingItemParser.h"

#import "FlyingItemDao.h"
#import "FlyingItemData.h"

#import "FlyingTagTransform.h"
#import "NSString+FlyingExtention.h"
#import "FlyingItemParser.h"
#import "FlyingItemDao.h"
#import "FlyingSoundPlayer.h"
#import <AFNetworking.h>
#import "AFHttpTool.h"
#import "iFlyingAppDelegate.h"
#import "FlyingWordDetailVC.h"
#import "shareDefine.h"

#define TAG_ACTIVITY_INDICATOR 149462


@implementation UITouch (TouchSorting)

- (NSComparisonResult)compareAddress:(id)obj
{
    if ((__bridge void *)self < (__bridge void *)obj)
    {
        return NSOrderedAscending;
    }
    else if ((__bridge void *)self == (__bridge void *)obj)
    {
        return NSOrderedSame;
    }
    else
    {
        return NSOrderedDescending;
    }
}

@end

@interface FlyingItemView (TouchCOntrol)

- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches;
- (void)updateOriginalTransformForTouches:(NSSet *)touches;

- (void)cacheBeginPointForTouches:(NSSet *)touches;
- (void)removeTouchesFromCache:(NSSet *)touches;

@end

@interface FlyingItemView ()<UIGestureRecognizerDelegate>

@property (strong,nonatomic) UIImageView * backgroundNotesImageView;

@property (strong,nonatomic) UILabel     * titleLabel;
@property (strong,nonatomic) UILabel     * abbOfWordLabel;
@property (strong,nonatomic) UIImageView * magnetImageView;

@property NSDictionary * colorImageDictionary;
@property NSDictionary * colorWordDictionary;

@property FlyingTagTransform * tagTrasform;

@property (strong,nonatomic) FlyingItemParser  * parser;

@end

@implementation FlyingItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque=NO;
        self.alpha=0;
        
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.exclusiveTouch = YES;
        self.clipsToBounds=YES;
        
        self.fullScreenModle=NO;
        
        self.tagTrasform= [[FlyingTagTransform alloc] init];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchItem)];
        tapRecognizer.numberOfTapsRequired = 1; // 单击
        [self addGestureRecognizer:tapRecognizer];
        
        originalTransform = CGAffineTransformIdentity;
        touchBeginPoints = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    return self;
}

- (void)  drawWithLemma:(NSString *) lemma AppTag: (NSString*) appTag
{
    self.lemma=lemma;
    self.appTag=appTag;
    
    [self presentBaseContent];

    FlyingItemDao * pubDAO=[[FlyingItemDao  alloc] init];
    
    
    NSArray * itmeDataArry;
    if(appTag==nil)
    {
    
        itmeDataArry = [pubDAO selectWithWord:lemma];
    }
    else{

        itmeDataArry = [pubDAO selectWithWord:lemma index:[self.tagTrasform indexforTag:appTag]];
    }
    
    //词性偏差
    if (itmeDataArry.count==0) {
        
        itmeDataArry = [pubDAO selectWithWord:lemma];
    }
    
    self.desc= [[NSMutableString alloc] init];
    
    if (itmeDataArry.count==1) {
        
        
        NSString * str = [itmeDataArry[0] descriptionOnly];
        if (str) {
            
            [self.desc appendString:str];
        }
    }
    else{
    
        __block int i=1;
        
        [itmeDataArry enumerateObjectsUsingBlock:^(FlyingItemData * obj, NSUInteger idx, BOOL *stop) {
            
            @autoreleasepool {
                
                if (i>3) {
                    
                    [self.desc appendFormat:@"*点击磁贴获取更多*"];
                    *stop=YES;
                }
                else{
                    
                    if (obj.descriptionOnly) {
                        
                        [self.desc appendFormat:@"%d.%@\r\n",i,obj.descriptionOnly];
                        i++;
                    }
                }
            }
        }];
    }
    
    //联网查询
    if (itmeDataArry.count==0) {
        
        if (INTERFACE_IS_PAD) {
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        else{
            
            [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleGray];
        }
        
        [self showWebData];

    }
    else{

        [self presentDesc];
    }
}

- (void) presentBaseContent
{
    CGRect thisframe = self.frame;
    CGSize thisSize =self.frame.size;
    
    //磁贴背景图
    self.backgroundNotesImageView = [[UIImageView alloc] initWithFrame:thisframe];
    self.backgroundNotesImageView.image =  [UIImage imageNamed:@"Board" ];
    
    //磁铁以及文字
    self.magnetImageView                 = [[UIImageView alloc] initWithFrame:CGRectMake(thisSize.width*2/5, 0, thisSize.width/5, thisSize.width/5)];
    self.magnetImageView.image           = [[[FlyingTagTransform alloc] init] corlorMagnetForTag:self.appTag];
    self.magnetImageView.backgroundColor = [UIColor clearColor];
    
    self.abbOfWordLabel                 = [UILabel new];
    self.abbOfWordLabel.textAlignment   =  NSTextAlignmentCenter;
    self.abbOfWordLabel.backgroundColor = [UIColor clearColor];
    self.abbOfWordLabel.text            = [self.tagTrasform wordForTag:self.appTag];
    
    CGFloat fontTagSize = 8;
    
    if (self.fullScreenModle)
    {
        fontTagSize = KNormalFontSize;
    }
    else
    {
        fontTagSize = KLittleFontSize;
    }
    
    self.abbOfWordLabel.font      = [UIFont systemFontOfSize:fontTagSize];
    self.abbOfWordLabel.textColor = [UIColor blackColor];
    self.abbOfWordLabel.frame     =  CGRectMake(0, thisSize.width/20, thisSize.width/5, thisSize.width/10);
    
    //组装磁贴图片和文字为磁贴
    [self.magnetImageView addSubview:self.abbOfWordLabel];
    
    //单词标题
    self.titleLabel               = [UILabel new];
    self.titleLabel.text          = self.word;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    CGFloat fontTitleSize         = 8;
    
    if (self.fullScreenModle)
    {
        fontTitleSize = KLargeFontSize;
    }
    else
    {
        fontTitleSize = KNormalFontSize;
    }

    self.titleLabel.font          = [UIFont boldSystemFontOfSize:fontTitleSize];
    self.titleLabel.textColor     = [UIColor blackColor];
    self.titleLabel.frame         =  CGRectMake(thisSize.width/10, thisSize.width*3/20, thisSize.width/2, thisSize.width/10);
    
    
    //统一组装成个性化单词解释
    [self addSubview:self.backgroundNotesImageView];
    [self addSubview:self.magnetImageView];
    [self addSubview:self.titleLabel];
}


- (void) presentDesc
{
    if (self.desc)
    {
     
        UILabel * descLabel = [UILabel new];
        
        CGSize thisSize =self.frame.size;
        
        //单词本词性中文解释
        descLabel.text       = self.desc;
        descLabel.textAlignment=NSTextAlignmentLeft;
        descLabel.numberOfLines=0;
        descLabel.backgroundColor = [UIColor clearColor];
        
        CGFloat fontSubtitleSize = 8;
        
        if (self.fullScreenModle)
        {
            fontSubtitleSize = KLargeFontSize;
        }
        else
        {
            fontSubtitleSize = KNormalFontSize;
        }
        
        descLabel.font       = [UIFont systemFontOfSize:fontSubtitleSize];
        descLabel.textColor  = [UIColor blackColor];
        
        CGSize constraint = CGSizeMake(160*thisSize.width/200, MAXFLOAT);
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = descLabel.font;
        gettingSizeLabel.text = self.desc;
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
        
        descLabel.frame = CGRectMake(20*thisSize.width/200,
                                     self.titleLabel.frame.size.height+self.titleLabel.frame.origin.y,
                                     constraint.width, expectSize.height);
        
        [self addSubview:descLabel];
    }
}
//////////////////////////////////////////////////////////////
#pragma mark - Download data from Web Dictionary
//////////////////////////////////////////////////////////////
- (void) showWebData
{
    [AFHttpTool dicDataforWord:self.lemma success:^(id response) {
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
            
            if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                
                if (!self.parser) {
                    self.parser = [[FlyingItemParser alloc] init];
                }
                
                [_parser SetData:response];
                
                __weak typeof(self) weakSelf = self;
                FlyingItemDao * dao= [[FlyingItemDao alloc] init];
                
                _parser.completionBlock = ^(NSArray *itemList,NSInteger allRecordCount)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{

                        [weakSelf removeActivityIndicator];
                        
                        if (itemList.count>=1) {
                            
                            [itemList enumerateObjectsUsingBlock:^(FlyingItemData  *item, NSUInteger idx, BOOL *stop) {
                                
                                [dao insertWithData:item];
                            }];
                            
                            NSArray * itmeDataArry;
                            if(weakSelf.appTag==nil)
                            {
                                itmeDataArry = [dao selectWithWord:weakSelf.lemma];
                            }
                            else{
                                
                                itmeDataArry = [dao selectWithWord:weakSelf.lemma index:[weakSelf.tagTrasform indexforTag:weakSelf.appTag]];
                            }
                            
                            weakSelf.desc= [[NSMutableString alloc] init];
                            
                            
                            //词性偏差
                            if (itmeDataArry.count==0) {
                                
                                itmeDataArry = [dao selectWithWord:weakSelf.lemma];
                            }
                            
                            if (itmeDataArry.count==1) {
                                
                                
                                NSString * str = [itmeDataArry[0] descriptionOnly];
                                if (str) {
                                    
                                    [weakSelf.desc appendString:str];
                                }
                            }
                            else{
                                
                                __block int i=1;
                                
                                [itmeDataArry enumerateObjectsUsingBlock:^(FlyingItemData * obj, NSUInteger idx, BOOL *stop) {
                                    
                                    if (i>3) {
                                        
                                        [weakSelf.desc appendFormat:@"*点击磁贴获取更多*"];
                                        *stop=YES;
                                    }
                                    else{
                                        
                                        if (obj.descriptionOnly) {
                                            
                                            [weakSelf.desc appendFormat:@"%d.%@\r\n",i,obj.descriptionOnly];
                                            i++;
                                        }
                                    }
                                }];
                            }
                            
                            [weakSelf presentDesc];
                        }
                    });
                };
                
                [_parser parse];
            }
            else{
                
                [self removeActivityIndicator];
                
                self.desc = [NSMutableString stringWithString: @"我们会尽快补充，谢谢你的贡献：）"];
                [self presentDesc];
            }
        });

    } failure:^(NSError *err) {
        //
        NSLog(@"dicDataforWord:%@",err.description);
        
        [self removeActivityIndicator];
        
        self.desc = [NSMutableString stringWithString: @"我们会尽快补充，谢谢你的贡献：）"];
        [self presentDesc];
    }];
}

- (UIViewController *)parentViewController
{
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    return (UIViewController *)responder;
}

-(void) createActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle) activityStyle
{
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityStyle];
    
    //calculate the correct position
    float width = activityIndicator.frame.size.width;
    float height = activityIndicator.frame.size.height;
    float x = (self.frame.size.width / 2.0) - width/2;
    float y = (self.frame.size.height / 2.0) - height/2;
    activityIndicator.frame = CGRectMake(x, y, width, height);
    activityIndicator.tag=TAG_ACTIVITY_INDICATOR;
    activityIndicator.hidesWhenStopped = YES;
    [self addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
}

-(void) removeActivityIndicator
{
    
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:TAG_ACTIVITY_INDICATOR];
    if (activityIndicator) {
        [activityIndicator removeFromSuperview];
    }
}

- (void)dismissViewAnimated:(BOOL)animated {
    
    if (animated) {
        
        [UIView animateWithDuration:1 animations:^{
            
            self.alpha=0;
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
        
    }
    else{
        
        [self removeFromSuperview];
    }
}

- (void) touchItem
{
    [[[FlyingSoundPlayer alloc] init] speechWord:self.word LessonID:self.lessonID];

    if (self.delegate && [self.delegate respondsToSelector:@selector(itemPressed:)])
    {
        [self.delegate itemPressed:self.lemma];
    }
}

#pragma mark - 拖拽 缩放手势功能

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:1 animations:^{
        [self.superview bringSubviewToFront:self];
    }];
    
    
    //发音功能
    /*UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.magnetImageView];
    if ([self.magnetImageView pointInside:touchPoint withEvent:event]) {
        
        [[[FlyingSoundPlayer alloc] init] speechWord:self.word LessonID:self.lessonID];
    }
     */
    
    NSMutableSet *currentTouches = [[event touchesForView:self] mutableCopy];
    [currentTouches minusSet:touches];
    if ([currentTouches count] > 0)
    {
        [self updateOriginalTransformForTouches:currentTouches];
        [self cacheBeginPointForTouches:currentTouches];
    }
    [self cacheBeginPointForTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGAffineTransform incrementalTransform =
    [self incrementalTransformWithTouches:[event touchesForView:self]];
    self.transform = CGAffineTransformConcat(originalTransform,
                                             incrementalTransform);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if (touch.tapCount >= 2)
        {
            [self.superview bringSubviewToFront:self];
        }
    }
    
    [self updateOriginalTransformForTouches:[event touchesForView:self]];
    [self removeTouchesFromCache:touches];
    
    NSMutableSet *remainingTouches = [[event touchesForView:self] mutableCopy];
    [remainingTouches minusSet:touches];
    [self cacheBeginPointForTouches:remainingTouches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches
{
    NSArray *sortedTouches = [[touches allObjects] sortedArrayUsingSelector:
                              @selector(compareAddress:)];
    NSInteger numTouches = [sortedTouches count];
    
    // No touches
    if (numTouches == 0)
    {
        return CGAffineTransformIdentity;
    }
    
    // Single touch
    if (numTouches == 1)
    {
        UITouch *touch = [sortedTouches objectAtIndex:0];
        CGPoint beginPoint = *(CGPoint *)CFDictionaryGetValue(touchBeginPoints,(__bridge const void *)(touch));
        CGPoint currentPoint = [touch locationInView:self.superview];
        return CGAffineTransformMakeTranslation(currentPoint.x - beginPoint.x,
                                                currentPoint.y - beginPoint.y);
    }
    
    // If two or more touches, go with the first two (sorted by address)
    UITouch *touch1 = [sortedTouches objectAtIndex:0];
    UITouch *touch2 = [sortedTouches objectAtIndex:1];
    
    CGPoint beginPoint1 = *(CGPoint *)CFDictionaryGetValue(touchBeginPoints,(__bridge const void *)(touch1));
    CGPoint currentPoint1 = [touch1 locationInView:self.superview];
    CGPoint beginPoint2 = *(CGPoint *)CFDictionaryGetValue(touchBeginPoints,(__bridge const void *)(touch2));
    CGPoint currentPoint2 = [touch2 locationInView:self.superview];
    
    double layerX = self.center.x;
    double layerY = self.center.y;
    
    double x1 = beginPoint1.x - layerX;
    double y1 = beginPoint1.y - layerY;
    double x2 = beginPoint2.x - layerX;
    double y2 = beginPoint2.y - layerY;
    double x3 = currentPoint1.x - layerX;
    double y3 = currentPoint1.y - layerY;
    double x4 = currentPoint2.x - layerX;
    double y4 = currentPoint2.y - layerY;
    
    // Solve the system:
    //[a b t1, -b a t2, 0 0 1] * [x1, y1, 1] = [x3, y3, 1]
    //[a b t1, -b a t2, 0 0 1] * [x2, y2, 1] = [x4, y4, 1]
    
    double D = (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2);
    if (D < 0.1)
    {
        return CGAffineTransformMakeTranslation(x3-x1, y3-y1);
    }
    
    double a = (y1-y2)*(y3-y4) + (x1-x2)*(x3-x4);
    double b = (y1-y2)*(x3-x4) - (x1-x2)*(y3-y4);
    double tx = (y1*x2 - x1*y2)*(y4-y3) - (x1*x2 + y1*y2)*(x3+x4) +
    x3*(y2*y2 + x2*x2) + x4*(y1*y1 + x1*x1);
    double ty = (x1*x2 + y1*y2)*(-y4-y3) + (y1*x2 - x1*y2)*(x3-x4) +
    y3*(y2*y2 + x2*x2) + y4*(y1*y1 + x1*x1);
    
    return CGAffineTransformMake(a/D, -b/D, b/D, a/D, tx/D, ty/D);
}

- (void)updateOriginalTransformForTouches:(NSSet *)touches
{
    if ([touches count] > 0)
    {
        CGAffineTransform incrementalTransform =
        [self incrementalTransformWithTouches:touches];
        self.transform = CGAffineTransformConcat(originalTransform,
                                                 incrementalTransform);
        originalTransform = self.transform;
    }
}

- (void)cacheBeginPointForTouches:(NSSet *)touches
{
    if ([touches count] > 0)
    {
        for (UITouch *touch in touches)
        {
            CGPoint *point = (CGPoint *)CFDictionaryGetValue(touchBeginPoints,(__bridge const void *)(touch));
            if (point == NULL)
            {
                point = (CGPoint *)malloc(sizeof(CGPoint));
                CFDictionarySetValue(touchBeginPoints, (__bridge const void *)(touch), point);
            }
            *point = [touch locationInView:self.superview];
        }
    }
}

- (void)removeTouchesFromCache:(NSSet *)touches
{
    for (UITouch *touch in touches)
    {
        CGPoint *point = (CGPoint *)CFDictionaryGetValue(touchBeginPoints,
                                                         (__bridge const void *)(touch));
        if (point != NULL)
        {
            free((void *)CFDictionaryGetValue(touchBeginPoints, (__bridge const void *)(touch)));
            CFDictionaryRemoveValue(touchBeginPoints, (__bridge const void *)(touch));
        }
    }
}

@end
