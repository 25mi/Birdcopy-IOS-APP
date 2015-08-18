//
//  FlyingAccountVC.m
//  FlyingEnglish
//
//  Created by vincent on 5/25/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingAccountVC.h"
#import "UIColor+RCColor.h"
#import "iFlyingAppDelegate.h"
#import "FlyingSearchViewController.h"
#import "FlyingOpenIDVC.h"
#import "FlyingHome.h"
#import "FlyingNavigationController.h"
#import "RCDChatListViewController.h"
#import "AFHttpTool.h"
#import "UICKeyChainStore.h"
#import "FlyingPickColorVCViewController.h"
#import <RongIMKit/RCIM.h>

#import "shareDefine.h"
#import "NSString+FlyingExtention.h"
#import "RCDataBaseManager.h"
#import "UIImageView+WebCache.h"
#import "SIAlertView.h"
#import "UIView+Toast.h"
#import "RSKImageCropViewController.h"

#import "AFHttpTool.h"


#define ORIGINAL_MAX_WIDTH 640.0f

@interface FlyingAccountVC ()<UINavigationControllerDelegate,
                                UIImagePickerControllerDelegate,
                                UIActionSheetDelegate,
                                RSKImageCropViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (strong, nonatomic) IBOutlet UILabel *accountNikename;

@end

@implementation FlyingAccountVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.94 alpha:1.000];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addBackFunction];
    
    self.title=@"我的账户";
    
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
      
    self.tableView.separatorColor = [UIColor colorWithHexString:@"dfdfdf" alpha:1.0f];
    //self.currentUserNameLabel.text = [RCIMClient sharedClient].currentUserInfo.name;
    
    self.tabBarController.navigationItem.title = @"我";
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    dispatch_async(dispatch_get_main_queue() , ^{
        [self loadPortrait];
        [self updateChatIcon];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *nickName=[UICKeyChainStore keyChainStore][kUserNickName];
    
    if (nickName.length==0) {
        nickName =[[UIDevice currentDevice] name];
    }
    
    self.accountNikename.text=nickName;
}

-(void) loadPortrait
{

    NSString *portraitUri=[UICKeyChainStore keyChainStore][kUserPortraitUri];
    
    if (portraitUri) {
        
        [_portraitImageView  sd_setImageWithURL:[NSURL URLWithString:portraitUri]  placeholderImage:[UIImage imageNamed:@"Icon"]];
    }
    else
    {
        NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];
        
        [AFHttpTool getUserInfoWithOpenID:passport
                                  success:^(id response) {
                                      //
                                      if (response) {
                                          NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                          
                                          if ([code isEqualToString:@"1"]) {
                                              
                                              RCUserInfo *userInfo = [RCUserInfo new];
                                              
                                              userInfo.userId= [passport MD5];
                                              userInfo.name=response[@"name"];
                                              userInfo.portraitUri=response[@"portraitUri"];
                                              
                                              [_portraitImageView  sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri]  placeholderImage:[UIImage imageNamed:@"Icon"]];
                                          }
                                          else
                                          {
                                              NSLog(@"getUserInfoWithOpenID:%@",response[@"rm"]);
                                          }
                                      }
                                  } failure:^(NSError *err) {
                                      //
                                      [_portraitImageView setImage:[UIImage imageNamed:@"Icon"]];
                                      NSLog(@"Get rongcloud Toke %@",err.description);
                                      
                                  }];
    }
    
    [_portraitImageView.layer setCornerRadius:(_portraitImageView.frame.size.height/2)];
    [_portraitImageView.layer setMasksToBounds:YES];
    [_portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_portraitImageView setClipsToBounds:YES];
    _portraitImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _portraitImageView.layer.shadowOffset = CGSizeMake(4, 4);
    _portraitImageView.layer.shadowOpacity = 0.5;
    _portraitImageView.layer.shadowRadius = 2.0;
    _portraitImageView.userInteractionEnabled = YES;
    _portraitImageView.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer *portraitTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
    [_portraitImageView addGestureRecognizer:portraitTap];

}

-(void) updateChatIcon
{
    int unreadMsgCount = [[RCIMClient sharedRCIMClient]getUnreadCount: @[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_PUBLICSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP)]];
    
    UIImage *image;
    if(unreadMsgCount>0)
    {
        image = [UIImage imageNamed:@"chat"];
    }
    else
    {
        image= [UIImage imageNamed:@"chat_b"];
    }
    
    CGRect frame= CGRectMake(0, 0, 24, 24);
    UIButton* chatButton= [[UIButton alloc] initWithFrame:frame];
    [chatButton setBackgroundImage:image forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(doChat) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* chatBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
    image= [UIImage imageNamed:@"search"];
    frame= CGRectMake(0, 0, 24, 24);
    UIButton* searchButton= [[UIButton alloc] initWithFrame:frame];
    [searchButton setBackgroundImage:image forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* searchBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:chatBarButtonItem, searchBarButtonItem, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        [self.navigationController pushViewController:[[FlyingOpenIDVC alloc] init] animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id myProfileVC = [storyboard instantiateViewControllerWithIdentifier:@"myProfile"];
        
        [self.navigationController pushViewController:myProfileVC animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 0) {
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id rongCloudSetting = [storyboard instantiateViewControllerWithIdentifier:@"RongCloudSetting"];
        
        [self.navigationController pushViewController:rongCloudSetting animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 1) {
        
        [self clearCache];
    }
    else if (indexPath.section == 3 && indexPath.row == 0) {
        
        //定制导航条背景颜色
        [self.navigationController pushViewController:[[FlyingPickColorVCViewController alloc] init] animated:YES];

    }
    else if (indexPath.section == 4 && indexPath.row == 0) {
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id helpVC = [storyboard instantiateViewControllerWithIdentifier:@"helpinfo"];
     
        [self.navigationController pushViewController:helpVC animated:YES];
    }
    else if (indexPath.section == 4 && indexPath.row == 1) {
        
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [appDelegate  showWebviewWithURL:KAboutProvierAddress];
    }

        /*
#define SERVICE_ID @"kefu114"
        RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
        chatService.targetName = @"客服";
        chatService.targetId = SERVICE_ID;
        chatService.conversationType = ConversationType_CUSTOMERSERVICE;
        chatService.title = chatService.targetName;
        [self.navigationController pushViewController:chatService animated:YES];
         */
    
}


//清理缓存
-(void) clearCache
{
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   , ^{
                       
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                           }
                       }
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess)
                                              withObject:nil waitUntilDone:YES];});
}

-(void)clearCacheSuccess
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"缓存清理成功！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)editPortrait {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        
        /*
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
         */
        
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:portraitImg];
        imageCropVC.delegate = self;
        [self.navigationController pushViewController:imageCropVC animated:YES];
    }];
}


#pragma mark RSKImageCropViewControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}


-(void) dealWithImage:(UIImage *)editedImage
{
    NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.7); // 0.7 is JPG quality
    
    [AFHttpTool requestUploadPotraitWithOpenID:[UICKeyChainStore keyChainStore][KOPENUDIDKEY] data:imageData success:^(id response) {
        //
        if (response)
        {
            NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
            
            //上传图片到服务器，成功后通知融云服务器更新用户信息
            if ([code isEqualToString:@"1"])
            {
                NSString *portraitUri = [NSString stringWithFormat:@"%@",response[@"portraitUri"]];
                
                if (portraitUri.length!=0) {
                    
                    [AFHttpTool refreshUesrWithOpenID: [UICKeyChainStore keyChainStore][KOPENUDIDKEY] name:nil portraitUri:portraitUri br_intro:nil success:^(id response) {
                        
                        NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                        
                        //上传图片到服务器，成功后通知融云服务器更新用户信息
                        if ([code isEqualToString:@"1"])
                        {
                            //更新本地信息
                            [UICKeyChainStore keyChainStore][kUserPortraitUri] = portraitUri;
                            
                            RCUserInfo *currentUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
                            currentUserInfo.portraitUri=portraitUri;
                            [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
                            
                            //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                            [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
                            
                            [[RCDataBaseManager shareInstance] insertUserToDB:currentUserInfo];
                            
                        }
                    }
                                              failure:^(NSError *err) {
                                                  //
                                                  NSLog(@"requestUploadPotraitWithOpenID:%@",err.description);
                                              }];
                }
            }
            else
            {
                NSLog(@"requestUploadPotraitWithOpenID:%@",response[@"rm"]);
            }
        }
    }
                                       failure:^(NSError *err) {
                                           //
                                           NSLog(@"requestUploadPotraitWithOpenID:%@",err.description);
                                       }];

}

// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    self.portraitImageView.image = croppedImage;
    [self dealWithImage:croppedImage];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    self.portraitImageView.image = croppedImage;
    [self dealWithImage:croppedImage];

    [self.navigationController popViewControllerAnimated:YES];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage
{
    // Use when `applyMaskToCroppedImage` set to YES.
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


//////////////////////////////////////////////////////////////
#pragma mark socail Related
//////////////////////////////////////////////////////////////
- (void) showMenu
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void) doChat
{
    if (INTERFACE_IS_PAD) {
        
        
        [self.view makeToast:@"PAD版本暂时不支持聊天功能!！"];

        return;
    }
    
    RCDChatListViewController  * chatList=[[RCDChatListViewController alloc] init];
    [self.navigationController pushViewController:chatList animated:YES];
}

- (void) doSearch
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FlyingSearchViewController * search=[storyboard instantiateViewControllerWithIdentifier:@"search"];
    [self.navigationController pushViewController:search animated:YES];
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
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePinch:)];
    
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

-(void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        
        [self dismiss];
    }
}

-(void) handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if ((recognizer.state ==UIGestureRecognizerStateEnded) || (recognizer.state ==UIGestureRecognizerStateCancelled)) {
        
        [self dismiss];
    }
}

//LogoDone functions
- (void)dismiss
{
    FlyingNavigationController *navigationController =(FlyingNavigationController *)[[self sideMenuViewController] contentViewController];
    
    if (navigationController.viewControllers.count==1) {
        
        FlyingHome* homeVC = [[FlyingHome alloc] init];
        
        [[self sideMenuViewController] setContentViewController:[[UINavigationController alloc] initWithRootViewController:homeVC]
                                                       animated:YES];
        [[self sideMenuViewController] hideMenuViewController];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
