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


#pragma mark - 拖拽 缩放手势功能

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    FlyingWordDetailVC * wordDetail =[[FlyingWordDetailVC alloc] init];
    [wordDetail setTheWord:self.lemma];
    
    [appDelegate pushViewController:wordDetail animated:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[FlyingSoundPlayer alloc] init] speechWord:self.word LessonID:self.lessonID];
}

@end
