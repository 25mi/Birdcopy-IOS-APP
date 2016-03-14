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
#import "SIAlertView.h"
#import "UIView+Toast.h"
#import "FlyingMyGroupsVC.h"
#import "NSString+FlyingExtention.h"
#import "FlyingDataManager.h"

@interface FlyingReviewVC ()<MAOFlipViewControllerDelegate>

@property (strong,nonatomic) MAOFlipViewController *flipViewController;

@property (strong,nonatomic)     NSString           *currentPassPort;
@property (strong,nonatomic)     NSMutableArray     *currentData;


@end


@implementation FlyingReviewVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    //更新欢迎语言
    self.title =@"我的魔词";
    
    //顶部导航
    UIButton* searchButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    
    NSString *openID = [FlyingDataManager getOpenUDID];

    self.currentPassPort = openID;
    
    self.currentData =  [[[FlyingTaskWordDAO alloc] init] selectWithUserID:self.currentPassPort];
    
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
                       [[[FlyingTaskWordDAO alloc] init] cleanTaskWithUSerID:self.currentPassPort];
                   });
}

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"FlyingSearchViewController"];
    [search setSearchType:BEFindWord];
    
    [self.navigationController pushViewController:search animated:YES];
}

#pragma mark - MAOFlipViewControllerDelegate

- (UIViewController*)flipViewController:(MAOFlipViewController *)flipViewController contentIndex:(NSUInteger)contentIndex
{
    
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
    [self.view makeToast:@"已经没有更多了!" duration:3 position:CSToastPositionCenter];
}

//////////////////////////////////////////////////////////////
#pragma mark MAOFlipViewControllerDelegate
//////////////////////////////////////////////////////////////
- (void)handleRightSwipeTapFrom: (id) sender
{
    //[(FlyingNavigationController*)self.navigationController dismiss];
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
