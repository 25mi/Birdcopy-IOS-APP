//
//  FlyingCommentVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingCommentVC.h"

#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"

#import "UIView+Toast.h"

#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"

#import "RCDChatListViewController.h"

#import "FlyingGroupVC.h"

#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "FlyingDiscoverContent.h"

#import <AFNetworking/AFNetworking.h>
#import "iFlyingAppDelegate.h"

#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
#import "RCDChatViewController.h"
#import "RCDataBaseManager.h"

#import "NSString+FlyingExtention.h"

@interface FlyingCommentVC ()
{
    NSInteger            _maxNumOfComments;
    NSInteger            _currentLodingIndex;
    
    NSInteger           kLoadMoreIndicatorTag;
}
@end

@implementation FlyingCommentVC

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder
{
    return UITableViewStylePlain;
}

- (void)commonInit
{
    /*
    // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
    [self registerClassForTextView:[MessageTextView class]];
    
#if DEBUG_CUSTOM_TYPING_INDICATOR
    // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom typing indicator view.
    [self registerClassForTypingIndicatorView:[TypingIndicatorView class]];
#endif
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
        
    //更新欢迎语言
    //self.title =self.streamData.title;
    
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
    
    [self reloadAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (!_currentData)
    {
        _currentData = [NSMutableArray new];
    }

    [_currentData removeAllObjects];
    _currentLodingIndex=0;
    _maxNumOfComments=NSIntegerMax;
    
    [self loadMore];
}

- (BOOL)loadMore
{
    //test only
    NSString *author = [[NSUserDefaults standardUserDefaults] objectForKey:KAppOwner];

    [FlyingHttpTool getAllGroupsForAPPOwner:author
                                  Recommend:YES
                                 PageNumber:1
                                 Completion:^(NSArray *groupList, NSInteger allRecordCount) {
                                     
                                     if (groupList.count!=0) {
                                         
                                         [self.currentData addObjectsFromArray:groupList];
                                         _maxNumOfComments=allRecordCount;
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             
                                             [self finishLoadingData];
                                         });
                                     }
                                 }];
    
    
    return true;
    
    /*
     if (_currentData.count<_maxNumOfComments)
     {
     _currentLodingIndex++;
     
     [FlyingHttpTool getMyGroupsForPageNumber:_currentLodingIndex
     Completion:^(NSArray *groupList, NSInteger allRecordCount) {
     //
     [self.currentData addObjectsFromArray:groupList];
     _maxNumOfComments=allRecordCount;
     
     dispatch_async(dispatch_get_main_queue(), ^{
     [self finishLoadingData];
     });
     }];
     return true;
     }
     else{
     
     return false;
     }
     */
}

-(void) finishLoadingData
{
    //更新界面
    if (_currentData.count>0)
    {
        [self.tableView reloadData];
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
    if (self.currentData.count && _currentData.count<_maxNumOfComments)
    {
        return 2; // 增加一个加载更多
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        //test
        
        return 8;
        
        //return [self.currentData count];
    }
    
    // 加载更多
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 普通Cell
        FlyingCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:COMMENTCELL_IDENTIFIER];
        
        if (!cell) {
            cell = [[FlyingCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:COMMENTCELL_IDENTIFIER];
        }
        
        //Test
        FlyingCommentData* commentData =  [[FlyingCommentData alloc] init];
        
        commentData.nickName=@"测试用户";
        commentData.commentContent=@"这个是简单的评论内容，或者说是聊天的文本内容。";
        commentData.portraitURL=@"http://www.birdenglish.com:9999/public/puu/3/pu_logo_3.png";
        
        
        //FlyingCommentData* commentData = [_currentData objectAtIndex:indexPath.row];
        [cell loadingCommentData:commentData];
        cell.delegate =self;
        
        cell.transform = self.tableView.transform;

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
    
    loadCell.transform = self.tableView.transform;

    
    return loadCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        // 普通Cell的高度
        return (INTERFACE_IS_PAD ? 250 : 100) ;
    }
    
    // 加载更多
    return 44;
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
    
    FlyingCommentData* commentData = [_currentData objectAtIndex:indexPath.row];

    [self profileImageViewPressed:commentData];
}

//////////////////////////////////////////////////////////////
#pragma cell related
//////////////////////////////////////////////////////////////
- (void)profileImageViewPressed:(FlyingCommentData*)commentData
{
    NSString *openID = [NSString getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    if ([openID isEqualToString:commentData.userID])
    {
        //个人档案页
    }
    else
    {
        RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
        
        NSString* userID = commentData.userID;
        
        RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:userID];
        chatService.userName = userInfo.name;
        chatService.targetId = userID;
        chatService.conversationType = ConversationType_PRIVATE;
        chatService.title = chatService.userName;
        [self.navigationController pushViewController:chatService animated:YES];
    }
}

//////////////////////////////////////////////////////////////
#pragma menu related
//////////////////////////////////////////////////////////////

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
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
