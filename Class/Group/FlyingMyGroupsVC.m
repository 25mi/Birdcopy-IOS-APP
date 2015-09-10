//
//  FlyingMyGroupsVC.m
//  FlyingEnglish
//
//  Created by vincent on 9/4/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingMyGroupsVC.h"
#import "FlyingHttpTool.h"
#import "FlyingGroupData.h"

#import "UIView+Toast.h"

#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"

#import "RCDChatListViewController.h"

#import "FlyingGroupVC.h"

@interface FlyingMyGroupsVC ()

@end

@implementation FlyingMyGroupsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UITableView *)feedTableView
{
    if (!_feedTableView)
    {
        _feedTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        _feedTableView.delegate = self;
        _feedTableView.dataSource = self;
        _feedTableView.backgroundColor = [UIColor whiteColor];
        _feedTableView.separatorColor = [UIColor clearColor];
        
        [self.view addSubview:_feedTableView];
    }
    
    return _feedTableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    //更新欢迎语言
    self.title =@"我的群组";
    
    //顶部导航
    UIImage* image= [UIImage imageNamed:@"menu"];
    CGRect frame= CGRectMake(0, 0, 28, 28);
    UIButton* menuButton= [[UIButton alloc] initWithFrame:frame];
    [menuButton setBackgroundImage:image forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* menuBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.leftBarButtonItem = menuBarButtonItem;
    
    dispatch_async(dispatch_get_main_queue() , ^{
        [self updateChatIcon];
    });

    _currentGroupData = [NSMutableArray new];
    
    [self loadData];
}

-(void) updateChatIcon
{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_PUBLICSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
    
    UIImage *image;
    if(unreadMsgCount>0)
    {
        image = [UIImage imageNamed:@"chat"];
    }
    else
    {
        image= [UIImage imageNamed:@"chat_b"];
    }
    
    CGRect frame= CGRectMake(0, 0, 24, 24);
    UIButton* chatButton= [[UIButton alloc] initWithFrame:frame];
    [chatButton setBackgroundImage:image forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* chatBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
    image= [UIImage imageNamed:@"People"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doGroup) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:chatBarButtonItem, searchBarButtonItem, nil];
}


-(void) loadData
{
     [FlyingHttpTool getAllFlyingGroupForRecommend:YES
     PageNumber:1
     Completion:^(NSArray *groupList, NSInteger allRecordCount) {

         [self.currentGroupData addObjectsFromArray:groupList];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [self.feedTableView reloadData];
         });

     }];
     
    /*
     
     [FlyingHttpTool getMyGroupsCompletion:^(NSArray *groupList, NSInteger allRecordCount) {
     //
     
     [self.currentGroupData addObjectsFromArray:groupList];
     _maxNumOfGroups=allRecordCount;
     
     dispatch_async(dispatch_get_main_queue(), ^{
     [self finishLoadingData];
     });
     }];
     
     */

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return INTERFACE_IS_PAD ? 674 : 337;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.currentGroupData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlyingMyGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:GROUPCELL_IDENTIFIER];
    
    if (!cell) {
        cell = [[FlyingMyGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GROUPCELL_IDENTIFIER];
    }
    
    FlyingGroupData* groupData = [_currentGroupData objectAtIndex:indexPath.row];
    [cell LoadingGroupData:groupData];
    cell.delegate =self;

    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////
#pragma cell related
//////////////////////////////////////////////////////////////

- (void)memberCountButtonPressed:(FlyingGroupData*)groupData
{}

- (void)lessonCountButtonPressed:(FlyingGroupData*)groupData
{}

- (void)coverImageViewPressed:(FlyingGroupData*)groupData
{
    FlyingGroupVC *groupVC = [FlyingGroupVC new];
    groupVC.groupData=groupData;
    
    [self.navigationController pushViewController:groupVC animated:YES];
}
//////////////////////////////////////////////////////////////
#pragma menu related
//////////////////////////////////////////////////////////////

- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) doGroup
{
    
}

- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        [self.view makeToast:@"PAD版本暂时不支持聊天功能!！"];
        
        return;
    }
    
    RCDChatListViewController  * chatList=[[RCDChatListViewController alloc] init];
    
    [self.navigationController pushViewController:chatList animated:YES];
}


@end
