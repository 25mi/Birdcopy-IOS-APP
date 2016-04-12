//
//  RCDSettingBaseViewController.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDSettingBaseViewController.h"
#import <RongIMLib/RongIMLib.h>

@interface RCDSettingBaseViewController () <UIActionSheetDelegate,
                                            UIViewControllerRestoration>
@end

@implementation RCDSettingBaseViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //默认隐藏顶部视图
    self.headerHidden = YES;
    
    //设置switch状态
    [self setSwitchState];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Setting", @"RongCloudKit", nil); //@"设置";
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 87, 23);
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigator_btn_back"]];
    backImg.frame = CGRectMake(-10, 0, 22, 22);
    [backBtn addSubview:backImg];
    UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 85, 22)];
    backText.text = NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
    backText.font = [UIFont systemFontOfSize:15];
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:self action:@selector(backBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

- (void)backBarButtonItemClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSwitchState {
    
    //设置新消息通知状态
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:self.conversationType
                                                            targetId:self.targetId
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                 
                                                                 BOOL enableNotification = NO;
                                                                 if (nStatus == NOTIFY) {
                                                                     enableNotification = YES;
                                                                 }
                                                                 self.switch_newMessageNotify = enableNotification;
                                                                 
                                                             }
                                                               error:^(RCErrorCode status){
                                                                   
                                                               }];
    
    //设置置顶聊天状态
    RCConversation *conversation =
    [[RCIMClient sharedRCIMClient] getConversation:self.conversationType targetId:self.targetId];
    self.switch_isTop = conversation.isTop;
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickNewMessageNotificationSwitch:(id)sender {
    UISwitch *swch = sender;
    __weak RCDSettingBaseViewController *weakSelf = self;
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:self.conversationType
                                                            targetId:self.targetId
                                                           isBlocked:!swch.on
                                                             success:^(RCConversationNotificationStatus nStatus) {
                                                                 BOOL enableNotification = NO;
                                                                 if (nStatus == NOTIFY) {
                                                                     enableNotification = YES;
                                                                 }
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     weakSelf.switch_newMessageNotify = enableNotification;
                                                                 });
                                                                 
                                                             }
                                                               error:^(RCErrorCode status){
                                                                   
                                                               }];
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickClearMessageHistory:(id)sender
{
    
    NSString *title = @"清除聊天记录";
    NSString *message = nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self clearHistoryMessage];
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:doneAction];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{
        //
    }];

}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self clearHistoryMessage];
    }
}
- (void)clearHistoryMessage {
    BOOL isClear = [[RCIMClient sharedRCIMClient] clearMessages:self.conversationType targetId:self.targetId];
    
    //清除消息之后回调操作，例如reload 会话列表
    if (self.clearHistoryCompletion) {
        self.clearHistoryCompletion(isClear);
    }
}

/**
 *  override
 *
 *  @param sender sender description
 */
- (void)onClickIsTopSwitch:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:self.conversationType targetId:self.targetId isTop:swch.on];
}

// override
- (void)settingTableViewHeader:(RCDConversationSettingTableViewHeader *)settingTableViewHeader
       indexPathOfSelectedItem:(NSIndexPath *)indexPathOfSelectedItem
            allTheSeletedUsers:(NSArray *)users {
}

// override
- (void)deleteTipButtonClicked:(NSIndexPath *)indexPath {
}

@end
