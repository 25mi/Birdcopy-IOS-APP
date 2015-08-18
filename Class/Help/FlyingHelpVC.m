//
//  FlyingHelpVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 3/2/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "FlyingHelpVC.h"
#import "FlyingMyLessonsViewController.h"
#import "RESideMenu.h"
#import "SIAlertView.h"
#import "iFlyingAppDelegate.h"

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
    [self addBackFunction];
    
    //更新欢迎语言
    self.title =@"高级功能";
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.leftBarButtonItem = menuBarButtonItem;

    
    if (INTERFACE_IS_PAD ) {
        
        self.aboveTitle.font     = [UIFont systemFontOfSize:28.0];
        self.aboveDes.font   = [UIFont systemFontOfSize:32.0];
        
        self.middleTitle.font     = [UIFont systemFontOfSize:28.0];
        self.middleDes.font   = [UIFont systemFontOfSize:32.0];
        
        self.lastTitle.font   = [UIFont systemFontOfSize:28.0];
        self.lastDes.font = [UIFont systemFontOfSize:32.0];
        
        self.finalTitle.font   = [UIFont systemFontOfSize:28.0];
        self.finalDes.font = [UIFont systemFontOfSize:32.0];
    }
    
    self.pageScroll.delegate = self;
    [self.pageScroll setShowsHorizontalScrollIndicator:NO];
    [self.pageScroll setShowsVerticalScrollIndicator:NO];
    self.pageScroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    self.pageScroll.pagingEnabled = NO;
    self.pageScroll.bounces = YES;
    self.pageScroll.alwaysBounceVertical= YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{
    [self setPageScroll:nil];
    [self setAboveTitle:nil];
    [self setAboveDes:nil];
    [self setMiddleTitle:nil];
    [self setMiddleDes:nil];
    [self setLastTitle:nil];
    [self setLastDes:nil];
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

//////////////////////////////////////////////////////////////
#pragma mark 
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

//LogoDone functions
- (void)dismiss
{
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
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

-(void) handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if ((recognizer.state ==UIGestureRecognizerStateEnded) || (recognizer.state ==UIGestureRecognizerStateCancelled)) {
        
        [self dismiss];
    }
}

#pragma only portart events
//////////////////////////////////////////////////////////////

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
