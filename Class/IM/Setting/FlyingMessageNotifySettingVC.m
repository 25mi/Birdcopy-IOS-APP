//
//  FlyMessageNotifySettingVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingMessageNotifySettingVC.h"
#import "iFlyingAppDelegate.h"
#import "FlyingSwitchCell.h"
#import "shareDefine.h"

@interface FlyingMessageNotifySettingVC ()<UITableViewDataSource,
                                        UITableViewDelegate,
                                        UIViewControllerRestoration,
                                        FlyingSwitchCellDelegate>

@property (strong, nonatomic) UITableView        *tableView;

@end

@implementation FlyingMessageNotifySettingVC

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
        
    self.title =  NSLocalizedString(@"Chat Setting",nil);
    //顶部导航
    if(self.navigationController.viewControllers.count>1)
    {
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
    
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (spansMin > 0) {
                //self.notifySwitch.on = NO;
            } else {
                //self.notifySwitch.on = YES;
            }
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.notifySwitch.on = YES;
        });
    }];
    
    [self reloadAll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissNavigation
{
    [self willDismiss];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) willDismiss
{
}

//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (!self.tableView)
    {
        self.tableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingSwitchCell" bundle:nil]
             forCellReuseIdentifier:@"FlyingSwitchCell"];
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.tableView.backgroundColor = [UIColor clearColor];
        //self.tableView.separatorColor = [UIColor clearColor];
        
        self.tableView.tableFooterView = [UIView new];
        
        [self.view addSubview:self.tableView];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Datasource
//////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    FlyingSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingSwitchCell"];
    
    if(switchCell == nil)
        switchCell = [FlyingSwitchCell switchCell];
    
    [self configureCell:switchCell atIndexPath:indexPath];
    
    cell = switchCell;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47.5;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:KNoticeNewMessage]) {
            
            [(FlyingSwitchCell*)cell setItemText:NSLocalizedString(@"Notification ON",nil)];
            [(FlyingSwitchCell*)cell setSwitchON:YES];
        }
        else
        {
            [(FlyingSwitchCell*)cell setItemText:NSLocalizedString(@"Notification ON",nil)];
            [(FlyingSwitchCell*)cell setSwitchON:NO];
        }
    }
    else
    {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:KNoticeVoiceMessage]) {
            
            [(FlyingSwitchCell*)cell setItemText:NSLocalizedString(@"Notification Voice",nil)];
            [(FlyingSwitchCell*)cell setSwitchON:YES];
        }
        else
        {
            [(FlyingSwitchCell*)cell setItemText:NSLocalizedString(@"Notification Voice",nil)];
            [(FlyingSwitchCell*)cell setSwitchON:NO];
        }
    }
    
    [(FlyingSwitchCell*)cell setDelegate:self];

}

#pragma mark - FlyingSwitchCellDelegate

- (void)switchAction:(id)sender
{

    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];

    UITableViewCell * cell = (UITableViewCell*) switchButton.superview;
    NSIndexPath * indexpath = [self.tableView indexPathForCell:cell];
    
    if (indexpath.section ==0) {
        
        [[RCIM sharedRCIM] setDisableMessageNotificaiton:!isButtonOn];
        
        [[NSUserDefaults standardUserDefaults] setBool:isButtonOn forKey:KNoticeNewMessage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else  if (indexpath.section ==0) {
    
        [[RCIM sharedRCIM] setDisableMessageAlertSound:!isButtonOn];
        [[NSUserDefaults standardUserDefaults] setBool:isButtonOn forKey:KNoticeVoiceMessage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
