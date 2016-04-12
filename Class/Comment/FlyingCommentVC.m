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
#import "UIView+Toast.h"
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

@interface FlyingCommentVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfComments;
    NSInteger            _currentLodingIndex;
    
    BOOL                 _refresh;
}

@property (strong, nonatomic) FlyingLoadingCell *loadingCommentIndicatorCell;


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
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

- (id)init
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {

        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FlyingLoadingCell" bundle: nil]
         forCellReuseIdentifier:@"FlyingLoadingCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FlyingContentSummaryCell" bundle: nil]
         forCellReuseIdentifier:@"FlyingContentSummaryCell"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor grayColor];
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    /*
    // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation.
    
#if DEBUG_CUSTOM_TYPING_INDICATOR
    // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom typing indicator view.
    [self registerClassForTypingIndicatorView:[TypingIndicatorView class]];
#endif
     */
    
    [self.textInputbar setAutoHideRightButton:NO];
    
    self.inverted=false;
    
    _refresh=NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
        
    //更新欢迎语言
    if(self.commentTitle)
    {
        self.title =self.commentTitle;
    }
    
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
    
    [self loadMore];
}

- (BOOL)loadMore
{
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
        return true;
    }
    else
    {
        return false;
    }
}

-(void) finishLoadingData
{
    [self.tableView reloadData];
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return CGFLOAT_MIN;
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_currentData.count && _currentData.count<_maxNumOfComments)
    {
        return 2; // 增加一个加载更多
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        NSInteger actualNumberOfRows = [self.currentData count];
        return (actualNumberOfRows  == 0) ? 1 : actualNumberOfRows;
    }
    
    // 加载更多
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;

    if (indexPath.section == 0)
    {
        NSInteger actualNumberOfRows = [self.currentData count];

        if (actualNumberOfRows == 0) {
            // Produce a special cell with the "list is now empty" message
            FlyingContentSummaryCell *contentSummaryCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingContentSummaryCell"];
            
            if(contentSummaryCell == nil)
                contentSummaryCell = [FlyingContentSummaryCell contentSummaryCell];
            
            [self configureCell:contentSummaryCell atIndexPath:indexPath];
            cell = contentSummaryCell;
        }
        else
        {
            FlyingCommentCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingCommentCell"];
            
            if(commentCell == nil)
                commentCell = [FlyingCommentCell commentCell];
            
            commentCell.delegate=self;
            
            [self configureCell:commentCell atIndexPath:indexPath];
            
            cell = commentCell;
        }
    }
    else
    {
        FlyingLoadingCell *loadingCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingLoadingCell"];
        
        if(loadingCell == nil)
            loadingCell = [FlyingLoadingCell loadingCell];
        
        cell = loadingCell;
        self.loadingCommentIndicatorCell=loadingCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSInteger actualNumberOfRows = [self.currentData count];
        
        if (actualNumberOfRows == 0) {
            return [self.tableView fd_heightForCellWithIdentifier:@"FlyingContentSummaryCell"
                                                 cacheByIndexPath:indexPath
                                                    configuration:^(FlyingContentSummaryCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
        else
        {
            return [self.tableView fd_heightForCellWithIdentifier:@"FlyingCommentCell"
                                                 cacheByIndexPath:indexPath
                                                    configuration:^(FlyingCommentCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
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
        NSInteger actualNumberOfRows = [self.currentData count];
        
        if (actualNumberOfRows == 0) {
            
            [(FlyingContentSummaryCell*)cell setSummaryText:@"骄傲的去做第一个评论者吧!"];
            [(FlyingContentSummaryCell*)cell setTextAlignment:NSTextAlignmentCenter];
        }
        else
        {
            FlyingCommentData *commentData = self.currentData[indexPath.row];
            [(FlyingCommentCell*)cell setCommentData:commentData];
        }
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
    [self.loadingCommentIndicatorCell startAnimating:@"尝试加载更多..."];
    
    // 加载下一页
    [self loadMore];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return;
    }
    
    [self.loadingCommentIndicatorCell stopAnimating];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger actualNumberOfRows = [self.currentData count];
    
    if (actualNumberOfRows == 0) {
    
        [self.textView becomeFirstResponder];
    }
    else
    {
        FlyingCommentData* commentData = [_currentData objectAtIndex:indexPath.row];
        
        [self profileImageViewPressed:commentData];
    }
}

//////////////////////////////////////////////////////////////
#pragma cell related
//////////////////////////////////////////////////////////////
- (void)profileImageViewPressed:(FlyingCommentData*)commentData
{
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FlyingProfileVC  *profileVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyingProfileVC"];
    profileVC.userID = commentData.userID;
    
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
    
    commentData.userID = [FlyingDataManager getOpenUDID];
    
    FlyingUserData *userData = [FlyingDataManager getUserData:nil];
    
    commentData.portraitURL=userData.portraitUri;
    commentData.nickName=userData.name;

    commentData.commentContent=self.textView.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *commentTime = [formatter stringFromDate:[NSDate date]];
    commentData.commentTime=commentTime;
    
    [FlyingHttpTool updateComment:commentData Completion:^(BOOL result) {
        
        if (result) {
            
            if (self.currentData.count==0) {
                
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
        
        [self dismissNavigation];
    }
}

@end
