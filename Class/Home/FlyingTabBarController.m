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
#import "iFlyingAppDelegate.h"

@interface FlyingTabBarController ()<UIViewControllerRestoration>

@property (strong, nonatomic) FlyingNavigationController *disCoverTab;
@property (strong, nonatomic) FlyingNavigationController *myGroupsTab;
@property (strong, nonatomic) FlyingNavigationController *myMessagersTab;
@property (strong, nonatomic) FlyingNavigationController *myAccountTab;

@end

@implementation FlyingTabBarController


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    FlyingTabBarController *vc = [self new];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTabBarController:vc];

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
        
        [self setupTabBar];
    }
    return self;
}

-(void) setupTabBar
{
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //发现
    if (!self.disCoverTab)
    {
        if (!appDelegate.homeVC)
        {
            appDelegate.homeVC = [[FlyingHomeVC alloc] init];
        }
        
        self.disCoverTab = [[FlyingNavigationController alloc] initWithRootViewController:appDelegate.homeVC];
        self.disCoverTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Discover",nil)
                                                               image:[UIImage imageNamed:@"Discover"]
                                                                 tag:0];
        self.disCoverTab.restorationIdentifier = @"disCoverTab";
    }
    
    //群组
    if (!self.myGroupsTab)
    {
        if (!appDelegate.myGroupsVC)
        {
            appDelegate.myGroupsVC = [[FlyingMyGroupsVC alloc] init];
        }

        self.myGroupsTab = [[FlyingNavigationController alloc] initWithRootViewController:appDelegate.myGroupsVC];
        
        self.myGroupsTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Group",nil)
                                                               image:[UIImage imageNamed:@"People"]
                                                                 tag:0];
        self.myGroupsTab.restorationIdentifier = @"myGroupsTab";
    }
    
    
    //消息
    if (!self.myMessagersTab)
    {
        if (!appDelegate.messagesVC) {
            
            appDelegate.messagesVC = [[FlyingConversationListVC alloc] init];
        }
        
        //设置要显示的会话类型
        [appDelegate.messagesVC setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
        
        //聚合会话类型
        [appDelegate.messagesVC setCollectionConversationType:@[@(ConversationType_GROUP),@(ConversationType_DISCUSSION),@(ConversationType_SYSTEM)]];
        
        self.myMessagersTab = [[FlyingNavigationController alloc] initWithRootViewController:appDelegate.messagesVC];
        
        self.myMessagersTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Message",nil)
                                                                  image:[UIImage imageNamed:@"Message"]
                                                                    tag:0];
        
        self.myMessagersTab.restorationIdentifier = @"myMessagersTab";
    }
    
    //账户
    if (!self.myAccountTab)
    {
        if (!appDelegate.accountVC)
        {
            
            appDelegate.accountVC = [[FlyingAccountVC alloc] init];
        }
        
        self.myAccountTab = [[FlyingNavigationController alloc] initWithRootViewController:appDelegate.accountVC];
        self.myAccountTab.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Account",nil)
                                                                image:[UIImage imageNamed:@"Account"]
                                                                  tag:0];
        
        self.myAccountTab.restorationIdentifier = @"myAccountTab";
    }
    
    self.viewControllers = [NSArray arrayWithObjects:self.disCoverTab,self.myGroupsTab,self.myMessagersTab,self.myAccountTab,nil];
    
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"];
    UIColor *backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
    
    self.tabBar.tintColor =  backgroundColor;
    
    NSInteger height = self.tabBar.frame.size.height;
    [[NSUserDefaults standardUserDefaults] setInteger:height forKey:KTabBarHeight];
    [[NSUserDefaults standardUserDefaults]  synchronize];
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
