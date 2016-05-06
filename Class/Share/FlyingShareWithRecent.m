//
//  FlyingShareWithRecent.m
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingShareWithRecent.h"
#import "UIColor+RCColor.h"
#import "iFlyingAppDelegate.h"
#import "NSString+FlyingExtention.h"

@interface FlyingShareWithRecent ()<UIViewControllerRestoration>

@end

@implementation FlyingShareWithRecent

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"请选择分享好友";
    
    //待定？
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:19];
    titleView.textColor = [UIColor whiteColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.text = @"会话";
    self.tabBarController.navigationItem.titleView = titleView;
    
    //顶部导航
    UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    //设置要显示的会话类型
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)]];
    
    //设置为不用默认渲染方式
    self.tabBarItem.image = [[UIImage imageNamed:@"icon_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_chat_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    self.conversationListTableView.tableFooterView = [UIView new];
    //    self.conversationListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 12)];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) dismissNavigation
{
    [self willDismiss];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) willDismiss
{
}

/**
 *  点击进入会话界面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL)
    {
        
        NSString *message = nil;
        
        if ([self.message isKindOfClass:[RCRichContentMessage class]])
        {
            RCRichContentMessage * richContent = (RCRichContentMessage * )self.message;
    
            message = richContent.title;
        }
        
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"分享"
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField*textField) {
            
            textField.placeholder=@"留言";
        }];
        
        UIAlertAction *doneAction = [UIAlertAction   actionWithTitle:@"发送" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //
            [self dismissNavigation];
            
            // 调用RCIMClient的sendMessage方法进行发送，结果会通过回调进行反馈。
            [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE
                                              targetId:model.targetId
                                               content:self.message
                                           pushContent:nil
                                              pushData:nil
                                               success:^(long messageId) {
                                                   
                                                   NSString * msg = alertVC.textFields[0].text;
                                                   
                                                   if(![NSString isBlankString:msg])
                                                   {
                                                   
                                                      RCTextMessage *textMsg = [[RCTextMessage alloc] init];
                                                       textMsg.content = msg;
                                                       
                                                       [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE
                                                                                         targetId:model.targetId
                                                                                          content:textMsg
                                                                                      pushContent:nil
                                                                                         pushData:nil
                                                        success:^(long messageId) {
                                                            //
                                                        } error:^(RCErrorCode nErrorCode, long messageId) {
                                                            //
                                                        }];
                                                   }
                                                   
                                               } error:^(RCErrorCode nErrorCode, long messageId) {
                                                   
                                               }];

        } ];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //
            [self dismissNavigation];
        }];
        
        [alertVC addAction:cancelAction];
        [alertVC addAction:doneAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        
    }
    
    //聚合会话类型，此处自定设置。
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
        
        NSLog(@"不能有聚合类型，如果要支持，要单独实现");
        
        /*
         RCDChatListViewController *temp = [[RCDChatListViewController alloc] init];
         NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
         [temp setDisplayConversationTypes:array];
         [temp setCollectionConversationType:nil];
         temp.isEnteredToCollectionViewController = YES;
         [self.navigationController pushViewController:temp animated:YES];
         */
    }
    
    //自定义会话类型
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION)
    {
    }
    
    [super onSelectedTableRow:conversationModelType conversationModel:model atIndexPath:indexPath];
}


//高度
-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0f;
}

@end
