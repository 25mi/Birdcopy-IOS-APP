//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

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

#import "FlyingAddressBookVC.h"

@interface FlyingGroupVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfContents;
    NSInteger            _currentLodingIndex;
    
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

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.groupData forKey:@"self.groupData"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.groupData = [coder decodeObjectForKey:@"self.groupData"];
    
    if (self.groupData) {
        
        [self reloadAll];
    }
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    if (self.groupData) {
        
        [self reloadAll];
    }
}

-(void) prepareForChatRoom
{
    if(!self.accessChatbutton)
    {
        CGRect chatButtonFrame=self.view.frame;
        
        CGRect frame=self.view.frame;
        
        chatButtonFrame.origin.x    = frame.size.width*8/10;
        chatButtonFrame.origin.y    =frame.size.height-frame.size.width/8-frame.size.width*3/40;
        chatButtonFrame.size.width  = frame.size.width/8;
        chatButtonFrame.size.height = frame.size.width/8;
        
        self.accessChatContainer = [[UIView alloc]  initWithFrame:chatButtonFrame];
        
        self.accessChatbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, chatButtonFrame.size.width, chatButtonFrame.size.height)];
        [self.accessChatbutton setBackgroundImage:[UIImage imageNamed:@"chat"]
                                          forState:UIControlStateNormal];
        [self.accessChatbutton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
        [self.accessChatContainer addSubview:self.accessChatbutton];

        [self.view  addSubview:self.accessChatContainer];
        [self.view bringSubviewToFront:self.accessChatContainer];
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
    
    if (self.groupData) {

        FlyingDiscoverVC *discoverContent = [[FlyingDiscoverVC alloc] init];
        
        discoverContent.domainID = self.groupData.gp_id;
        discoverContent.domainType = BC_Domain_Group;
        
        discoverContent.shoudLoaingFeature = YES;
        
        [self.navigationController pushViewController:discoverContent animated:YES];
    }
}

- (void) doChat
{
    
    if (self.groupData) {

        FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
        
        chatService.domainID   = self.groupData.gp_id;
        chatService.domainType = BC_Domain_Group;
        
        chatService.targetId = self.groupData.gp_id;
        chatService.conversationType = ConversationType_CHATROOM;
        chatService.title =self.groupData.gp_name;
        [self.navigationController pushViewController:chatService animated:YES];
    }
}

-(void) showMember
{
    
    if (self.groupData) {
    
        FlyingAddressBookVC * membersVC=[[FlyingAddressBookVC alloc] init];
        
        membersVC.domainID = self.groupData.gp_id;
        membersVC.domainType = BC_Domain_Group;
        
        membersVC.title = NSLocalizedString(@"Memberships", nil);
        
        [self.navigationController pushViewController:membersVC animated:YES];
    }
}

- (void) willDismiss
{
}
//////////////////////////////////////////////////////////////
#pragma FlyingGroupCoverViewDelegate Related
//////////////////////////////////////////////////////////////
- (void) touchCover:(FlyingPubLessonData*)lessonPubData
{
    
    if (self.groupData) {
        
        FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
        contentVC.domainID = self.groupData.gp_id;
        contentVC.domainType = BC_Domain_Group;
        
        [contentVC setThePubLesson:lessonPubData];
        
        [self.navigationController pushViewController:contentVC animated:YES];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    self.domainID = self.groupData.gp_id;
    self.domainType = BC_Domain_Group;
    
    //更新欢迎语言
    self.title = self.groupData.gp_name;
    
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
        [_pathCover setBackgroundImageUrlString:self.groupData.cover];
        [_pathCover setAvatarImageURL:self.groupData.logo];
                        
        [FlyingHttpTool getCoverListForDomainID:self.groupData.gp_id
                                     DomainType:BC_Domain_Group
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

        self.groupStreamTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.groupStreamTableView.frame.size.width, 1)];

        self.groupStreamTableView.restorationIdentifier = self.restorationIdentifier;

        [self.view addSubview:self.groupStreamTableView];

        __weak FlyingGroupVC *wself = self;
        [_pathCover setHandleRefreshEvent:^{

            [wself reloadAll];
        }];
        
        [_pathCover setHandleTapBackgroundImageEvent:^{
            
            if ([wself.currentFeatueContent.contentType isEqualToString:KContentTypePageWeb] ) {
                
                FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
                webVC.domainID = wself.domainID;
                webVC.domainType = wself.domainType;
                
                [webVC setThePubLesson:wself.currentFeatueContent];
                
                [wself.navigationController pushViewController:webVC animated:YES];
            }
            else
            {
                FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
                contentVC.domainID = wself.domainID;
                contentVC.domainType = wself.domainType;
                
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
                                      DomainType:BC_Domain_Group
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
    
    [self prepareForChatRoom];
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
        FlyingContentCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentCell"];
        
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
        return [tableView fd_heightForCellWithIdentifier:@"FlyingContentCell"
                                        cacheByIndexPath:indexPath
                                           configuration:^(id cell) {
    
            [self configureCell:cell atIndexPath:indexPath];
        }];
    
    }
    
    // 加载更多
    return 44;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<self.currentData.count) {

        FlyingPubLessonData *contentData = self.currentData[indexPath.row];
        [(FlyingContentCell*)cell settingWithContentData:contentData];
    }
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
            
            FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
            webVC.domainID = self.domainID;
            webVC.domainType = self.domainType;
            
            [webVC setThePubLesson:lessonPubData];
            
            [self.navigationController pushViewController:webVC animated:YES];
        }
        else
        {
            FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
            
            contentVC.domainID = self.groupData.gp_id;
            contentVC.domainType = BC_Domain_Group;
            
            [contentVC setThePubLesson:lessonPubData];
            
            [self.navigationController pushViewController:contentVC animated:YES];
        }
    }
}

@end
