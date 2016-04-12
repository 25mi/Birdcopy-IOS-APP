//
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingAddressBookVC.h"
#import "NSString+FlyingExtention.h"
#import "shareDefine.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupMemberData.h"
#import "FlyingAddressBookTableViewCell.h"
#import "iFlyingAppDelegate.h"
#import "UIView+Toast.h"
#import "FlyingDataManager.h"
#import "FlyingProfileVC.h"
#import <RongIMLib/RongIMLib.h>
#import "RCDataBaseManager.h"

static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface FlyingAddressBookVC ()<UISearchResultsUpdating,
                                    UISearchBarDelegate,
                                    UIViewControllerRestoration>

@property (strong, nonatomic) UITableView         *tableView;

@property (strong, nonatomic) UISearchController    *searchController;
@property (nonatomic, retain) NSMutableArray        *searchResults;
@property (nonatomic, retain) NSOperationQueue      *searchQueue;

@property (nonatomic, retain) NSArray               *memberNameList;
@property (nonatomic, retain) NSMutableDictionary   *allMemberDic;

@property (strong, nonatomic) NSString          *searchStringForCurrentResult;
@property (nonatomic, retain) NSString          *defaultShowStr;


@end

@implementation FlyingAddressBookVC

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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self commonInit];
}

- (void) commonInit
{
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    //顶部导航
    if (!self.searchController) {

        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.searchBar.delegate = self;
    }
    
    if (!self.tableView) {

        self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        self.tableView.tableHeaderView = self.searchController.searchBar;
        [self.view addSubview:self.tableView];
    }
    
    self.definesPresentationContext = YES;
    
    //初始化相关数据
    [self initDefultData];
}

- (void)initDefultData
{
    self.defaultShowStr = @"没有查询结果";
    self.searchController.searchBar.placeholder = @"请输入昵称";
    
    self.searchResults = [NSMutableArray array];
    self.allMemberDic = [NSMutableDictionary new];
    
    self.searchQueue = [NSOperationQueue new];
    [self.searchQueue setMaxConcurrentOperationCount:1];
    
    
    [self getAllMemberListForForDomainID:self.domainID
                              DomainType:self.domainType];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) willDismiss
{
}

-(RCUserInfo*) getUserIofo:(NSIndexPath *)indexPath
{
    NSString *name = [_searchResults objectAtIndex:indexPath.row];
    
    if ([[_allMemberDic objectForKey:name] isKindOfClass:[FlyingGroupMemberData class]]) {
        
        FlyingGroupMemberData * groupMemberData = (FlyingGroupMemberData *)[_allMemberDic objectForKey:name];
        
        RCUserInfo * result = [RCUserInfo new];
        
        result.userId = [groupMemberData.openUDID MD5];
        result.name = [groupMemberData name];
        result.portraitUri = [groupMemberData portrait_url];
        
        return result;
    }
    
    else if ([[_allMemberDic objectForKey:name] isKindOfClass:[RCUserInfo class]]) {
     
        return [_allMemberDic objectForKey:name];
    }
    
    return nil;
}

-(void) setallowsMultipleSelection:(BOOL) allowsMultipleSelection
{
    self.tableView.allowsMultipleSelection = allowsMultipleSelection;
}


-(NSArray*) indexPathsForSelectedRows
{
    return  [self.tableView indexPathsForSelectedRows];
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////
- (void)getAllMemberListForForDomainID:(NSString*)domainID
                          DomainType:(NSString*) domainType
{
    if ([domainType isEqualToString:BC_Domain_Business]) {
        //所有会员
    }
    else if([domainType isEqualToString:BC_Domain_Group])
    {
        [FlyingHttpTool getMemberListForGroupID:self.domainID
                                     Completion:^(NSArray *memberList, NSInteger allRecordCount) {
                                         
                                         //
                                         if (memberList) {
                                             
                                             [memberList enumerateObjectsUsingBlock:^(FlyingGroupMemberData* obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                 
                                                 [self.allMemberDic setObject:obj forKey:[NSString transformToPinyin:obj.name]];
                                             }];
                                         }
                                         
                                         self.memberNameList = [self.allMemberDic allKeys];
                                         
                                         [self.searchResults removeAllObjects];
                                         [self.searchResults addObjectsFromArray:self.memberNameList];
                                         
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.tableView  reloadData];
                                         });
                                     }];

    }
    else if ([domainType isEqualToString:BC_Domain_Author])
    {
        //个人粉丝
    }
    else
    {
        NSArray * conversationList = [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE)]];
        
        
        [conversationList enumerateObjectsUsingBlock:^(RCConversation* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //
            
            RCUserInfo *userInfo=[[RCDataBaseManager shareInstance] getUserByUserId:obj.targetId];

            [self.allMemberDic setObject:userInfo forKey:userInfo.name];
        }];
        
        self.memberNameList = [self.allMemberDic allKeys];
        
        [self.searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:self.memberNameList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView  reloadData];
        });
    }
}

- (void)handleError:(NSError *)error
{
    
    self.title = self.defaultShowStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dealWtihTapString:(NSString *) resultString
{
    if (![resultString isEqualToString:self.defaultShowStr]) {
        
        FlyingUserRightData * userRightData = [FlyingDataManager getUserRightForDomainID:self.domainID domainType:self.domainType];
        
        if ([userRightData checkRightPresent]) {
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FlyingProfileVC* profileVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyingProfileVC"];
            
            FlyingGroupMemberData * groupMemberData = (FlyingGroupMemberData *)[_allMemberDic objectForKey:resultString];
            
            profileVC.openUDID = groupMemberData.openUDID;
            
            [self.navigationController pushViewController:profileVC animated:YES];
        }
        else
        {
            if ([userRightData.memberState isEqualToString:BC_Member_Noexisted]||
                [userRightData.memberState isEqualToString:BC_Member_Refused]
                )
            {
                
                NSString *title   =  NSLocalizedString(@"Attenion Please", nil);
                NSString *message =  NSLocalizedString(@"Member can chat freely, Do you want to become a member?",nil);
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                         message:message
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                                     style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                    [FlyingHttpTool joinGroupForAccount:[FlyingDataManager getOpenUDID]
                                                GroupID:self.domainID
                                             Completion:^(FlyingUserRightData *userRightData) {
                                                 //
                                                 [self showMemberInfo:userRightData];
                                                 
                                             }];
                }];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                                       style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertController addAction:doneAction];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:^{
                    //
                }];
            }
            else
            {
                [self  showMemberInfo:userRightData];
            }
        }
    }
}

-(void) showMemberInfo:(FlyingUserRightData*)userRightData
{
    NSString * infoStr=@"未知错误！";
    
    if([userRightData.memberState  isEqualToString:BC_Member_Reviewing])
    {
        infoStr = @"不存在会员身份！";
    }
    
    else if([userRightData.memberState  isEqualToString:BC_Member_Reviewing])
    {
        infoStr = @"你的成员资格正在审批中...";
    }
    else if ([userRightData.memberState isEqualToString:BC_Member_Verified]) {
        
        infoStr =  @"你已经是正式会员，可以参与互动了!";
    }
    else if ([userRightData.memberState isEqualToString:BC_Member_Refused]) {
        
        infoStr = @"你的成员资格被拒绝!";
    }
    
    [self.view makeToast:infoStr duration:2 position:CSToastPositionCenter];
}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 普通Cell
    FlyingAddressBookTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"FlyingAddressBookTableViewCell"];
    
    if (!cell) {
        cell = [FlyingAddressBookTableViewCell adressBookCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [(FlyingAddressBookTableViewCell*)cell settingWithContentData:[self getUserIofo:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(INTERFACE_IS_PAD){
        
        return 52;
    }
    else{
        
        return 44;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * key=(NSString *)[_searchResults objectAtIndex:indexPath.row];
    
    if (key) {
        
        [self dealWtihTapString:key];
    }
}

#pragma mark - Search Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED;   // called when cancel button pressed
{
    
    [self.searchQueue cancelAllOperations];
    
    [_searchResults removeAllObjects];
    [_searchResults addObjectsFromArray:_memberNameList];
    
    _searchStringForCurrentResult = @"";
    
    [self refreshSearchResult];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = searchController.searchBar.text;
    
    BOOL refreshResult =NO;
    
    if  (searchString.length==0)
    {
        
        if (_searchResults.count==_memberNameList.count) {
            
            refreshResult = NO;
        }
        else
        {
            [_searchResults removeAllObjects];
            [_searchResults addObjectsFromArray:_memberNameList];
            
            refreshResult = YES;
        }
    }
    else
    {
        if (_searchStringForCurrentResult.length > 0 && [searchString rangeOfString:_searchStringForCurrentResult].location == 0) {
            // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            
            NSArray * resultsToReuse = _searchResults;
            
            NSArray *results = [resultsToReuse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
            
            [self.searchResults removeAllObjects];
            
            if (results.count!=0) {
                
            }
            else
            {
                [self.searchResults addObjectsFromArray:results];
            }
            
            refreshResult = YES;
        }
        else
        {
            [self.searchQueue cancelAllOperations];
            
            NSArray * resultsToReuse = _memberNameList;
            NSArray *results = [resultsToReuse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
            
            [self.searchResults removeAllObjects];
            
            if (results.count!=0) {
                
                refreshResult = YES;
                
                [self.searchResults addObjectsFromArray:results];
            }
            else
            {
                refreshResult = NO;
            }
        }
    }
    
    if (refreshResult) {
        
        _searchStringForCurrentResult = searchString;
        
        [self refreshSearchResult];
    }
}

-(void) refreshSearchResult
{
    
    [self.tableView reloadData];
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

#pragma only portart events
//////////////////////////////////////////////////////////////
-(BOOL)shouldAutorotate
{
    return NO;
}

@end
