//
//  WeChatActivityBasic.m
//  
//
//  Created by Leo Han on 15/5/13.
//
//

#import "WeChatActivityBasic.h"
#import "FlyingShareData.h"
#import "NSString+FlyingExtention.h"
#import "UIImageView+thumnail.h"

@implementation WeChatActivityBasic

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
  
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
    
        for (id item in activityItems) {
            if ([item isKindOfClass:[UIImage class]]) {
                return YES;
            }
            
            if ([item isKindOfClass:[NSString class]]) {
                return YES;
            }
            
            if ([item isKindOfClass:[NSURL class]]) {
                return YES;
            }
            
            if ([item isKindOfClass:[FlyingShareData class]]) {
                
                return YES;
            }
        }
  }
    
  return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
    for (id item in activityItems) {
        
        if ([item isKindOfClass:[UIImage class]]) {
            self.image = (UIImage *)item;
        }
        
        if ([item isKindOfClass:[NSString class]]) {
            self.title = (NSString *)item;
        }
        
        if ([item isKindOfClass:[NSURL class]]) {
            self.url = (NSURL *)item;
        }
        
        if ([item isKindOfClass:[FlyingShareData class]]) {
            
            self.shareData = (FlyingShareData*) item;
        }
    }
  
}

- (void)performActivity {
    
   
    WXMediaMessage *message = [WXMediaMessage message];
    
    if(![NSString isBlankString:self.title])
    {
        message.title =self.title;
    }
    
    if(![NSString isBlankString:self.shareData.digest])
    {
        message.description =self.shareData.digest;
    }

    if(self.image)
    {
        if (!self.isSessionScene)
        {
            UIImage *myIcon = [UIImageView imageWithImage:self.image scaledToSize:CGSizeMake(20, 20)];
            [message setThumbImage:myIcon];
        }
        else
        {
            [message setThumbImage:self.image];
        }

    }
    
    if(self.url)
    {
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = [self.url absoluteString];
        message.mediaObject = ext;
    }
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    if (self.isSessionScene) {
        
        req.scene = WXSceneSession;
    }
    else{
        req.scene = WXSceneTimeline;
    }
    
    [WXApi sendReq:req];
    
    [self activityDidFinish:YES];
}

@end
