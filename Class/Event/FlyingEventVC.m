//
//  FlyingEventVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/23/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingEventVC.h"

#import "KMSimilarMoviesCollectionViewCell.h"
#import "UIImageView+WebCache.h"

#import "FlyingHttpTool.h"
#import "FlyingCalendarEvent.h"

#import "KMMovieDetailsSimilarMoviesCell.h"
#import "iFlyingAppDelegate.h"
#import "StoryBoardUtilities.h"

#import "FlyingCommentVC.h"

#import "FlyingEventTitleCell.h"
#import "FlyingEventAuthorCell.h"
#import "FlyingEventScheduleCell.h"
#import "FlyingEventLocationCell.h"
#import "FlyingEventPriceCell.h"
#import "UIImage+localFile.h"

@interface FlyingEventVC ()

@property (nonatomic, strong) NSMutableArray* membersDataSource;

@property (nonatomic, strong) KMNetworkLoadingViewController* networkLoadingViewController;

@property (nonatomic, strong) UITableView *eventTableView;

@property (nonatomic, strong) UIImageView *tableHeaderImageView;

@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *voteButton;

@end

@implementation FlyingEventVC

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    [self addBackFunction];
    
    //更新欢迎语言
    self.title =@"活动详情";
    
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
    
    
    image= [UIImage imageNamed:@"share"];
    frame= CGRectMake(0, 0, 28, 28);
    UIButton* shareButton= [[UIButton alloc] initWithFrame:frame];
    [shareButton setBackgroundImage:image forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* shareBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    self.navigationItem.rightBarButtonItem = shareBarButtonItem;

    
    [self reloadAll];
}

#pragma mark -
#pragma mark Setup

- (void)reloadAll
{
    if (!self.eventTableView)
    {
        _eventTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _eventTableView.delegate = self;
        _eventTableView.dataSource = self;
        _eventTableView.backgroundColor = [UIColor clearColor];
        _eventTableView.separatorColor = [UIColor clearColor];
        
        [self.view addSubview:_eventTableView];
    }
    
    [self requestEventDetails];
}

#pragma mark -
#pragma mark Network Request Methods

- (void)requestEventDetails
{
    if(!self.networkLoadingViewController)
    {
        KMNetworkLoadingViewController* loadingVC = (KMNetworkLoadingViewController*)[StoryBoardUtilities viewControllerForStoryboardName:@"KMNetworkLoadingViewController" class:[KMNetworkLoadingViewController class]];

        self.networkLoadingViewController= loadingVC;
        self.networkLoadingViewController.delegate = self;
    }
    
    [self.navigationController presentViewController:self.networkLoadingViewController animated:YES completion:^{
        //
        
        self.eventData.eventID=@"sfsfsf";
        
        [FlyingHttpTool getEventDetailsForEventID:self.eventData.eventID Completion:^(FlyingCalendarEvent *event) {
            
            if (event != nil)
                [self processEventDetailsData:event];
            else
                [self.networkLoadingViewController showErrorView];
        }];
    }];
}

#pragma mark -
#pragma mark Fetched Data Processing

- (void)processEventDetailsData:(FlyingCalendarEvent*)eventData
{
    if (!eventData)
    {
        [self.networkLoadingViewController showNoContentView];
    }
    else
    {
        // Test
        eventData.coverURL=@"http://mmbiz.qpic.cn/mmbiz/v6uP0lGcBZ7wII3OBibpLY53YQVribKGrgYEFmNkiaVXcmGRM6kicIYIWyGuwG1v8fW4r7QqSIIFO83hBtZEYp0l6Q/640?wx_fmt=jpeg&wxfrom=5";
        self.membersDataSource=[[NSMutableArray alloc] initWithObjects:@"123", nil];
        // Test

        self.eventData = eventData;
        
        [self setupEventHeader];
        [self.eventTableView reloadData];
        [self setupCommmentAndVote];
        
        [self hideLoadingView];
    }
}

-(void) setupEventHeader
{
    CGRect tableHeaderViewFrame = CGRectMake(0.0, 0.0, self.eventTableView.frame.size.width, self.eventTableView.frame.size.width*9/16);
    UIImageView *tableHeaderImageView = [[UIImageView alloc] initWithFrame:tableHeaderViewFrame];
    
    [tableHeaderImageView sd_setImageWithURL:[NSURL URLWithString:self.eventData.coverURL]];
    
    self.eventTableView.tableHeaderView = tableHeaderImageView;
}

-(void) setupCommmentAndVote
{
    //comment button
    CGRect commentButtonFrame;
    CGRect frame=self.view.frame;
    
    commentButtonFrame.size.width  = frame.size.width/2;
    commentButtonFrame.size.height = frame.size.width/8;
    commentButtonFrame.origin.x    = 0;
    commentButtonFrame.origin.y    = frame.size.height-commentButtonFrame.size.height;
    
    self.commentButton = [[UIButton alloc] initWithFrame:commentButtonFrame];
    self.commentButton.backgroundColor=[UIColor colorWithWhite:0.94 alpha:1.000];
    [self.commentButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [self.commentButton setTitle:@"评论(100)" forState: UIControlStateNormal];
    self.commentButton.titleLabel.font= [UIFont systemFontOfSize:(INTERFACE_IS_PAD ? 28.0f : 14.0f)];

    [self.commentButton addTarget:self action:@selector(doComment) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.commentButton];
    
    //vote button
    CGRect voteButtonFrame=commentButtonFrame;
    voteButtonFrame.origin.x    = commentButtonFrame.size.width;
    
    self.voteButton = [[UIButton alloc] initWithFrame:voteButtonFrame];
    self.voteButton.backgroundColor=[UIColor redColor];
    [self.voteButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [self.voteButton setTitle:@"我要参与(10)" forState: UIControlStateNormal];
    self.voteButton.titleLabel.font= [UIFont systemFontOfSize:(INTERFACE_IS_PAD ? 28.0f : 14.0f)];

    [self.voteButton addTarget:self action:@selector(doVote) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.voteButton];
}

#pragma mark -
#pragma mark Action Methods

-(void)doComment
{
    FlyingCommentVC *commentVC =[[FlyingCommentVC alloc] init];
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

-(void)doVote
{
}


- (void)viewAllSimilarMoviesButtonPressed:(id)sender
{
}

#pragma mark -
#pragma mark UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would take care of building the cells.
    UITableViewCell* cell = nil;
    
    switch (indexPath.row) {
        case 0:
        {
            FlyingEventTitleCell *eventTitleCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingEventTitleCell"];
            
            if(eventTitleCell == nil)
                eventTitleCell = [FlyingEventTitleCell eventTitleCell];
            eventTitleCell.titleLabel.text=@"中国移动互联网＋教育2015年会";
            
            cell = eventTitleCell;

            break;
        }
        case 1:
        {
            FlyingEventScheduleCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingEventScheduleCell"];
            
            if(descriptionCell == nil)
                descriptionCell = [FlyingEventScheduleCell eventScheduleCell];
            
            descriptionCell.descriptionLabel.text =@"09/27 17:00 - 09/27 19:00";
            [descriptionCell.iconImageView setImage:[UIImage imageNamed:@"Calendar"]];

            
            cell = descriptionCell;
        }
            break;
            
        case 2:
        {
            FlyingEventLocationCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingEventLocationCell"];
            
            if(descriptionCell == nil)
                descriptionCell = [FlyingEventLocationCell eventLocationCell];
            
            descriptionCell.descriptionLabel.text =@"昌平回龙观青年汇";
            [descriptionCell.iconImageView setImage:[UIImage imageNamed:@"Map"]];
            
            cell = descriptionCell;
            
            break;
        }

        case 3:
        {
            FlyingEventPriceCell *descriptionCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingEventPriceCell"];
            
            if(descriptionCell == nil)
                descriptionCell = [FlyingEventPriceCell eventPriceCell];
            
            descriptionCell.descriptionLabel.text =@"234元";
            [descriptionCell.iconImageView setImage:[UIImage imageNamed:@"Price"]];
            
            cell = descriptionCell;
            
            break;
        }

        case 4:
        {
            KMMovieDetailsSimilarMoviesCell *contributionCell = [tableView dequeueReusableCellWithIdentifier:@"KMMovieDetailsSimilarMoviesCell"];
            
            if(contributionCell == nil)
                contributionCell = [KMMovieDetailsSimilarMoviesCell movieDetailsSimilarMoviesCell];
            
            [contributionCell.viewAllSimilarMoviesButton addTarget:self action:@selector(viewAllSimilarMoviesButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = contributionCell;
            
            break;
        }
        case 5:
        {
            FlyingEventAuthorCell *detailsCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingEventAuthorCell"];
            
            if(detailsCell == nil)
                detailsCell = [FlyingEventAuthorCell eventAuthorCell];
            
            [detailsCell.cellImageView sd_setImageWithURL:[NSURL URLWithString:@"http://g.hiphotos.baidu.com/news/crop%3D116%2C0%2C1429%2C857%3Bw%3D638/sign=9889a28b2e381f308a56d7e994307d3e/b03533fa828ba61eae75589c4734970a314e59ed.jpg"]];
            detailsCell.usernameLabel.text = @"美国心理学专家";
            detailsCell.userInfoLabel.text = @"这个是啥事撒 是发生发撒发生fads风的撒风大水";
            
            cell = detailsCell;

            
            break;
        }
        default:
            break;
    }
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
    
    if ([cell isKindOfClass:[KMMovieDetailsSimilarMoviesCell class]])
    {
        KMMovieDetailsSimilarMoviesCell* similarMovieCell = (KMMovieDetailsSimilarMoviesCell*)cell;
        
        [similarMovieCell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would return the cells' height.
    CGFloat height = 0;
    
    switch (indexPath.row) {
            
        case 0:
        {
            height = 44;
            break;
        }
        case 1:
        {
            height = 60;
            break;
        }
        case 2:
        {
            height = 60;
            break;
        }
        case 3:
        {
            height = 60;
            break;
        }
        case 4:
        {
            if ([self.membersDataSource count] == 0)
                
                height = 0;
            
            else
                
                height = 80;
            
            break;
        }
        case 5:
        {
            height = 60;
            break;
        }
            
        default:
        {
            height = 100;
            break;
        }
    }
    
    return height;
}

#pragma mark -
#pragma mark UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    
    return 16;
    
    return [self.membersDataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    KMSimilarMoviesCollectionViewCell* cell = (KMSimilarMoviesCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"KMSimilarMoviesCollectionViewCell" forIndexPath:indexPath];
    
    [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:@"http://birdenglish.com/img/logo.png"]];
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
}


#pragma mark -
#pragma mark KMNetworkLoadingViewController Methods

- (void)hideLoadingView
{
    [self.networkLoadingViewController dismissViewControllerAnimated:YES completion:^{
        //
        self.networkLoadingViewController = nil;
    }];
}

#pragma mark -
#pragma mark KMNetworkLoadingViewDelegate

-(void)retryRequest;
{
    [self requestEventDetails];
}


//////////////////////////////////////////////////////////////
#pragma only portart events
//////////////////////////////////////////////////////////////
-(void) dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark socail Related
//////////////////////////////////////////////////////////////

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) doReset
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate resetnavigationBarWithDefaultStyle];
}

- (void) doShare
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *webURL= @"";
    NSString *description= @"";
    
    [appDelegate shareImageURL:self.eventData.coverURL
                       withURL:webURL
                         Title:self.eventData.title
                          Text:description
                         Image:[self.tableHeaderImageView.image makeThumbnailOfSize:CGSizeMake(90, 120)]];
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
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

@end
