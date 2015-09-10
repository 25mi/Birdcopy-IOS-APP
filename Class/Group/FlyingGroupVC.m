//
//  FlyingGroupVC.m
//  FlyingEnglish
//
//  Created by vincent on 9/8/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingGroupVC.h"
#import "FlyingGroupData.h"

#import "FlyingHttpTool.h"

#import "FlyingGroupStreamCell.h"

#import "UIView+Toast.h"
#import "RCDChatViewController.h"

#import "iFlyingAppDelegate.h"
#import "RESideMenu.h"

#import "FlyingCalendarVC.h"

#import "FlyingDiscoverContent.h"

@interface FlyingGroupVC ()
{
    NSInteger            _maxNumOfGroupNews;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
    UIRefreshControl    *_refreshControl;
}

@property (assign) CGPoint scrollViewDragPoint;

@end

@implementation FlyingGroupVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.leftBarButtonItem = menuBarButtonItem;
    
    image= [UIImage imageNamed:@"Content"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* discoverButton= [[UIButton alloc] initWithFrame:frame];
    [discoverButton setBackgroundImage:image forState:UIControlStateNormal];
    [discoverButton addTarget:self action:@selector(doDiscover) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* discoverButtonItem= [[UIBarButtonItem alloc] initWithCustomView:discoverButton];
    
    image= [UIImage imageNamed:@"Calendar"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* calendarButton= [[UIButton alloc] initWithFrame:frame];
    [calendarButton setBackgroundImage:image forState:UIControlStateNormal];
    [calendarButton addTarget:self action:@selector(doCalendar) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* calendarBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:calendarButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:calendarBarButtonItem,discoverButtonItem,nil];
    
    
    [self setupdetailsGroupView];
    
    [self.detailsGroupView reloadData];
    
    //[self requestMoreGroupDetails];
}

#pragma mark -
#pragma mark Setup

- (void)setupdetailsGroupView
{
    if(!self.detailsGroupView)
    {
        self.detailsGroupView=[[FlyingGroupDetailsView alloc] initWithFrame:self.view.frame];
        
        self.detailsGroupView.tableViewDataSource = self;
        self.detailsGroupView.tableViewDelegate = self;
        self.detailsGroupView.delegate = self;
        self.detailsGroupView.tableViewSeparatorColor = [UIColor clearColor];
        
        [self.view addSubview:self.detailsGroupView];
    }
    
    if (!_currentData) {
        _currentData =[NSMutableArray arrayWithObjects:@"1",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",nil];
    }
    
    //[_currentData removeAllObjects];
    _currentLodingIndex=0;
    _maxNumOfGroupNews=NSIntegerMax;
}

#pragma mark Laoding indicatior

- (void) laodingIndicator
{
}

#pragma mark -
#pragma mark Network Request Methods

- (void)requestMoreGroupDetails
{
     if (_currentData.count<_maxNumOfGroupNews)
     {
         _currentLodingIndex++;

         [FlyingHttpTool getGroupNewsListForGroupID:self.groupData.gp_id PageNumber:0 Completion:^(NSArray *newsList, NSInteger allRecordCount) {
             //
             [self.currentData addObjectsFromArray:newsList];
             
             _maxNumOfGroupNews=allRecordCount;
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self finishLoadingData];
             });
         }];

         [FlyingHttpTool getAlbumListForContentType:nil
                                         PageNumber:_currentLodingIndex
                                          Recommend:YES
                                         Completion:^(NSArray *albumList,NSInteger allRecordCount) {
                                         }];
     }
}

#pragma mark -
#pragma mark Fetched Data Processing

- (void)finishLoadingData
{
    [self.detailsGroupView reloadData];
}

#pragma mark -
#pragma mark Action Methods

- (void)popViewController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;

    //return [_currentData count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would take care of building the cells.
    
    FlyingGroupStreamCell* cell = [tableView dequeueReusableCellWithIdentifier:GROUPSTREAMCELL_IDENTIFIER];
    
    if(indexPath.row % 2){

        if (!cell) {
            cell = [[FlyingGroupStreamCell alloc] initWithStyle:UITableViewCellStyleDefault ReuseIdentifier:GROUPSTREAMCELL_IDENTIFIER StreamCellType:FlyingGroupStreamCellTextType];
        }

    }
    else
    {
        if (!cell) {
            cell = [[FlyingGroupStreamCell alloc] initWithStyle:UITableViewCellStyleDefault ReuseIdentifier:GROUPSTREAMCELL_IDENTIFIER StreamCellType:FlyingGroupStreamCellPictureType];
        }
    
    }
    
    [cell setStreamCellData:[_currentData objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    /*
    
    if ([cell isKindOfClass:[KMMovieDetailsSimilarMoviesCell class]])
    {
        KMMovieDetailsSimilarMoviesCell* similarMovieCell = (KMMovieDetailsSimilarMoviesCell*)cell;
        
        [similarMovieCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    }
    
    if ([cell isKindOfClass:[KMMovieDetailsCommentsCell class]])
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
     
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? (INTERFACE_IS_PAD ? 250 : 125) : (INTERFACE_IS_PAD ? 502 : 251);
}

#pragma mark -
#pragma mark UICollectionView DataSource

/*

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return [self.similarMoviesDataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    KMSimilarMoviesCollectionViewCell* cell = (KMSimilarMoviesCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"KMSimilarMoviesCollectionViewCell" forIndexPath:indexPath];
    
    [cell.cellImageView setImageURL:[NSURL URLWithString:[[self.similarMoviesDataSource objectAtIndex:indexPath.row] movieThumbnailPosterImageUrl]]];
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    KMMovieDetailsViewController* viewController = (KMMovieDetailsViewController*)[StoryBoardUtilities viewControllerForStoryboardName:@"KMMovieDetailsStoryboard" class:[KMMovieDetailsViewController class]];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    viewController.movieDetails = [self.similarMoviesDataSource objectAtIndex:indexPath.row];
}

 */

 
#pragma mark -
#pragma mark FlyingGroupDetailsViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollViewDragPoint = scrollView.contentOffset;
}

- (CGPoint)detailsPage:(FlyingGroupDetailsView *)detailsGroupView tableViewWillBeginDragging:(UITableView *)tableView;
{
    return self.scrollViewDragPoint;
}

- (UIViewContentMode)contentModeForImage:(UIImageView *)imageView
{
    return UIViewContentModeTop;
}

- (UIImageView*)detailsPage:(FlyingGroupDetailsView*)detailsGroupView imageDataForImageView:(UIImageView*)imageView;
{
    __block UIImageView* blockImageView = imageView;
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.groupData.cover] completed:^ (UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if ([detailsGroupView.delegate respondsToSelector:@selector(headerImageViewFinishedLoading:)])
        [detailsGroupView.delegate headerImageViewFinishedLoading:blockImageView];
        
    }];
    
    return imageView;

}

- (void)detailsPage:(FlyingGroupDetailsView *)detailsGroupView tableViewDidLoad:(UITableView *)tableView
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)detailsPage:(FlyingGroupDetailsView *)detailsGroupView headerViewDidLoad:(UIView *)headerView
{
    [headerView setAlpha:0.0];
    [headerView setHidden:YES];
}


//////////////////////////////////////////////////////////////
#pragma mark
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

//LogoDone functions
- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) doCalendar
{
    [self.navigationController pushViewController:[[FlyingCalendarVC alloc] init] animated:YES];
}

- (void) doDiscover
{
    [self.navigationController pushViewController:[[FlyingDiscoverContent alloc] init] animated:YES];
}


- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        [self.view makeToast:@"PAD版本暂时不支持聊天功能!！"];
        
        return;
    }
    
    RCDChatViewController  * chatVC=[[RCDChatViewController alloc] init];
    [self.navigationController pushViewController:chatVC animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark controller events
//////////////////////////////////////////////////////////////

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shakeNow];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void) addBackFunction
{
    
    //在一个函数里面（初始化等）里面添加要识别触摸事件的范围
    UISwipeGestureRecognizer *recognizer= [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeFrom:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

-(void) handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if ((recognizer.state ==UIGestureRecognizerStateEnded) || (recognizer.state ==UIGestureRecognizerStateCancelled)) {
        
        [self dismiss];
    }
}


@end
