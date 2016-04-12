//
//  WeChatSessionActivity.m
//  WeChatSharingFromActivity
//
//  Created by Leo Han on 15/5/13.
//  Copyright (c) 2015年 Leo Han. All rights reserved.
//

#import "WeChatSessionActivity.h"

@implementation WeChatSessionActivity

+ (UIActivityCategory)activityCategory {
  return UIActivityCategoryShare;
}

- (NSString *)activityType {
  return [[NSBundle mainBundle].bundleIdentifier stringByAppendingString: @".WeChatSessionActivity"];
}

- (NSString *)activityTitle {
  self.isSessionScene = YES;
  return @"微信好友";
}

- (UIImage *)activityImage {
  return [UIImage imageNamed:@"WeiXin"];
}

@end
