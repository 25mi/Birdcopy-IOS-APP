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

#import "FlyingMemberCollectionViewCell.h"

#import "FlyingLessonVC.h"

@interface FlyingGroupVC ()<UIGestureRecognizerDelegate>
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
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];

    [self addBackFunction];
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    image= [UIImage imageNamed:@"back"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* backButton= [[UIButton alloc] initWithFrame:frame];
    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem,menuBarButtonItem,nil];
    
    image= [UIImage imageNamed:@"Discover"];
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
    
    self.title=self.groupData.gp_name;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupGroupView];

    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setnavigationBarWithClearStyle:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Apple bug Fix
    [self.groupView removeFromSuperview];
    self.groupView=nil;
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setnavigationBarWithClearStyle:NO];
    
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Setup

- (void)setupGroupView
{
    if(!self.groupView)
    {
        self.groupView=[[FlyingGroupDetailsView alloc] initWithFrame:self.view.frame];
        
        self.groupView.tableViewDataSource = self;
        self.groupView.tableViewDelegate = self;
        self.groupView.groupDetailsViewDelegate = self;
        self.groupView.tableViewSeparatorColor = [UIColor clearColor];
        [self.view addSubview:self.groupView];
    }
    
    if (!_currentData) {
        
        _currentData =[NSMutableArray arrayWithObjects:@"1",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",nil];
        
        _currentLodingIndex=0;
        _maxNumOfGroupNews=NSIntegerMax;

        [self requestMoreGroupStream];
    }

    //[self.groupView setNavBarView:self.navigationController.navigationBar];
    
    if (!self.topBoardNewsData) {
        
        self.topBoardNewsData = [[FlyingStreamData alloc] init];
        
        self.topBoardNewsData.title=@"周一课程改期通知";
        self.topBoardNewsData.contentSummary=@"以下几类人群尤其应该关注血脂水平：一是已患冠心病、脑卒中、外周动脉粥样硬化性疾病的患者；二是吸烟、肥胖、患有高血压或糖尿病的患者；三是家族中有冠心病、脑卒中或外周动脉粥样硬化性疾病病史患者，特别是直系亲属中有人50岁以前就得了心脑血管病甚至死于心脑血管病的；四是有家族遗传的高胆固醇血症；五是绝经后女性和40岁以上的男性。以下几类人群尤其应该关注血脂水平：一是已患冠心病、脑卒中、外周动脉粥样硬化性疾病的患者；二是吸烟、肥胖、患有高血压或糖尿病的患者；三是家族中有冠心病、脑卒中或外周动脉粥样硬化性疾病病史患者，特别是直系亲属中有人50岁以前就得了心脑血管病甚至死于心脑血管病的；四是有家族遗传的高胆固醇血症；五是绝经后女性和40岁以上的男性。";
        self.topBoardNewsData.updateTime=@"8 分钟前";
        self.topBoardNewsData.relatedNumber =@"13 评论";
        self.topBoardNewsData.streamType =@"通知";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.groupView reloadBoardNews];
        });

        
        //[self requestGoupBoardNews];
    }
    
    //[_currentData removeAllObjects];
}

#pragma mark Laoding indicatior

- (void) laodingIndicator
{
}

#pragma mark -
#pragma mark Network Request Methods

- (void)requestGoupBoardNews
{
    [FlyingHttpTool getGroupBoardNewsForGroupID:self.groupData.gp_id PageNumber:1 Completion:^(NSArray *streamList, NSInteger allRecordCount) {
        
        self.topBoardNewsData = streamList[0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.groupView reloadBoardNews];
        });
    }];
}

- (void)requestMoreGroupStream
{
     if (_currentData.count<_maxNumOfGroupNews)
     {
         _currentLodingIndex++;

         [FlyingHttpTool getGroupStreamForGroupID:self.groupData.gp_id PageNumber:_currentLodingIndex Completion:^(NSArray *streamList, NSInteger allRecordCount) {
             //
             [self.currentData addObjectsFromArray:streamList];
             
             _maxNumOfGroupNews=allRecordCount;
             
             dispatch_async(dispatch_get_main_queue(), ^{

                 [self.groupView.tableView reloadData];
             });

         }];

     }
}

#pragma mark -
#pragma mark Action Methods

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
    
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        // This is the last cell
        [self requestMoreGroupStream];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? (INTERFACE_IS_PAD ? 250 : 125) : (INTERFACE_IS_PAD ? 502 : 251);
}

#pragma mark -
#pragma mark UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return  8;
    //return [self.membersDataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    FlyingMemberCollectionViewCell* cell = (FlyingMemberCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"FlyingMemberCollectionViewCell" forIndexPath:indexPath];
    
    [cell.cellImageView setImage:[UIImage imageNamed:@"Icon"]];
    
    //[cell.cellImageView setImageURL:[NSURL URLWithString:[[self.membersDataSource objectAtIndex:indexPath.row] movieThumbnailPosterImageUrl]]];
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    //[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark FlyingGroupDetailsViewDelegate

- (FlyingStreamData*)getTopBoardNewsData
{
    return self.topBoardNewsData;
}

- (CGFloat) getnavigationBarHeight
{
    return  self.navigationController.navigationBar.frame.size.height;
}

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
        
        if ([detailsGroupView.groupDetailsViewDelegate respondsToSelector:@selector(headerImageViewFinishedLoading:)])
        [detailsGroupView.groupDetailsViewDelegate headerImageViewFinishedLoading:blockImageView];
        
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

- (void)detailsPage:(FlyingGroupDetailsView *)detailsPageView imageViewWasSelected:(UIImageView *)imageView
{
    //
    if ( [self.topBoardNewsData.streamType isEqualToString:@""]) {
        
        //
        NSString *lessonID = self.topBoardNewsData.contentID;
        
        [FlyingHttpTool getLessonForLessonID:lessonID
                                  Completion:^(FlyingPubLessonData *lesson) {
                                      //
                                      FlyingLessonVC * vc=[[FlyingLessonVC alloc] init];
                                      vc.theLesson=lesson;
                                      
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          [self.navigationController pushViewController:vc animated:YES];
                                      });
                                  }];
    }
    else
    {
        //
    }
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
    FlyingDiscoverContent *discoverContent = [[FlyingDiscoverContent alloc] init];
    discoverContent.author= self.groupData.gp_author;
    
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

- (void) addBackFunction
{
    //在一个函数里面（初始化等）里面添加要识别触摸事件的范围
    UISwipeGestureRecognizer *recognizer= [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleSwipeFrom:)];
    
    recognizer.delegate=self;
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

@end
