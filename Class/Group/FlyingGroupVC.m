//
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"
#import <CRToastManager.h>
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
#import "FlyingWebViewController.h"
#import "FlyingAddressBookVC.h"
#import "FlyingSoundPlayer.h"
#import "FlyingGroupMembersCell.h"

@interface FlyingGroupVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfContents;
    NSInteger            _currentLodingIndex;
}

@property (nonatomic, strong) FlyingGroupBoard  *groupBoard;
@property (strong, nonatomic) UITableView        *groupStreamTableView;
@property (strong, nonatomic) FlyingPubLessonData    *currentFeatueContent;

@property (strong, nonatomic) FlyingGroupMemberStartView  *memberStartView;

@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@property (atomic,assign)    BOOL refresh;

@property (atomic,assign)    BOOL restorationState;
@property (atomic,assign)    CGRect restoreFrame;

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
    [coder encodeCGRect:self.groupStreamTableView.frame forKey:@"self.groupStreamTableView.frame"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.groupData = [coder decodeObjectForKey:@"self.groupData"];
    self.restoreFrame = [coder decodeCGRectForKey:@"self.groupStreamTableView.frame"];
    
    if (self.groupData)
    {
        self.restorationState = YES;
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
    UIButton* memberButton= [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 24, 24)];
    [memberButton setBackgroundImage:[UIImage imageNamed:@"People"] forState:UIControlStateNormal];
    [memberButton addTarget:self action:@selector(touchTopRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* chatBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:memberButton];
    
    self.navigationItem.rightBarButtonItem = chatBarButtonItem;
    
    if (self.groupData)
    {
        [self reloadAll];
    }
    
    [self setupRefreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //实时检查会员资格问题
    [FlyingHttpTool checkGroupMemberInfoForAccount:[FlyingDataManager getOpenUDID]
                                           GroupID:self.groupData.gp_id
                                        Completion:^(FlyingUserRightData *userRightData)
     {
         [self showMemberState:userRightData];
     }];
}

-(void) showMemberState:(FlyingUserRightData*)userRightData
{
    if(!self.memberStartView)
    {
        CGRect memberStartFrame=self.view.frame;
        CGRect frame=self.view.frame;
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSInteger height = appDelegate.getTabBarController.tabBar.frame.size.height;
        
        memberStartFrame.size.width  = frame.size.width;
        memberStartFrame.size.height = height;
        memberStartFrame.origin.x    = 0;
        memberStartFrame.origin.y    = CGRectGetHeight(self.groupStreamTableView.frame)-height;

        self.memberStartView = [[FlyingGroupMemberStartView alloc]  initWithFrame:memberStartFrame];
        self.memberStartView.delegate = self;
        
        [self.view addSubview:self.memberStartView];
    }
    
    [self.memberStartView setUserGroupRight:userRightData];
    
    [self.view bringSubviewToFront:self.memberStartView];
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

- (void) doFavor
{
    if (self.groupData) {
        
        FlyingDiscoverVC *discoverContent = [[FlyingDiscoverVC alloc] init];
        
        discoverContent.domainID = self.groupData.gp_id;
        discoverContent.domainType = BC_Domain_Group;
        
        [self.navigationController pushViewController:discoverContent animated:YES];
    }
}

-(void) doMembers
{
    if (self.groupData) {
    
        FlyingAddressBookVC * membersVC=[[FlyingAddressBookVC alloc] init];
        
        membersVC.domainID = self.groupData.gp_id;
        membersVC.domainType = BC_Domain_Group;
        
        membersVC.title = self.groupData.gp_name;
        
        [self.navigationController pushViewController:membersVC animated:YES];
    }
}

- (void) willDismiss
{
}
//////////////////////////////////////////////////////////////
#pragma FlyingGroupBoardDelegate Related
//////////////////////////////////////////////////////////////
- (void) touchBoardNews
{
    if ([self.currentFeatueContent.contentType isEqualToString:KContentTypePageWeb] ) {
        
        FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
        webVC.domainID = self.groupData.gp_id;
        webVC.domainType = BC_Domain_Group;
        
        [webVC setThePubLesson:self.currentFeatueContent];
        
        [self.navigationController pushViewController:webVC animated:YES];
    }
    else
    {
        FlyingContentVC *contentVC = [[FlyingContentVC alloc] init];
        contentVC.domainID =self.groupData.gp_id;
        contentVC.domainType = BC_Domain_Group;
        
        [contentVC setThePubLesson:self.currentFeatueContent];
        
        [self.navigationController pushViewController:contentVC animated:YES];
    }
}

-(void)touchGroupLogo
{
    NSString * message = [NSString stringWithFormat:NSLocalizedString(@"I need help in the group:%@", nil),self.groupData.gp_name];
    
    [FlyingGroupVC contactAdminWithGroupID:self.groupData.gp_id
                                   message:message
                                      inVC:self];
}


//////////////////////////////////////////////////////////////
#pragma FlyingGroupMemberStartViewDelegate Related
//////////////////////////////////////////////////////////////
- (void)touchLeft
{
    [FlyingGroupVC doMemberRightInVC:self
                             GroupID:self.groupData.gp_id
                          Completion:^(FlyingUserRightData *userRightData) {
                              //
                              [self doFavor];
                          }];
}

- (void)touchRight
{
    [FlyingGroupVC doMemberRightInVC:self
                             GroupID:self.groupData.gp_id
                          Completion:^(FlyingUserRightData *userRightData) {
                              //
                              [self doChat];
                          }];
}

- (void)touchTopRight
{
    [FlyingGroupVC doMemberRightInVC:self
                             GroupID:self.groupData.gp_id
                          Completion:^(FlyingUserRightData *userRightData) {
                              //
                              [self doMembers];
                          }];
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
        if (self.restorationState)
        {
            self.groupStreamTableView = [[UITableView alloc] initWithFrame:self.restoreFrame
                                                                     style:UITableViewStylePlain];
            
            self.restorationState = NO;
        }
        else
        {
            self.groupStreamTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)-64) style:UITableViewStylePlain];
        }
        
        //必须在设置delegate之前
        [self.groupStreamTableView registerNib:[UINib nibWithNibName:@"FlyingGroupMembersCell" bundle: nil]  forCellReuseIdentifier:@"FlyingGroupMembersCell"];
        [self.groupStreamTableView registerNib:[UINib nibWithNibName:@"FlyingContentCell" bundle: nil]  forCellReuseIdentifier:@"FlyingContentCell"];

        self.groupStreamTableView.delegate = self;
        self.groupStreamTableView.dataSource = self;
        self.groupStreamTableView.backgroundColor = [UIColor clearColor];
        
        //Add cover view
        self.groupBoard = [FlyingGroupBoard groupBoard];
        int coverHight = CGRectGetWidth(self.view.frame)*9/16;
        [self.groupBoard setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), coverHight)];
        [self.groupBoard setDelegate:self];
        self.groupStreamTableView.tableHeaderView = self.groupBoard;

        NSInteger bottom = [[NSUserDefaults standardUserDefaults] integerForKey:KTabBarHeight];
        self.groupStreamTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.groupStreamTableView.frame.size.width, bottom)];

        self.groupStreamTableView.restorationIdentifier = self.restorationIdentifier;

        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_1)
        {
            self.groupStreamTableView.cellLayoutMarginsFollowReadableWidth = NO;
        }

        [self.view addSubview:self.groupStreamTableView];
        
        self.currentData = [NSMutableArray new];
        _currentLodingIndex=0;
        _maxNumOfContents=NSIntegerMax;
    }
    
    //更新群组封面
    [self.groupBoard settingWithGroupData:self.groupData];
    [FlyingHttpTool getCoverListForDomainID:self.groupData.gp_id
                                 DomainType:BC_Domain_Group
                                 PageNumber:1
                                 Completion:^(NSArray *lessonList, NSInteger allRecordCount)
     {
         //取第一个推荐课程
         if(lessonList.count>0)
         {
             self.currentFeatueContent =lessonList[0];
             [self.groupBoard settingWithContentData:self.currentFeatueContent];
         }
     }];
    
    //更新群组流
    [self.currentData removeAllObjects];
    _currentLodingIndex=0;
    _maxNumOfContents=NSIntegerMax;

    [self loadMore];
}


# pragma mark - YALSunyRefreshControl methods

-(void)setupRefreshControl
{
    _refresh = NO;
    self.sunnyRefreshControl = [YALSunnyRefreshControl new];
    self.sunnyRefreshControl.delegate = self;
    [self.sunnyRefreshControl attachToScrollView:self.groupStreamTableView];
}

-(void)beginRefreshing
{
    if (_refresh)
    {
        return;
    }
    
    // start loading something
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        _refresh=YES;
        [self reloadAll];
    }
    else
    {
        [self endAnimationHandle];
    }
}

-(void)endAnimationHandle
{
    [self.sunnyRefreshControl endRefreshing];
    _refresh=NO;
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////

- (void)loadMore
{
    if (self.currentData.count<_maxNumOfContents &&
        self.currentData.count<BC_GroupStream_MaxCount
        )
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
    //更新下拉刷新
    if(_refresh)
    {
        [self endAnimationHandle];
    }
    
    //更新界面
    if (self.currentData.count>0)
    {
        [self.groupStreamTableView reloadData];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentData.count
        && self.currentData.count<_maxNumOfContents
        && self.currentData.count<BC_GroupStream_MaxCount)
    {
        return 3; // 增加一个加载更多
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
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
        //会员Cell
        FlyingGroupMembersCell * membersCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingGroupMembersCell"];
        
        if (!membersCell) {
            membersCell = [FlyingGroupMembersCell groupMembersCell];
        }
        
        [self configureCell:membersCell atIndexPath:indexPath];

        return membersCell;
    }
    else if (indexPath.section == 1)
    {
        //流Cell
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
        return [tableView fd_heightForCellWithIdentifier:@"FlyingGroupMembersCell"
                                        cacheByIndexPath:indexPath
                                           configuration:^(id cell) {
    
            [self configureCell:cell atIndexPath:indexPath];
        }];
    
    }
    if (indexPath.section == 1)
    {
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
    if (indexPath.section == 0)
    {
        [(FlyingGroupMembersCell*)cell settingWithGroupData:self.groupData];
    }
    else
    {
        if (indexPath.row<self.currentData.count)
        {
            FlyingPubLessonData *contentData = self.currentData[indexPath.row];
            [(FlyingContentCell*)cell settingWithContentData:contentData];
        }
    }
}
//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 ||
        indexPath.section == 1)
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
    if (indexPath.section == 0 ||
        indexPath.section == 1)
    {
        return;
    }
    
    // 加载更多
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:kLoadMoreIndicatorTag];
    [indicator stopAnimating];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        //[self doMembers];
    }
    else if (indexPath.section == 1)
    {
        if (self.currentData.count!=0) {
            
            FlyingPubLessonData* lessonPubData = [self.currentData objectAtIndex:indexPath.row];
            
            if ([lessonPubData.contentType isEqualToString:KContentTypePageWeb] ) {
                
                FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
                webVC.domainID = self.groupData.gp_id;
                webVC.domainType = self.groupData.gp_id;
                
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
}

+(void) contactAdminWithGroupID:(NSString*) groupID
                        message:(NSString*) message
                           inVC:(UIViewController*) vc
{
    [FlyingHttpTool getGroupByID:groupID
               successCompletion:^(FlyingGroupUpdateData *updata)
    {
        //获取群组管理员聊天ID
        NSString * adminUserID = updata.groupData.gp_owner;
        if (adminUserID)
        {
            [FlyingHttpTool getOpenIDForUserID:adminUserID
                                    Completion:^(NSString *openUDID)
            {
                //
                if (openUDID)
                {
                    NSString* targetID = [openUDID MD5];
                    
                    RCTextMessage *textMsg = [[RCTextMessage alloc] init];
                    textMsg.content = message;
                    
                    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE
                                                      targetId:targetID
                                                       content:textMsg
                                                   pushContent:nil
                                                      pushData:nil
                                                       success:^(long messageId)
                     {
                         //
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (vc)
                             {
                                 FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
                                 
                                 chatService.targetId = targetID;
                                 chatService.conversationType = ConversationType_PRIVATE;
                                 [vc.navigationController pushViewController:chatService animated:YES];
                             }
                         });
                         
                     } error:^(RCErrorCode nErrorCode, long messageId) {
                         //
                     }];
                }
                else
                {
                    [FlyingGroupVC contactAppServiceWithMessage:message
                                                           inVC:vc];
                }
            }];
        }
    }];
}


+(void) contactAppServiceWithMessage:(NSString*) message
                                inVC:(UIViewController*) vc
{
    NSString * serviceID = [FlyingDataManager getAppData].domainID;
    
    if (serviceID)
    {
        //获取客服绑定的终端ID
        [FlyingHttpTool getOpenIDForUserID:serviceID
                                Completion:^(NSString *openUDID)
         {
             //
             if (openUDID)
             {
                 NSString* targetID = [openUDID MD5];
                 
                 RCTextMessage *textMsg = [[RCTextMessage alloc] init];
                 textMsg.content = message;
                 
                 [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE
                                                   targetId:targetID
                                                    content:textMsg
                                                pushContent:nil
                                                   pushData:nil
                                                    success:^(long messageId)
                  {
                      
                      //
                      dispatch_async(dispatch_get_main_queue(), ^{
                          if (vc)
                          {
                              FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
                              
                              chatService.targetId = targetID;
                              chatService.conversationType = ConversationType_PRIVATE;
                              [vc.navigationController pushViewController:chatService animated:YES];
                          }
                      });
                      
                  } error:^(RCErrorCode nErrorCode, long messageId) {
                      //
                  }];
             }
         }];
    }
}

+ (void) doMemberRightInVC:(UIViewController*) vc
                   GroupID:(NSString*)groupID
                Completion:(void (^)(FlyingUserRightData *userRightData)) completion
{
    //从服务器实时获取成员权限
    [FlyingHttpTool checkGroupMemberInfoForAccount:[FlyingDataManager getOpenUDID]
                                           GroupID:groupID
                                        Completion:^(FlyingUserRightData *userRightData)
     {
         //新成员提醒申请成为会员
         if ([userRightData.memberState isEqualToString:BC_Member_Noexisted])
         {
             
             NSString *title   = NSLocalizedString(@"Free chat is for members only!", nil);
             NSString *message = NSLocalizedString(@"I am applying to join the group!", nil);
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                      message:message
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                                  style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
            {
                //触发后台申请机制
                [FlyingHttpTool joinGroupForAccount:[FlyingDataManager getOpenUDID]
                                            GroupID:groupID
                                         Completion:^(FlyingUserRightData *userRightData)
                 {
                     //同步信息给客服
                     [FlyingHttpTool getGroupByID:groupID
                                successCompletion:^(FlyingGroupUpdateData *updata)
                      {
                          //
                          NSString * message = [NSString stringWithFormat:NSLocalizedString(@"I am applying to join the group:%@", nil),updata.groupData.gp_name];
                          
                          [FlyingGroupVC contactAppServiceWithMessage:message
                                                                 inVC:nil];
                          
                      }];
                     
                     //获取权限直接进入下一步操作
                     if([userRightData checkRightPresent])
                     {
                         if(completion)
                         {
                             completion(userRightData);
                         }
                     }
                     //没有获取权限，提示用户现在状态
                     else
                     {
                         if (![BC_Member_Noexisted isEqualToString:userRightData.memberState])
                         {
                             //反馈显示最新状态
                             [FlyingSoundPlayer noticeSound];
                             NSString *message =[userRightData getMemberStateInfo];
                             [CRToastManager showNotificationWithMessage:message
                                                         completionBlock:^{
                                                             NSLog(@"Completed");
                                                         }];
                         }
                         else
                         {
                             //反馈显示已经处理
                             [FlyingSoundPlayer noticeSound];
                             NSString *message = NSLocalizedString(@"Your Message has sent to us...",nil);
                             [CRToastManager showNotificationWithMessage:message
                                                         completionBlock:^{
                                                             NSLog(@"Completed");
                                                         }];
                         }
                     }
                 }];
            }];
             UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                                    style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
            {
                //提示用户只有会员才能参与互动
                [FlyingSoundPlayer noticeSound];
                NSString *message = NSLocalizedString(@"Free chat is for members only!",nil);
                [CRToastManager showNotificationWithMessage:message
                                            completionBlock:^{
                                                NSLog(@"Completed");
                                            }];
            }];
             
             [alertController addAction:doneAction];
             [alertController addAction:cancelAction];
             
             [vc presentViewController:alertController animated:YES completion:^{
                 //
             }];
         }
         //现有审核通过成员
         else if ([BC_Member_Verified isEqualToString:userRightData.memberState])
         {
             //在成员开始和截止时期内
             if ([userRightData periodOK])
             {
                 //离截止日期还有多久
                 NSInteger alertDays = [userRightData daysLeft];
                 
                 //“正常”会员
                 if (alertDays>BC_GroupMember_AlertDays)
                 {
                     if(completion)
                     {
                         completion(userRightData);
                     }
                 }
                 //快到期的会员
                 else
                 {
                     NSString *title =[NSString stringWithFormat: NSLocalizedString(@"%@days remaining!", nil), @(alertDays).stringValue];
                     NSString *message = [NSString stringWithFormat: NSLocalizedString(@"%@days remaining!Renew it!", nil), @(alertDays).stringValue];
                     
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                              message:message
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
                     
                     UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                                          style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                    {
                        //同步信息给客服
                        [FlyingHttpTool getGroupByID:groupID
                                   successCompletion:^(FlyingGroupUpdateData *updata)
                         {
                             //只剩7天以内有效期就提醒用户
                             
                             NSString *message =[NSString stringWithFormat: NSLocalizedString(@"%@days remaining!Group Name:%@", nil), @(alertDays).stringValue,updata.groupData.gp_name];
                             // 反馈给客服
                             [FlyingGroupVC contactAppServiceWithMessage:message
                                                                    inVC:nil];
                         }];
                        
                        //反馈显示已经处理
                        [FlyingSoundPlayer noticeSound];
                        NSString *message = NSLocalizedString(@"Your Message has sent to us...",nil);
                        [CRToastManager showNotificationWithMessage:message
                                                    completionBlock:^{
                                                        
                                                        if(completion)
                                                        {
                                                            completion(userRightData);
                                                        }
                                                    }];
                    }];
                     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                                            style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                                                    {
                                                        if(completion)
                                                        {
                                                            completion(userRightData);
                                                        }
                                                    }];
                     
                     [alertController addAction:doneAction];
                     [alertController addAction:cancelAction];
                     
                     [vc presentViewController:alertController animated:YES completion:^{
                         //
                     }];
                 }
             }
             //不在开始和截止时间内/过期
             else
             {
                 NSString *title =[NSString stringWithFormat: NSLocalizedString(@"Membership has expired!", nil)];
                 NSString *message = NSLocalizedString(@"Membership has expired! Renew it!",nil);
                 
                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                          message:message
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                 
                 UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                                      style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
                {
                    //同步消息给客服
                    [FlyingHttpTool getGroupByID:groupID
                               successCompletion:^(FlyingGroupUpdateData *updata)
                     {
                         NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Membership has expired! Group Name:%@", nil),updata.groupData.gp_name];
                         [FlyingGroupVC contactAppServiceWithMessage:message
                                                                inVC:nil];
                         //显示当前反馈
                         [FlyingSoundPlayer noticeSound];
                         message = NSLocalizedString(@"Your Message has sent to us...",nil);
                         [CRToastManager showNotificationWithMessage:message
                                                     completionBlock:^{
                                                         NSLog(@"Completed");
                                                     }];
                     }];
                }];
                 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                                        style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                                                {
                                                    //
                                                }];
                 
                 [alertController addAction:doneAction];
                 [alertController addAction:cancelAction];
                 
                 [vc presentViewController:alertController animated:YES completion:^{
                     //
                 }];
             }
         }
         //被拒绝，申诉处理
         else if ([BC_Member_Refused isEqualToString:userRightData.memberState])
         {
             
             NSString *title =[NSString stringWithFormat: NSLocalizedString(@"You are rejected by the group!", nil)];
             NSString *message = NSLocalizedString(@"You are rejected by the group! Complain it!",nil);
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                      message:message
                                                                               preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                                  style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
            {
                //同步消息给客服
                [FlyingHttpTool getGroupByID:groupID
                           successCompletion:^(FlyingGroupUpdateData *updata)
                 {
                     NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You are rejected by the group! Group Name:%@", nil),updata.groupData.gp_name];
                     [FlyingGroupVC contactAppServiceWithMessage:message
                                                            inVC:nil];
                     //显示当前反馈
                     [FlyingSoundPlayer noticeSound];
                     message = NSLocalizedString(@"Your Message has sent to us...",nil);
                     [CRToastManager showNotificationWithMessage:message
                                                 completionBlock:^{
                                                     NSLog(@"Completed");
                                                 }];
                 }];
                
            }];
             UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                                    style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
                                            {
                                            }];
             
             [alertController addAction:doneAction];
             [alertController addAction:cancelAction];
             
             [vc presentViewController:alertController animated:YES completion:^{
                 //
             }];
         }
         //其他情况,友情提醒
         else
         {
             [FlyingSoundPlayer noticeSound];
             NSString * message = [userRightData getMemberStateInfo];
             [CRToastManager showNotificationWithMessage:message
                                         completionBlock:^{
                                             //:"
                                         }];
             
         }
     }];
}

@end
