//
//  FlyingConversationVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/25/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//
#import "FlyingConversationVC.h"

#import "RCDataBaseManager.h"

#import "RealTimeLocationViewController.h"
#import "RealTimeLocationStartCell.h"
#import "RealTimeLocationStatusView.h"
#import "RealTimeLocationEndCell.h"

#import "RCDPrivateSettingViewController.h"
#import "RCDRoomSettingViewController.h"

#import "FlyingHttpTool.h"
#import "iFlyingAppDelegate.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "FlyingWebViewController.h"
#import "NSString+FlyingExtention.h"
#import "FlyingLessonParser.h"
#import "FlyingContentVC.h"
#import <AFNetworking.h>
#import  "ZXingObjC.h"
#import "FlyingSoundPlayer.h"
#import "FlyingScanViewController.h"
#import "FlyingImagePreivewVC.h"
#import "UIView+Toast.h"
#import "FlyingHttpTool.h"
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"
#import "FlyingShareWithRecent.h"
#import "FlyingProfileVC.h"
#import "FlyingGroupVC.h"

@interface FlyingConversationVC () <RCRealTimeLocationObserver,
                                    RealTimeLocationStatusViewDelegate,
                                    RCMessageCellDelegate,
                                    UIViewControllerRestoration>

@property (nonatomic, weak)id<RCRealTimeLocationProxy> realTimeLocation;
@property (nonatomic, strong)RealTimeLocationStatusView *realTimeLocationStatusView;

@property (strong,nonatomic) RCMessageModel *theMessagemodel;

@end

@implementation  FlyingConversationVC


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeObject:self.title forKey:@"self.title"];
    [coder encodeObject:self.targetId forKey:@"self.targetId"];
    [coder encodeInteger:self.conversationType forKey:@"self.conversationType"];
    
    if (![self.domainID isBlankString]) {
        
        [coder encodeObject:self.domainID forKey:@"self.domainID"];
    }
    
    if (![self.domainType isBlankString]) {
        
        [coder encodeObject:self.domainType forKey:@"self.domainType"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.title =[coder decodeObjectForKey:@"self.title"];
    self.conversationType = [coder decodeIntegerForKey:@"self.conversationType"];
    self.targetId = [coder decodeObjectForKey:@"self.targetId"];
    self.domainID = [coder decodeObjectForKey:@"self.domainID"];
    self.domainType = [coder decodeObjectForKey:@"self.domainType"];
    
    [self.conversationMessageCollectionView reloadData];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
        
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
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
    
    UIButton* settingButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [settingButton setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(rightBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* settingBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    
    if (self.conversationType != ConversationType_CHATROOM) {

        self.navigationItem.rightBarButtonItem = settingBarButtonItem;
    }
    
    self.enableSaveNewPhotoToLocalSystem = YES;
    
    //顶部导航
  
    if (self.conversationType == ConversationType_PRIVATE)
    {
        RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:self.targetId];
        
        if (userInfo)
        {
            
            self.title = userInfo.name;
        }
        else
        {
            [FlyingHttpTool getUserInfoByRongID:self.targetId
                                     completion:^(FlyingUserData *userData, RCUserInfo *userInfo) {
                                         //
                                     }];
        }
        
    }
    
    /*******************实时地理位置共享***************/
    [self registerClass:[RealTimeLocationStartCell class] forCellWithReuseIdentifier:RCRealTimeLocationStartMessageTypeIdentifier];
    [self registerClass:[RealTimeLocationEndCell class] forCellWithReuseIdentifier:RCRealTimeLocationEndMessageTypeIdentifier];
    [self registerClass:[RCUnknownMessageCell class] forCellWithReuseIdentifier:RCUnknownMessageTypeIdentifier];
    
    __weak typeof(&*self) weakSelf = self;
    [[RCRealTimeLocationManager sharedManager] getRealTimeLocationProxy:self.conversationType targetId:self.targetId success:^(id<RCRealTimeLocationProxy> realTimeLocation) {
        weakSelf.realTimeLocation = realTimeLocation;
        [weakSelf.realTimeLocation addRealTimeLocationObserver:self];
        [weakSelf updateRealTimeLocationStatus];
    } error:^(RCRealTimeLocationErrorCode status) {
        NSLog(@"get location share failure with code %d", (int)status);
    }];
    
    /******************实时地理位置共享**************/
    
    ///注册自定义测试消息Cell
    //[self registerClass:[RCDTestMessageCell class] forCellWithReuseIdentifier:RCDTestMessageTypeIdentifier];
    
    [self notifyUpdateUnreadMessageCount];
    
    //如果是单聊，不显示发送方昵称
    if (self.conversationType == ConversationType_PRIVATE) {
        self.displayUserNameInCell = NO;
    }
    
    [self.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"Help"]
                                        title:@"参与设计"
                                          tag:101];
    
    //    self.chatSessionInputBarControl.hidden = YES;
    //    CGRect intputTextRect = self.conversationMessageCollectionView.frame;
    //    intputTextRect.size.height = intputTextRect.size.height+50;
    //    [self.conversationMessageCollectionView setFrame:intputTextRect];
    //    [self scrollToBottomAnimated:YES];
    /***********如何自定义面板功能***********************
     自定义面板功能首先要继承RCConversationViewController，如现在所在的这个文件。
     然后在viewDidLoad函数的super函数之后去编辑按钮：
     插入到指定位置的方法如下：
     [self.pluginBoardView insertItemWithImage:imagePic
     title:title
     atIndex:0
     tag:101];
     或添加到最后的：
     [self.pluginBoardView insertItemWithImage:imagePic
     title:title
     tag:101];
     删除指定位置的方法：
     [self.pluginBoardView removeItemAtIndex:0];
     删除指定标签的方法：
     [self.pluginBoardView removeItemWithTag:101];
     删除所有：
     [self.pluginBoardView removeAllItems];
     更换现有扩展项的图标和标题:
     [self.pluginBoardView updateItemAtIndex:0 image:newImage title:newTitle];
     或者根据tag来更换
     [self.pluginBoardView updateItemWithTag:101 image:newImage title:newTitle];
     以上所有的接口都在RCPluginBoardView.h可以查到。
     
     当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
     pluginBoardView:clickedItemWithTag:
     在super之后加上自己的处理。
     
     */
    
    //默认输入类型为语音
    //self.defaultInputType = RCChatSessionInputBarInputExtention;
    
    
    /***********如何在会话界面插入提醒消息***********************
     
     RCInformationNotificationMessage *warningMsg = [RCInformationNotificationMessage notificationWithMessage:@"请不要轻易给陌生人汇钱！" extra:nil];
     BOOL saveToDB = NO;  //是否保存到数据库中
     RCMessage *savedMsg ;
     if (saveToDB) {
     savedMsg = [[RCIMClient sharedRCIMClient] insertMessage:self.conversationType targetId:self.targetId senderUserId:[RCIMClient sharedRCIMClient].currentUserInfo.userId sendStatus:SentStatus_SENT content:warningMsg];
     } else {
     savedMsg =[[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:MessageDirection_SEND messageId:-1 content:warningMsg];//注意messageId要设置为－1
     }
     [self appendAndDisplayMessage:savedMsg];
     */
    
    self.enableContinuousReadUnreadVoice = YES;//开启语音连读功能
}

-(void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
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

- (void)leftBarButtonItemPressed:(id)sender {
    
    if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_OUTGOING ||
        [self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_CONNECTED) {
        
        NSString *title = nil;
        NSString *message = @"退出当前界面位置共享会终止，确定要退出？";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            [self.realTimeLocation quitRealTimeLocation];
            [self popupChatViewController];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:doneAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{
            //
        }];
        
    } else {
        
        [self popupChatViewController];
    }
}

- (void)popupChatViewController {
    [super leftBarButtonItemPressed:nil];
    [self.realTimeLocation removeRealTimeLocationObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)rightBarButtonItemClicked:(id)sender {
    
    if (self.conversationType == ConversationType_PRIVATE) {
        
        RCDPrivateSettingViewController *settingVC =
        [[RCDPrivateSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        //    settingVC.conversationTitle = self.userName;
        //    //设置讨论组标题时，改变当前聊天界面的标题
        //    settingVC.setDiscussTitleCompletion = ^(NSString *discussTitle) {
        //      self.title = discussTitle;
        //    };
        //清除聊天记录之后reload data
        __weak  FlyingConversationVC *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        
        [self.navigationController pushViewController:settingVC animated:YES];
        
    }
    
    //讨论组设置
    else if (self.conversationType == ConversationType_DISCUSSION) {
        
        RCDDiscussGroupSettingViewController *settingVC =
        [[RCDDiscussGroupSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        settingVC.conversationTitle = self.title;
        //设置讨论组标题时，改变当前聊天界面的标题
        settingVC.setDiscussTitleCompletion = ^(NSString *discussTitle) {
            self.title = discussTitle;
        };
        //清除聊天记录之后reload data
        __weak  FlyingConversationVC *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
    //聊天室设置
    else if (self.conversationType == ConversationType_CHATROOM) {
        RCDRoomSettingViewController *settingVC =
        [[RCDRoomSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    
    //客服设置
    else if (self.conversationType == ConversationType_CUSTOMERSERVICE) {
        RCDSettingBaseViewController *settingVC = [[RCDSettingBaseViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        //清除聊天记录之后reload data
        __weak  FlyingConversationVC *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        [self.navigationController pushViewController:settingVC animated:YES];
    }else if (ConversationType_APPSERVICE == self.conversationType ||
              ConversationType_PUBLICSERVICE == self.conversationType) {
        RCPublicServiceProfile *serviceProfile = [[RCIMClient sharedRCIMClient]
                                                  getPublicServiceProfile:(RCPublicServiceType)self.conversationType
                                                  publicServiceId:self.targetId];
        
        RCPublicServiceProfileViewController *infoVC =
        [[RCPublicServiceProfileViewController alloc] init];
        infoVC.serviceProfile = serviceProfile;
        infoVC.fromConversation = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    }
    
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    
    switch (tag) {
            
        case 101: {
            //这里加你自己的事件处理
            
            [self showSurvey];
            
            break;
        }
            
        case PLUGIN_BOARD_ITEM_LOCATION_TAG: {
            
            if (self.realTimeLocation) {
                
                NSString *title = @"选择操作方式";
                NSString *message = nil;
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                         message:message
                                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction *doneAction1 = [UIAlertAction actionWithTitle:@"发送位置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                   
                    [super pluginBoardView:self.pluginBoardView clickedItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
                }];
                
                UIAlertAction *doneAction2 = [UIAlertAction actionWithTitle:@"位置实时共享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self showRealTimeLocationViewController];
                }];
                
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertController addAction:doneAction1];
                [alertController addAction:doneAction2];
                
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:^{
                    //
                }];

                
            } else {
                
                [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            }
            
            break;
        }
        default:
        {
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
        }
    }
}

-(void) showSurvey
{
    FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
    webVC.title=@"参与设计";
    [webVC setWebURL:@"http://www.mikecrm.com/f.php?t=UkWGrx"];
    
    [self.navigationController pushViewController:webVC animated:YES];
}

/*!
 准备发送消息的回调
 
 @param messageCotent 消息内容
 
 @return 修改后的消息内容
 
 @discussion 此回调在消息准备向外发送时会回调，您可以在此回调中对消息内容进行过滤和修改等操作。
 如果此回调的返回值不为nil，SDK会对外发送返回的消息内容。
 */
- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageCotent
{
    BOOL access = YES;
    
    FlyingUserRightData * userRightData = [FlyingDataManager getUserRightForDomainID:self.domainID
                                                                          domainType:self.domainType];
    //如果是群组，那么只有正式会员才能对话
    if([self.domainType isEqualToString:BC_Domain_Group])
    {
        if (![userRightData checkRightPresent]) {
            
            access = NO;
        }
    }
    
    if (access) {
        
        return messageCotent;
    }
    else
    {
        [FlyingGroupVC showMemberInfo:userRightData
                                 inView:self.view];
        return nil;
    }
}


- (void)setRealTimeLocation:(id<RCRealTimeLocationProxy>)realTimeLocation {
    _realTimeLocation = realTimeLocation;
}

- (RealTimeLocationStatusView *)realTimeLocationStatusView {
    
    if (!_realTimeLocationStatusView) {
        _realTimeLocationStatusView = [[RealTimeLocationStatusView alloc] initWithFrame:CGRectMake(0, 62, self.view.frame.size.width, 0)];
        _realTimeLocationStatusView.delegate = self;
        [self.view addSubview:_realTimeLocationStatusView];
    }
    return _realTimeLocationStatusView;
}

#pragma mark - RealTimeLocationStatusViewDelegate
- (void)onJoin {
    
    [self showRealTimeLocationViewController];
}

- (RCRealTimeLocationStatus)getStatus {
    
    return [self.realTimeLocation getStatus];
}

- (void)onShowRealTimeLocationView {
    [self showRealTimeLocationViewController];
}

#pragma mark override
/**
 *  重写方法实现自定义消息的显示
 *
 *  @param collectionView collectionView
 *  @param indexPath      indexPath
 *
 *  @return RCMessageTemplateCell
 */
- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    
    if (!self.displayUserNameInCell) {
        if (model.messageDirection == MessageDirection_RECEIVE) {
            model.isDisplayNickname = NO;
        }
    }
    RCMessageContent *messageContent = model.content;
    RCMessageBaseCell *cell = nil;
    if ([messageContent isMemberOfClass:[RCRealTimeLocationStartMessage class]]) {
        RealTimeLocationStartCell *__cell = [collectionView
                                             dequeueReusableCellWithReuseIdentifier:RCRealTimeLocationStartMessageTypeIdentifier
                                             forIndexPath:indexPath];
        [__cell setDataModel:model];
        [__cell setDelegate:self];
        //__cell.locationDelegate=self;
        cell = __cell;
        return cell;
    } else if ([messageContent isMemberOfClass:[RCRealTimeLocationEndMessage class]]) {
        RealTimeLocationEndCell *__cell = [collectionView
                                           dequeueReusableCellWithReuseIdentifier:RCRealTimeLocationEndMessageTypeIdentifier
                                           forIndexPath:indexPath];
        [__cell setDataModel:model];
        cell = __cell;
        return cell;
    }
    else {
        return [super rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}


/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCMessageModel *)model;
{
    RCImagePreviewController *_imagePreviewVC =
    [[RCImagePreviewController alloc] init];
    _imagePreviewVC.messageModel = model;
    _imagePreviewVC.title = @"图片预览";
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:_imagePreviewVC];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage
{
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error != NULL)
    {
        [self.view makeToast:@"保存图片失败！"
                    duration:1
                    position:CSToastPositionCenter];

    }
    else
    {
        [self.view makeToast:@"成功保存图片！"
                    duration:1
                    position:CSToastPositionCenter];

    }
}

- (void)didTapCellPortrait:(NSString *)userId
{
    FlyingProfileVC  *profileVC = [[FlyingProfileVC alloc] init];
    profileVC.userID = userId;
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)didTapMessageCell:(RCMessageModel *)model
{
    [super didTapMessageCell:model];
    
    RCMessageContent * messageCotent = model.content;
    if ([messageCotent isMemberOfClass:[RCRichContentMessage class]]) {
        
        NSString *urlString =[(RCRichContentMessage*)messageCotent url];
        
        if (urlString) {
            
            [self showWebLesson:urlString];
        }
    }
    else if ([messageCotent isMemberOfClass:[RCImageMessage class]]) {
        
        NSString *imageURI =[(RCImageMessage*)messageCotent imageUrl];
        
        UIImage *originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURI]]];
        
        FlyingImagePreivewVC *imageVC=[[FlyingImagePreivewVC alloc] init];
        imageVC.imageUrl=imageURI;
        imageVC.originalImage=originalImage;
        
        [self presentViewController:imageVC animated:YES completion:^{
            //
        }];
    }
    else if ([messageCotent isKindOfClass:[RCRealTimeLocationStartMessage class]]) {
        
        [self showRealTimeLocationViewController];
    }
    
    else
    {
        [super didTapMessageCell:model];
    }
}

- (void)didTapUrlInMessageCell:(NSString *)url model:(RCMessageModel *)model;
{
    
    NSString * urlString=nil;
    
    RCMessageContent * messageCotent = model.content;
    
    if ([messageCotent isMemberOfClass:[RCTextMessage class]]) {
        //
        
        NSString * textMessage =[(RCTextMessage*)messageCotent content];
        
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:textMessage options:0 range:NSMakeRange(0, [textMessage length])];
        for (NSTextCheckingResult *match in matches) {
            if ([match resultType] == NSTextCheckingTypeLink) {
                NSURL *url = [match URL];
                NSLog(@"found URL: %@", url);
                
                urlString=[url absoluteString];
            }
        }
    }
    else if ([messageCotent isMemberOfClass:[RCRichContentMessage class]]) {
        
        urlString =[(RCRichContentMessage*)messageCotent url];
        
    }
    
    [self showWebLesson:urlString];
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view;
{
    RCMessageContent * messageCotent = model.content;
    
    self.theMessagemodel = model;
    
    if ([messageCotent isMemberOfClass:[RCImageMessage class]])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *doneAction1 = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIImageWriteToSavedPhotosAlbum([(RCImageMessage*)messageCotent originalImage], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }];
        
        UIAlertAction *doneAction2 = [UIAlertAction actionWithTitle:@"二维码解析" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self handleScan];
        }];
        
        UIAlertAction *doneAction3 = [UIAlertAction actionWithTitle:@"分享图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self handleShare];
        }];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:doneAction1];
        [alertController addAction:doneAction2];
        [alertController addAction:doneAction3];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{
            //
        }];
    }
    else
    {
        [super didLongTouchMessageCell:model inView:view];
    }
    
    //[self.navigationController pushViewController:chatService animated:YES];
}

#pragma mark override
/**
 *  重写方法实现自定义消息的显示的高度
 *
 *  @param collectionView       collectionView
 *  @param collectionViewLayout collectionViewLayout
 *  @param indexPath            indexPath
 *
 *  @return 显示的高度
 */
- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    if ([messageContent isMemberOfClass:[RCRealTimeLocationStartMessage class]]) {
        
        if (model.isDisplayMessageTime) {
            return CGSizeMake(collectionView.frame.size.width, 66);
        }
        return CGSizeMake(collectionView.frame.size.width, 66);
    }
    else {
        return [super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
}

/**
 *  重写方法实现未注册的消息的显示
 *  如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
 *  需要设置RCIM showUnkownMessage属性
 *
 *  @param collectionView collectionView
 *  @param indexPath      indexPath
 *
 *  @return RCMessageTemplateCell
 */
- (RCMessageBaseCell *)rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    NSLog(@"message objectName = %@", model.objectName);
    RCMessageCell *cell = [collectionView
                           dequeueReusableCellWithReuseIdentifier:RCUnknownMessageTypeIdentifier
                           forIndexPath:indexPath];
    [cell setDataModel:model];
    return cell;
}

/**
 *  重写方法实现未注册的消息的显示的高度
 *  如：新版本增加了某种自定义消息，但是老版本不能识别，开发者可以在旧版本中预先自定义这种未识别的消息的显示
 *  需要设置RCIM showUnkownMessage属性
 *
 *  @param collectionView       collectionView
 *  @param collectionViewLayout collectionViewLayout
 *  @param indexPath            indexPath
 *
 *  @return 显示的高度
 */
- (CGSize) rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                       layout:(UICollectionViewLayout *)collectionViewLayout
                       sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    NSLog(@"message objectName = %@", model.objectName);
    return CGSizeMake(collectionView.frame.size.width, 66);
}

#pragma mark override
- (void)resendMessage:(RCMessageContent *)messageContent{
    if ([messageContent isKindOfClass:[RCRealTimeLocationStartMessage class]]) {
        [self showRealTimeLocationViewController];
    } else {
        [super resendMessage:messageContent];
    }
}

#pragma mark - RCRealTimeLocationObserver
- (void)onRealTimeLocationStatusChange:(RCRealTimeLocationStatus)status {
    __weak typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onReceiveLocation:(CLLocation *)location fromUserId:(NSString *)userId {
    __weak typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateRealTimeLocationStatus];
    });
}

- (void)onParticipantsJoin:(NSString *)userId {
    __weak typeof(&*self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self notifyParticipantChange:@"你加入了地理位置共享"];
    } else {
        [[RCIM sharedRCIM].userInfoDataSource getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
            if (userInfo.name.length) {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:@"%@加入地理位置共享", userInfo.name]];
            } else {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:@"user<%@>加入地理位置共享", userId]];
            }
        }];
    }
}

- (void)onParticipantsQuit:(NSString *)userId {
    __weak typeof(&*self) weakSelf = self;
    if ([userId isEqualToString:[RCIMClient sharedRCIMClient].currentUserInfo.userId]) {
        [self notifyParticipantChange:@"你退出地理位置共享"];
    } else {
        [[RCIM sharedRCIM].userInfoDataSource getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
            if (userInfo.name.length) {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:@"%@退出地理位置共享", userInfo.name]];
            } else {
                [weakSelf notifyParticipantChange:[NSString stringWithFormat:@"user<%@>退出地理位置共享", userId]];
            }
        }];
    }
}

- (void)onRealTimeLocationStartFailed:(long)messageId {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model =
            [self.conversationDataRepository objectAtIndex:i];
            if (model.messageId == messageId) {
                model.sentStatus = SentStatus_FAILED;
            }
        }
        NSArray *visibleItem = [self.conversationMessageCollectionView indexPathsForVisibleItems];
        for (int i = 0; i < visibleItem.count; i++) {
            NSIndexPath *indexPath = visibleItem[i];
            RCMessageModel *model =
            [self.conversationDataRepository objectAtIndex:indexPath.row];
            if (model.messageId == messageId) {
                [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    });
}

- (void)notifyParticipantChange:(NSString *)text {
    __weak typeof(&*self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.realTimeLocationStatusView updateText:text];
        [weakSelf performSelector:@selector(updateRealTimeLocationStatus) withObject:nil afterDelay:0.5];
    });
}


- (void)onFailUpdateLocation:(NSString *)description {
    
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message
{
    return message;
}

/*******************实时地理位置共享***************/
- (void)showRealTimeLocationViewController{
    RealTimeLocationViewController *lsvc = [[RealTimeLocationViewController alloc] init];
    lsvc.realTimeLocationProxy = self.realTimeLocation;
    if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_INCOMING) {
        [self.realTimeLocation joinRealTimeLocation];
    }else if([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_IDLE){
        [self.realTimeLocation startRealTimeLocation];
    }
    [self.navigationController presentViewController:lsvc animated:YES completion:^{
        
    }];
}
- (void)updateRealTimeLocationStatus {
    if (self.realTimeLocation) {
        [self.realTimeLocationStatusView updateRealTimeLocationStatus];
        __weak typeof(&*self) weakSelf = self;
        NSArray *participants = nil;
        switch ([self.realTimeLocation getStatus]) {
            case RC_REAL_TIME_LOCATION_STATUS_OUTGOING:
                [self.realTimeLocationStatusView updateText:@"你正在共享位置"];
                break;
            case RC_REAL_TIME_LOCATION_STATUS_CONNECTED:
            case RC_REAL_TIME_LOCATION_STATUS_INCOMING:
                participants = [self.realTimeLocation getParticipants];
                if (participants.count == 1) {
                    NSString *userId = participants[0];
                    [weakSelf.realTimeLocationStatusView updateText:[NSString stringWithFormat:@"user<%@>正在共享位置", userId]];
                    [[RCIM sharedRCIM].userInfoDataSource getUserInfoWithUserId:userId completion:^(RCUserInfo *userInfo) {
                        if (userInfo.name.length) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.realTimeLocationStatusView updateText:[NSString stringWithFormat:@"%@正在共享位置", userInfo.name]];
                            });
                        }
                    }];
                } else {
                    if(participants.count<1)
                        [self.realTimeLocationStatusView removeFromSuperview];
                    else
                        [self.realTimeLocationStatusView updateText:[NSString stringWithFormat:@"%d人正在共享地理位置", (int)participants.count]];
                }
                break;
            default:
                break;
        }
    }
}

- (void) showLessonViewForLessonID:(NSString *) lesssonID
{
    [FlyingHttpTool getLessonForLessonID:lesssonID Completion:^(FlyingPubLessonData *pubLesson) {
        //
        if (pubLesson) {
            FlyingContentVC * vc= [[FlyingContentVC alloc] init];
            [vc setThePubLesson:pubLesson];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)handleSave
{
    RCMessageContent * messageCotent = self.theMessagemodel.content;
    
    if ([messageCotent isMemberOfClass:[RCImageMessage class]])
    {
        NSString * imageURI =[(RCImageMessage*)messageCotent imageUrl];
        
        UIImage *originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURI]]];
        
        if(originalImage)
        {
            UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        else
        {
            [self.view makeToast:@"保存图片失败！"
                        duration:1
                        position:CSToastPositionCenter];

        }
    }
    
    else if ([messageCotent isMemberOfClass:[RCLocationMessageCell class]])
    {
        UIImage * image =[(RCLocationMessageCell*)messageCotent pictureView].image;
        
        if (image)
        {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        }
        else
        {
            [self.view makeToast:@"保存地址图片失败"
                        duration:1
                        position:CSToastPositionCenter];

        }
    }
}

- (void)handleShare
{
    FlyingShareWithRecent *shareFriends = [[FlyingShareWithRecent alloc] init];
    
    shareFriends.message=self.theMessagemodel.content;
    
    [self.navigationController pushViewController:shareFriends animated:YES];
}

- (void)handleScan
{
    RCMessageContent * messageCotent = self.theMessagemodel.content;
    
    if ([messageCotent isMemberOfClass:[RCImageMessage class]])
    {
        NSString * imageURI =[(RCImageMessage*)messageCotent imageUrl];
        UIImage *originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURI]]];
        
        if (originalImage) {
            
            CGImageRef imageToDecode=originalImage.CGImage;  // Given a CGImage in which we are looking for barcodes
            
            ZXLuminanceSource* source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
            ZXBinaryBitmap* bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
            
            NSError* error = nil;
            
            // There are a number of hints we can give to the reader, including
            // possible formats, allowed lengths, and the string encoding.
            ZXDecodeHints* hints = [ZXDecodeHints hints];
            
            ZXMultiFormatReader* reader = [ZXMultiFormatReader reader];
            ZXResult* result = [reader decode:bitmap
                                        hints:hints
                                        error:&error];
            if (result.length!=0)
            {
                // The coded result as a string. The raw data can be accessed with
                // result.rawBytes and result.length.
                NSString* contents = result.text;
                
                // The barcode format, such as a QR code or UPC-A
                //ZXBarcodeFormat format = result.barcodeFormat;
                
                [FlyingSoundPlayer soundEffect:SECalloutLight];
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                
                [FlyingScanViewController processingSCanResult:contents];
            }
        }
    }
}

- (void) showWebLesson:(NSString*) webURL
{
    if (![webURL isBlankString]) {
        
        NSString * lessonID = [NSString getLessonIDFromOfficalURL:webURL];
        
        if (lessonID) {
            
            [self  showLessonViewForLessonID:lessonID];
        }
        else{
            
            if (webURL)
            {
                FlyingWebViewController * webVC=[[FlyingWebViewController alloc] init];
                [webVC setWebURL:webURL];
                
                [self.navigationController pushViewController:webVC animated:YES];
            }
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
