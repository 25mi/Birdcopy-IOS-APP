//
//  FlyingLoginVC.h
//  FlyingEnglish
//
//  Created by vincent sung on 12/10/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlyingAnimatedImagesView.h"

@interface FlyingLoginVC : UIViewController<FlyingAnimatedImagesViewDelegate>

- (void)login:(NSString *)userName password:(NSString *)password;

//验证手机号码
+ (BOOL) validateMobile:(NSString *)mobile;

//验证电子邮箱
+ (BOOL) validateEmail:(NSString *)email;

//验证密码
+ (BOOL) validatePassword:(NSString *) password;

@end
