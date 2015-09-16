//
//  FlyingSearchViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 6/20/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingSearchViewController.h"
#import "FlyingSearchBar.h"
#import "FlyingLessonListViewController.h"
#import "NSString+FlyingExtention.h"

#import "shareDefine.h"

#import "FlyingTaskWordDAO.h"
#import "FlyingTaskWordData.h"
#import "FlyingWordDetailVC.h"
#import "RESideMenu.h"
#import "iFlyingAppDelegate.h"
#import <AFNetworking.h>
#import "FlyingScanViewController.h"
#import "RCDChatListViewController.h"
#import "SIAlertView.h"

#import "UICKeyChainStore.h"

static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";


@interface FlyingSearchViewController ()
{
    NSArray                   * _famousTags;
    NSArray                   * _filteredTags;
    NSString                  * _currentSearchString;
    UISearchDisplayController * _strongSearchDisplayController;
}


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
    
    //更新欢迎语言
    [self initDefultData];
    
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

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;

    _strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _strongSearchDisplayController.searchResultsDataSource = self;
    _strongSearchDisplayController.searchResultsDelegate = self;
    _strongSearchDisplayController.delegate = self;
    
    image= [UIImage imageNamed:@"scan"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* scanButton= [[UIButton alloc] initWithFrame:frame];
    [scanButton setBackgroundImage:image forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(doScan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* scanBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    
    self.navigationItem.rightBarButtonItem = scanBarButtonItem;
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
        [self getAllTagListForAuthor:self.author Count:1000];
    }
    else
    {
        self.title=@"搜索群组";
        self.searchBar.placeholder = @"例如：美剧";
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Learning center
//////////////////////////////////////////////////////////////
- (void)getAllTagListForAuthor:(NSString*)author Count:(NSInteger) count
{
    NSURL *url =[NSString tagListStrForAuthor:author
                              Tag:@""
                        withCount:count];
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    
	[NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSString *tagListStr =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         _famousTags = [tagListStr  componentsSeparatedByString:@","];
         [self.tableView  reloadData];
     }];
}


- (NSArray *)getTagListForAuthor:(NSString*)author Tag:(NSString *) tag withCount:(NSInteger) count
{
    NSURL *url =[NSString tagListStrForAuthor:author
                                          Tag:tag
                                    withCount:count];

    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:2];
    
    // 發送同步請求, 這裡得returnData就是返回得數據楽
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    NSString *tagListStr =[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    if ([tagListStr isEqualToString:@""]) {
        
        return nil;
    }
    else{
        
        return [tagListStr  componentsSeparatedByString:@","];
    }
}

- (void) getWordList
{

    NSString *passport = [UICKeyChainStore  keyChainStore][KOPENUDIDKEY];
    
    _famousTags =[[FlyingTaskWordDAO  alloc] selectWordsWithUserID:passport];

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

- (NSArray *)getListby:(NSString *) searchString
{
    
    if (self.searchType==BEFindWord)
    {
        return [self getWordListby:searchString];

    }
    else if (self.searchType==BEFindLesson)
    {
        return [self getTagListForAuthor:self.author
                              Tag:searchString
                        withCount:10000];
    }
    else
    {
        //return [self getTagListby:searchString withCount:10000];
    }
}

- (void)handleError:(NSError *)error
{
    
    self.title = @"没有取到数据";
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

-(void) searchByTag:(NSString *) tag
{
    /*
    if (![tag isEqualToString:@"暂时没有查询记录，尽快补充：）"]) {
        
        if (self.presentingClass==BEReviewClass || self.presentingClass==BEHomeFindWordClass ) {
            
            FlyingWordDetailVC * wordDetail =[[FlyingWordDetailVC alloc] init];
            [wordDetail setTheWord:tag];
            [self.navigationController pushViewController:wordDetail animated:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];
                               [[[FlyingTaskWordDAO alloc] init] insertWithUesrID:passport
                                                                             Word:tag
                                                                         Sentence:nil
                                                                         LessonID:nil];
                           });
        }
        else{
            
            FlyingLessonListViewController *lessonList = [[FlyingLessonListViewController alloc] init];
            [lessonList setTagString:tag];

            [self.navigationController pushViewController:lessonList animated:YES];
        }
    }
     */
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
        
        return _famousTags.count;
    } else {
        
        return _filteredTags.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier];
    }
    
    if (tableView == self.tableView) {
        
        cell.textLabel.text = [_famousTags objectAtIndex:indexPath.row];
    } else {
        
        cell.textLabel.text = [_filteredTags objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString * tagToSearchFinal=nil;
    if (tableView == self.tableView) {
        
        tagToSearchFinal=(NSString *)[_famousTags objectAtIndex:indexPath.row];
    }
    else{
        
        tagToSearchFinal=(NSString *)[_filteredTags objectAtIndex:indexPath.row];
    }
    
    if (tagToSearchFinal) {
        
        [self searchByTag:tagToSearchFinal];
    }
}

#pragma mark - Search Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
{
    if (_filteredTags.count==0) {
        
        if (_currentSearchString) {
            
            [self searchByTag:_currentSearchString];
        }
    }
    else{
        
        if (NSNotFound!=[_filteredTags indexOfObject:_currentSearchString]) {
            
            [self searchByTag:_currentSearchString];
        }
        else{
            
            self.title = @"没有相关内容" ;
        }
    }
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    _filteredTags = nil;
    _currentSearchString = @"";
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    _filteredTags = nil;
    _currentSearchString = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSInteger gatLength=1;
    
    if (self.searchType==BEFindWord)
    {
        gatLength=3;
    }
    
    if (searchString.length == 0) {
        
        _filteredTags = _famousTags;
    }
    else{
        
        if (searchString.length <gatLength) {
            
            
            _filteredTags = [_famousTags  filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
        }
        else if (searchString.length==gatLength  || _currentSearchString.length==0 || ([_currentSearchString isEqualToString:@""]&&(gatLength==1))) {
            
            _filteredTags = [self getListby:searchString];
        }
        else{
        
            if (_currentSearchString.length > 0 && [searchString rangeOfString:_currentSearchString].location == 0) {
                // If the new search string starts with the last search string, reuse the already filtered array so searching is faster
                NSArray * tagsToSearch = _filteredTags;
                
                _filteredTags = [tagsToSearch filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchString]];
            }
            
            if (_filteredTags.count==0) {
                
                _filteredTags =@[@"暂时没有查询记录，尽快补充：）"];
                
                if (gatLength==1) {
                    
                    [self getWordListby:searchString];
                }
            }
        }
    }
    
    if (_filteredTags.count==0) {
        
        if (gatLength==3) {
            
            _filteredTags =@[searchString];
        }
        else{
            _filteredTags =@[@"暂时没有查询记录，尽快补充：）"];
        }
    }
    
    _currentSearchString = searchString;
    
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

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
        
        [self dismiss];
    }
}

#pragma only portart events
//////////////////////////////////////////////////////////////
-(BOOL)shouldAutorotate
{
    return NO;
}

@end
