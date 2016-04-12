//
//  FlyingProfileVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingProfileVC.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"
#import "AFHttpTool.h"
#import "RSKImageCropViewController.h"
#import "FlyingEditVC.h"
#import "UIView+Toast.h"
#import "FlyingDataManager.h"
#import "FlyingHttpTool.h"
#import "FlyingActiveViewController.h"
#import "FlyingLoginVC.h"
#import "shareDefine.h"
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"
#import <UIImageView+AFNetworking.h>
#import "FlyingUserData.h"
#import "RCDataBaseManager.h"
#import "FlyingConversationVC.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface FlyingProfileVC ()<UINavigationControllerDelegate,
                            UIImagePickerControllerDelegate,
                            RSKImageCropViewControllerDelegate,
                            UIViewControllerRestoration>

@property (strong, nonatomic) IBOutlet UILabel *portraitLabel;
@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;

@property (strong, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *nickName;

@property (strong, nonatomic) IBOutlet UILabel *abstractLabel;
@property (strong, nonatomic) IBOutlet UILabel *userAbstract;

@property (strong, nonatomic) IBOutlet UILabel *loginLabel;

@property (strong, nonatomic) FlyingUserData    *userdata;


@end

@implementation FlyingProfileVC


+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    
    [super encodeRestorableStateWithCoder:coder];

    if(![self.openUDID isBlankString])
    {
        [coder encodeObject:self.openUDID forKey:@"self.openUDID"];
    }
    
    if(![self.userID isBlankString])
    {
        [coder encodeObject:self.userID forKey:@"self.userID"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    self.openUDID = [coder decodeObjectForKey:@"self.openUDID"];

    self.userID = [coder decodeObjectForKey:@"self.userID"];
    
    [super decodeRestorableStateWithCoder:coder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
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
    self.title = NSLocalizedString(@"Profile",nil);
    
    if ([self.navigationController.viewControllers count]>1) {
        
        UIButton* backButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissNavigation) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* backBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
    
    self.portraitLabel.text = NSLocalizedString(@"Portrait", nil);
    self.nickNameLabel.text = NSLocalizedString(@"NickName", nil);
    self.abstractLabel.text = NSLocalizedString(@"Who am I", nil);
}

- (void) loadData
{
    NSString * openID = [FlyingDataManager getOpenUDID];
    NSString * userID = [FlyingDataManager getRongID];
    
    if ([openID isEqualToString:self.openUDID] ||
          [userID isEqualToString:self.userID]){
        
        self.userdata = [FlyingDataManager getUserData:[FlyingDataManager getOpenUDID]];
    }
    else
    {
        if (self.openUDID) {
            
            [FlyingHttpTool getUserInfoByopenID:self.openUDID
                                     completion:^(FlyingUserData *userData, RCUserInfo *userInfo) {
                                         //
                                         [FlyingDataManager saveUserData:userData];
                                         
                                         self.userdata = userData;

                                         //用户融云数据库
                                         [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                                         //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                         [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                                         
                                         [self refreshAccountView];
                                     }];
        }
        else if(self.userID){
            
            [FlyingHttpTool getUserInfoByRongID:self.userID
                                     completion:^(FlyingUserData *userData, RCUserInfo *userInfo) {
                                         //
                                         [FlyingDataManager saveUserData:userData];
                                         
                                         self.userdata = userData;
                                         
                                         //用户融云数据库
                                         [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                                         //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                         [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                                         
                                         [self refreshAccountView];
                                     }];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    [self refreshAccountView];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:KBEAccountChange
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      [self refreshAccountView];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBEAccountChange    object:nil];
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

- (void) refreshAccountView
{
    
    [self.portraitImageView  setImageWithURL:[NSURL URLWithString:self.userdata.portraitUri]
                            placeholderImage:[UIImage imageNamed:@"Icon"]];
    
    self.nickName.text= self.userdata.name;
    self.userAbstract.text=self.userdata.digest;
    
    NSString * openID = [FlyingDataManager getOpenUDID];
    NSString * userID = [FlyingDataManager getRongID];
    
    if ([openID isEqualToString:self.openUDID] ||
        [userID isEqualToString:self.userID]){
        
        if(![NSString isBlankString:[FlyingDataManager getUserName]])
        {
            self.loginLabel.text=NSLocalizedString(@"Login Out",nil);
        }
        else
        {
            self.loginLabel.text=NSLocalizedString(@"Login/Register",nil);
        }
    }
    else
    {
        self.title = self.userdata.name;
        self.loginLabel.text=NSLocalizedString(@"Chat Now", nil);
    }
}

#pragma mark - Table view

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * openID = [FlyingDataManager getOpenUDID];
    NSString * userID = [FlyingDataManager getRongID];
    
    if ([openID isEqualToString:self.openUDID] ||
        [userID isEqualToString:self.userID]){
        
        if (indexPath.section == 0 )
        {
            
            switch (indexPath.row) {
                case 0:
                {
                    [self editPortrait];
                    
                    break;
                }
                case 1:
                {
                    FlyingEditVC *editVC =[[FlyingEditVC alloc] init];
                    editVC.someText=self.userdata.name;
                    editVC.isNickName=YES;
                    
                    [self.navigationController pushViewController:editVC animated:YES];
                    
                    break;
                }
                    
                case 2:
                {
                    FlyingEditVC *editVC =[[FlyingEditVC alloc] init];
                    editVC.someText=self.userdata.digest;
                    editVC.isNickName=NO;
                    
                    [self.navigationController pushViewController:editVC animated:YES];
                    
                    break;
                }
                    
                default:
                    break;
            }
        }
        else if (indexPath.section == 1 )
        {
            [self.navigationController presentViewController:[[FlyingLoginVC alloc] init]
                                                    animated:YES
                                                  completion:^{
                                                      //
                                                  }];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else
    {
        if (indexPath.section == 1 )
        {
            if ([NSString isBlankString:[FlyingDataManager getUserData:nil].portraitUri]) {
                
                [self.view makeToast:NSLocalizedString(@"Upload your portrait first please!", nil)
                            duration:1
                            position:CSToastPositionCenter];

            }
            else
            {
                FlyingConversationVC *chatService = [[FlyingConversationVC alloc] init];
                
                chatService.targetId = [self.userdata.openUDID MD5];
                
                chatService.conversationType = ConversationType_PRIVATE;
                chatService.title = self.userdata.name;
                [self.navigationController pushViewController:chatService animated:YES];
            }
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)editPortrait
{
    
    NSString *title = nil;
    NSString *message = nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *doneAction1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo",nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        
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
    }];

    UIAlertAction *doneAction2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose From Album",nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
       
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
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:doneAction1];
    [alertController addAction:doneAction2];
    [alertController addAction:cancelAction];
    
    if (INTERFACE_IS_PAD) {

        [alertController setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popPresenter = [alertController
                                                         popoverPresentationController];
        popPresenter.sourceView = self.portraitImageView;
        popPresenter.sourceRect = self.portraitImageView.bounds;
        [self presentViewController:alertController animated:YES completion:nil];

    }
    else
    {
        [self.navigationController presentViewController:alertController animated:YES completion:^{
            //
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
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
    
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    [FlyingHttpTool requestUploadPotraitWithOpenID:openID
                                              data:imageData
                                        Completion:^(BOOL result) {
                                            //
                                            if (result) {
                                                //
                                                [self.portraitImageView  setImageWithURL:[NSURL URLWithString:self.userdata.portraitUri]  placeholderImage:[UIImage imageNamed:@"Icon"]];
                                                [self.view makeToast:@"上传头像成功！"
                                                            duration:1
                                                            position:CSToastPositionCenter];
                                            }
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
