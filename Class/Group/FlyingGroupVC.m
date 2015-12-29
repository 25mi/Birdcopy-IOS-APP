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

#import "iFlyingAppDelegate.h"
#import "RESideMenu.h"

#import "FlyingCalendarVC.h"

#import "FlyingDiscoverContent.h"

#import "FlyingContentVC.h"
#import <AFNetworking/AFNetworking.h>

#import "FlyingCommentVC.h"

#import <RongIMKit/RongIMKit.h>
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "RCDataBaseManager.h"
#import "NSString+FlyingExtention.h"

#import "FlyingNavigationController.h"
#import "FlyingConversationVC.h"
#import "FlyingDataManager.h"

@interface FlyingGroupVC ()<UIGestureRecognizerDelegate>
{
    NSInteger            _maxNumOfGroupStreams;
    NSInteger            _currentLodingIndex;
    
    NSInteger           kLoadMoreIndicatorTag;
    
    BOOL                 _refresh;
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
    UIButton* discoverButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [discoverButton setBackgroundImage:[UIImage imageNamed:@"Discover"] forState:UIControlStateNormal];
    [discoverButton addTarget:self action:@selector(doDiscover) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* discoverButtonItem= [[UIBarButtonItem alloc] initWithCustomView:discoverButton];
    
    UIButton* calendarButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [calendarButton setBackgroundImage:[UIImage imageNamed:@"Calendar"] forState:UIControlStateNormal];
    [calendarButton addTarget:self action:@selector(doCalendar) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* calendarBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:calendarButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:calendarBarButtonItem,discoverButtonItem,nil];
    
    self.title=self.groupData.gp_name;
    
    [self reloadAll];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.groupView.tableView.contentOffset.y> CGRectGetHeight(self.groupView.tableView.tableHeaderView.frame))
    {
        [appDelegate setnavigationBarWithClearStyle:NO];
    }
    else
    {
        [appDelegate setnavigationBarWithClearStyle:YES];
    }
    
    [self.groupView enableKVO:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.groupView enableKVO:NO];
    
    //恢复默认状态
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setnavigationBarWithClearStyle:NO];
}

- (void) willDismiss
{
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////
- (void)reloadAll
{
    if(!self.groupView)
    {
        self.groupView=[[FlyingGroupDetailsView alloc] initWithFrame:self.view.frame];
        
        self.groupView.tableViewDataSource = self;
        self.groupView.tableViewDelegate = self;
        self.groupView.groupDetailsViewDelegate = self;
        self.groupView.tableViewSeparatorColor = [UIColor clearColor];
        [self.view addSubview:self.groupView];
        
        _currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfGroupStreams=NSIntegerMax;
    }
    else
    {
        [_currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfGroupStreams=NSIntegerMax;
    }
    
    [self prepareForChatRoom];
    
    //Test only begin
    _currentData =[NSMutableArray arrayWithObjects:@"1",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",@"2",nil];
    
    _currentLodingIndex=1;
    _maxNumOfGroupStreams=_currentData.count;
    
    [self.groupView.tableView reloadData];

    //Test only
    self.topBoardNewsData = [[FlyingStreamData alloc] init];
    self.topBoardNewsData.title=@"周一课程改期通知";
    self.topBoardNewsData.contentSummary=@"以下几类人群尤其应该关注血脂水平：一是已患冠心病、脑卒中、外周动脉粥样硬化性疾病的患者；二是吸烟、肥胖、患有高血压或糖尿病的患者；三是家族中有冠心病、脑卒中或外周动脉粥样硬化性疾病病史患者，特别是直系亲属中有人50岁以前就得了心脑血管病甚至死于心脑血管病的；四是有家族遗传的高胆固醇血症；五是绝经后女性和40岁以上的男性。以下几类人群尤其应该关注血脂水平：一是已患冠心病、脑卒中、外周动脉粥样硬化性疾病的患者；二是吸烟、肥胖、患有高血压或糖尿病的患者；三是家族中有冠心病、脑卒中或外周动脉粥样硬化性疾病病史患者，特别是直系亲属中有人50岁以前就得了心脑血管病甚至死于心脑血管病的；四是有家族遗传的高胆固醇血症；五是绝经后女性和40岁以上的男性。";
    self.topBoardNewsData.updateTime=@"8 分钟前";
    self.topBoardNewsData.contentType =@"通知";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.groupView reloadBoardNews];
    });
    
    [self finishLoadingData];
    
    //Test only end

    //[self requestMoreGroupStream];
    //[self requestGoupBoardNews];
}

-(void) prepareForChatRoom
{
    if (INTERFACE_IS_PAD) {
        
        return;
    }
    
    if(!self.groupAccessbutton)
    {
        CGRect chatButtonFrame=self.view.frame;
        
        CGRect frame=self.view.frame;
        
        chatButtonFrame.size.width  = frame.size.width/8;
        chatButtonFrame.size.height = frame.size.width/8;
        chatButtonFrame.origin.x    = frame.size.width*8/10;
        chatButtonFrame.origin.y    = frame.size.height-frame.size.width/5;
        
        self.groupAccessbutton = [[UIButton alloc] initWithFrame:chatButtonFrame];
        [self.groupAccessbutton setBackgroundImage:[UIImage imageNamed:@"chat"]
                                       forState:UIControlStateNormal];
        [self.groupAccessbutton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.groupAccessbutton];
        //self.groupView.groupAccessView= self.groupAccessbutton;
    }
}

- (void)refreshNow
{
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        
        _refresh=YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self reloadAll];
        });
    }
    else
    {
        [self.groupView setRefreshState:RefreshStateNormal];
        
        _refresh=NO;

        [self.view makeToast:@"请联网后再试一下!" duration:3 position:CSToastPositionCenter];
    }
}

- (void)requestGoupBoardNews
{
    [FlyingHttpTool getGroupBoardNewsForGroupID:self.groupData.gp_id PageNumber:1 Completion:^(NSArray *streamList, NSInteger allRecordCount) {
        
        if (streamList.count>0) {

            self.topBoardNewsData = streamList[0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.groupView reloadBoardNews];
            });
        }
    }];
}

- (void)requestMoreGroupStream
{
     if (_currentData.count<_maxNumOfGroupStreams)
     {
         _currentLodingIndex++;

         [FlyingHttpTool getGroupStreamForGroupID:self.groupData.gp_id PageNumber:_currentLodingIndex Completion:^(NSArray *streamList, NSInteger allRecordCount) {
             //
             [self.currentData addObjectsFromArray:streamList];
             
             _maxNumOfGroupStreams=allRecordCount;
             
             dispatch_async(dispatch_get_main_queue(), ^{

                 [self finishLoadingData];
             });

         }];
     }
}
-(void) finishLoadingData
{
    //更新下拉刷新
    if(_refresh)
    {
        [self.groupView setRefreshState:RefreshStateNormal];
        
        _refresh=NO;
    }
    
    //更新界面
    if (_currentData.count>0)
    {
        [self.groupView.tableView reloadData];
    }
    else
    {
        [self.view makeToast:@"请联网后再试一下!" duration:3 position:CSToastPositionCenter];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentData.count && _currentData.count<_maxNumOfGroupStreams)
    {
        return 2; // 增加一个加载更多
    }
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.currentData count];
    }
    
    // 加载更多
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // A much nicer way to deal with this would be to extract this code to a factory class, that would take care of building the cells.
    if (indexPath.section == 0)
    {
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

        FlyingStreamData* streamData = [_currentData objectAtIndex:indexPath.row];
        cell.delegate =self;
        [cell loadingStreamCellData:streamData];
        
        return cell;
    }
    
    // 加载更多
    static NSString *CellIdentifierLoadMore = @"CellIdentifierLoadMore";
    
    UITableViewCell *loadCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLoadMore];
    if (!loadCell)
    {
        loadCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLoadMore];
        loadCell.backgroundColor = [UIColor clearColor];
        loadCell.contentView.backgroundColor = [UIColor clearColor];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.tag = kLoadMoreIndicatorTag;
        indicator.hidesWhenStopped = YES;
        indicator.center =loadCell.center;
        indicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|
        UIViewAutoresizingFlexibleRightMargin|
        UIViewAutoresizingFlexibleTopMargin|
        UIViewAutoresizingFlexibleBottomMargin;
        [loadCell.contentView addSubview:indicator];
    }
    
    return loadCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        // 普通Cell的高度
        return (indexPath.row % 2) ? (INTERFACE_IS_PAD ? 250 : 125) : (INTERFACE_IS_PAD ? 502 : 251);
    }
    
    // 加载更多
    return 44;
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.contentView.backgroundColor = [UIColor clearColor];
    if (indexPath.section == 0)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator startAnimating];
    
    // 加载下一页
    [self requestMoreGroupStream];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator stopAnimating];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    FlyingGroupData* groupData = [_currentData objectAtIndex:indexPath.row];
    
    FlyingGroupVC *groupVC = [FlyingGroupVC new];
    groupVC.groupData=groupData;
    
    [self.navigationController pushViewController:groupVC animated:YES];
     */
}

//////////////////////////////////////////////////////////////
#pragma mark - FlyingGroupDetailsViewDelegate
//////////////////////////////////////////////////////////////
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
    if ( [self.topBoardNewsData.contentType isEqualToString:@""]) {
        
        //
        NSString *lessonID = self.topBoardNewsData.contentID;
        
        [FlyingHttpTool getLessonForLessonID:lessonID
                                  Completion:^(FlyingPubLessonData *lesson) {
                                      //
                                      FlyingContentVC * vc=[[FlyingContentVC alloc] init];
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
#pragma cell related
//////////////////////////////////////////////////////////////

- (void)commentCountButtonPressed:(FlyingStreamData*)streamData
{
    FlyingCommentVC *commentVC =[[FlyingCommentVC alloc] init];
    
    //commentVC.contentID=streamData.contentID;
    //commentVC.contentType=streamData.contentType;
    
    //Test only
    commentVC.contentID=@"testid";
    commentVC.contentType=KContentTypeVideo;
    
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)likeCountButtonPressed:(FlyingStreamData*)streamData
{

}

- (void)profileImageViewPressed:(FlyingStreamData*)streamData
{

    NSString *openID = [FlyingDataManager getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    if ([openID isEqualToString:streamData.openID])
    {
    }
    else
    {
        FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
        
        NSString* userID = streamData.openID;
        
        RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:userID];
        chatService.targetId = userID;
        chatService.conversationType = ConversationType_PRIVATE;
        chatService.title = userInfo.name;
        [self.navigationController pushViewController:chatService animated:YES];
    }
}

- (void)coverImageViewPressed:(FlyingStreamData*)streamData
{


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
    if ([self.navigationController.viewControllers count]==1) {
        
        [self showMenu];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) doCalendar
{
    FlyingCalendarVC *calendarVC =[[FlyingCalendarVC alloc] init];
    calendarVC.groupData=self.groupData;
    
    [self.navigationController pushViewController:calendarVC animated:YES];
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
    
    RCBaseViewController  * chatVC=[[FlyingConversationVC alloc] init];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
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
        
        [self dismissNavigation];
    }
}

@end
