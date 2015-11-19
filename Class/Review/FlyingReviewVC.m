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
#import "RESideMenu.h"
#import "iFlyingAppDelegate.h"
#import "FlyingNavigationController.h"
#import "RCDChatListViewController.h"
#import "SIAlertView.h"
#import "UIView+Toast.h"
#import "FlyingMyGroupsVC.h"
#import "FlyingDiscoverContent.h"
#import "NSString+FlyingExtention.h"

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
    
    //更新欢迎语言
    self.title =@"我的魔词";
    
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
    
    image= [UIImage imageNamed:@"search"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    
    NSString *openID = [NSString getOpenUDID];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark
//////////////////////////////////////////////////////////////

-(void) dismiss
{
    FlyingNavigationController *navigationController =(FlyingNavigationController *)[[self sideMenuViewController] contentViewController];
    
    if (navigationController.viewControllers.count==1) {
        
#ifdef __CLIENT__GROUP__VERSION
        FlyingMyGroupsVC  * homeVC = [[FlyingMyGroupsVC alloc] init];
#else
        FlyingDiscoverContent * homeVC = [[FlyingDiscoverContent alloc] init];
#endif

        [[self sideMenuViewController] setContentViewController:[[UINavigationController alloc] initWithRootViewController:homeVC]
                                                       animated:YES];
        [[self sideMenuViewController] hideMenuViewController];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        [self.view makeToast:@"保存二维码失败，再试试了：）"];
        
        return;
    }

    RCDChatListViewController  * chatList=[[RCDChatListViewController alloc] init];
    [self.navigationController pushViewController:chatList animated:YES];
}

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
    [search setSearchType:BEFindWord];
    
    [self.navigationController pushViewController:search animated:YES];
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

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [[[FlyingTaskWordDAO alloc] init] cleanTaskWithUSerID:self.currentPassPort];
                   });
}

- (void)handleRightSwipeTapFrom: (id) sender
{
    [self showMenu];
}

@end
