//
//  FlyingGroupDetailsView.m
//  FlyingEnglish
//
//  Created by vincent on 9/8/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//


#import "FlyingGroupDetailsView.h"

#import "UIView+Autosizing.h"
#import "iFlyingAppDelegate.h"

/**
 *  Change these values to customize you details page
 *
 *  @define kDefaultImagePagerHeight : The background image's height. Increase value to show a bigger image.
 *  @define kDefaultTableViewHeaderMargin : Tableview's header height margin.
 *  @define kDefaultImageAlpha : Image view default alpha
 *  @define kDefaultImageScalingFactor : Image view scale factor. Increase value to decrease scaling effect and vice versa.
 *
 */
#define kDefaultImagePagerHeight 375.0f
#define kDefaultTableViewHeaderMargin 95.0f
#define kDefaultImageAlpha 1.0f
#define kDefaultImageScalingFactor 450.0f

@interface FlyingGroupDetailsView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton    *imageButton;

@property (nonatomic, assign) BOOL         enableKVO;

@property (nonatomic, assign) RefreshState refreshState;

@property (nonatomic, assign) CGFloat       angle;
@property (nonatomic, assign) CGFloat       lastContentOffset;

@end

@implementation FlyingGroupDetailsView

#pragma mark -
#pragma mark Init Methods

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _enableKVO=YES;
    
    _angle=0;
    _lastContentOffset=0;

    _refreshState=RefreshStateNormal;
    
    _imageHeaderViewHeight = kDefaultImagePagerHeight;
    _imageScalingFactor = kDefaultImageScalingFactor;
    _headerImageAlpha = kDefaultImageAlpha;
    _backgroundViewColor = [UIColor clearColor];
    self.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark -
#pragma mark View layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _navBarFadingOffset = _imageHeaderViewHeight - kDefaultTableViewHeaderMargin;
    
    if (!self.tableView)
    {
        [self setupTableView];
    }
    
    if (!self.tableView.tableHeaderView)
    {
        [self setupTableViewHeader];
    }
    
    if(!self.imageView)
    {
        [self setupImageView];
    }
    
    if (self.backgroundColor)
    {
        [self setupBackgroundColor];
    }
    
    [self setupImageButton];
    
    if (!self.boardView) {
        [self setupBoardNews];
    }
}

#pragma mark -
#pragma mark View Layout Setup Methods

- (void)setupTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self.tableViewDelegate;
    self.tableView.dataSource = self.tableViewDataSource;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.tableViewSeparatorColor)
    self.tableView.separatorColor = self.tableViewSeparatorColor;
    
    void *context = (__bridge void *)self;
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:context];
    
    [self addSubview:self.tableView];
    
    if([self.groupDetailsViewDelegate respondsToSelector:@selector(detailsPage:tableViewDidLoad:)])
    [self.groupDetailsViewDelegate detailsPage:self tableViewDidLoad:self.tableView];
}

- (void)setupTableViewHeader
{
    CGRect tableHeaderViewFrame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.imageHeaderViewHeight - kDefaultTableViewHeaderMargin);
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)setupImageButton
{
    if (!self.imageButton)
    self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.imageHeaderViewHeight)];
    
    [self.imageButton addTarget:self action:@selector(imageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView.tableHeaderView addSubview:self.imageButton];
}

- (void)setupImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0, self.tableView.frame.size.width, self.imageHeaderViewHeight)];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if ([self.groupDetailsViewDelegate respondsToSelector:@selector(contentModeForImage:)])
    self.imageView.contentMode = [self.groupDetailsViewDelegate contentModeForImage:self.imageView];
    
    [self insertSubview:self.imageView belowSubview:self.tableView];
    
    if ([self.groupDetailsViewDelegate respondsToSelector:@selector(detailsPage:imageDataForImageView:)])
    [self.groupDetailsViewDelegate detailsPage:self imageDataForImageView:self.imageView];
}

- (void)setupBackgroundColor
{
    self.backgroundColor = self.backgroundViewColor;
    self.tableView.backgroundColor = self.backgroundViewColor;
}

- (void)setupImageViewGradient
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.imageView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], [(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], nil];
    
    gradientLayer.startPoint = CGPointMake(0.6f, 0.6);
    gradientLayer.endPoint = CGPointMake(0.6f, 1.0f);
    
    self.imageView.layer.mask = gradientLayer;
}

-(void)setupBoardNews
{
    if(self.boardView)
    {
        [self.boardView removeFromSuperview];
    }
    
    if ([self.groupDetailsViewDelegate respondsToSelector:@selector(getTopBoardNewsData)])
    {
        CGRect frame=CGRectMake(0, 0, 160, 160);
        if (INTERFACE_IS_PAD ) {
            
            frame=CGRectMake(0, 0, 200, 200);
        }
        
        FlyingStreamData *bordNewData =[self.groupDetailsViewDelegate getTopBoardNewsData];
        
        if (bordNewData) {
            
            self.boardView = [[FlyingBoardUIView alloc] initWithFrame:frame];
            [self.boardView setBoardData:bordNewData];
            
            //随机散开磁贴的显示位置
            srand((unsigned int)bordNewData.contentSummary.length);
            
            CGFloat x = (self.tableView.tableHeaderView.frame.size.width-self.boardView.frame.size.width)*rand()/(RAND_MAX+1.0);
            CGFloat y=  (self.tableView.tableHeaderView.frame.size.height-self.boardView.frame.size.height)*rand()/(RAND_MAX+1.0);
            
            CGFloat barHeight =0;

            if ([self.groupDetailsViewDelegate respondsToSelector:@selector(getnavigationBarHeight)])
            {
                barHeight= [self.groupDetailsViewDelegate getnavigationBarHeight];
            }
            
            self.boardView.frame =CGRectMake(x, barHeight+y,CGRectGetWidth(self.boardView.frame),CGRectGetHeight(self.boardView.frame)) ;
            
            [self.boardView adjustForAutosizing];
            self.boardView.alpha=0;
            
            [self insertSubview:self.boardView belowSubview:self.tableView];
            
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                self.boardView.alpha=1;
                
            } completion:^(BOOL finished) {}];
        }
    }
}

#pragma mark -
#pragma mark Data Refresh

- (void)reloadData;
{
    if ([self.groupDetailsViewDelegate respondsToSelector:@selector(contentModeForImage:)])
    self.imageView.contentMode = [self.groupDetailsViewDelegate contentModeForImage:self.imageView];
    
    if ([self.groupDetailsViewDelegate respondsToSelector:@selector(detailsPage:imageDataForImageView:)])
    [self.groupDetailsViewDelegate detailsPage:self imageDataForImageView:self.imageView];
    
    [self.tableView reloadData];
}

- (void)reloadBoardNews
{
    [self setupBoardNews];
}

#pragma mark -
#pragma mark Tableview Delegate and DataSource setters

- (void)setTableViewDataSource:(id<UITableViewDataSource>)tableViewDataSource
{
    _tableViewDataSource = tableViewDataSource;
    
    self.tableView.dataSource = _tableViewDataSource;
    
    if (_tableViewDelegate)
    [self.tableView reloadData];
}

- (void)setTableViewDelegate:(id<UITableViewDelegate>)tableViewDelegate
{
    _tableViewDelegate = tableViewDelegate;
    
    self.tableView.delegate = _tableViewDelegate;
    
    if (_tableViewDataSource)
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark HeaderView Setter

- (void)hideHeaderImageView:(BOOL)hidden
{
    self.imageView.hidden = hidden;
}

- (void)setGroupAccessView:(UIView *)view
{
    _groupAccessView = view;
    
    if([self.groupDetailsViewDelegate respondsToSelector:@selector(detailsPage:headerViewDidLoad:)])
        [self.groupDetailsViewDelegate detailsPage:self headerViewDidLoad:self.groupAccessView];
}

#pragma mark -
#pragma mark KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_enableKVO) {
        
        return;
    }
    
    if (context != (__bridge void *)self)
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ((object == self.tableView) && ([keyPath isEqualToString:@"contentOffset"] == YES))
    {
        [self scrollViewDidScrollWithOffset:self.tableView.contentOffset.y];
        return;
    }
}

-(void) enableKVO:(BOOL) enableKVO
{
    _enableKVO=enableKVO;
}

#pragma mark -
#pragma mark Action Methods

- (void)imageButtonPressed:(UIButton*)buttom
{
    if ([self.groupDetailsViewDelegate respondsToSelector:@selector(detailsPage:imageViewWasSelected:)])
    [self.groupDetailsViewDelegate detailsPage:self imageViewWasSelected:self.imageView];
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)scrollViewDidScrollWithOffset:(CGFloat)scrollOffset
{
    CGPoint scrollViewDragPoint = [self.groupDetailsViewDelegate detailsPage:self tableViewWillBeginDragging:self.tableView];
        
    if (scrollOffset < 0)
    {
        self.imageView.transform = CGAffineTransformMakeScale(1 - (scrollOffset / self.imageScalingFactor), 1 - (scrollOffset / self.imageScalingFactor));
    }
    else
    {
        self.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
    
    [self animateImageView:scrollOffset draggingPoint:scrollViewDragPoint alpha:self.headerImageAlpha];
    
    //聊天入口
        
    //加载状态显示
    if(scrollOffset >=0)
    {
        if(self.refreshState == RefreshStateLoading)
        {
            [UIView animateWithDuration:3 animations:^{
                
                self.boardView.magnetImageView.alpha = 0;
                
            } completion:nil];
        }
        else
        {
            self.refreshState = RefreshStateNormal;
        }
    }
    else
    {
        if(self.refreshState == RefreshStateLoading)
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                self.boardView.magnetImageView.alpha = 0;
                
            } completion:nil];
        }
        else
        {
            if (scrollOffset< _lastContentOffset )
            {
                self.angle+=M_PI/10;
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.boardView.magnetImageView.transform = CGAffineTransformMakeRotation(self.angle);//箭头旋转180º
                    
                } completion:nil];
            }
            else if (scrollOffset > _lastContentOffset )
            {
                self.angle-=M_PI/10;
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.boardView.magnetImageView.transform = CGAffineTransformMakeRotation(self.angle);//箭头旋转180º
                    
                } completion:nil];
            }
            
            if(scrollOffset < -80)
            {
                ////手指离开屏幕
                if(!self.tableView.isDragging)
                {
                    [self setRefreshState:RefreshStateLoading];
                }
            }
        }
      }
    
    _lastContentOffset=scrollOffset;
}

- (void)setRefreshState:(RefreshState)refreshState
{
    _refreshState = refreshState;
    
    switch (refreshState) {
        case RefreshStateNormal:
        {
            [self.boardView.magnetImageView.layer removeAllAnimations];
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.boardView.magnetImageView.transform = CGAffineTransformIdentity;
                self.boardView.magnetImageView.alpha = 1;
                
            } completion:nil];
            
            break;

        }
        case RefreshStateLoading:
        {
            if ([self.groupDetailsViewDelegate respondsToSelector:@selector(refreshNow)])
            {
                [self.groupDetailsViewDelegate refreshNow];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)animateImageView:(CGFloat)scrollOffset draggingPoint:(CGPoint)scrollViewDragPoint alpha:(float)alpha
{
    [self animateNavigationBar:scrollOffset draggingPoint:scrollViewDragPoint];
    
    if (scrollOffset > scrollViewDragPoint.y && scrollOffset > kDefaultTableViewHeaderMargin)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.imageView.alpha = alpha;
            
        } completion:nil];
    }
    else if (scrollOffset <= kDefaultTableViewHeaderMargin)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.imageView.alpha = 1.0;
            
        } completion:nil];
    }
}

- (void)animateNavigationBar:(CGFloat)scrollOffset draggingPoint:(CGPoint)scrollViewDragPoint
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        
    if(scrollOffset > _navBarFadingOffset)
    {
        [appDelegate setnavigationBarWithClearStyle:NO];
    }
    else if(scrollOffset < _navBarFadingOffset)
    {
        [appDelegate setnavigationBarWithClearStyle:YES];
    }
}

@end
