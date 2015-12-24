//
//  FlyingEditVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingEditVC.h"
#import "ACEExpandableTextCell.h"
#import "iFlyingAppDelegate.h"
#import "AFHttpTool.h"
#import "NSString+FlyingExtention.h"
#import "RCDataBaseManager.h"
#import "shareDefine.h"


@interface FlyingEditVC ()<ACEExpandableTableViewDelegate>
{
    CGFloat _cellHeight;
}

@property (strong, nonatomic) UIButton *saveBtn;

@end

@implementation FlyingEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    if (self.isNickName) {
        
        self.title=@"昵称";
    }
    else
    {
        self.title=@"简介";
    }

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
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
    [self.saveBtn  setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [self.saveBtn setHidden:YES];

    [self.saveBtn addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveBtn];
    
    self.navigationItem.rightBarButtonItem=saveButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    ACEExpandableTextCell *cell = [tableView expandableTextCellWithId:@"cellId"];
    
    if(!self.someText)
    {
        cell.textView.placeholder = @"点击这里编辑";
    }
    else
    {
        cell.text=self.someText;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MAX(50.0, _cellHeight);
}

- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath
{
    _cellHeight = height;
}

- (void)tableView:(UITableView *)tableView updatedText:(NSString *)text atIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isNickName) {
        
        if (text && ![text isEqualToString:[NSString getNickName]]) {
            //
            [self.saveBtn setHidden:NO];
            self.someText=text;
        }
        else
        {
            [self.saveBtn setHidden:YES];
        }
    }
    else
    {
        if (text && ![text isEqualToString:[NSString getUserAbstract]]) {
            //
            [self.saveBtn setHidden:NO];
            self.someText=text;
        }
        else
        {
            [self.saveBtn setHidden:YES];
        }
    }
}

- (void)dismiss
{
    if ([self.navigationController.viewControllers count]==1) {
        
        [self showMenu];
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

- (void) doSave
{
    NSString *openID = [NSString getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    NSString* nickName=nil;
    NSString* userAbstract=nil;
    
    if (self.isNickName) {
        
        nickName=self.someText;
    }
    else{
    
        userAbstract=self.someText;
    }
    
    [AFHttpTool refreshUesrWithOpenID:openID
                                 name:nickName
                          portraitUri:nil
                             br_intro:userAbstract
                              success:^(id response) {
                                  
                                  //更新本地用户信息（IM）
                                  RCUserInfo *currentUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
                                  currentUserInfo.name=nickName;
                                  [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
                                  
                                  //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                  [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
                                  
                                  [[RCDataBaseManager shareInstance] insertUserToDB:currentUserInfo];
                                  
                                  //更新本地用户信息（系统）
                                  if (self.isNickName) {
                                      [NSString setNickName:nickName];
                                  }
                                  else
                                  {
                                      [NSString setUserAbstract:userAbstract];
                                  }
                                  
                              } failure:^(NSError *err) {
                                  //
                              }];
    
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
