//
//  RCDSelectPersonViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/27.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "FlyingSelectPersonViewController.h"
#import "FlyingSelectPersonTableViewCell.h"
#import "UIImage+localFile.h"
#import "RCDRCIMDataSource.h"
#import "FlyingConversationVC.h"
#import "RCDataBaseManager.h"


@interface FlyingSelectPersonViewController()<UIViewControllerRestoration>

@end

@implementation FlyingSelectPersonViewController

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

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"选择联系人";
    
    //控制多选
    
    [super setallowsMultipleSelection:YES];
    
    //rightBarButtonItem click event
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(clickedDone:)];

}


//clicked done
-(void) clickedDone:(id) sender
{
    NSArray *indexPaths = [super indexPathsForSelectedRows];
    if (!indexPaths||indexPaths.count == 0){
                
        NSString *title = nil;
        NSString *message = @"请选择联系人!";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@" 确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{
            //
        }];
        
        return;
    }
    
    //get seleted users
    NSMutableArray *seletedUsers = [NSMutableArray new];
    for (NSIndexPath *indexPath in indexPaths) {
       
        RCUserInfo *userInfo = [self getUserIofo:indexPath];
        [seletedUsers addObject:userInfo];
        
        [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];

    }
    
    
    //excute the clickDoneCompletion
    if (self.clickDoneCompletion) {
        self.clickDoneCompletion(self,seletedUsers);
    }
}




//override delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.f;
}


//override datasource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 普通Cell
    FlyingSelectPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlyingSelectPersonTableViewCell"];
    
    if (!cell) {
        cell = [FlyingSelectPersonTableViewCell selectPersonCell];
    }
    
    [self configureCell:cell atIndexPath:indexPath];

    [cell setUserInteractionEnabled:YES];

    
    RCUserInfo *userInfo = [self getUserIofo:indexPath];
    
    //设置选中状态
    for (RCUserInfo *user in self.seletedUsers) {
        
        if ([userInfo.userId isEqualToString:user.userId]) {
            
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            [cell setUserInteractionEnabled:NO];
            
            break;
        }
    }


    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [(FlyingSelectPersonTableViewCell*)cell settingWithContentData:[self getUserIofo:indexPath]];
}


//override delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlyingSelectPersonTableViewCell *cell = (FlyingSelectPersonTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:YES];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FlyingSelectPersonTableViewCell *cell = (FlyingSelectPersonTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
}


@end
