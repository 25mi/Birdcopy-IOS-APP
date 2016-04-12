//
//  WeChatActivityBasic.h
//  
//
//  Created by Leo Han on 15/5/13.
//
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@class FlyingShareData;

@interface WeChatActivityBasic : UIActivity

@property (nonatomic, strong) NSString  *title;
@property (nonatomic, strong) NSURL     *url;
@property (nonatomic, strong) UIImage   *image;

@property (nonatomic, strong) FlyingShareData   *shareData;

@property (nonatomic, assign) BOOL isSessionScene;

@end
