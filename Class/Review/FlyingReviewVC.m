//
//  FlyingReviewVC.m
//  FlyingEnglish
//
//  Created by vincent on 4/3/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingReviewVC.h"
#import "MAOFlipViewController.h"
#import "FlyingWordAbstractVC.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "FlyingTaskWordDAO.h"
#import "FlyingScanViewController.h"
#import "FlyingSearchViewController.h"
#import "iFlyingAppDelegate.h"
#import "FlyingNavigationController.h"
#import "FlyingConversationListVC.h"
#import "NSString+FlyingExtention.h"
#import "FlyingDataManager.h"
#import "FlyingWordDetailVC.h"
#import "FlyingTaskWordData.h"
#import "MAOFlipViewController.h"
#import "FlyingSoundPlayer.h"

@interface FlyingReviewVC ()<MAOFlipViewControllerDelegate,
                                UIViewControllerRestoration>
{
    NSInteger _currentContentIndex;
}

@property (strong,nonatomic) MAOFlipViewController *flipViewController;

@property (strong,nonatomic)     NSMutableArray     *currentData;

@end


@implementation FlyingReviewVC

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
    
    _currentContentIndex=0;

    //更新欢迎语言
    self.title =NSLocalizedString(@"English Tool",nil);
    
    //顶部导航
    UIButton* dictionaryButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [dictionaryButton setBackgroundImage:[UIImage imageNamed:@"dictionary"] forState:UIControlStateNormal];
    [dictionaryButton addTarget:self action:@selector(doDictionary) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* dictionaryBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:dictionaryButton];
    
    self.navigationItem.rightBarButtonItem = dictionaryBarButtonItem;
    
    self.currentData =  [[[FlyingTaskWordDAO alloc] init] selectWithUserID:[FlyingDataManager getOpenUDID]];
    
    if (self.currentData.count==0)
    {
        self.title=@"学学再来有惊喜！";
    }
    else
    {
        self.flipViewController = [[MAOFlipViewController alloc]init];
        self.flipViewController.delegate = self;
        [self addChildViewController:self.flipViewController];
        self.flipViewController.view.frame = self.view.frame;
        [self.view addSubview:self.flipViewController.view];
        [self.flipViewController didMoveToParentViewController:self];
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
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [[[FlyingTaskWordDAO alloc] init] cleanTaskWithUSerID:[FlyingDataManager getOpenUDID]];
                   });
}

-(void) doDictionary
{
    BOOL showSearch = true;
    NSString * word;
    
    _currentContentIndex = self.flipViewController.flipNavigationController.viewControllers.count-1;
    
    if (_currentContentIndex>=0 && _currentContentIndex<self.currentData.count) {
        
        word =[(FlyingTaskWordData*)[self.currentData objectAtIndex:_currentContentIndex] BEWORD];
        
        if (word) {

            showSearch = NO;
        }
    }

    if (showSearch) {

        FlyingSearchViewController * search= [[FlyingSearchViewController alloc] init];
        [search setSearchType:BC_Search_Word];
        
        [self.navigationController pushViewController:search animated:YES];
    }
    else{
    
        FlyingWordDetailVC * wordDetail =[[FlyingWordDetailVC alloc] init];
        [wordDetail setTheWord:word];
        [self.navigationController pushViewController:wordDetail animated:YES];
    }
}

#pragma mark - MAOFlipViewControllerDelegate

- (UIViewController*)flipViewController:(MAOFlipViewController *)flipViewController contentIndex:(NSUInteger)contentIndex
{
    
    _currentContentIndex = contentIndex;
    
    if (self.currentData.count!=0)
    {

        FlyingWordAbstractVC * abtractVc= [[FlyingWordAbstractVC alloc] initWithTaskWord:[self.currentData objectAtIndex:contentIndex]];
        
        return abtractVc;
    }
    else
    {
        return nil;
    }
}

- (NSUInteger)numberOfFlipViewControllerContents
{
    return self.currentData.count;
}

-(void)reachEnd
{
    NSString * message =NSLocalizedString(@"已经没有更多了!", nil);
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate makeToast:message];
}

//////////////////////////////////////////////////////////////
#pragma mark MAOFlipViewControllerDelegate
//////////////////////////////////////////////////////////////
- (void)handleRightSwipeTapFrom: (id) sender
{
    //[(FlyingNavigationController*)self.navigationController dismiss];
}
@end
