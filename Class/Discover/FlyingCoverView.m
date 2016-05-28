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
#import <UIImageView+AFNetworking.h>
#import "NSString+FlyingExtention.h"
#import "FlyingLessonParser.h"
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

        //[self loadData];
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
        self.coverTitle.font         = [UIFont systemFontOfSize:KNormalFontSize];
        self.coverTitle.textAlignment=NSTextAlignmentCenter;
        self.coverTitle.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
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
    
    if (self.coverData.count==0)
    {
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
        
        [coverImageView setImageWithURL:[NSURL URLWithString:lessonData.imageURL]];
    }
}


- (void) loadCoverData
{    
    [FlyingHttpTool getCoverListForDomainID:self.domainID
                                 DomainType:self.domainType
                                 PageNumber:1
                               Completion:^(NSArray *lessonList, NSInteger allRecordCount) {
                                   //
                                   if(lessonList.count!=0)
                                   {
                                       if (!self.coverData) {
                                           
                                           self.coverData = [NSMutableArray new];
                                       }
                                       //重新载入数据
                                       [self.coverData removeAllObjects];
                                       [self.coverImageViewDic removeAllObjects];
                                       [self.coverData addObjectsFromArray:lessonList];
                                       
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
