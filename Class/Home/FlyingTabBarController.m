//
//  FlyingTabBarController.m
//  FlyingEnglish
//
//  Created by vincent sung on 13/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingTabBarController.h"
#import "FlyingHomeVC.h"
#import "FlyingMyGroupsVC.h"
#import "FlyingConversationListVC.h"
#import "FlyingAccountVC.h"
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"
#import "FlyingHttpTool.h"

@interface FlyingTabBarController ()<UIViewControllerRestoration>

@end

@implementation FlyingTabBarController


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.tabBar.tintColor  forKey:@"tabBar.tintColor"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.tabBar.tintColor = [coder decodeObjectForKey:@"tabBar.tintColor"];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        [self commoninit];
        
    }
    return self;
}

-(void) commoninit
{
    //发现
    FlyingHomeVC * homeVC = [[FlyingHomeVC alloc] init];
    FlyingNavigationController *disCoverTab = [[FlyingNavigationController alloc] initWithRootViewController:homeVC];
    disCoverTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Discover",nil)
                                                           image:[UIImage imageNamed:@"Discover"]
                                                             tag:0];
    disCoverTab.restorationIdentifier = @"disCoverTab";
    
    //群组
    FlyingMyGroupsVC * myGroupVC = [[FlyingMyGroupsVC alloc] init];
    FlyingNavigationController *myGroupsTab = [[FlyingNavigationController alloc] initWithRootViewController:myGroupVC];
    
    myGroupsTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Group",nil)
                                                           image:[UIImage imageNamed:@"People"]
                                                             tag:0];
    myGroupsTab.restorationIdentifier = @"myGroupsTab";
    
    //消息
    FlyingConversationListVC * messageList =[[FlyingConversationListVC alloc] init];
    //设置要显示的会话类型
    [messageList setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
    
    //聚合会话类型
    [messageList setCollectionConversationType:@[@(ConversationType_GROUP),@(ConversationType_DISCUSSION),@(ConversationType_SYSTEM)]];
    
    FlyingNavigationController *myMessagersTab = [[FlyingNavigationController alloc] initWithRootViewController:messageList];
    
    myMessagersTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Message",nil)
                                                              image:[UIImage imageNamed:@"Message"]
                                                                tag:0];
    
    myMessagersTab.restorationIdentifier = @"myMessagersTab";
    
    
    //账户
    FlyingAccountVC * accountVC = [[FlyingAccountVC alloc] init];
    FlyingNavigationController *myAccountTab = [[FlyingNavigationController alloc] initWithRootViewController:accountVC];
    myAccountTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Account",nil)
                                                            image:[UIImage imageNamed:@"Account"]
                                                              tag:0];
    
    myAccountTab.restorationIdentifier = @"myAccountTab";

    self.viewControllers = [NSArray arrayWithObjects:disCoverTab,myGroupsTab,myMessagersTab,myAccountTab,nil];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    self.tabBar.tintColor =  backgroundColor;
    
    NSInteger height = self.tabBar.frame.size.height;
    [[NSUserDefaults standardUserDefaults] setInteger:height forKey:KTabBarHeight];
    [[NSUserDefaults standardUserDefaults]  synchronize];
    
    //登录融云
    [FlyingHttpTool loginRongCloud];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
