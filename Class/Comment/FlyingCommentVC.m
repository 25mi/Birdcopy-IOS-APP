//
//  FlyingCommentVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/19/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//
#import "shareDefine.h"
#import "FlyingCommentVC.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"
#import "FlyingGroupVC.h"
#import "UICKeyChainStore.h"
#import <AFNetworking/AFNetworking.h>
#import "iFlyingAppDelegate.h"
#import <RongIMKit/RongIMKit.h>
#import <RongIMLib/RongIMLib.h>
#import "NSString+FlyingExtention.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "FlyingLoadingCell.h"
#import "FlyingContentSummaryCell.h"
#import "FlyingNavigationController.h"
#import "FlyingConversationVC.h"
#import "FlyingConversationListVC.h"
#import "FlyingDataManager.h"
#import "FlyingUserData.h"
#import "FlyingProfileVC.h"
#import <CRToastManager.h>

@interface FlyingCommentVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfComments;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
}

@property (strong, nonatomic) FlyingLoadingCell *loadingMoreIndicatorCell;

@end

@implementation FlyingCommentVC

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.title forKey:@"self.title"];
    
    if (![self.domainID isBlankString]) {
        
        [coder encodeObject:self.domainID forKey:@"self.domainID"];
    }
    
    if (![self.domainType isBlankString]) {
        
        [coder encodeObject:self.domainType forKey:@"self.domainType"];
    }

    if (![self.contentID isBlankString]) {
        
        [coder encodeObject:self.contentID forKey:@"self.contentID"];
    }

    if (![self.contentType isBlankString]) {
        
        [coder encodeObject:self.contentType forKey:@"self.contentType"];
    }
    if (![self.commentTitle isBlankString]) {
        
        [coder encodeObject:self.commentTitle forKey:@"self.commentTitle"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    NSString * title =  [coder decodeObjectForKey:@"self.title"];
    if (![title isBlankString])
    {
        self.title = title;
    }
    
    NSString * domainID  = [coder decodeObjectForKey:@"self.domainID"];
    if (![domainID isBlankString])
    {
        self.domainID = domainID;
    }

    NSString * domainType = [coder decodeObjectForKey:@"self.domainType"];
    if (![domainType isBlankString])
    {
        self.domainType = domainType;
    }
    
    NSString * contentID = [coder decodeObjectForKey:@"self.contentID"];
    if (![contentID isBlankString])
    {
        self.contentID = contentID;
    }
    
    NSString * contentType = [coder decodeObjectForKey:@"self.contentType"];
    if (![contentType isBlankString])
    {
        self.contentType = contentType;
    }

    NSString * commentTitle = [coder decodeObjectForKey:@"self.commentTitle"];
    if (![commentTitle isBlankString])
    {
        self.commentTitle = commentTitle;
    }

    [self reloadAll];
}

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {

        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        self.hidesBottomBarWhenPushed=YES;
        
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
    UINib *nib = [UINib nibWithNibName:@"FlyingCommentCell" bundle: nil];
    [self.tableView registerNib:nib  forCellReuseIdentifier:@"FlyingCommentCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FlyingContentSummaryCell" bundle: nil]
         forCellReuseIdentifier:@"FlyingContentSummaryCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FlyingLoadingCell" bundle: nil]
         forCellReuseIdentifier:@"FlyingLoadingCell"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor grayColor];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    self.tableView.tableFooterView = [UIView new];

    
    /*
    // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
    
#if DEBUG_CUSTOM_TYPING_INDICATOR
    // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom typing indicator view.
    [self registerClassForTypingIndicatorView:[TypingIndicatorView class]];
#endif
     */
    
    [self.textInputbar setAutoHideRightButton:NO];
    [self.textInputbar setMaxCharCount:200];
    [self.textInputbar.leftButton setImage:[UIImage imageNamed:@"icn_arrow_down"]
                                  forState:UIControlStateNormal];
    
    [self registerPrefixesForAutoCompletion:[NSArray arrayWithObject:@""]];

    self.inverted=false;
    
    _refresh=NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    if(self.navigationController.viewControllers.count>1)
    {
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
    
    [self reloadAll];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.navigationController.viewControllers count]>1) {
        
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        [self.tabBarController.tabBar setHidden:YES];
    }
    else
    {
        [self.tabBarController.tabBar setHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) dismissNavigation
{
    [self willDismiss];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) willDismiss
{
    if (_refresh && self.reloadDatadelegate && [self.reloadDatadelegate respondsToSelector:@selector(reloadCommentData)])
    {
        [self.reloadDatadelegate reloadCommentData];
    }
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
    
    //更新欢迎语言
    if(self.commentTitle)
    {
        self.title =self.commentTitle;
    }
    
    [self loadMore];
}

- (void)loadMore
{
    if (self.contentID) {

        if (_currentData.count<_maxNumOfComments)
        {
            _currentLodingIndex++;
            
            [FlyingHttpTool getCommentListForContentID:self.contentID
                                           ContentType:self.contentType
                                            PageNumber:_currentLodingIndex
                                            Completion:^(NSArray *commentList, NSInteger allRecordCount) {
                                                
                                                if (commentList.count!=0) {
                                                    
                                                    [self.currentData addObjectsFromArray:commentList];
                                                    _maxNumOfComments=allRecordCount;
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [self.tableView reloadData];
                                                    });
                                                }
                                            }];
        }
    }
}

-(void) finishLoadingData
{
    [self.tableView reloadData];
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2; // 增加一个加载更多
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.currentData count];
    }
    else
    {
        // 加载更多
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;

    if (indexPath.section == 0)
    {
        FlyingCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingCommentCell"];
        
        if(commentCell == nil)
            commentCell = [FlyingCommentCell commentCell];
        
        commentCell.delegate=self;
        
        [self configureCell:commentCell atIndexPath:indexPath];
        
        cell = commentCell;
    }
    else
    {
        FlyingLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingLoadingCell"];
        
        if(loadingCell == nil)
            loadingCell = [FlyingLoadingCell loadingCell];
        
        cell = loadingCell;
        self.loadingMoreIndicatorCell=loadingCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return [self.tableView fd_heightForCellWithIdentifier:@"FlyingCommentCell"
                                             cacheByIndexPath:indexPath
                                                configuration:^(FlyingCommentCell *cell) {
                                                    [self configureCell:cell atIndexPath:indexPath];
                                                }];
    }
    else
    {
        return [self.tableView fd_heightForCellWithIdentifier:@"FlyingLoadingCell"
                                             cacheByIndexPath:indexPath
                                                configuration:^(FlyingLoadingCell *cell) {
            //[self configureCell:cell atIndexPath:indexPath];
        }];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        FlyingCommentData *commentData = self.currentData[indexPath.row];
        [(FlyingCommentCell*)cell setCommentData:commentData];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (_currentData.count>0&&
            _currentData.count<_maxNumOfComments)
        {
            // 加载更多
            [self.loadingMoreIndicatorCell startAnimating:@"尝试加载更多..."];
            
            // 加载下一页
            [self loadMore];
        }
        else
        {
            [self.loadingMoreIndicatorCell stopAnimating:@"点击成为第一个评论者"];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        FlyingCommentData* commentData = [_currentData objectAtIndex:indexPath.row];
        
        [self profileImageViewPressed:commentData];
    }
    else
    {
        [self.textView becomeFirstResponder];
    }
}

//////////////////////////////////////////////////////////////
#pragma cell related
//////////////////////////////////////////////////////////////
- (void)profileImageViewPressed:(FlyingCommentData*)commentData
{
    
    FlyingProfileVC  *profileVC = [[FlyingProfileVC alloc] init];
    profileVC.openUDID = commentData.openUDID;
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

//////////////////////////////////////////////////////////////
#pragma SLKTextViewController related
//////////////////////////////////////////////////////////////
- (void)didPressRightButton:(id)sender
{
    // Notifies the view controller when the right button's action has been triggered, manually or by using the keyboard return key.
    // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
    
    [self.textView refreshFirstResponder];
    
    FlyingCommentData *commentData=[[FlyingCommentData alloc] init];
    commentData.contentID=self.contentID;
    commentData.contentType=self.contentType;
    
    commentData.openUDID = [FlyingDataManager getOpenUDID];
    
    FlyingUserData *userData = [FlyingDataManager getUserData:nil];
    
    commentData.portraitURL=userData.portraitUri;
    commentData.nickName=userData.name;

    commentData.commentContent=self.textView.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *commentTime = [formatter stringFromDate:[NSDate date]];
    commentData.commentTime=commentTime;
    
    [FlyingHttpTool updateComment:commentData Completion:^(BOOL result) {
        
        if (result)
        {
            if (self.currentData.count==0)
            {
                //[self.currentData addObject:commentData];
                [self reloadAll];
            }
            else
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
                UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;
                                
                [self.tableView beginUpdates];
                [self.currentData insertObject:commentData atIndex:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
                [self.tableView endUpdates];
                
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];
                
                // Fixes the cell from blinking (because of the transform, when using translucent cells)
                // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            _refresh=YES;
        }
    }];
    
    [super didPressRightButton:sender];
}

@end
