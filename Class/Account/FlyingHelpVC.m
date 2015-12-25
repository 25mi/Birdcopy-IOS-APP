//
//  FlyingHelpVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 3/2/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingHelpVC.h"
#import "RESideMenu.h"
#import "SIAlertView.h"
#import "iFlyingAppDelegate.h"
#import "FlyingSearchViewController.h"
#import "UIView+Toast.h"
#import "FlyingNavigationController.h"
#import "FlyingConversationListVC.h"

@interface FlyingHelpVC ()

@end

@implementation FlyingHelpVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addBackFunction];
    
    //更新欢迎语言
    self.title =@"做课帮助";
    
    //顶部导航
    UIButton* searchButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [searchButton setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItem = searchBarButtonItem;

    if (INTERFACE_IS_PAD ) {

        self.helpTitle.font     = [UIFont systemFontOfSize:32.0];
        
        self.aboveTitle.font     = [UIFont systemFontOfSize:32.0];
        self.aboveDes.font   = [UIFont systemFontOfSize:28.0];
        
        self.middleTitle.font     = [UIFont systemFontOfSize:32.0];
        self.middleDes.font   = [UIFont systemFontOfSize:28.0];
        
        self.lastTitle.font   = [UIFont systemFontOfSize:32.0];
        self.lastDes.font = [UIFont systemFontOfSize:28.0];
        
        self.finalTitle.font   = [UIFont systemFontOfSize:28.0];
        self.finalDes.font = [UIFont systemFontOfSize:28.0];
    }
    
    self.pageScroll.delegate = self;
    [self.pageScroll setShowsHorizontalScrollIndicator:NO];
    [self.pageScroll setShowsVerticalScrollIndicator:NO];
    self.pageScroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    self.pageScroll.pagingEnabled = NO;
    self.pageScroll.bounces = YES;
    self.pageScroll.alwaysBounceVertical= YES;
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

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
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
