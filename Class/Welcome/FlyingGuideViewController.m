//
//  FlyingGuideViewController.m
//  FlyingEnglish
//
//  Created by vincent sung on 11/12/12.
//  Copyright (c) 2012 vincent sung. All rights reserved.

#import "FlyingGuideViewController.h"
#import "shareDefine.h"
#import "UICKeyChainStore.h"
#import "FlyingStatisticDAO.h"
#import "UIImage+localFile.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"
#import  <AFNetworking/AFNetworking.h>
#import "SIAlertView.h"
#import "FlyingSysWithCenter.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface FlyingGuideViewController()<UIViewControllerRestoration>
{
    MBProgressHUD* hud;
}

@end

@implementation FlyingGuideViewController

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *retViewController = [[FlyingGuideViewController alloc] init];
    return retViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.restorationIdentifier = @"FlyingGuideViewController";
    self.restorationClass      = [self class];    // Do any additional setup after loading the view.

	// Do any additional setup after loading the view.
    
    self.view.autoresizesSubviews=UIViewAutoresizingNone;
    
    // 单击的 Recognizer
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleRecognizer];

    [self BeginMagic];

    self.timer=[NSTimer scheduledTimerWithTimeInterval:5
                                                target:self
                                              selector:@selector(timerFired)
                                              userInfo:nil
                                               repeats:NO];
    /*
    [self loadBroadPic];
     */
}

-(void)timerFired
{
    [self BeginMagic];
}

-(void)loadBroadPic
{
    /*
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSString getAccountBroadURL]];
    Reachability *r = [Reachability reachabilityWithHostname:KServerNetAddress];
    if ([r currentReachabilityStatus]!=NotReachable)
    {
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (INTERFACE_IS_PAD) {
             
             [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhiteLarge];
         }
         else{
             
             [self createActivityIndicatorWithStyle:UIActivityIndicatorViewStyleWhite];
         }
         
         NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         [self.logoImageView setContentMode:UIViewContentModeScaleAspectFit];
         [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:newStr]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [self removeActivityIndicator];
                                       }];
     }];
     */
}

- (void)BeginMagic
{
    if (!hud) {

        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"第一次登陆，激活设备中...";
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"activeBEAccount"]&&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"activeBETouchAccount"])
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.window.rootViewController = [appDelegate getMenu];
        [appDelegate.window makeKeyAndVisible];
        
        [self.timer invalidate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
    }
    else
    {
        if ( [AFNetworkReachabilityManager sharedManager].reachable) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [FlyingSysWithCenter activeAccount];
            });
        }
    }
}

- (void)accountActive
{
    [self BeginMagic];
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    //监控激活信息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accountActive)
                                                 name:KBEAccountActive
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //关闭监控激活信息
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBEAccountActive  object:nil];    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self my_viewDidUnload];
}

- (void)my_viewDidUnload
{
    //[self setLogoImageView:nil];
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

//屏幕单击
- (void)handleSingleTapFrom: (id) sender
{
    [self BeginMagic];
}

/*
-(void) createActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle) activityStyle
{
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityStyle];
    
    //calculate the correct position
    float width = _activityIndicator.frame.size.width;
    float height = _activityIndicator.frame.size.height;
    float x = (self.logoImageView.frame.size.width / 2.0) - width/2;
    float y = (self.logoImageView.frame.size.height / 2.0) - height/2;
    _activityIndicator.frame = CGRectMake(x, y, width, height);
    _activityIndicator.color=[UIColor grayColor];
    
    _activityIndicator.hidesWhenStopped = YES;
    [self.logoImageView addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
}

-(void) removeActivityIndicator
{
    [[self.logoImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}
*/
@end
