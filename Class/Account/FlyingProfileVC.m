//
//  FlyingProfileVC.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/4/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingProfileVC.h"
#import "UIImageView+WebCache.h"
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"
#import "AFHttpTool.h"
#import "RSKImageCropViewController.h"
#import "RCDataBaseManager.h"
#import "FlyingEditVC.h"
#import "SIAlertView.h"
#import "UIView+Toast.h"
#import "FlyingDataManager.h"
#import "FlyingHttpTool.h"
#import "FlyingActiveViewController.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface FlyingProfileVC ()<UINavigationControllerDelegate,
                            UIImagePickerControllerDelegate,
                            UIActionSheetDelegate,
                            RSKImageCropViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (strong, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *userAbstractLabel;

@property (strong, nonatomic) IBOutlet UILabel *openUDIDLabel;


@end

@implementation FlyingProfileVC

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
    
    [self.portraitImageView  sd_setImageWithURL:[NSURL URLWithString:[NSString getUserPortraitUri]]  placeholderImage:[UIImage imageNamed:@"Icon"]];

    self.nickNameLabel.text=[NSString getNickName];
    self.userAbstractLabel.text=[NSString getUserAbstract];
    
    self.openUDIDLabel.text=[NSString getOpenUDID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


#pragma mark - Table view

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
                editVC.isNickName=YES;
                
                [self.navigationController pushViewController:editVC animated:YES];

                break;
            }
        
            case 2:
            {
                FlyingEditVC *editVC =[[FlyingEditVC alloc] init];
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
        [self changeMyOPENUDID];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)editPortrait {
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet setTag:0];
    [choiceSheet showInView:self.view];
}

-(void) changeMyOPENUDID
{
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"复制ID", @"从旧设备同步数据", nil];
    [choiceSheet setTag:1];
    [choiceSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag==0) {
        
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
    else
    {
        if (buttonIndex == 0) {
            //复制openUDID到剪切板
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString getOpenUDID];

            [self.view makeToast:@"已经成功复制ID到剪贴板！"];
            
        } else if (buttonIndex == 1) {
            //输入旧设备openUDID，准备恢复帐号数据
            
            
            UIAlertView *shakingAlert = [[UIAlertView alloc] initWithTitle:@"输入ID"
                                                       message:@"输入从旧设备复制的相关ID"
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定", nil];
            [shakingAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [shakingAlert show];
        }
    }
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textfield =  [alertView textFieldAtIndex: 0];
    
    NSString * sourceOenUDID=textfield.text;
    
    if (sourceOenUDID.length==40 && ![sourceOenUDID isEqualToString:[NSString getOpenUDID]]) {
        
        
        [FlyingHttpTool updateCurrentID:[NSString getOpenUDID]
                           withSourceID:sourceOenUDID
                             Completion:^(BOOL result) {
                                 
                                 if(result)
                                 {
                                     FlyingActiveViewController *activeVC= [[FlyingActiveViewController alloc] init];
                                     
                                     //切换账户
                                     [self.navigationController presentViewController:activeVC animated:YES completion:^{
                                         //
                                     }];
                                 }
                                 else
                                 {
                                     [self.view makeToast:@"迁移失败，重新来了：）"];
                                 }

                             }];
    }
    else
    {
        [self.view makeToast:@"旧设备的ID不合法或者重复！"];
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
    
    NSString *openID = [NSString getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    [AFHttpTool requestUploadPotraitWithOpenID:openID
                                          data:imageData
                                       success:^(id response) {
                                           //
                                           if (response)
                                           {
                                               NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                               
                                               //上传图片到服务器，成功后通知融云服务器更新用户信息
                                               if ([code isEqualToString:@"1"])
                                               {
                                                   NSString *portraitUri = [NSString stringWithFormat:@"%@",response[@"portraitUri"]];
                                                   
                                                   if (portraitUri.length!=0) {
                                                       
                                                       [AFHttpTool refreshUesrWithOpenID:openID
                                                                                    name:nil
                                                                             portraitUri:portraitUri
                                                                                br_intro:nil
                                                                                 success:^(id response) {
                                                                                     
                                                                                     NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                                                                     
                                                                                     //上传图片到服务器，成功后通知融云服务器更新用户信息
                                                                                     if ([code isEqualToString:@"1"])
                                                                                     {
                                                                                         //更新本地信息
                                                                                         [NSString setUserPortraitUri:portraitUri];
                                                                                         
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


- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
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
