//
//  FlyingCoverView.m
//  FlyingEnglish
//
//  Created by vincent on 15/9/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingCoverView.h"
#import "shareDefine.h"
#import "FlyingPubLessonData.h"
#import "UIImageView+WebCache.h"
#import "NSString+FlyingExtention.h"
#import "FlyingLessonParser.h"
#import "SIAlertView.h"
#import "UIView+Autosizing.h"
#import  <AFNetworking.h>
#import "FlyingHttpTool.h"

@interface FlyingCoverView ()

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end


@implementation FlyingCoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.orientation = [UIApplication sharedApplication].statusBarOrientation;

        [self loadData];
    }
    return self;
}

-(void) loadData
{
    
    if (!self.coverScrollView) {
        
        self.coverScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0, self.bounds.size.width, self.bounds.size.width*9/16)];
        
        //封面推荐部分
        UITapGestureRecognizer *coverRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchCover:)];
        coverRecognizer.numberOfTapsRequired = 1; // 单击
        [self.coverScrollView addGestureRecognizer:coverRecognizer];
        
        self.coverScrollView.delegate = self;
        [self.coverScrollView setShowsHorizontalScrollIndicator:NO];
        [self.coverScrollView setShowsVerticalScrollIndicator:NO];
        self.coverScrollView.contentSize = CGSizeMake(self.coverScrollView.frame.size.width *KBELoadingCount, self.coverScrollView.frame.size.height);
        self.coverScrollView.pagingEnabled = YES;
        self.coverScrollView.alwaysBounceHorizontal= YES;
        //self.coverScrollView.backgroundColor=[UIColor whiteColor];
        
        [self addSubview:self.coverScrollView];
        
        self.coverTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.coverScrollView.frame.size.height, self.bounds.size.width*200/320, self.bounds.size.width*30/320)];
        self.coverTitle.backgroundColor=[UIColor clearColor];
        self.coverTitle.font         = [UIFont systemFontOfSize:12.0];
        self.coverTitle.textAlignment=NSTextAlignmentCenter;
        self.coverTitle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        
        if (INTERFACE_IS_PAD )
        {
            //封面推荐
            self.coverTitle.font         = [UIFont systemFontOfSize:20.0];
        }
        [self addSubview:self.coverTitle];
        
        self.coverControl=[[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width*200/320+1, self.coverScrollView.frame.size.height, self.bounds.size.width*100/320, self.bounds.size.width*30/320)];
        
        self.coverControl.numberOfPages = KBELoadingCount;
        self.coverControl.currentPage = 0;
        self.coverControl.enabled=NO;
        self.coverControl.pageIndicatorTintColor=[UIColor whiteColor];
        self.coverControl.currentPageIndicatorTintColor=[UIColor grayColor];
        self.coverControl.backgroundColor=[UIColor clearColor];
        [self addSubview:self.coverControl];
        
        self.coverImageViewDic =[[NSMutableDictionary  alloc] init];
    }
    else
    {
        [[self.coverScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.coverData removeAllObjects];
        [self.coverImageViewDic removeAllObjects];
    }
    
    if (self.coverData.count==0) {
        
        [self loadCoverData];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.coverScrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (self.coverControl.currentPage != page) {
        
        self.coverControl.currentPage = page;
        [self paintCoverView:page];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    
    CGFloat currentOffset = offset.x + bounds.size.width -inset.right;
    CGFloat maximumOffset = size.width;
    
    if((fabs(maximumOffset - currentOffset)>self.frame.size.width/8)
       && (maximumOffset<currentOffset)
       && offset.x>0 )
    {
        [self showFeatureContent];
    }
}

-(void) paintCoverView:(NSInteger) index
{
    //更新封面显示标题
    
    if (index>=self.coverData.count) {
        return;
    }
    
    FlyingPubLessonData * lessonData  =self.coverData[index];
    [self.coverTitle setText:lessonData.title];
    
    if (index<self.coverData.count) {
        
        //更新封面图
        UIImageView * coverImageView=[self.coverImageViewDic objectForKey:@(index)];
        
        if (coverImageView) {
            
            [coverImageView removeFromSuperview];
            coverImageView.image=nil;
        }
        
        CGRect frame=self.coverScrollView.frame;
        
        frame.origin.x=index*frame.size.width;
        
        coverImageView= [[UIImageView alloc] initWithFrame:frame];
        [coverImageView setContentMode:UIViewContentModeScaleAspectFit];
        
        UIImageView * contentTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width*9/(16*4), frame.size.width*9/(16*4))];
        
        if ([lessonData.contentType isEqualToString:KContentTypeText])
        {
            [contentTypeImageView setImage:[UIImage imageNamed:PlayDocIcon]];
        }
        else if ([lessonData.contentType isEqualToString:KContentTypeVideo])
        {
            [contentTypeImageView setImage:[UIImage imageNamed:PlayVideoIcon]];
        }
        else  if ([lessonData.contentType isEqualToString:KContentTypeAudio])
        {
            [contentTypeImageView setImage:[UIImage imageNamed:PlayAudioIcon]];
        }
        else  if ([lessonData.contentType isEqualToString:KContentTypePageWeb])
        {
            [contentTypeImageView setImage:[UIImage imageNamed:PlayWebIcon]];
        }
        [self.coverScrollView addSubview:coverImageView];
        [self.coverScrollView addSubview:contentTypeImageView];

        [self.coverImageViewDic setObject:coverImageView forKey:@(index)];
        
        if (!coverImageView.image) {
            
            if (INTERFACE_IS_PAD) {
                
                [self createActivityIndicatorAt:coverImageView WithStyle:UIActivityIndicatorViewStyleWhiteLarge];
                
            }
            else{
                
                [self createActivityIndicatorAt:coverImageView WithStyle:UIActivityIndicatorViewStyleWhite];
            }
        }
        
        __weak typeof(self) weakSelf = self;
        
        [coverImageView sd_setImageWithURL:[NSURL URLWithString:lessonData.imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [weakSelf removeActivityIndicator:(NSUInteger) index];
        }];
    }
}

-(void) createActivityIndicatorAt:(UIView*) myView  WithStyle:(UIActivityIndicatorViewStyle) activityStyle
{
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityStyle];
    activityIndicator.color=[UIColor grayColor];
    
    //calculate the correct position
    float width = activityIndicator.frame.size.width;
    float height = activityIndicator.frame.size.height;
    float x = (myView.frame.size.width / 2.0) - width/2;
    float y = (myView.frame.size.height / 2.0) - height/2;
    activityIndicator.frame = CGRectMake(x, y, width, height);
    
    //_activityIndicator.hidesWhenStopped = YES;
    [myView addSubview:activityIndicator];
    
    if (!activityIndicator.isAnimating) {
        [activityIndicator startAnimating];
    }
}

-(void) removeActivityIndicator:(NSUInteger) idx
{
    
    UIImageView * coverImageView=[self.coverImageViewDic objectForKey:@(idx)];
    
    if (coverImageView) {
        
        [[coverImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (void) loadCoverData
{
    [FlyingHttpTool getCoverListWithSuccessCompletion:^(NSArray *LessonList,NSInteger allRecordCount) {
        //
        if(LessonList.count!=0)
        {
            if (!self.coverData) {
                
                self.coverData = [NSMutableArray new];
            }
            //重新载入数据
            [self.coverData removeAllObjects];
            [self.coverImageViewDic removeAllObjects];
            [self.coverData addObjectsFromArray:LessonList];
            
            [[self.coverScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            [self paintCoverView:self.coverControl.currentPage];
        }

    }];
}

- (void) showFeatureContent
{
    if (self.coverViewDelegate && [self.coverViewDelegate respondsToSelector:@selector(showFeatureContent)])
    {
        [self.coverViewDelegate showFeatureContent];
    }
}

- (void) touchCover:(id)sender
{
    if(self.coverData.count>self.coverControl.currentPage)
    {
        FlyingPubLessonData* lessonData = self.coverData[self.coverControl.currentPage];
        
        if (self.coverViewDelegate && [self.coverViewDelegate respondsToSelector:@selector(touchCover:)])
        {
            [self.coverViewDelegate touchCover:lessonData];
        }
    }
}

#pragma mark - View

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.orientation != orientation) {
        
        // Recalculates layout
        [self rejustCoverView];
        
        self.orientation = orientation;
    }
}

- (void)rejustCoverView
{
    [[self.coverScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.coverImageViewDic removeAllObjects];
    [self.coverScrollView removeFromSuperview];
    self.coverScrollView=nil;
    
    [self.coverTitle removeFromSuperview];
    self.coverTitle=nil;
    
    [self.coverControl removeFromSuperview];
    self.coverControl=nil;
    
    [self loadData];
    
    [self paintCoverView:0];
}


@end