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
#import <SIAlertView.h>
#import "UIView+Toast.h"
#import "FlyingDataManager.h"

static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface FlyingAddressBookVC ()
{
    NSString                  * _searchStringForCurrentResult;
    UISearchDisplayController * _strongSearchDisplayController;
}

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) NSOperationQueue *searchQueue;

@property (nonatomic, retain) NSString* defaultShowStr;


@property (nonatomic, retain) NSArray *memberNameList;
@property (nonatomic, retain) NSMutableDictionary *allMemberDic;

@end

@implementation FlyingAddressBookVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addBackFunction];
    
    //顶部导航
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;

    _strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _strongSearchDisplayController.searchResultsDataSource = self;
    _strongSearchDisplayController.searchResultsDelegate = self;
    _strongSearchDisplayController.delegate = self;
    
    //初始化相关数据
    [self initDefultData];
}

- (void)initDefultData
{
    self.defaultShowStr = @"没有查询结果";
    self.searchBar.placeholder = @"请输入昵称";
    
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

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////
- (void)getAllMemberListForForDomainID:(NSString*)domainID
                          DomainType:(BC_Domain_Type) type
{
    switch (self.domainType) {
            
        case BC_Business_Domain:
        {
            break;
        }
            
        case BC_Group_Domain:
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
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView  reloadData];
                                             });
                                         }];
            
            break;
        }
            
        case BC_Author_Domain:
        {
            break;
        }
            
        default:
            break;
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
        
        
        BOOL right = [[NSUserDefaults standardUserDefaults] boolForKey:self.domainID];
        
        if (!right) {
            
            NSString *title = @"友情提醒！";
            NSString *message = @"正式会员才能参与互动，你需要申请成为群组成员吗？";
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
            [alertView addButtonWithTitle:@"取消"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                  }];
            
            [alertView addButtonWithTitle:@"确认"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      
                                      [FlyingHttpTool joinGroupForAccount:[FlyingDataManager getOpenUDID]
                                                                  GroupID:self.domainID
                                                               Completion:^(NSString *result) {
                                                                   //
                                                                   [self showMemberInfo:result];
                                                                   
                                                               }];
                                  }];
            
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            [alertView show];
            
            return;
        }
    }
}

-(void) showMemberInfo:(NSString*)reslutStr
{
    NSString * verifiedStr = @"你已经是正式会员，可以参与互动了!";
    NSString * refuseStr = @"你的成员资格被拒绝!";
    NSString * reviewStr = @"你的成员资格正在审批中...";
    
    NSString * infoStr=@"未知错误！";
    
    if ([reslutStr isEqualToString:KGroupMemberVerified]) {
        
        infoStr = verifiedStr;
    }
    
    else if ([reslutStr isEqualToString:KGroupMemberRefused]) {
        
        infoStr = refuseStr;
    }
    else if([reslutStr isEqualToString:KGroupMemberReviewing])
    {
        infoStr = reviewStr;
        
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
    if (tableView == self.tableView) {
        
        return _memberNameList.count;
    } else {
        
        return _searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 普通Cell
    FlyingAddressBookTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ADRESSCELL_IDENTIFIER];
    
    if (!cell) {
        cell = [FlyingAddressBookTableViewCell adressBookCell];
    }
    
    if (tableView == self.tableView) {

        [self configureCell:cell atIndexPath:indexPath isSearchResult:NO];
    } else {
        
        [self configureCell:cell atIndexPath:indexPath isSearchResult:YES];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath isSearchResult:(BOOL) isSerach
{
    NSString *name;
    if (isSerach) {
        
        name = [_searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        name = [_memberNameList objectAtIndex:indexPath.row];
    
    }
    
    [(FlyingAddressBookTableViewCell*)cell settingWithContentData:(FlyingGroupMemberData *)[_allMemberDic objectForKey:name]];
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
    
    NSString * tagToSearchFinal=nil;
    if (tableView == self.tableView) {
        
        tagToSearchFinal=(NSString *)[_memberNameList objectAtIndex:indexPath.row];
    }
    else{
        
        tagToSearchFinal=(NSString *)[_searchResults objectAtIndex:indexPath.row];
    }
    
    if (tagToSearchFinal) {
        
        [self dealWtihTapString:tagToSearchFinal];
    }
}

#pragma mark - Search Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    if (_searchResults.count==0) {
        
        if (_searchStringForCurrentResult) {
            
            [self dealWtihTapString:_searchStringForCurrentResult];
        }
    }
    else{
        
        if (NSNotFound!=[_searchResults indexOfObject:_searchStringForCurrentResult]) {
            
            [self dealWtihTapString:_searchStringForCurrentResult];
        }
        else{
            
            self.title = self.defaultShowStr ;
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    NSString * absStr = [NSString transformToPinyin:searchString];
    
    BOOL refreshResult =NO;
    
    if  (absStr.length==0)
    {
        
        [_searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:_memberNameList];
        
        refreshResult = YES;
    }
    else
    {
        if (_searchStringForCurrentResult.length == 0 ||
            [absStr rangeOfString:_searchStringForCurrentResult].location == 0) {
            
            // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            NSArray * resultsToReuse = _searchResults;
            
            if (self.searchResults.count==0) {
                
                [self.searchResults addObjectsFromArray:_memberNameList];
            }
            
            NSArray *results = [resultsToReuse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", absStr]];
            
            if (results.count==0) {
                
                refreshResult = NO;
            }
            else
            {
                
                [self.searchResults removeAllObjects];
                [self.searchResults addObjectsFromArray:results];

                refreshResult = YES;
            }
        }
        else
        {
            [self.searchQueue cancelAllOperations];
            [self.searchQueue addOperationWithBlock:^{
                
                [self refreshSearchResult:_memberNameList];
            }];
            
            refreshResult = NO;
        }
    }
    
    if (refreshResult) {
        
        _searchStringForCurrentResult = absStr;
    }
    
    return refreshResult;
}

-(void) refreshSearchResult:(NSArray*) result
{
    
    [self.searchResults removeAllObjects];
    
    if (result.count==0) {
        
        [_searchResults addObject:self.defaultShowStr];
    }
    else
    {
        [self.searchResults addObjectsFromArray:result];
    }
    
    // Reload your search results table data.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_strongSearchDisplayController.searchResultsTableView reloadData];
    }];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchQueue cancelAllOperations];
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
