//
//  BEMenuController.m
//  FlyingEnglish
//
//  Created by BE_Air on 10/28/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#import "BEMenuController.h"
#import "FlyingProviderListVC.h"
#import "FlyingLessonListViewController.h"
#import "shareDefine.h"
#import "RESideMenu.h"
#import "FlyingHelpVC.h"
#import "FlyingReviewVC.h"
#import "FlyingScanViewController.h"
#import "RCDChatListViewController.h"
#import "FlyingNavigationController.h"

#import "FlyingDiscoverContent.h"
#import "FlyingDIscoverGroups.h"
#import "FlyingMyGroupsVC.h"

#import "FlyingDiscoverContent.h"

#import "FlyingTaskWordDAO.h"
#import "UICKeyChainStore.h"
#import "iFlyingAppDelegate.h"
#import "NSString+FlyingExtention.h"

#define MENU_IPHONE_HEIGHT  50
#define MENU_IPAD_HEIGHT    MENU_IPHONE_HEIGHT*2

#define MENU_IPHONE_OFFSET  44
#define MENU_IPAD_OFFSET  MENU_IPHONE_OFFSET*2

@interface BEMenuController ()
@property (strong, readwrite, nonatomic) UITableView *tableView;


@property (strong, readwrite, nonatomic) NSMutableArray *titles;
@property (strong, readwrite, nonatomic) NSMutableArray *images;

@end

@implementation BEMenuController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titles =  [NSMutableArray arrayWithArray:@[@"首页"]];
    self.images =  [NSMutableArray arrayWithArray:@[@"Home"]];
    
#ifdef __CLIENT__IS__ENGLISH__
    
    NSString *openID = [NSString getOpenUDID];
    
    if (openID) {
        
        NSArray *currentData =  [[[FlyingTaskWordDAO alloc] init] selectWithUserID:openID];
        
        if (currentData.count>0)
        {
            [self.titles addObject:@"魔词"];
            [self.images addObject:@"Word"];
        }
    }
    
#endif
    
    [self.titles addObject:@"账户"];
    [self.images addObject:@"Profile"];
    
    
#if (defined __CLIENT__IS__PLATFORM__) && (defined __CLIENT__GROUP__VERSION)
    [self.titles addObject:@"服务"];
    [self.images addObject:@"location"];
#endif

    
    CGFloat offset_x=MENU_IPHONE_OFFSET;
    CGFloat menu_item_height=MENU_IPHONE_HEIGHT;
    
    if (INTERFACE_IS_PAD )
    {
        offset_x=MENU_IPAD_OFFSET;
        menu_item_height=MENU_IPAD_HEIGHT;
    }
    
    CGFloat menuHight =menu_item_height * [self numberOfSectionsInTableView:self.tableView];
    CGFloat offset_y=0;

    if (self.view.frame.size.height>menuHight)
    {
        offset_y=(self.view.frame.size.height - menuHight) / 2.0f;
    }
    else
    {
        menuHight=self.view.frame.size.width;
        offset_y=0;
    }
    
    if (!self.tableView) {
        self.tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(offset_x, offset_y, self.view.frame.size.width, menuHight)
                                                                  style:UITableViewStylePlain];
            tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.opaque = NO;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.bounces = YES;
            tableView;
        });
        
        [self.view addSubview:self.tableView];
    }
}

#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KGodIsComing object:nil userInfo:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setnavigationBarWithClearStyle:NO];
    
    NSString * title=self.titles[indexPath.section];
    
    if ([title containsString:@"首页"])
    {
#ifdef __CLIENT__GROUP__VERSION
        FlyingMyGroupsVC  * homeVC = [[FlyingMyGroupsVC alloc] init];
#else
        FlyingDiscoverContent * homeVC = [[FlyingDiscoverContent alloc] init];
#endif
        
        [self.sideMenuViewController setContentViewController:[[FlyingNavigationController alloc] initWithRootViewController:homeVC]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    else if([title containsString:@"发现"])
    {
        FlyingDiscoverContent * contentVC =[[FlyingDiscoverContent alloc] init];
        
        [self.sideMenuViewController setContentViewController:[[FlyingNavigationController alloc] initWithRootViewController:contentVC]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    else if([title containsString:@"魔词"])
    {
        FlyingReviewVC * reviewVC =[[FlyingReviewVC alloc] init];
        
        [self.sideMenuViewController setContentViewController:[[FlyingNavigationController alloc] initWithRootViewController:reviewVC]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    else if([title containsString:@"账户"])
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id settingVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyingAccountVC"];
        
        [self.sideMenuViewController setContentViewController:[[FlyingNavigationController alloc] initWithRootViewController:settingVC]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    else if([title containsString:@"服务"])
    {
        FlyingProviderListVC * providerListVC =[[FlyingProviderListVC alloc] init];
        
        [self.sideMenuViewController setContentViewController:[[FlyingNavigationController alloc] initWithRootViewController:providerListVC]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    else if([title containsString:@"扫描"])
    {
        
        FlyingScanViewController * scan=[[FlyingScanViewController alloc] init];
        [self.sideMenuViewController setContentViewController:[[FlyingNavigationController alloc] initWithRootViewController:scan]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
    else if([title containsString:@"聊天"])
    {
        RCDChatListViewController  * chatList=[[RCDChatListViewController alloc] init];

        [self.sideMenuViewController setContentViewController:[[FlyingNavigationController alloc] initWithRootViewController:chatList]
                                                     animated:YES];
        [self.sideMenuViewController hideMenuViewController];
    }
}

#pragma mark -
#pragma mark UITableView Datasource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view =[[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view =[[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float alpha = 1;
    if (INTERFACE_IS_PAD) {
        alpha=2;
    }

    return 10*alpha;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    float alpha = 1;
    if (INTERFACE_IS_PAD) {
        alpha=2;
    }
    return 10*alpha;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float alpha = 1;
    if (INTERFACE_IS_PAD) {
        alpha=2;
    }

    return 30*alpha;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    cell.textLabel.text = self.titles[indexPath.section];
    cell.imageView.image = [UIImage imageNamed:self.images[indexPath.section]];
    
    return cell;
}

@end
