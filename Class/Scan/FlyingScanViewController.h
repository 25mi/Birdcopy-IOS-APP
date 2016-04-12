//
//  FlyingScanViewController.h
//  FlyingEnglish
//
//  Created by BE_Air on 1/15/14.
//  Copyright (c) 2014 vincent sung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "shareDefine.h"
#import "FlyingViewController.h"

@interface FlyingScanViewController : FlyingViewController<AVCaptureMetadataOutputObjectsDelegate,
                                                        UINavigationControllerDelegate,
                                                        UIImagePickerControllerDelegate>

@property (strong,nonatomic)  AVCaptureDevice             *device;
@property (strong,nonatomic)  AVCaptureDeviceInput        *input;
@property (strong,nonatomic)  AVCaptureMetadataOutput     *output;
@property (strong,nonatomic)  AVCaptureSession            *session;
@property (strong,nonatomic)  AVCaptureVideoPreviewLayer  *preview;

//@property (strong, nonatomic)  NSString *                 qrType;

+(void) processingSCanResult:(NSString*) resultStr;
+(void) charge:(NSString*) cardID;
+(void) processLogin:(NSString*) logQRStr;
+(void) processCode:(NSString*) codeStr;
+(void) showWebLesson:(NSString*) webURL;


@end

