//
//  FlyingMyGroupsVC.m
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingMyGroupsVC.h"
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
#import "FlyingGroupUpdateCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FlyingGroupUpdateData.h"
#import "FlyingDataManager.h"

@interface FlyingMyGroupsVC ()<UIViewControllerRestoration>
{
    NSInteger            _maxNumOfGroups;
    NSInteger            _currentLodingIndex;
}

@end

@implementation FlyingMyGroupsVC

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
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    //标题
    self.title = NSLocalizedString(@"Group",nil);
    
    self.domainID = [FlyingDataManager getBusinessID];
    self.domainType = BC_Domain_Business;
        
    //顶部导航
    [self reloadAll];
}

- (void) willDismiss
{
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (!self.groupTableView)
    {
        self.groupTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        UINib *nib = [UINib nibWithNibName:@"FlyingGroupUpdateCell" bundle: nil];
        [self.groupTableView registerNib:nib  forCellReuseIdentifier:@"FlyingGroupUpdateCell"];
        
        self.groupTableView.delegate = self;
        self.groupTableView.dataSource = self;
        self.groupTableView.backgroundColor = [UIColor clearColor];
        
        self.groupTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.groupTableView.frame.size.width, 1)];
        
        self.groupTableView.restorationIdentifier = self.restorationIdentifier;

        [self.view addSubview:self.groupTableView];
        
        _currentData = [NSMutableArray new];
        
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
        
    }
    else
    {
        [_currentData removeAllObjects];
        _currentLodingIndex=0;
        _maxNumOfGroups=NSIntegerMax;
    }
    
    [self loadMore];
}

- (void) loadMore
{
     if (_currentData.count<_maxNumOfGroups)
     {
         _currentLodingIndex++;
         
         [FlyingHttpTool getMyGroupsForPageNumber:_currentLodingIndex
                                       Completion:^(NSArray *groupUpdateList, NSInteger allRecordCount) {
                                           //
                                           [self.currentData addObjectsFromArray:groupUpdateList];
                                           _maxNumOfGroups=allRecordCount;
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self finishLoadingData];
                                           });
                                       }];
     }
}

-(void) finishLoadingData
{
    
    //更新界面
    if (_currentData.count>0)
    {
        [self.groupTableView reloadData];
    }
    else
    {
        [self.view makeToast:@"请联网后再试一下!"
                    duration:1
                    position:CSToastPositionCenter];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.currentData.count && _currentData.count<_maxNumOfGroups)
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
        FlyingGroupUpdateCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FlyingGroupUpdateCell"];
        
        if (!cell) {
            
            cell = [FlyingGroupUpdateCell groupCell];
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
        return [tableView fd_heightForCellWithIdentifier:@"FlyingGroupUpdateCell"
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
    FlyingGroupUpdateData *updateData = self.currentData[indexPath.row];
    [(FlyingGroupUpdateCell*)cell settingWithGroupData:updateData];
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
    FlyingGroupUpdateData* groupUpdaeData = [_currentData objectAtIndex:indexPath.row];

    FlyingGroupVC *groupVC = [[FlyingGroupVC alloc] init];
    groupVC.groupData=groupUpdaeData.groupData;
    groupVC.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController pushViewController:groupVC animated:YES];
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
