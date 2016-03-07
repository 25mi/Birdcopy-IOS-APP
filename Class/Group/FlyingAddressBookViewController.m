//
//  FlyingAddressBookViewController.m

#import "FlyingAddressBookViewController.h"
#import "RCDRCIMDataSource.h"
#import <RongIMLib/RongIMLib.h>
#import "FlyingAddressBookTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "shareDefine.h"
#include <ctype.h>
#import "RCDataBaseManager.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"

@interface FlyingAddressBookViewController ()
{
    NSInteger            _maxNumOfPeople;
    NSInteger            _currentLodingIndex;

    BOOL                 _refresh;
    UIRefreshControl    *_refreshControl;
}

//#字符索引对应的user object
@property (nonatomic,strong) NSMutableArray *tempOtherArr;
@property (nonatomic,strong) NSMutableArray *friends;

@property (strong, nonatomic) UITableView        *adressTableView;


@end

@implementation FlyingAddressBookViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"通讯录";
    
    [self addBackFunction];
    
    [self getAllData];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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

//删除已选中用户
-(void) removeSelectedUsers:(NSArray *) selectedUsers
{
    for (RCUserInfo *user in selectedUsers) {
        
        [_friends enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RCUserInfo *userInfo = obj;
            if ([user.userId isEqualToString:userInfo.userId]) {
                [_friends removeObject:obj];
            }
            
        }];
    }

}
//////////////////////////////////////////////////////////////
#pragma mark - Loading data and setup view
//////////////////////////////////////////////////////////////

- (void)reloadAll
{
    if (!self.adressTableView)
    {
        self.adressTableView = [[UITableView alloc] initWithFrame: CGRectMake(0.0f, 0, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
        
        //必须在设置delegate之前
        UINib *nib = [UINib nibWithNibName:@"FlyingGroupTableViewCell" bundle: nil];
        [self.adressTableView registerNib:nib  forCellReuseIdentifier:@"FlyingGroupTableViewCell"];
        
        self.adressTableView.delegate = self;
        self.adressTableView.dataSource = self;
        self.adressTableView.backgroundColor = [UIColor clearColor];
        
        
        [self.view addSubview:self.adressTableView];
        
        _currentLodingIndex=0;
        _maxNumOfPeople=NSIntegerMax;
        
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshNow:) forControlEvents:UIControlEventValueChanged];
        [self.adressTableView addSubview:_refreshControl];
    }
    else
    {
        _currentLodingIndex=0;
        _maxNumOfPeople=NSIntegerMax;
    }
    
    [self getAllData];
}


/**
 *  initial data
 */
-(void) getAllData
{
    _keys = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#"];
    _allFriends = [NSMutableDictionary new];
    _allKeys = [NSMutableArray new];
    _friends = [NSMutableArray arrayWithArray:[[RCDataBaseManager shareInstance] getAllFriends] ];
    if (_friends==nil||_friends.count<1) {
        
        /*[RCDDataSource syncFriendList:^(NSMutableArray * result) {
            _friends=result;
            if (_friends.count < 20) {
                self.hideSectionHeader = YES;
            }
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                _allFriends = [self sortedArrayWithPinYinDic:_friends];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    
                });
            });

        }];
         */
    }else
    {
        if (_friends.count < 20) {
            self.hideSectionHeader = YES;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            _allFriends = [self sortedArrayWithPinYinDic:_friends];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.adressTableView reloadData];
                
            });
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *key = [_allKeys objectAtIndex:indexPath.section];
    NSArray *arrayForKey = [_allFriends objectForKey:key];

    RCUserInfo *user = arrayForKey[indexPath.row];
    
    // 普通Cell
    FlyingAddressBookTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:ADRESSCELL_IDENTIFIER];
    
    if (!cell) {
        cell = [FlyingAddressBookTableViewCell adressBookCell];
    }
    
    //[self configureCell:cell atIndexPath:indexPath];

    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_allKeys objectAtIndex:section];
    
    NSArray *arr = [_allFriends objectForKey:key];

    return [arr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    return [_allKeys count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.f;
}

//pinyin index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (self.hideSectionHeader) {
        return nil;
    }
    return _allKeys;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.hideSectionHeader) {
        return nil;
    }

    NSString *key = [_allKeys objectAtIndex:section];
    return key;
    
}

#pragma mark - 拼音排序

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
-(NSString *) hanZiToPinYinWithString:(NSString *)hanZi
{
    if(!hanZi) return nil;
    NSString *pinYinResult=[NSString string];
    for(int j=0;j<hanZi.length;j++){
        NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([hanZi characterAtIndex:j])] uppercaseString];
        pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
        
    }
    
    return pinYinResult;

}

/**
 *  根据转换拼音后的字典排序
 *
 *  @param pinyinDic 转换后的字典
 *
 *  @return 对应排序的字典
 */
-(NSMutableDictionary *) sortedArrayWithPinYinDic:(NSArray *) friends
{
    if(!friends) return nil;
    
    NSMutableDictionary *returnDic = [NSMutableDictionary new];
    _tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;
    
    for (NSString *key in _keys) {
        
        if ([_tempOtherArr count]) {
            isReturn = YES;
        }
        
        NSMutableArray *tempArr = [NSMutableArray new];
        for (RCUserInfo *user in friends) {
            
            NSString *pyResult = [self hanZiToPinYinWithString:user.name];
            NSString *firstLetter = [pyResult substringToIndex:1];
            if ([firstLetter isEqualToString:key]){
                [tempArr addObject:user];
            }
            
            if(isReturn) continue;
            char c = [pyResult characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:user];
            }
        }
        if(![tempArr count]) continue;
        [returnDic setObject:tempArr forKey:key];
        
    }
    if([_tempOtherArr count])
        [returnDic setObject:_tempOtherArr forKey:@"#"];
    
    
    _allKeys = [[returnDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    return returnDic;
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate shakeNow];
    }
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
