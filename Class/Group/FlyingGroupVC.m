//
//  FlyingMyGroupsVC.m
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingHomeVC.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"

#import "UIView+Toast.h"

#import "FlyingConversationListVC.h"
#import "FlyingConversationVC.h"

#import "FlyingGroupVC.h"

#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "FlyingDiscoverVC.h"

#import <AFNetworking/AFNetworking.h>
#import "iFlyingAppDelegate.h"

#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>

#import "RCDataBaseManager.h"

#import "UICKeyChainStore.h"
#import "NSString+FlyingExtention.h"

#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"

#import "FlyingContentVC.h"
#import "FlyingContentListVC.h"
#import "FlyingContentCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "shareDefine.h"

#import "FlyingGroupCoverView.h"
#import "FlyingWebViewController.h"

#import "FlyingAddressBookViewController.h"

@interface FlyingGroupVC ()
{
    NSInteger            _maxNumOfContents;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
    
    int                  _lastPosition;
}

@property (strong, nonatomic) UIButton *accessChatbutton;
@property (strong, nonatomic) UIView   *accessChatContainer;


@property (nonatomic, strong) FlyingGroupCoverView *pathCover;

@property (strong, nonatomic) NSMutableArray     *currentData;
@property (strong, nonatomic) UITableView        *groupStreamTableView;
@property (strong, nonatomic) FlyingPubLessonData    *currentFeatueContent;

@end

@implementation FlyingGroupVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    _refresh=NO;
    
    //更新欢迎语言
    self.title = self.groupData.gp_name;
    
    //顶部导航
    UIButton* discoverButton= [[UIButton alloc] initWithFrame:CGRectMake(200, 7, 24, 24)];
    [discoverButton setBackgroundImage:[UIImage imageNamed:@"Discover"] forState:UIControlStateNormal];
    [discoverButton addTarget:self action:@selector(doDiscover) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* discoverButtonItem= [[UIBarButtonItem alloc] initWithCustomView:discoverButton];
    
    UIButton* memberButton= [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 24, 24)];
    [memberButton setBackgroundImage:[UIImage imageNamed:@"People"] forState:UIControlStateNormal];
    [memberButton addTarget:self action:@selector(showMember) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* chatBarButtonItems= [[UIBarButtonItem alloc] initWithCustomView:memberButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:discoverButtonItem,chatBarButtonItems,nil];
    
    //顶部导航
    [self reloadAll];
}

-(void) prepareForChatRoom
{
    if (INTERFACE_IS_PAD) {
        
        return;
    }
    
    if(!self.accessChatbutton)
    {
        CGRect chatButtonFrame=self.view.frame;
        
        CGRect frame=self.view.frame;
        
        chatButtonFrame.size.width  = frame.size.width/8;
        chatButtonFrame.size.height = frame.size.width/8;
        chatButtonFrame.origin.x    = frame.size.width*8/10;
        chatButtonFrame.origin.y    = frame.size.height-frame.size.width/5;

        self.accessChatContainer = [[UIView alloc]  initWithFrame:chatButtonFrame];
        
        self.accessChatbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, chatButtonFrame.size.width, chatButtonFrame.size.height)];
        [self.accessChatbutton setBackgroundImage:[UIImage imageNamed:@"Chat"]
                                          forState:UIControlStateNormal];
        [self.accessChatbutton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];

        [self.accessChatContainer addSubview:self.accessChatbutton];
        [self.view addSubview:self.accessChatContainer];
    }
}

- (void) shakeToShow:(UIView*)aView

{
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = 1.5;// 动画时间
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    // 这三个数字，我只研究了前两个，所以最后一个数字我还是按照它原来写1.0；前两个是控制view的大小的；
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.6, 1.6, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 1.0)]];
    
    animation.values = values;
    
    [aView.layer addAnimation:animation forKey:nil];
}

- (void) doDiscover
{
    FlyingDiscoverVC *discoverContent = [[FlyingDiscoverVC alloc] init];
    discoverContent.domainID = self.groupData.gp_id;
    discoverContent.domainType = BC_Group_Domain;
    discoverContent.shoudLoaingFeature = YES;
    discoverContent.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:discoverContent animated:YES];
}

- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        [self.view makeToast:@"PAD版本暂时不支持聊天功能!！"];
        
        return;
    }
    
    FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
    
    chatService.targetId = self.groupData.gp_id;
    chatService.conversationType = ConversationType_CHATROOM;
    chatService.title = @"公共聊天室";
    chatService.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatService animated:YES];
}

-(void) showMember
{
    FlyingAddressBookViewController * membersVC = [[FlyingAddressBookViewController alloc] init];
    
    membersVC.title = @"群成员";
    membersVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:membersVC animated:YES];
}

- (void) willDismiss
{
}
//////////////////////////////////////////////////////////////
#pragma FlyingGroupCoverViewDelegate Related
//////////////////////////////////////////////////////////////
- (void) touchCover:(FlyingPubLessonData*)lessonPubData
{
    FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
    [contentVC setThePubLesson:lessonPubData];
    contentVC.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:contentVC animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    
    if (!self.groupStreamTableView)
    {
        self.groupStreamTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        UINib *nib = [UINib nibWithNibName:@"FlyingContentCell" bundle: nil];
        [self.groupStreamTableView registerNib:nib  forCellReuseIdentifier:@"FlyingContentCell"];
        
        self.groupStreamTableView.delegate = self;
        self.groupStreamTableView.dataSource = self;
        self.groupStreamTableView.backgroundColor = [UIColor clearColor];
        
        //Add cover view
        int coverHight = CGRectGetWidth(self.view.frame)*9/16;
        _pathCover = [[FlyingGroupCoverView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), coverHight)];
        [_pathCover setBackgroundImage:[UIImage imageNamed:@"Default"]];
        [_pathCover setAvatarImage:[UIImage imageNamed:@"Icon"]];
        
        [FlyingHttpTool getCoverListForDomainID:self.groupData.gp_id
                                     DomainType:BC_Group_Domain
                                     PageNumber:1
                                  Completion:^(NSArray *lessonList, NSInteger allRecordCount) {
                                      
                                      //
                                      if(lessonList.count>0)
                                      {
                                          self.currentFeatueContent =lessonList[0];
                                          [_pathCover settingWithContentData:self.currentFeatueContent];
                                      }
                                  }];
        
        self.groupStreamTableView.tableHeaderView = self.pathCover;
        [self.view addSubview:_groupStreamTableView];

        __weak FlyingGroupVC *wself = self;
        [_pathCover setHandleRefreshEvent:^{

            [wself reloadAll];
        }];
        
        [_pathCover setHandleTapBackgroundImageEvent:^{
            
            if ([wself.currentFeatueContent.contentType isEqualToString:KContentTypePageWeb] ) {
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
                [webpage setWebURL:wself.currentFeatueContent.contentURL];
                [webpage setLessonID:wself.currentFeatueContent.lessonID];
                
                [wself.navigationController pushViewController:webpage animated:YES];
            }
            else
            {
                FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
                [contentVC setThePubLesson:wself.currentFeatueContent];
                
                [wself.navigationController pushViewController:contentVC animated:YES];
            }
        }];

        
        _currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfContents=NSIntegerMax;
    }
    else
    {
        [_currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfContents=NSIntegerMax;
    }
    
    //Test
    self.currentFeatueContent = [[FlyingPubLessonData alloc] init];
    self.currentFeatueContent.title=@"关于组团游学哈佛科本科教育的紧急通知";
    self.currentFeatueContent.desc =@"1，为了各团队更加熟悉云平台的使用和视频患教项目组更好的执行项目，希望由供应商做一次后台全面的使用说明及注意事项；总平台是服务于所有项目，注册的医生会不断的增加，需要增加筛选功能；审核医生信息的总平台，各项目对于医生有不同的要求，需要增加总平台的功能";
    [_pathCover settingWithContentData:self.currentFeatueContent];
    
    //Test End

    [self prepareForChatRoom];

    [self loadMore];
}



#pragma mark - scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_pathCover scrollViewDidScroll:scrollView];
    
    int currentPostion = scrollView.contentOffset.y;
    if (currentPostion - _lastPosition > 25) {
        _lastPosition = currentPostion;
    }
    else if (_lastPosition - currentPostion > 25)
    {
        _lastPosition = currentPostion;
        
        [self shakeToShow:self.accessChatContainer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_pathCover scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_pathCover scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_pathCover scrollViewWillBeginDragging:scrollView];
}

- (void)loadMore
{
    if (_currentData.count<_maxNumOfContents)
    {
        _currentLodingIndex++;
        
        [FlyingHttpTool getLessonListForDomainID:self.groupData.gp_id
                                      DomainType:BC_Group_Domain
                                   PageNumber:_currentLodingIndex
                            lessonConcentType:nil
                                 DownloadType:nil
                                          Tag:nil
                                OnlyRecommend:NO
                                   Completion:^(NSArray *lessonList, NSInteger allRecordCount) {
                                       //
                                       if (lessonList) {
                                           [self.currentData addObjectsFromArray:lessonList];
                                       }
                                       
                                       _maxNumOfContents=allRecordCount;
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self finishLoadingData];
                                       });
                                   }];
    }
}

-(void) finishLoadingData
{
    [self.pathCover stopRefresh];

    //更新界面
    if (_currentData.count>0)
    {
        [self.groupStreamTableView reloadData];
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
    if (self.currentData.count && _currentData.count<_maxNumOfContents)
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
    if (indexPath.section == 0)
    {
        // 普通Cell
        FlyingContentCell* cell = [tableView dequeueReusableCellWithIdentifier:CONTENT_CELL_IDENTIFIER];
        
        if (!cell) {
            cell = [FlyingContentCell contentCell];
        }
        
        [self configureCell:cell atIndexPath:indexPath];

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
        return [tableView fd_heightForCellWithIdentifier:@"FlyingContentCell" configuration:^(id cell) {
            
            [self configureCell:cell atIndexPath:indexPath];
        }];
    
    }
    
    // 加载更多
    return 44;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FlyingPubLessonData *contentData = self.currentData[indexPath.row];
    [(FlyingContentCell*)cell settingWithContentData:contentData];
}
//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator startAnimating];
    
    // 加载下一页
    [self loadMore];
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentData.count!=0) {
        
        FlyingPubLessonData* lessonPubData = [_currentData objectAtIndex:indexPath.row];
        
        if ([lessonPubData.contentType isEqualToString:KContentTypePageWeb] ) {
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
            [webpage setWebURL:lessonPubData.contentURL];
            [webpage setLessonID:lessonPubData.lessonID];
            
            [self.navigationController pushViewController:webpage animated:YES];
        }
        else
        {
            FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
            [contentVC setThePubLesson:lessonPubData];
            
            [self.navigationController pushViewController:contentVC animated:YES];
        }
    }
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
    [super viewDidDisappear:animated];
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
