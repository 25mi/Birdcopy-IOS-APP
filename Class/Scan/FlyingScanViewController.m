//
//  FlyingScanViewController.m
//  FlyingEnglish
//
//  Created by BE_Air on 1/15/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import "FlyingScanViewController.h"
#import "iFlyingAppDelegate.h"
#import "NSString+FlyingExtention.h"
#import "FlyingSoundPlayer.h"
#import  "ZXingObjC.h"
#import "FlyingNavigationController.h"
#import "FlyingHttpTool.h"
#import "FlyingNavigationController.h"
#import "FlyingDataManager.h"

@interface FlyingScanViewController ()<UIViewControllerRestoration>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}

@property (strong, nonatomic) UILabel            *descLabel;

@property (strong, nonatomic) UIImageView        *scanLine;
@property (strong, nonatomic) UIImageView        *scanView;

@end

@implementation FlyingScanViewController

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
    self.title = NSLocalizedString(@"QR Code| Bar Code",nil);
    
    //顶部导航
    UIButton* scanButton= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [scanButton setBackgroundImage:[UIImage imageNamed:@"photos"] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(doPhotos) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* scanBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    
    self.navigationItem.rightBarButtonItem = scanBarButtonItem;
    
    CGRect frame=self.view.frame;
    
    CGFloat sideLength = frame.size.width*200/320;
    
    CGRect scanFrame = CGRectMake((frame.size.width-sideLength)/2.0, (frame.size.width-sideLength), sideLength, sideLength);
    
    self.scanView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"scanFrame"]];
    self.scanView.frame=scanFrame;
    
    [self.view addSubview:self.scanView];

    CGRect scanLineFrame =scanFrame;
    scanLineFrame.size.height=1;

    self.scanLine = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"line"]];
    self.scanLine.frame=scanLineFrame;
    
    [self.view addSubview:self.scanLine];

    self.descLabel = [[UILabel alloc] init];

    CGRect descFrame =scanFrame;
    
    self.descLabel.font              = [UIFont systemFontOfSize:12.0];
    descFrame.size.height=30;
    if (INTERFACE_IS_PAD ) {
        
        //描述
        self.descLabel.font              = [UIFont systemFontOfSize:16.0];
        descFrame.size.height=60;
    }

    descFrame.origin.y=scanFrame.origin.y+scanFrame.size.height+descFrame.size.height;
    
    self.descLabel.frame=descFrame;
    self.descLabel.textColor=[UIColor whiteColor];
    self.descLabel.textAlignment=NSTextAlignmentCenter;
    self.descLabel.text=@"将二维码或者条码放入框内";
    
    [self.view addSubview:self.descLabel];
    
    [self setupCamera];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:KBERQloginOK
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         
         [self scanningOK:NSLocalizedString(@"Scanning is ok",nil)];
     }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:KBERQBoundsOK
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
    {
        
        [self scanningOK:NSLocalizedString(@"Bounding is ok!", nil)];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:KBERQloginFail
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         
         [self scanningOK:NSLocalizedString(@"Bounding is fail!", nil)];
     }];

    [[NSNotificationCenter defaultCenter] addObserverForName:KBERQBoundsFail
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note)
     {
         
         [self scanningOK:NSLocalizedString(@"Bounding is fail!", nil)];
     }];

}

-(void) scanningOK:(NSString*) message
{
    [FlyingSoundPlayer noticeSound];
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate makeToast:message];

    [_session stopRunning];
    [timer invalidate];
    [self setupCamera];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBERQloginOK    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBERQBoundsOK    object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBERQloginFail    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KBERQBoundsFail    object:nil];
}

- (void) willDismiss
{
    [_session stopRunning];
    [timer invalidate];
}

- (void) doPhotos
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        /*self.isScanning = NO;
         [self.captureSession stopRunning];
         */
    }];
}

-(void)animation
{
    
    CGRect rect = self.scanView.frame;
    
    if (upOrdown == NO) {
        num ++;
        self.scanLine.frame = CGRectMake(rect.origin.x, rect.origin.y+2*num, rect.size.width, 2);
        if (2*num >= rect.size.height) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        self.scanLine.frame = CGRectMake(rect.origin.x, rect.origin.y+2*num, rect.size.width, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

- (void)setupCamera
{
    upOrdown = NO;
    num =0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    
    // Device
    
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // Input
    if (!_input) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    
    // Output
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    
    // Session
    if (!_session) {
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[
                                   AVMetadataObjectTypeUPCECode,
                                   AVMetadataObjectTypeCode39Code,
                                   AVMetadataObjectTypeCode39Mod43Code,
                                   AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeEAN8Code,
                                   AVMetadataObjectTypeCode93Code,
                                   AVMetadataObjectTypeCode128Code,
                                   AVMetadataObjectTypePDF417Code,
                                   AVMetadataObjectTypeQRCode,
                                   AVMetadataObjectTypeAztecCode];
    
    // Preview
    if (!_preview) {
        _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _preview.frame =self.view.bounds;
        [self.view.layer insertSublayer:self.preview atIndex:0];
    }
    
    // Start
    if (![_session isRunning]) {
        [_session startRunning];
    }
}

+(void) processingSCanResult:(NSString*) resultStr
{
    
    NSString * qrType = [NSString judgeScanType:resultStr];
    
    if([qrType isEqualToString:KQRTypeBound])
    {
        //绑定终端和后台作者
        [FlyingScanViewController processBound:resultStr];
    }
    else if([qrType isEqualToString:KQRTypeLogin])
    {
        //终端登陆
        [FlyingScanViewController processLogin:resultStr];
    }
    else if([qrType isEqualToString:KQRTyepeChargeCard])
    {
        //扫描充值卡
        [FlyingScanViewController charge:resultStr];
    }
    else if([qrType isEqualToString:KQRTyepeWebURL])
    {
        //扫描课程
        [FlyingScanViewController  showWebLesson:resultStr];
    }
    else if([qrType isEqualToString:KQRTyepeCode])
    {
        //扫描条形码
        [FlyingScanViewController  processCode:resultStr];
    }
}

+ (void)  charge:(NSString*) cardID
{
    if (cardID) {
        
        [FlyingHttpTool chargingCrad:cardID
                          WithOpenID:[FlyingDataManager getOpenUDID]
                          Completion:^(BOOL result) {
                              //
                              [FlyingSoundPlayer noticeSound];
                              NSString * message = NSLocalizedString( @"登录网站成功！", nil);
                              iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
                              [appDelegate makeToast:message];
                          }];
    }
}

+ (void) showWebLesson:(NSString*) webURL
{
    if (webURL) {
        
        NSString * lessonID =[NSString getLessonIDFromOfficalURL:webURL];
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (lessonID) {
            
            [appDelegate showLessonViewWithID:lessonID];
        }
        else{
            
            [appDelegate  showWebviewWithURL:webURL];
        }
    }
}

+(void) processLogin:(NSString*) logQRStr
{
    if(logQRStr)
    {
        NSString * loginID = [NSString getLoginIDFromQR:logQRStr];
        
        if (loginID) {
            
            [FlyingHttpTool loginWebsiteWithQR:loginID];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:KBERQloginFail object:nil];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KBERQloginFail object:nil];
    }
}

+(void) processBound:(NSString*) boundQRStr
{
    if(boundQRStr)
    {
        NSString * boundID = [NSString getboundCodeFromQR:boundQRStr];
        
        if (boundID) {
            
            [FlyingHttpTool boundTerminalWithQR:boundID
                                     Completion:^(BOOL result)
            {
                if (result)
                {
                    NSLog(@"绑定成功");
                    [[NSNotificationCenter defaultCenter] postNotificationName:KBERQBoundsOK object:nil];
                }
                else
                {
                    NSLog(@"绑定失败");

                    [[NSNotificationCenter defaultCenter] postNotificationName:KBERQBoundsFail object:nil];
                }
            }];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:KBERQBoundsFail object:nil];
        }
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KBERQBoundsFail object:nil];
    }
}

+(void) processCode:(NSString*) codeStr
{
    if (codeStr)
    {
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];

        if([appDelegate respondsToSelector:@selector(showLessonViewWithCode:)]) {
            
            [appDelegate showLessonViewWithCode:codeStr];
        }
        else
        {
            [appDelegate showLessonViewWithID:codeStr];
        }
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
            didOutputMetadataObjects:(NSArray *)metadataObjects
                      fromConnection:(AVCaptureConnection *)connection
{    
    NSString *resultStr=nil;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        resultStr = metadataObject.stringValue;
        
        if(resultStr.length!=0)
        {
            [_session stopRunning];
            [timer invalidate];
            
            [FlyingSoundPlayer noticeSound];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [FlyingScanViewController processingSCanResult:resultStr];
        }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CGImageRef imageToDecode=image.CGImage;  // Given a CGImage in which we are looking for barcodes
        
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
            
            [_session stopRunning];
            [timer invalidate];
            
            [FlyingSoundPlayer noticeSound];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [FlyingScanViewController processingSCanResult:contents];
            
        } else
        {
            [FlyingSoundPlayer noticeSound];
            NSString * message = NSLocalizedString(@"提醒：图片中没有发现二维码!", nil);
            iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate makeToast:message];
        }
    }];
}

-(BOOL) isRSSLesson:(NSString*) url
{
    NSRange textRange;
    NSString * substring= @"rss";
    textRange =[url rangeOfString:substring];
    
    if(textRange.location == NSNotFound)
    {
        return NO;
    }
    else{
        
        return YES;
    }
}

@end
