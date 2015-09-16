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
#import "SIAlertView.h"
#import "FlyingWordItemCell.h"
#import "UIView+Autosizing.h"
#import "RESideMenu.h"
#import "FlyingSearchViewController.h"
#import "SoundPlayer.h"
#import "iFlyingAppDelegate.h"
#import "UIView+Toast.h"
#import "FlyingHttpTool.h"

@interface FlyingWordDetailVC ()
{
    SoundPlayer                *_soundPlayer;
}

@end

@implementation FlyingWordDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addBackFunction];
    
    //更新欢迎语言
    self.title =self.theWord;
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.leftBarButtonItem = menuBarButtonItem;
    
    image= [UIImage imageNamed:@"PlayAudio"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* playButton= [[UIButton alloc] initWithFrame:frame];
    [playButton setBackgroundImage:image forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(soundWord) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* playButtonItem= [[UIBarButtonItem alloc] initWithCustomView:playButton];
    
    image= [UIImage imageNamed:@"search"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:playButtonItem, searchBarButtonItem, nil];
    
    FlyingItemDao * pubDAO = [[FlyingItemDao alloc] init];
    self.itemList = [pubDAO selectWithWord:self.theWord];

    if (self.itemList.count==0) {
        
        [self showWebData];
    }
    else{
        
        [self showItemList];
    }
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
    else{
        
        [self.view makeToast:@"我们会尽快补充词典！"];
    }
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

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{
    [self setWordDetailCollectView:nil];
    [self.itemList removeAllObjects];
    self.itemList=nil;
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
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
}

- (void)collectionView:(PSCollectionView *)collectionView didDeleteCell:(PSCollectionViewCell *)cell atIndex:(NSInteger)index
{
}

//////////////////////////////////////////////////////////////
#pragma mark
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) soundWord
{
    
    if (!_soundPlayer) {
        _soundPlayer = [[SoundPlayer alloc] init];
    }
    
    [_soundPlayer speechWord:self.theWord LessonID:nil];
}


- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
    [search setSearchType:BEFindWord];
    
    [self.navigationController pushViewController:search animated:YES];
}

//LogoDone functions
- (void)dismiss{
    
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

#pragma only portart events
//////////////////////////////////////////////////////////////
-(BOOL)shouldAutorotate
{
    return NO;
}

@end
