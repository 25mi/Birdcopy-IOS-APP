//
//  FlyingOpenIDVC.m
//  FlyingEnglish
//
//  Created by vincent on 5/28/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingOpenIDVC.h"
#import "ACEExpandableTextCell.h"
#import "RESideMenu.h"
#import "iFlyingAppDelegate.h"
#import "UICKeyChainStore.h"
#import "AFHttpTool.h"
#import "NSString+FlyingExtention.h"
#import "RCDataBaseManager.h"
#import "shareDefine.h"

@interface FlyingOpenIDVC ()<ACEExpandableTableViewDelegate>
{
    CGFloat _cellHeight[2];
}

@property (nonatomic, strong) NSMutableArray *cellData;

@end

@implementation FlyingOpenIDVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    self.title=@"我的账户";
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
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
    [saveBtn  setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];

    [saveBtn addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    
    self.navigationItem.rightBarButtonItem=saveButtonItem;
    
    NSString *nickName=[UICKeyChainStore keyChainStore][kUserNickName];
    NSString *userAbstract=[UICKeyChainStore keyChainStore][kUserAbstract];
    
    if (!nickName || nickName.length==0) {
        
        nickName =[[UIDevice currentDevice] name];
    }
    
    if (!userAbstract || userAbstract.length==0) {
        
        userAbstract = @"我就是我，一个英语菜鸟：）";
    }
    
    self.cellData = [NSMutableArray arrayWithArray:@[nickName,userAbstract]];
    
    self.tableView.separatorStyle = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    ACEExpandableTextCell *cell = [tableView expandableTextCellWithId:@"cellId"];
    cell.text = [self.cellData objectAtIndex:indexPath.section];
    
    if (indexPath.section==0) {
        
        cell.textView.placeholder = @"这里编辑你的昵称";
    }
    else
    {
        cell.textView.placeholder = @"这里输入你的简介，让别人更有人气：）";
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return @"昵称";
    }
    else
    {
        return @"我的简介";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MAX(50.0, _cellHeight[indexPath.section]);
}

- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath
{
    _cellHeight[indexPath.section] = height;
}

- (void)tableView:(UITableView *)tableView updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath
{
    [_cellData replaceObjectAtIndex:indexPath.section withObject:text];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) doSave
{
    NSString * nickName = [self.cellData objectAtIndex:0];
    NSString * userAbstract = [self.cellData objectAtIndex:1];

    NSString *oldNickName =[UICKeyChainStore keyChainStore][kUserNickName];
    NSString *oldUserAbstract=[UICKeyChainStore keyChainStore][kUserAbstract];

    [UICKeyChainStore keyChainStore][kUserNickName] = nickName;
    [UICKeyChainStore keyChainStore][kUserAbstract] = userAbstract;
    
    if (![nickName  isEqualToString:oldNickName]||
        ![userAbstract  isEqualToString:oldUserAbstract]
        )
    {
        
        NSString *openID = [NSString getOpenUDID];
        
        if (!openID) {
            
            return;
        }
        
        [AFHttpTool refreshUesrWithOpenID:openID
                                     name:nickName
                              portraitUri:nil
                                 br_intro:userAbstract
                                  success:^(id response) {
            //
            RCUserInfo *currentUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
            currentUserInfo.name=nickName;
            [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
            
            //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
            [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
            
            [[RCDataBaseManager shareInstance] insertUserToDB:currentUserInfo];
            
        } failure:^(NSError *err) {
            //
            
            [UICKeyChainStore keyChainStore][kUserNickName] = oldNickName;
            [UICKeyChainStore keyChainStore][kUserAbstract] = oldUserAbstract;
            
            RCUserInfo *currentUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
            currentUserInfo.name=oldNickName;
            [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
            
            [[RCDataBaseManager shareInstance] insertUserToDB:currentUserInfo];
        }];
    }
    
    [self dismiss];
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
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

@end
