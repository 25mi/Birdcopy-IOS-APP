//
//  RCDChatViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/3/13.
//  Copyright (c) 2015年 胡利武. All rights reserved.
//

#import "RCDChatViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "RCDChatViewController.h"
#import "FlyingHttpTool.h"
#import "RESideMenu.h"
#import "iFlyingAppDelegate.h"
#import "UICKeyChainStore.h"
#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "FlyingWebViewController.h"
#import "NSString+FlyingExtention.h"
#import "FlyingLessonParser.h"
#import "FlyingContentVC.h"
#import "RCDataBaseManager.h"
#import <AFNetworking.h>
#import  "ZXingObjC.h"
#import "FlyingSoundPlayer.h"
#import "FlyingScanViewController.h"
#import "SIAlertView.h"
#import "FlyingShareWithFriends.h"
#import "FlyingImagePreivewVC.h"
#import "UIView+Toast.h"
#import "FlyingHttpTool.h"

#import "FlyingRCLocationPickerViewController.h"


@interface RCDChatViewController ()<CFShareCircleViewDelegate>

@property (strong,nonatomic) RCMessageModel *theMessagemodel;

@property (nonatomic, strong) CFShareCircleView *shareCircleView;

@end

@implementation RCDChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    
    [self addBackFunction];
    
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

    self.enableSaveNewPhotoToLocalSystem = YES;
        
    [self.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"Help"]
                                        title:@"参与设计"
                                          tag:101];
    
    
}
/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */
- (void)doSetting
{
    if (self.conversationType == ConversationType_PRIVATE) {
        
        /*
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
        __weak RCDChatViewController *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        
        [self.navigationController pushViewController:settingVC animated:YES];
         */
        
    } else if (self.conversationType == ConversationType_DISCUSSION) {
        
        /*
        RCDDiscussGroupSettingViewController *settingVC =
        [[RCDDiscussGroupSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        settingVC.conversationTitle = self.userName;
        //设置讨论组标题时，改变当前聊天界面的标题
        settingVC.setDiscussTitleCompletion = ^(NSString *discussTitle) {
            self.title = discussTitle;
        };
        //清除聊天记录之后reload data
        __weak RCDChatViewController *weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
            if (isSuccess) {
                [weakSelf.conversationDataRepository removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        
        [self.navigationController pushViewController:settingVC animated:YES];
         */
    }
    
    //聊天室设置
    else if (self.conversationType == ConversationType_CHATROOM)
    {
    }
    
    //群组设置
    else if (self.conversationType == ConversationType_GROUP)
    {
    }
    //客服设置
    else if (self.conversationType == ConversationType_CUSTOMERSERVICE) {
        RCSettingViewController *settingVC = [[RCSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        //清除聊天记录之后reload data
        __weak RCDChatViewController *weakSelf = self;
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
            
            FlyingRCLocationPickerViewController* locationPicker = [[FlyingRCLocationPickerViewController alloc] init];
            
            [locationPicker setDelegate:self];
            
            [self.navigationController pushViewController:locationPicker animated:YES];
            
            
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
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
    webpage.title=@"参与设计";
    [webpage setWebURL:@"http://www.mikecrm.com/f.php?t=UkWGrx"];
    
    [self.navigationController pushViewController:webpage animated:YES];
}

/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCMessageModel *)model;
{
    /*
  RCImagePreviewController *_imagePreviewVC =
      [[RCImagePreviewController alloc] init];
  _imagePreviewVC.messageModel = model;
  _imagePreviewVC.title = @"图片预览";

  UINavigationController *nav = [[UINavigationController alloc]
      initWithRootViewController:_imagePreviewVC];

  [self presentViewController:nav animated:YES completion:nil];
     */
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
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id myProfileVC = [storyboard instantiateViewControllerWithIdentifier:@"FlyingAccountVC"];
        [self.navigationController pushViewController:myProfileVC animated:YES];
    }
    else
    {
        if(self.conversationType!=ConversationType_PRIVATE)
        {
            RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
            
            RCUserInfo* userInfo =[[RCDataBaseManager shareInstance] getUserByUserId:userId];
            chatService.userName = userInfo.name;
            chatService.targetId = userId;
            chatService.conversationType = ConversationType_PRIVATE;
            chatService.title = chatService.userName;
            [self.navigationController pushViewController:chatService animated:YES];
        }
    }
}

- (void)didTapMessageCell:(RCMessageModel *)model
{
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

- (void) showLessonViewForLessonID:(NSString *) lesssonID
{
    [FlyingHttpTool getLessonForLessonID:lesssonID Completion:^(FlyingPubLessonData *lesson) {
        //
        if (lesson) {
            FlyingContentVC * vc= [[FlyingContentVC alloc] init];
            [vc setTheLesson:lesson];
            
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
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                FlyingWebViewController * webpage=[storyboard instantiateViewControllerWithIdentifier:@"webpage"];
                [webpage setWebURL:webURL];
                
                [self.navigationController pushViewController:webpage animated:YES];
            }
        }
    }
}


//////////////////////////////////////////////////////////////
#pragma only portart events
//////////////////////////////////////////////////////////////
-(void) dismiss
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
