//
//  FlyingWordDetailVC.m
//  FlyingEnglish
//
//  Created by vincent on 3/6/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingWordDetailVC.h"
#import "FlyingLoadingView.h"
#import "FlyingItemDao.h"
#import "NSString+FlyingExtention.h"
#import <AFNetworking.h>
#import "shareDefine.h"
#import "FlyingItemParser.h"
#import "FlyingWordItemCell.h"
#import "UIView+Autosizing.h"
#import "FlyingSearchViewController.h"
#import "FlyingSoundPlayer.h"
#import "iFlyingAppDelegate.h"
#import "FlyingHttpTool.h"
#import "FlyingNavigationController.h"
#import <CRToastManager.h>

@interface FlyingWordDetailVC ()<UIViewControllerRestoration>
{
    FlyingSoundPlayer                *_soundPlayer;
}

@end

@implementation FlyingWordDetailVC


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    if (![self.theWord isBlankString])
    {
        [coder encodeObject:self.theWord forKey:@"self.theWord"];
    }
    
    if (![self.showingModle isBlankString])
    {
        [coder encodeObject:self.showingModle forKey:@"self.showingModle"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    NSString * theWord = [coder decodeObjectForKey:@"self.theWord"];
    
    if ([theWord isBlankString])
    {
        self.theWord = theWord;
    }
    
    NSString * showingModle =  [coder decodeObjectForKey:@"self.showingModle"];
    
    if (![showingModle isBlankString])
    {
        self.showingModle = showingModle;
    }
    
    if (![self.theWord isBlankString])
    {
        [self loadWordContent];
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
        
    //更新欢迎语言
    self.title =self.theWord;
    
    //顶部右上角导航
    UIButton* playButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [playButton setBackgroundImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(soundWord) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* playButtonItem= [[UIBarButtonItem alloc] initWithCustomView:playButton];
    
    UIButton* searchButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:playButtonItem, searchBarButtonItem, nil];
    
    if (self.theWord)
    {
        [self loadWordContent];
    }
}

-(void) loadWordContent
{
    FlyingItemDao * pubDAO = [[FlyingItemDao alloc] init];
    self.itemList = [pubDAO selectWithWord:self.theWord];
    
    if (self.itemList.count==0) {
        
        [self showWebData];
    }
    else{
        
        [self showItemList];
    }

    if([BC_Presented_State isEqualToString:self.showingModle])
    {
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(closeAndExit) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
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

-(void) closeAndExit
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void) doSearch
{
    FlyingSearchViewController * search= [[FlyingSearchViewController alloc] init];
    [search setSearchType:BC_Search_Word];
    
    [self.navigationController pushViewController:search animated:YES];
}

-(void) showItemList
{
    if (!self.wordDetailCollectView) {
        
        self.wordDetailCollectView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        
        if (INTERFACE_IS_PAD ) {
            
            self.wordDetailCollectView.numColsPortrait  = 3;
            self.wordDetailCollectView.numColsLandscape = 4;
        } else {
            
            self.wordDetailCollectView.numColsPortrait  = 2;
            self.wordDetailCollectView.numColsLandscape = 3;
        }
        
        self.wordDetailCollectView.collectionViewDelegate = self;
        self.wordDetailCollectView.collectionViewDataSource = self;
        self.wordDetailCollectView.backgroundColor = [UIColor clearColor];
        self.wordDetailCollectView.autoresizingMask = ~UIViewAutoresizingNone;
        
        //Add a footer view
        CGRect  loadingRect  = CGRectMake(0, 0, self.view.frame.size.width, 44);
        FlyingLoadingView * loadingview = [[FlyingLoadingView alloc] initWithFrame:loadingRect];
        [loadingview showTitle:@"已显示全部内容！"];
        self.wordDetailCollectView.footerView = loadingview;
        [self.wordDetailCollectView setCanBeEdit:NO];
        
        [self.view addSubview:self.wordDetailCollectView];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Download data from Web Dictionary
//////////////////////////////////////////////////////////////

- (void) showWebData
{
    [FlyingHttpTool getItemsforWord:self.theWord
                         Completion:^(NSArray *itemList,NSInteger all) {
                             //
                             self.itemList = [itemList mutableCopy];
                             [self parserOK];
                         }];
}

-(void) parserOK
{
    
    if (self.itemList.count>=1) {
        
        [self showItemList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            FlyingItemDao * dao= [[FlyingItemDao alloc] init];
            
            [self.itemList enumerateObjectsUsingBlock:^(FlyingItemData  *item, NSUInteger idx, BOOL *stop) {
                
                [dao insertWithData:item];
            }];
        });
    }
    else
    {
        [FlyingSoundPlayer noticeSound];
        NSString * message = NSLocalizedString(@"我们会尽快补充词典！", nil);
        [CRToastManager showNotificationWithMessage:message
                                    completionBlock:^{
                                        NSLog(@"Completed");
                                    }];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark PSCollection
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return [self.itemList count];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    
    FlyingWordItemCell *v = (FlyingWordItemCell *)[self.wordDetailCollectView dequeueReusableViewForClass:[FlyingWordItemCell class]];
    if (!v) {
        v = [[FlyingWordItemCell alloc] initWithFrame:CGRectZero];
    }
    
    v.detailData=[self.itemList objectAtIndex:index];
    [v collectionView:self.wordDetailCollectView fillCellWithObject:[self.itemList objectAtIndex:index] atIndex:index];
    [v setLittleShadow];
    
    return v;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    FlyingItemData* data = [self.itemList objectAtIndex:index];
    return  [FlyingWordItemCell  rowHeightForObject:data inColumnWidth:self.wordDetailCollectView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
    // Get the current index
    [self soundWord];
}

- (void)collectionView:(PSCollectionView *)collectionView didDeleteCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
}

//////////////////////////////////////////////////////////////
#pragma mark
//////////////////////////////////////////////////////////////
- (void) soundWord
{
    
    if (!_soundPlayer) {
        _soundPlayer = [[FlyingSoundPlayer alloc] init];
    }
    
    [_soundPlayer speechWord:self.theWord LessonID:nil];
}

@end
