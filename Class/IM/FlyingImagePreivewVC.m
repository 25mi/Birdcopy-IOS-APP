//
//  FlyingImagePreivewVC.m
//  FlyingEnglish
//
//  Created by vincent on 6/30/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingImagePreivewVC.h"
#import <UIImageView+AFNetworking.h>
#import "FlyingShareWithRecent.h"
#import  "ZXingObjC.h"
#import "FlyingSoundPlayer.h"
#import "NSString+FlyingExtention.h"
#import "FlyingScanViewController.h"
#import "FlyingShareWithRecent.h"
#import <UIKit/UIKit.h>
#import <CRToastManager.h>
#import "iFlyingAppDelegate.h"

@interface FlyingImagePreivewVC ()<UIViewControllerRestoration>
{
    CGFloat lastScale;
    CGRect oldFrame;    //保存图片原来的大小
    CGRect largeFrame;  //确定图片放大最大的程度
}

/**
 *  原始图片视图
 */
@property(nonatomic, strong) UIImageView            *imageView;

@end

@implementation FlyingImagePreivewVC

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
    
    // Do any additional setup after loading the view.
    
    _imageView   = [[UIImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_imageView];
    
    [_imageView setContentMode:UIViewContentModeScaleAspectFit];

    [_imageView setMultipleTouchEnabled:YES];
    [_imageView setUserInteractionEnabled:YES];
    
    if (self.originalImage) {
        
        _imageView.image=self.originalImage;
        
        [self prepareGestureRecognizer];
    }
    else
    {
        if ([self.imageUrl hasPrefix:@"http://"] || [self.imageUrl hasPrefix:@"https://"])
        {
            [_imageView setImageWithURL:[NSURL URLWithString:self.imageUrl]];
            [self prepareGestureRecognizer];
        }
        else
        {
            UIImage *image = [UIImage imageWithContentsOfFile:self.imageUrl];

            _imageView.image = image;
            
            [self prepareGestureRecognizer];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor clearColor];

    [UIView animateWithDuration:1.0 animations:^{
        self.view.backgroundColor = [UIColor blackColor];
    }];
}

-(void) prepareGestureRecognizer
{
    CGSize screenSize=self.view.frame.size;
    oldFrame = _imageView.frame;
    largeFrame = CGRectMake(0 - screenSize.width, 0 - screenSize.height, 3 * oldFrame.size.width, 3 * oldFrame.size.height);
    
    [self addGestureRecognizerToView:_imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 添加所有的手势
- (void) addGestureRecognizerToView:(UIView *)view
{
    // 单击手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tapRecognizer.numberOfTapsRequired = 1; // 单击

    [view addGestureRecognizer:tapRecognizer];
    
    
    // 长按手势
    UILongPressGestureRecognizer *longpressGR= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressView:)];
    
    [view addGestureRecognizer:longpressGR];
    
    // 关键在这一行，如果长按侦测失败才會触发单击
    [tapRecognizer requireGestureRecognizerToFail:longpressGR];


    // 旋转手势
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
    [view addGestureRecognizer:rotationGestureRecognizer];
    
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [view addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [view addGestureRecognizer:panGestureRecognizer];
}

// 处理单击手势
- (void) tapView:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

// 处理长按手势
- (void) didLongPressView:(UILongPressGestureRecognizer *)longGestureRecognizer
{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *doneAction1 = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error != NULL)
    {
        NSString * message = NSLocalizedString( @"保存图片失败！", nil);
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeToast:message];
    }
    else
    {
        NSString * message = NSLocalizedString( @"成功保存图片！", nil);
        iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate makeToast:message];
    }
}

- (void)handleShare
{
    RCImageMessage * imageMessage = [RCImageMessage messageWithImageURI:_imageUrl];
    FlyingShareWithRecent * shareFriends = [[FlyingShareWithRecent alloc] init];
    shareFriends.message=imageMessage;
    
    [self.navigationController pushViewController:shareFriends animated:YES];
}

- (void)handleScan
{
    CGImageRef imageToDecode=self.imageView.image.CGImage;  // Given a CGImage in which we are looking for barcodes
    
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
        
        [FlyingSoundPlayer noticeSound];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        [FlyingScanViewController processingSCanResult:contents];
    }
}

// 处理旋转手势
- (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
{
    UIView *view = rotationGestureRecognizer.view;
    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
        [rotationGestureRecognizer setRotation:0];
    }
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        if (_imageView.frame.size.width < oldFrame.size.width) {
            _imageView.frame = oldFrame;
            //让图片无法缩得比原图小
        }
        if (_imageView.frame.size.width > 3 * oldFrame.size.width) {
            _imageView.frame = largeFrame;
        }
        pinchGestureRecognizer.scale = 1;
    }
}

// 处理拖拉手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}
    
@end

