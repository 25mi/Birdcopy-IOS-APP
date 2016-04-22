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
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"
#import "FlyingUserData.h"

@interface FlyingEditVC ()<ACEExpandableTableViewDelegate,
                            UIViewControllerRestoration>
{
    CGFloat _cellHeight;
}

@property (strong, nonatomic) UIButton *saveBtn;

@end

@implementation FlyingEditVC

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeBool:self.isNickName forKey:@"self.isNickName"];
    [coder encodeObject:self.someText forKey:@"self.someText"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    
    self.isNickName = [coder decodeBoolForKey:@"self.isNickName"];
    self.someText = [coder decodeObjectForKey:@"self.someText"];
    
    [super decodeRestorableStateWithCoder:coder];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        self.tableView.restorationIdentifier = @"edit.tableview";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
   
    //顶部导航
    if(self.navigationController.viewControllers.count>1)
    {
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }

    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 56, 56)];
    [self.saveBtn  setTitle:NSLocalizedString(@"Save", nil)
                   forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
    [self.saveBtn setHidden:YES];

    [self.saveBtn addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveBtn];
    
    self.navigationItem.rightBarButtonItem=saveButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.isNickName) {
        
        self.title=NSLocalizedString(@"NickName", nil);
    }
    else
    {
        self.title=NSLocalizedString(@"Who am I", nil);
    }
    
    if ([self.navigationController.viewControllers count]>1) {
        
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
        
        [self.tabBarController.tabBar setHidden:YES];
    }
    else
    {
        [self.tabBarController.tabBar setHidden:NO];
    }

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) dismissNavigation
{
    [self willDismiss];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//子类具体实现具体功能
- (void) willDismiss
{
}

- (void) doSave
{
    NSString *openID = [FlyingDataManager getOpenUDID];
    
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
                                  
                                  if (self.isNickName) {
                                      
                                      currentUserInfo.name=nickName;
                                  }
                                  else
                                  {
                                      [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
                                  }

                                  //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                  [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
                                  [[RCDataBaseManager shareInstance] insertUserToDB:currentUserInfo];
                                  
                                  //更新本地用户信息（系统）
                                  FlyingUserData * userData = [FlyingDataManager getUserData:nil];
                                  
                                  if (self.isNickName) {
                                      
                                      if (![NSString isBlankString:nickName]) {
                                          
                                          userData.name = nickName;
                                      }
                                  }
                                  else
                                  {
                                      if (![NSString isBlankString:userAbstract]) {
                                          
                                          userData.digest = userAbstract;
                                      }
                                  }
                                  
                                  [FlyingDataManager saveUserData:userData];
                                  
                                  [self dismissNavigation];
                                  
                              } failure:^(NSError *err) {
                                  //
                              }];
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
        
        if (text && ![text isEqualToString:[FlyingDataManager getUserData:nil].name]) {
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
        if (text && ![text isEqualToString:[FlyingDataManager getUserData:nil].digest]) {
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
        
        [self dismissNavigation];
    }
}
@end
