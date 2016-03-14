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
#import "SIAlertView.h"
#import "FlyingShareWithFriends.h"
#import "FlyingImagePreivewVC.h"
#import "UIView+Toast.h"
#import "FlyingHttpTool.h"
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"

@interface FlyingConversationVC () <UIActionSheetDelegate,
                                    RCRealTimeLocationObserver,
                                    RealTimeLocationStatusViewDelegate,
                                    UIAlertViewDelegate,
                                    RCMessageCellDelegate,
                                    CFShareCircleViewDelegate>

@property (nonatomic, weak)id<RCRealTimeLocationProxy> realTimeLocation;
@property (nonatomic, strong)RealTimeLocationStatusView *realTimeLocationStatusView;

@property (strong,nonatomic) RCMessageModel *theMessagemodel;

@property (nonatomic, strong) CFShareCircleView *shareCircleView;

@end

@implementation  FlyingConversationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
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
        RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:self.theMessagemodel.targetId];
        self.title = userInfo.name;
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
    //打开单聊强制从server 获取用户信息更新本地数据库
    if (self.conversationType == ConversationType_PRIVATE) {
        
        [FlyingHttpTool getUserInfoByRongID:self.targetId completion:^(RCUserInfo *userInfo) {
            
            self.title=userInfo.name;
        }];
    }
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

//子类具体实现具体功能
- (void) willDismiss
{
}

- (void)leftBarButtonItemPressed:(id)sender {
    
    if ([self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_OUTGOING ||
        [self.realTimeLocation getStatus] == RC_REAL_TIME_LOCATION_STATUS_CONNECTED) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"退出当前界面位置共享会终止，确定要退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
        [alertView show];
        
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
                
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发送位置", @"位置实时共享", nil];
                [actionSheet showInView:self.view];
                
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

-(void) showMemberInfo:(NSString*)reslutStr
{
    NSString * verifiedStr = @"你已经是正式会员，可以参与互动了!";
    NSString * refuseStr = @"你的成员资格被拒绝!";
    NSString * reviewStr = @"你的成员资格正在审批中...";
    
    NSString * infoStr=@"未知错误！";

    if ([reslutStr isEqualToString:KGroupMemberVerified]) {
        
        infoStr = verifiedStr;
    }

    else if ([reslutStr isEqualToString:KGroupMemberRefused]) {
        
        infoStr = refuseStr;
    }
    else if([reslutStr isEqualToString:KGroupMemberReviewing])
    {
        infoStr = reviewStr;
        
    }
    
    [self.view makeToast:infoStr duration:2 position:CSToastPositionCenter];
}

-(void) showSurvey
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
    webpage.title=@"参与设计";
    [webpage setWebURL:@"http://www.mikecrm.com/f.php?t=UkWGrx"];
    
    [self.navigationController pushViewController:webpage animated:YES];
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
    BOOL right = [[NSUserDefaults standardUserDefaults] boolForKey:self.targetId];

    if (right) {
        
        return messageCotent;
    }
    else
    {
        NSString *title = @"友情提醒！";
        NSString *message = @"正式会员才能参与互动，你需要申请成为群组成员吗？";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"取消"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                              }];
        
        [alertView addButtonWithTitle:@"确认"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  
                                  [FlyingHttpTool joinGroupForAccount:[FlyingDataManager getOpenUDID]
                                                              GroupID:self.targetId
                                                           Completion:^(NSString *result) {
                                                               //
                                                               [self showMemberInfo:result];
                                                               
                                                           }];
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        [alertView show];
        
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
        [self.view makeToast:@"保存图片失败！"];
    }
    else
    {
        [self.view makeToast:@"成功保存图片！"];
    }
}

- (void)didTapCellPortrait:(NSString *)userId
{
    if ([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:userId])
    {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        id myProfileVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyingAccountVC"];
        [self.navigationController pushViewController:myProfileVC animated:YES];
    }
    else
    {
        if(self.conversationType!=ConversationType_PRIVATE)
        {
             FlyingConversationVC *chatService = [[ FlyingConversationVC alloc] init];
            
            RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:userId];
            chatService.targetId = userId;
            chatService.conversationType = ConversationType_PRIVATE;
            chatService.title = userInfo.name;
            [self.navigationController pushViewController:chatService animated:YES];
        }
    }
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
        if ( !_shareCircleView) {
            
            _shareCircleView = [[CFShareCircleView alloc] initWithSharers:@[[CFSharer im], [CFSharer save], [CFSharer charge], [CFSharer scan]]];
            
            _shareCircleView.delegate = self;
        }
        
        if (!_shareCircleView.isShow) {
            [_shareCircleView show];
        }
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
#pragma mark - UIActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [super pluginBoardView:self.pluginBoardView clickedItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
        }
            break;
        case 1:
        {
            [self showRealTimeLocationViewController];
        }
            break;
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.realTimeLocation quitRealTimeLocation];
        [self popupChatViewController];
    }
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

- (void)shareCircleView:(CFShareCircleView *)shareCircleView didSelectSharer:(CFSharer *)sharer
{
    
    [_shareCircleView dismissAnimated:YES];
    
    if ([sharer.name isEqualToString:@"二维码解析"] ||
        [sharer.name isEqualToString:@"充值"]
        ) {
        
        [self handleScan];
    }
    else if ([sharer.name isEqualToString:@"保存图片"]) {
        
        [self handleSave];
    }
    else if ([sharer.name isEqualToString:@"聊天好友"]) {
        
        [self handleShare];
    }
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
            [self.view makeToast:@"保存图片失败！"];
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
            [self.view makeToast:@"保存地址图片失败！"];
        }
    }
}

- (void)handleShare
{
    FlyingShareWithFriends * shareFriends = [[FlyingShareWithFriends alloc] init];
    
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
    if (webURL) {
        
        NSString * lessonID = [NSString getLessonIDFromOfficalURL:webURL];
        
        if (lessonID) {
            
            [self  showLessonViewForLessonID:lessonID];
        }
        else{
            
            if (webURL)
            {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
                [webpage setWebURL:webURL];
                
                [self.navigationController pushViewController:webpage animated:YES];
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
