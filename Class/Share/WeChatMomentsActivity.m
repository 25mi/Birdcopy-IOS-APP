//
//  WeChatMomentsActivity.m
//  WeChatSharingFromActivity
//
//  Created by Leo Han on 15/5/13.
//  Copyright (c) 2015年 Leo Han. All rights reserved.
//

#import "WeChatMomentsActivity.h"

@implementation WeChatMomentsActivity

+ (UIActivityCategory)activityCategory {
  return UIActivityCategoryShare;
}

- (NSString *)activityType {
  return [[NSBundle mainBundle].bundleIdentifier stringByAppendingString: @".WeChatMomentsActivity"];
}

- (NSString *)activityTitle {
  self.isSessionScene = NO;
  return @"微信朋友圈";
}

- (UIImage *)activityImage {
  return [UIImage imageNamed:@"WeixinGroup"];
}

@end
