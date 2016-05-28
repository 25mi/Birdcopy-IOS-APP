//
//  FlyingBuyVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 4/4/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingBuyVC.h"
#import "iFlyingAppDelegate.h"
#import "FlyingMemberTableViewCell.h"
#import "FlyingStatisitcTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "FlyingImageTextCell.h"
#import "FlyingDataManager.h"
#import "FlyingStatisticDAO.h"
#import "FlyingSoundPlayer.h"

@interface FlyingBuyVC()<
                        UITableViewDataSource,
                        UITableViewDelegate,
                        UIViewControllerRestoration>

@property (strong, nonatomic) UITableView        *tableView;

@end


@implementation FlyingBuyVC

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
    
    //更新欢迎语言
    self.title = NSLocalizedString(@"My Service",nil);
    
    [self reloadAll];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:KBEAccountChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self.tableView reloadData];
                                                      //[self.tableView reloadData];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBEAccountChange    object:nil];
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
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingMemberTableViewCell" bundle:nil]
                    forCellReuseIdentifier:@"FlyingMemberTableViewCell"];

        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingStatisitcTableViewCell" bundle:nil]
                    forCellReuseIdentifier:@"FlyingStatisitcTableViewCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"FlyingImageTextCell" bundle:nil]
                    forCellReuseIdentifier:@"FlyingImageTextCell"];
        
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
    if (section == 1)
    {
        return 22;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 4;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                //年费相关
                FlyingMemberTableViewCell  *memberTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingMemberTableViewCell"];
                
                if(memberTableViewCell == nil)
                    memberTableViewCell = [FlyingMemberTableViewCell memberTableCell];
                
                [self configureCell:memberTableViewCell atIndexPath:indexPath];

                cell = memberTableViewCell;
                
                break;
            }
            case 1:
            {
                //金币相关
                FlyingStatisitcTableViewCell *statisticTableView = [tableView dequeueReusableCellWithIdentifier:@"FlyingStatisitcTableViewCell"];
                
                if(statisticTableView == nil)
                    statisticTableView = [FlyingStatisitcTableViewCell statisticTableCell];
                
                [self configureCell:statisticTableView atIndexPath:indexPath];
     
                cell = statisticTableView;
            }
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        //金币相关
        FlyingImageTextCell *buyTabelViewCell = [tableView dequeueReusableCellWithIdentifier:@"FlyingImageTextCell"];
        
        if(buyTabelViewCell == nil)
            buyTabelViewCell = [FlyingImageTextCell imageTextCell];
        
        [self configureCell:buyTabelViewCell atIndexPath:indexPath];
        
        cell = buyTabelViewCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
                
            case 0:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingMemberTableViewCell"
                                                       cacheByIndexPath:indexPath
                                                          configuration:^(FlyingMemberTableViewCell *cell) {
                    [self configureCell:cell atIndexPath:indexPath];
                }];
                
                break;
            }
            case 1:
            {
                height = [self.tableView fd_heightForCellWithIdentifier:@"FlyingStatisitcTableViewCell"
                                                       cacheByIndexPath:indexPath
                                                          configuration:^(FlyingStatisitcTableViewCell *cell) {
                    [self configureCell:cell atIndexPath:indexPath];
                }];
                
                break;
            }
        }
        
    }
    
    else if (indexPath.section == 1)
    {
        //height =  [self.tableView fd_heightForCellWithIdentifier:@"FlyingBuyViewCell" configuration:^(FlyingBuyViewCell *cell) {
        //    [self configureCell:cell atIndexPath:indexPath];
        //}];
        
        height = 47.5;
    }
    
    return height;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            
            case 0:
            {
                [(FlyingMemberTableViewCell *)cell setPortraitURL:[FlyingDataManager getUserData:[FlyingDataManager getOpenUDID]].portraitUri];
                
                FlyingUserRightData* userRight = [FlyingDataManager getUserRightForDomainID:[FlyingDataManager getAppData].appID
                                                                                 domainType:BC_Domain_Business];
                
                [(FlyingMemberTableViewCell *)cell setStart:userRight.startDate];
                [(FlyingMemberTableViewCell *)cell setEnd:userRight.endDate];

                
                break;
            }
            case 1:
            {
                FlyingStatisticDAO * statisticDAO = [[FlyingStatisticDAO alloc] init];
                [statisticDAO initDataForUserID:[FlyingDataManager getOpenUDID]];
                
                [(FlyingStatisitcTableViewCell*)cell setCurrent:@([statisticDAO finalMoneyWithUserID:[FlyingDataManager getOpenUDID]]).stringValue];
                [(FlyingStatisitcTableViewCell*)cell setBuy:@([statisticDAO totalBuyMoneyWithUserID:[FlyingDataManager getOpenUDID]]).stringValue];
                [(FlyingStatisitcTableViewCell*)cell setAward:@([statisticDAO giftCountWithUserID:[FlyingDataManager getOpenUDID]]+KBEFreeTouchCount).stringValue];
                [(FlyingStatisitcTableViewCell*)cell setConsume:@([statisticDAO touchCountWithUserID:[FlyingDataManager getOpenUDID]]).stringValue];
                break;
            }
        
            default:
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        NSString * priceStr;
        
        switch (indexPath.row) {
            case 0:
            {
                priceStr = NSLocalizedString(@"Price Info:500",nil);
                break;
            }
                
            case 1:
            {
                priceStr = NSLocalizedString(@"Price Info:2000",nil);
                break;
            }
                
            case 2:
            {
                priceStr = NSLocalizedString(@"Price Info:10000",nil);
                break;
            }
                
            case 3:
            {
                priceStr = NSLocalizedString(@"Price Info:member",nil);
                break;
            }
                
            default:
                break;
        }

        [(FlyingImageTextCell*)cell setImageIcon:[UIImage imageNamed:@"Price"]];

        [(FlyingImageTextCell*)cell setCellText:priceStr];
    }
}

-(void) toBuyMember
{
    FlyingUserRightData * userRightData = [FlyingDataManager getUserRightForDomainID:[FlyingDataManager getAppData].appID
                                                                          domainType:BC_Domain_Business];
    if ([userRightData checkRightPresent]) {
        
        NSString *title = NSLocalizedString(@"Attenion Please",nil);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *endTime = [formatter stringFromDate:userRightData.endDate];
        
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Member End:%@", nil),endTime];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{
            //
        }];
    }
    else
    {
        NSString *title = NSLocalizedString(@"Attenion Please",nil);
        
        NSString *message =NSLocalizedString(@"I want to purchase year-membership", nil);
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Destructive",nil)
                                                             style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 NSArray *availableProducts = [[MKStoreKit  sharedKit] availableProducts];
                                                                 
                                                                 [availableProducts enumerateObjectsUsingBlock:^(SKProduct* product, NSUInteger idx, BOOL * _Nonnull stop) {
                                                                     //
                                                                     if ([product.productIdentifier containsString:@"membership"]) {
                                                                         
                                                                         [FlyingDataManager buyAppleIdentify:product];
                                                                         
                                                                         *stop=YES;
                                                                     }
                                                                 }];
                                                             }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                               style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                                                   
                                                               }];
        
        [alertController addAction:doneAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{
            //
        }];
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - UITableView Delegate methods
//////////////////////////////////////////////////////////////

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
                
            case 0:
            {
                [self toBuyMember];
               
                break;
            }
        }
    }
    else if (indexPath.section == 1)
    {
        
        if ([SKPaymentQueue canMakePayments])
        {
            
            NSArray *availableProducts = [[MKStoreKit  sharedKit] availableProducts];
            
            if (availableProducts.count>0) {
                
                
                switch (indexPath.row) {
                        
                    case 0:
                    {
                        [availableProducts enumerateObjectsUsingBlock:^(SKProduct* product, NSUInteger idx, BOOL * _Nonnull stop) {
                            //
                            
                            if ([product.productIdentifier containsString:@"500coins"]) {
                                
                                [FlyingDataManager buyAppleIdentify:product];
                                
                                *stop=YES;
                            }
                        }];
                        break;
                    }
                        
                    case 1:
                    {
                        [availableProducts enumerateObjectsUsingBlock:^(SKProduct* product, NSUInteger idx, BOOL * _Nonnull stop) {
                            //
                            
                            if ([product.productIdentifier containsString:@"2000coins"]) {
                                
                                [FlyingDataManager buyAppleIdentify:product];
                                
                                *stop=YES;
                            }
                        }];
                        break;
                    }
                        
                    case 2:
                    {
                        [availableProducts enumerateObjectsUsingBlock:^(SKProduct* product, NSUInteger idx, BOOL * _Nonnull stop) {
                            //
                            
                            if ([product.productIdentifier containsString:@"10000coins"]) {
                                
                                [FlyingDataManager buyAppleIdentify:product];
                                
                                *stop=YES;
                            }
                        }];
                        
                        break;
                    }
                        
                    case 3:
                    {
                        [self toBuyMember];
                        
                        break;
                    }
                        
                }

            }
        }
        else
        {
            //即时反馈
            iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSString * message = NSLocalizedString(@"In App Purchasing Disabled", nil);
            [appDelegate makeToast:message];
        }
    }
}

@end
