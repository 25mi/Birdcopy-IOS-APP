//
//  Sharer.m
//  CFShareCircle
//
//  Created by Camden on 1/15/13.
//  Copyright (c) 2013 Camden. All rights reserved.
//

#import "CFSharer.h"

@implementation CFSharer

@synthesize name = _name;
@synthesize image = _image;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        _name = name;
        _image = [UIImage imageNamed:imageName];
    }
    return self;    
}

+ (CFSharer *)mail {
    return [[CFSharer alloc] initWithName:@"邮件分享" imageName:@"Mail"];
}

+ (CFSharer *)dropbox {
    return [[CFSharer alloc] initWithName:@"Dropbox" imageName:@"dropbox"];
}

+ (CFSharer *)evernote {
    return [[CFSharer alloc] initWithName:@"Evernote" imageName:@"evernote"];
}

+ (CFSharer *)facebook {
    return [[CFSharer alloc] initWithName:@"Facebook" imageName:@"facebook"];
}

+ (CFSharer *)googleDrive {
    return [[CFSharer alloc] initWithName:@"Google Drive" imageName:@"google_drive"];
}

+ (CFSharer *)pinterest {
    return [[CFSharer alloc] initWithName:@"Pinterest" imageName:@"pinterest"];
}

+ (CFSharer *)twitter {
    return [[CFSharer alloc] initWithName:@"Twitter" imageName:@"twitter"];
}

+ (CFSharer *)sms {
    return [[CFSharer alloc] initWithName:@"短信分享" imageName:@"Sms"];
}

+ (CFSharer *)weibo {
    return [[CFSharer alloc] initWithName:@"微博分享" imageName:@"Weibo"];
}

+ (CFSharer *)weixin {
    return [[CFSharer alloc] initWithName:@"微信好友" imageName:@"WeiXin"];
}

+ (CFSharer *)weixinGroup {
    return [[CFSharer alloc] initWithName:@"微信圈" imageName:@"WeixinGroup"];
}

+ (CFSharer *)copyLink
{
    return [[CFSharer alloc] initWithName:@"复制链接" imageName:@"link"];
}

+ (CFSharer *)im
{
    return [[CFSharer alloc] initWithName:@"聊天好友" imageName:@"chat"];
}

+ (CFSharer *)save
{
    return [[CFSharer alloc] initWithName:@"保存图片" imageName:@"photos"];
}

+ (CFSharer *)scan
{
    return [[CFSharer alloc] initWithName:@"二维码解析" imageName:@"scan"];
}

+ (CFSharer *)charge
{
    return [[CFSharer alloc] initWithName:@"充值" imageName:@"Profile"];
}



@end
