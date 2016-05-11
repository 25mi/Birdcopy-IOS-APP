//
//  FlyingSearchViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingSearchViewController.h"
#import "FlyingContentListVC.h"
#import "NSString+FlyingExtention.h"

#import "shareDefine.h"

#import "FlyingTaskWordDAO.h"
#import "FlyingTaskWordData.h"
#import "FlyingWordDetailVC.h"
#import "iFlyingAppDelegate.h"
#import <AFNetworking.h>
#import "FlyingScanViewController.h"
#import "FlyingConversationListVC.h"

#import "UICKeyChainStore.h"
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"

#import "FlyingHttpTool.h"
#import "FlyingReviewVC.h"
#import <CRToastManager.h>
#import "FlyingSoundPlayer.h"

static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";


@interface FlyingSearchViewController ()<UISearchResultsUpdating,
                                            UISearchBarDelegate,
                                            UIViewControllerRestoration>

@property (strong, nonatomic) UISearchController    *searchController;
@property (strong, nonatomic) NSMutableArray        *searchResults;
@property (strong, nonatomic) NSOperationQueue      *searchQueue;

@property (strong, nonatomic) NSArray   *famousResultList;
@property (strong, nonatomic) NSString  *searchStringForCurrentResult;

@property (strong, nonatomic) NSString  *defaultShowStr;

@end

@implementation FlyingSearchViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (![self.searchType isBlankString])
    {
        [coder encodeObject:self.searchType forKey:@"self.searchType"];
    }
    
    if (!CGRectEqualToRect(self.tableView.frame,CGRectZero))
    {
        [coder encodeCGRect:self.tableView.frame forKey:@"self.tableView.frame"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    CGRect frame = [coder decodeCGRectForKey:@"self.tableView.frame"];
    if (!CGRectEqualToRect(frame,CGRectZero))
    {
        self.tableView.frame = frame;
    }
    
    NSString * searchType = [coder decodeObjectForKey:@"self.searchType"];
    
    if (![searchType isBlankString])
    {
        self.searchType = searchType;
    }
    
    if (![self.searchType isBlankString]) {

        [self initDefultData];
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

- (void) viewDidLoad
{
    [super viewDidLoad];
        
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    //顶部导航
    if([BC_Search_Word isEqualToString:self.searchType])
    {
        UIButton* myWordsButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        [myWordsButton setBackgroundImage:[UIImage imageNamed:@"Word"] forState:UIControlStateNormal];
        [myWordsButton addTarget:self action:@selector(doWord) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* dictionaryBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:myWordsButton];
        
        self.navigationItem.rightBarButtonItem = dictionaryBarButtonItem;
    }
    
    if (!self.searchController)
    {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.searchController.searchBar.delegate = self;
    }
    
    if (!self.tableView)
    {
        self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        self.tableView.tableHeaderView = self.searchController.searchBar;
        [self.view addSubview:self.tableView];
    }
    

    self.definesPresentationContext = YES;
    
    if (![self.searchType isBlankString])
    {
        //初始化相关数据
        [self initDefultData];
    }
}

- (void)initDefultData
{
    self.defaultShowStr = @"没有查询结果";
    self.searchResults = [NSMutableArray array];

    self.searchQueue = [NSOperationQueue new];
    [self.searchQueue setMaxConcurrentOperationCount:1];

    if([BC_Search_Word isEqualToString:self.searchType])
    {
        self.title=@"查询单词";
        self.searchController.searchBar.placeholder = @"请输入单词";
        [self getWordList];
    }
    else if([BC_Search_Lesson isEqualToString:self.searchType])
    {
        self.title=@"搜索内容（课程）";
        self.searchController.searchBar.placeholder = @"例如：生活大爆炸  第二季";
        
        [self getAllTagListForForDomainID:self.domainID
                                DomainType:self.domainType Count:1000];
    }
    else if([BC_Search_Group isEqualToString:self.searchType])
    {
        self.title=@"搜索内容（课程）";
        self.searchController.searchBar.placeholder = @"例如：生活大爆炸  第二季";
        
    }
    else if([BC_Search_People isEqualToString:self.searchType])
    {
        self.title=@"搜索人";
        self.searchController.searchBar.placeholder = @"请输入昵称";
    }
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

-(void)doWord
{
    NSArray *wordArray =  [[[FlyingTaskWordDAO alloc] init] selectWithUserID:[FlyingDataManager getOpenUDID]];

    if (wordArray.count>0) {
        
        FlyingReviewVC * reviewVC = [[FlyingReviewVC alloc] init];
        reviewVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:reviewVC animated:YES];
    }
    else
    {
        [FlyingSoundPlayer noticeSound];
        NSString * message = NSLocalizedString(@"click the words in the subtitles for translation", nil);

        [CRToastManager showNotificationWithMessage:message
                                    completionBlock:^{
                                        NSLog(@"Completed");
                                    }];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////
- (void)getAllTagListForForDomainID:(NSString*)  domainID
                          DomainType:(NSString*) type
                               Count:(NSInteger) count
{
    [FlyingHttpTool getTagListForDomainID:domainID
                               DomainType:type
                                TagString:nil
                                    Count:count
                               Completion:^(NSArray *tagList) {
                                   //
                                   
                                   if (tagList.count!=0) {
                                       
                                       _famousResultList = tagList;
                                       
                                       [self.searchResults removeAllObjects];
                                       [self.searchResults addObjectsFromArray:tagList];
                                       
                                       [self.tableView  reloadData];
                                   }
                               }];
}

- (void) getWordList
{
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    _famousResultList =[[FlyingTaskWordDAO  alloc] selectWordsWithUserID:openID];
    
    [self.searchResults removeAllObjects];
    
    if (_famousResultList.count!=0) {
        
        [self.searchResults addObjectsFromArray:_famousResultList];
    }

    [self.tableView  reloadData];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dealWtihTapString:(NSString *) resultString
{
    if (![resultString isEqualToString:self.defaultShowStr]) {
        
        if([BC_Search_Lesson isEqualToString:self.searchType])
        {
            FlyingContentListVC *contentList = [[FlyingContentListVC alloc] init];
            [contentList setTagString:resultString];
            
            [contentList setDomainID:self.domainID];
            [contentList setDomainType:self.domainType];
            
            [self.navigationController pushViewController:contentList animated:YES];
        }
        else if([BC_Search_Word isEqualToString:self.searchType])
        {
            FlyingWordDetailVC * wordDetail =[[FlyingWordDetailVC alloc] init];
            [wordDetail setTheWord:resultString];
            [self.navigationController pushViewController:wordDetail animated:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               NSString *openID = [FlyingDataManager getOpenUDID];

                               [[[FlyingTaskWordDAO alloc] init] insertWithUesrID:openID
                                                                             Word:resultString
                                                                         Sentence:nil
                                                                         LessonID:nil];
                           });
        }
    }
}

#pragma mark - TableView Delegate and DataSource

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    }
    
    cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * tagToSearchFinal=nil;

    tagToSearchFinal=(NSString *)[self.searchResults objectAtIndex:indexPath.row];
    
    if (tagToSearchFinal) {
        
        [self dealWtihTapString:tagToSearchFinal];
    }
}

#pragma mark - Search Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED;   // called when cancel button pressed
{
    
    [self.searchQueue cancelAllOperations];
    
    [self.searchResults removeAllObjects];
    [self.searchResults addObjectsFromArray:_famousResultList];
    
    _searchStringForCurrentResult = @"";
    
    [self refreshSearchResult];
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = searchController.searchBar.text;
    
    BOOL refreshResult =NO;
    
    if  (searchString.length==0)
    {
        
        if (self.searchResults.count==_famousResultList.count) {
            
            refreshResult = NO;
        }
        else
        {
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:_famousResultList];
        
            refreshResult = YES;
        }
    }
    else
    {
        if (_searchStringForCurrentResult.length > 0 && [searchString rangeOfString:_searchStringForCurrentResult].location == 0) {
            // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            
            NSArray * resultsToReuse = self.searchResults;
            
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
            
            NSArray * resultsToReuse = _famousResultList;
            NSArray *results = [resultsToReuse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
            
            [self.searchResults removeAllObjects];
            
            if (results.count!=0) {
                
                refreshResult = YES;
                
                [self.searchResults addObjectsFromArray:results];
            }
            else
            {
                refreshResult = NO;
                
                [self.searchQueue addOperationWithBlock:^{
                    
                    if([BC_Search_Word isEqualToString:self.searchType])
                    {
                        [FlyingHttpTool getWordListby:searchString
                                           Completion:^(NSArray *wordList, NSInteger allRecordCount) {
                                               
                                               //
                                               [self.searchResults removeAllObjects];
                                               
                                               if (wordList.count>0) {
                                                   
                                                   [self.searchResults addObjectsFromArray:wordList];
                                               }
                                               
                                               // Reload your search results table data.
                                               [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                   
                                                   [self refreshSearchResult];
                                               }];

                                           }];
                        
                    }
                    else if([BC_Search_Lesson isEqualToString:self.searchType])
                    {
                        
                        [FlyingHttpTool getTagListForDomainID:self.domainID
                                                   DomainType:self.domainType
                                                    TagString:searchString
                                                        Count:10000
                                                   Completion:^(NSArray *tagList) {
                                                       
                                                       [self.searchResults removeAllObjects];

                                                       if (tagList.count>0) {
                                                           
                                                           [self.searchResults addObjectsFromArray:tagList];
                                                       }
                                                       
                                                       // Reload your search results table data.
                                                       [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                           
                                                           [self refreshSearchResult];
                                                       }];
                                                   }];
                    }
                }];
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


#pragma only portart events
//////////////////////////////////////////////////////////////
-(BOOL)shouldAutorotate
{
    return NO;
}

@end
