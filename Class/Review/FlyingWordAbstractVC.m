//
//  FlyingWordAbstractVC.m
//  FlyingEnglish
//
//  Created by vincent on 4/3/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingWordAbstractVC.h"
#import "FlyingTaskWordData.h"
#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"
#import "NSString+FlyingExtention.h"
#import "UIImageView+WebCache.h"
#import <AFNetworking/AFNetworking.h>
#import "FlyingItemDao.h"
#import "FlyingItemData.h"
#import "FlyingItemParser.h"
#import "SIAlertView.h"
#import "FlyingSeparateView.h"
#import "SoundPlayer.h" 
#import "HCSStarRatingView.h"
#import "FlyingTaskWordDAO.h"
#import "FlyingWordCollectVC.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHttpTool.h"

@interface FlyingWordAbstractVC()
{
    UILabel                 *_wordLabel;
    HCSStarRatingView       *_starRatingView;
    UILabel                 *_sentenceLabel;
    
    UIImageView             *_coverImageView;
    UILabel                 *_lessonTitleLabel;
    
    UILabel                 *_abstractLabel;
    
    CGFloat            _margin;
    float              _width;
}
@end

@implementation FlyingWordAbstractVC

- (id)initWithTaskWord:(FlyingTaskWordData*) taskWord
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        self.taskWord=taskWord;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (INTERFACE_IS_PAD)
    {
        
        _margin=MARGIN_ipad;
    }
    else{
        _margin=MARGIN_iphone;
    }
    _width=self.view.bounds.size.width-2*_margin;

    //标题
    CGSize size = self.view.frame.size;
    
    _wordLabel                  = [[UILabel alloc] initWithFrame:CGRectMake(_margin,0,_width*2/3,size.width*2/16)];
    _wordLabel.textAlignment    =  NSTextAlignmentLeft;
    _wordLabel.backgroundColor  = [UIColor clearColor];
    _wordLabel.textColor        = [UIColor blackColor];
    
    CGFloat titleFontSize       = 24;
    
    if (INTERFACE_IS_PAD) {
        
        titleFontSize           = 36;
    }
    _wordLabel.font      = [UIFont boldSystemFontOfSize:titleFontSize];

    _wordLabel.text         = self.taskWord.BEWORD;
    [self.view addSubview:_wordLabel];
    
    
    //重要性
    
    _starRatingView = [[HCSStarRatingView alloc] initWithFrame:CGRectMake(_wordLabel.frame.origin.x+_wordLabel.frame.size.width,
                                                                                            0,
                                                                                            _width/3,
                                                                                            size.width*2/16)];
    _starRatingView.maximumValue = 5;
    _starRatingView.minimumValue = 0;
    _starRatingView.allowsHalfStars = YES;
    //_starRatingView.value = self.taskWord.BETIMES/2.0;
    _starRatingView.tintColor = [UIColor redColor];
    [_starRatingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_starRatingView];

    
    //例句
    _sentenceLabel                  = [[UILabel alloc] initWithFrame:
                                       CGRectMake(_margin,
                                                _wordLabel.frame.origin.y+_wordLabel.frame.size.height,
                                                  _width,
                                                  size.width*2/16)];
    
    _sentenceLabel.textAlignment  =  NSTextAlignmentLeft;
    _sentenceLabel.backgroundColor= [UIColor clearColor];
    _sentenceLabel.textColor      = [UIColor blackColor];
    _sentenceLabel.numberOfLines  = 0;
    _sentenceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGFloat sentencFontSize      = 12;
    
    if (INTERFACE_IS_PAD) {
        
        sentencFontSize          = 16;
    }
    
    _sentenceLabel.font    = [UIFont systemFontOfSize:sentencFontSize];
    
    if(self.taskWord.BESENTENCE)
    {
        _sentenceLabel.text     = self.taskWord.BESENTENCE;
    }
    else
    {
        _sentenceLabel.text     = @"场景例句暂未纪录...";
    }
    [self.view addSubview:_sentenceLabel];
    
    [self prepareLessonrealted];
    [self prepareAbstract];
    
    // 单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleRecognizer];
}

- (void)handleSingleTapFrom: (id) sender
{
    FlyingWordCollectVC * vc = [[FlyingWordCollectVC alloc] init];

    [vc setTheWord:self.taskWord.BEWORD];
    
    [self presentViewController:vc animated:YES completion:^{
        //
    }];
}

- (void)didChangeValue:(HCSStarRatingView *)sender
{
    self.taskWord.BETIMES=(int)(sender.value*2.0);
    [[[FlyingTaskWordDAO alloc] init] insertWithData:self.taskWord];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _starRatingView.value = self.taskWord.BETIMES/2.0;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[[SoundPlayer alloc] init] speechWord:self.taskWord.BEWORD LessonID:self.taskWord.BELESSONID];
        
        self.taskWord.BETIMES = (self.taskWord.BETIMES-1)>0? (self.taskWord.BETIMES-1):0;
        
        [[[FlyingTaskWordDAO alloc] init] insertWithData:self.taskWord];
    });
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) isInternetReachable
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

-(void) prepareLessonrealted
{
    CGSize size = self.view.frame.size;

    _coverImageView   = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                      _sentenceLabel.frame.origin.y+_sentenceLabel.frame.size.height,
                                                                      size.width,
                                                                      size.width*9/16)];
    
    [self.view addSubview:_coverImageView];
    
    
    _lessonTitleLabel                = [[UILabel alloc] initWithFrame:
                                        CGRectMake(_margin,
                                                   _coverImageView.frame.origin.y+_coverImageView.
                                                   frame.size.height,
                                                   _width,
                                                   size.width*2/16)];
    
    _lessonTitleLabel.textAlignment  =  NSTextAlignmentLeft;
    _lessonTitleLabel.backgroundColor= [UIColor clearColor];
    _lessonTitleLabel.textColor      = [UIColor blackColor];
    _lessonTitleLabel.numberOfLines  = 0;
    _lessonTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGFloat lessonFontSize       = 12;
    
    if (INTERFACE_IS_PAD) {
        
        lessonFontSize           = 16;
    }
    _lessonTitleLabel.font    = [UIFont systemFontOfSize:lessonFontSize];

    [self.view addSubview:_lessonTitleLabel];
    
    FlyingLessonData * lessonData = [[[FlyingLessonDAO alloc] init] selectWithLessonID:self.taskWord.BELESSONID];
    
    if (lessonData.BETITLE) {
        
        _lessonTitleLabel.text       = lessonData.BETITLE;
        
        NSString * picPath = [NSString picPathForWord:self.taskWord.BEWORD];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:picPath]){
            
            [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
            [_coverImageView  setImage:[[UIImage alloc] initWithContentsOfFile:picPath]]; //获取图片
        }
        else{
            
            if(lessonData.BEOFFICIAL){
                
                [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
                [_coverImageView sd_setImageWithURL:[NSURL URLWithString:lessonData.BEIMAGEURL]];
            }
            else{
                
                [_coverImageView setImage:[UIImage imageNamed:@"Default"]];
            }
        }
    }
    else{
        
        NSString * picPath = [NSString picPathForWord:self.taskWord.BEWORD];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:picPath]){
            
            [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
            [_coverImageView  setImage:[[UIImage alloc] initWithContentsOfFile:picPath]]; //获取图片
        }
        else{
            
            if(self.taskWord.BELESSONID){
                
                [AFHttpTool lessonResourceType:kResource_Cover
                                      lessonID:self.taskWord.BELESSONID
                                    contentURL:nil
                                         isURL:YES
                                       success:^(id response) {
                                           //
                                           NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                           NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
                                           
                                           if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                                               
                                               [_coverImageView setContentMode:UIViewContentModeScaleAspectFit];
                                               [_coverImageView sd_setImageWithURL:[NSURL URLWithString:temStr] ];
                                           }

                                       } failure:^(NSError *err) {
                                           //
                                       }];
            }
            else{
                
                [_coverImageView setImage:[UIImage imageNamed:@"Default"]];
            }
        }
        
        if(self.taskWord.BELESSONID){
            
            
            
            [AFHttpTool lessonResourceType:kResource_Title
                                  lessonID:self.taskWord.BELESSONID
                                contentURL:nil
                                     isURL:NO
                                   success:^(id response) {
                                       //
                                       NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                       NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
                                       
                                       if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                                           
                                           
                                           _lessonTitleLabel.text = temStr;
                                       }
                                       
                                   } failure:^(NSError *err) {
                                       //
                                   }];
        }
        else{
            
            _lessonTitleLabel.text       = @"来自用户自有内容。";
        }
    }
}

-(void) prepareAbstract
{
    _abstractLabel                = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _abstractLabel.textAlignment  =  NSTextAlignmentLeft;
    _abstractLabel.backgroundColor= [UIColor clearColor];
    _abstractLabel.numberOfLines  = 0;
    _abstractLabel.lineBreakMode  = NSLineBreakByTruncatingTail;
    _abstractLabel.clipsToBounds  = YES;
    
    [self.view addSubview:_abstractLabel];
    
    CGFloat abstractFontSize      = 14;
    
    if (INTERFACE_IS_PAD) {
        
        abstractFontSize          = 18;
    }
    _abstractLabel.font    = [UIFont systemFontOfSize:abstractFontSize];


    FlyingItemDao * pubDAO=[[FlyingItemDao  alloc] init];
    
    NSArray * itmeDataArry = [pubDAO selectWithWord:self.taskWord.BEWORD];
        
    NSMutableString *abstract= [[NSMutableString alloc] init];
    
    //联网查询
    if (itmeDataArry.count==0) {
        
        [self showWebData];
    }
    else if (itmeDataArry.count==1)
    {
        
        NSString * str = [itmeDataArry[0] sentenceOnly];
        if (str)
        {
            [abstract appendString:str];
            [self presentAbstract:abstract];
        }
        else
        {
            str = [itmeDataArry[0] descriptionOnly];
            
            if (str) {
                [abstract appendString:str];
                [self presentAbstract:abstract];
            }
        }
    }
    else{
        
        __block int i=1;
        
        [itmeDataArry enumerateObjectsUsingBlock:^(FlyingItemData * obj, NSUInteger idx, BOOL *stop) {
            
            @autoreleasepool {
                
                if (i>=9) {
                    
                    [abstract appendFormat:@"....."];
                    *stop=YES;
                }
                else
                {
                    if (obj.sentenceOnly) {
                        
                        [abstract appendFormat:@"%d.%@\r\n",i,obj.sentenceOnly];
                        i++;
                    }
                }
            }
        }];
        
        if (abstract.length>0)
        {
            [self presentAbstract:abstract];
        }
        else
        {
            [itmeDataArry enumerateObjectsUsingBlock:^(FlyingItemData * obj, NSUInteger idx, BOOL *stop) {
                
                @autoreleasepool {
                    
                    if (i>=9) {
                        
                        [abstract appendFormat:@"....."];
                        *stop=YES;
                    }
                    else
                    {
                        if (obj.sentenceOnly) {
                            
                            [abstract appendFormat:@"%d.%@\r\n",i,obj.descriptionOnly];
                            i++;
                        }
                    }
                }
            }];
            
            if (abstract.length>0)
            {
                [self presentAbstract:abstract];
            }
        }
    }
}

- (void) showWebData
{
    [AFHttpTool dicDataforWord:self.taskWord.BEWORD success:^(id response) {
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
            
            if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                
                if (!self.itemParser) {
                    self.itemParser = [[FlyingItemParser alloc] init];
                }
                
                [self.itemParser SetData:response];
                
                __weak typeof(self) weakSelf = self;
                FlyingItemDao * dao= [[FlyingItemDao alloc] init];
                
                self.itemParser.completionBlock = ^(NSArray *itemList,NSInteger allRecordCount)
                {
                    if (itemList.count>=1) {
                        
                        [itemList enumerateObjectsUsingBlock:^(FlyingItemData  *item, NSUInteger idx, BOOL *stop) {
                            
                            [dao insertWithData:item];
                        }];
                        
                        NSArray * itmeDataArry;
                        itmeDataArry = [dao selectWithWord:weakSelf.taskWord.BEWORD];
                        
                        NSMutableString *abstract= [[NSMutableString alloc] init];
                        
                        if (itmeDataArry.count==1) {
                            
                            
                            NSString * str = [itmeDataArry[0] sentenceOnly];
                            if (str) {
                                
                                [abstract appendString:str];
                            }
                            else
                            {
                                str = [itmeDataArry[0] descriptionOnly];
                                
                                if (str)
                                {
                                    [abstract appendString:str];
                                }
                            }
                        }
                        else{
                            
                            __block int i=1;
                            
                            [itmeDataArry enumerateObjectsUsingBlock:^(FlyingItemData * obj, NSUInteger idx, BOOL *stop) {
                                
                                if (i>=9) {
                                    
                                    [abstract appendFormat:@"....."];
                                    *stop=YES;
                                }
                                else
                                {
                                    if (obj.sentenceOnly) {
                                        
                                        [abstract appendFormat:@"%d.%@\r\n",i,obj.sentenceOnly];
                                        i++;
                                    }
                                }
                            }];
                            
                            if (abstract.length==0)
                            {
                                [itmeDataArry enumerateObjectsUsingBlock:^(FlyingItemData * obj, NSUInteger idx, BOOL *stop) {
                                    
                                    @autoreleasepool {
                                        
                                        if (i>=9) {
                                            
                                            [abstract appendFormat:@"....."];
                                            *stop=YES;
                                        }
                                        else
                                        {
                                            if (obj.sentenceOnly) {
                                                
                                                [abstract appendFormat:@"%d.%@\r\n",i,obj.descriptionOnly];
                                                i++;
                                            }
                                        }
                                    }
                                }];
                            }
                        }
                        
                        [weakSelf presentAbstract:abstract];
                    }
                };
                
                [self.itemParser parse];
            }
            else
            {
                [self presentAbstract:@"我们会尽快补充，谢谢你的贡献：）"];
            }
        });

    } failure:^(NSError *err) {
        //
    }];
}

-(void) presentAbstract:(NSString*) abstract
{
    CGSize size = self.view.frame.size;
    
    CGRect frame=CGRectMake(0,
                            _lessonTitleLabel.frame.origin.y+_lessonTitleLabel.frame.size.height,
                            size.width,
                            size.width/16);
    
    FlyingSeparateView *sepView =[[FlyingSeparateView alloc] initWithFrame:frame];
    [sepView setTitle:@"场景例句/简要"];
    [self.view addSubview:sepView];

    _abstractLabel.text = abstract;
    
    CGSize constraint = CGSizeMake(_width, MAXFLOAT);
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = _abstractLabel.font;
    gettingSizeLabel.text = abstract;
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:constraint];
    
    CGFloat temHight=expectSize.height;
    
    if (temHight>(size.height-size.width-self.navigationController.toolbar.frame.size.height
 )) {
        
        temHight=size.height-size.width-self.navigationController.toolbar.frame.size.height;
    }
    
    _abstractLabel.frame = CGRectMake(_margin,
                                      size.width,
                                      _width,
                                      temHight);
}

@end
