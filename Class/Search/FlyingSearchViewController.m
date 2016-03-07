//
//  FlyingSearchViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingSearchViewController.h"
#import "FlyingSearchBar.h"
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
#import "SIAlertView.h"

#import "UICKeyChainStore.h"
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"

#import "FlyingHttpTool.h"

static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";


@interface FlyingSearchViewController ()
{
    NSArray                   * _famousResultList;
    //NSArray                   * _filteredTags;
    NSString                  * _searchStringForCurrentResult;
    UISearchDisplayController * _strongSearchDisplayController;
}

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) NSOperationQueue *searchQueue;

@property (nonatomic, retain) NSString* defaultShowStr;

@end

@implementation FlyingSearchViewController

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
    
    
    if (!self.searchType) {
        [self setSearchType:BEFindLesson];
    }
    
    //初始化相关数据
    [self initDefultData];
}

- (void)initDefultData
{
    if (self.searchType==BEFindWord)
    {
        self.title=@"查询单词";
        self.searchBar.placeholder = @"请输入单词";
        [self getWordList];
    }
    else if (self.searchType==BEFindLesson)
    {
        self.title=@"搜索内容（课程）";
        self.searchBar.placeholder = @"例如：生活大爆炸  第二季";
        
        [self getAllTagListForForDomainID:self.domainID
                                DomainType:self.domainType Count:1000];
    }
    else if (self.searchType==BEFindGroup)
    {
        self.title=@"搜索内容（课程）";
        self.searchBar.placeholder = @"例如：生活大爆炸  第二季";
        
    }
    else if (self.searchType==BEFindPeople)
    {
        self.title=@"搜索人";
        self.searchBar.placeholder = @"请输入昵称";
    }
    
    self.defaultShowStr = @"没有查询结果";
    
    self.searchResults = [NSMutableArray array];
    
    self.searchQueue = [NSOperationQueue new];
    [self.searchQueue setMaxConcurrentOperationCount:1];
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
- (void)getAllTagListForForDomainID:(NSString*)domainID
                          DomainType:(BC_Domain_Type) type
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
                                       [self.tableView  reloadData];
                                   }
                               }];
}

- (void) getWordList
{
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    _famousResultList =[[FlyingTaskWordDAO  alloc] selectWordsWithUserID:openID];

    [self.tableView  reloadData];
}

- (NSArray *)getWordListby:(NSString *) word
{

    NSURL *url = [NSString wordListStrByTag:word];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:2];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString * temStr =[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
    
    if ( (segmentRange.location==NSNotFound) && (returnData!=nil) ) {

        NSString *wordListStr =[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        if ([wordListStr isEqualToString:@""]) {
            
            return nil;
        }
        else{
            
            return  [wordListStr  componentsSeparatedByString:@";"];
        }
    }
    else{
    
        return nil;
    }
}

- (void)handleError:(NSError *)error
{
    
    self.title = self.defaultShowStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && ([self.view window] == nil) ) {
        self.view = nil;
        [self my_viewDidUnload];
    }
}

- (void)my_viewDidUnload
{
    
    [self setTableView:nil];
    [self setSearchBar:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dealWtihTapString:(NSString *) resultString
{
    if (![resultString isEqualToString:self.defaultShowStr]) {
        
        if (self.searchType==BEFindLesson) {
            
            FlyingContentListVC *conetentList = [[FlyingContentListVC alloc] init];
            [conetentList setTagString:resultString];
            
            [self.navigationController pushViewController:conetentList animated:YES];

        }
        if (self.searchType==BEFindWord) {

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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    if ([segue.identifier isEqualToString:@"fromSearchToList"]) {
        
        FlyingLessonListViewController * tempVC = segue.destinationViewController;
        
        [tempVC setTagString:(NSString *)sender];
    }
    
    if ([segue.identifier isEqualToString:@"fromSearchToWord"]) {
        
    }
     */
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
    if (tableView == self.tableView) {
        
        return _famousResultList.count;
    } else {
        
        return _searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    }
    
    if (tableView == self.tableView) {
        
        cell.textLabel.text = [_famousResultList objectAtIndex:indexPath.row];
    } else {
        
        cell.textLabel.text = [_searchResults objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * tagToSearchFinal=nil;
    if (tableView == self.tableView) {
        
        tagToSearchFinal=(NSString *)[_famousResultList objectAtIndex:indexPath.row];
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
    
    BOOL refreshResult =NO;
    
    if  (searchString.length==0)
    {
        
        [_searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:_famousResultList];
        
        refreshResult = YES;
    }
    else
    {
        if (_searchStringForCurrentResult.length > 0 && [searchString rangeOfString:_searchStringForCurrentResult].location == 0) {
            // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
            NSArray * resultsToReuse = _searchResults;
            
            NSArray *results = [resultsToReuse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
            
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
                
                if (self.searchType==BEFindWord)
                {
                    [self getWordListby:searchString];
                    
                }
                else if (self.searchType==BEFindLesson)
                {
                    
                    [FlyingHttpTool getTagListForDomainID:self.domainID
                                               DomainType:self.domainType
                                                TagString:searchString
                                                    Count:10000
                                               Completion:^(NSArray *tagList) {
                                                   
                                                   [self refreshSearchResult:tagList];
                                               }];
                }
            }];
            
            refreshResult = NO;
        }
    }
    
    if (refreshResult) {
        
        _searchStringForCurrentResult = searchString;
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
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) doScan
{
    FlyingScanViewController * scanVC=[[FlyingScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
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
