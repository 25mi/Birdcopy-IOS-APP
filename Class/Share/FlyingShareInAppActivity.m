//
//  FlyingShareInAppActivity.m
//  FlyingEnglish
//
//  Created by vincent sung on 28/3/2016.
//  Copyright © 2016 BirdEngish. All rights reserved.
//

#import "FlyingShareInAppActivity.h"
#import "FlyingShareData.h"
#import <RongIMLib/RCRichContentMessage.h>
#import "NSString+FlyingExtention.h"
#import "iFlyingAppDelegate.h"
#import "FlyingShareWithRecent.h"
#import "FlyingNavigationController.h"

@implementation FlyingShareInAppActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    
    return @"FlyingShareInAppActivity";
}

- (NSString *)activityTitle {
    return @"APP内分享";
}

- (UIImage *)activityImage {
    
    return [UIImage imageNamed:@"Icon"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
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
    
    RCRichContentMessage * richMessage = [[RCRichContentMessage alloc] init];
                                          
    richMessage.title = self.title;
    
    if (![NSString isBlankString:self.shareData.digest]) {
        
        richMessage.digest = self.shareData.digest;
    }
    
    if (self.url) {
        
        richMessage.url = [self.url absoluteString];
    }
    
    if (![NSString isBlankString:self.shareData.imageURL]) {
        
        richMessage.imageURL = self.shareData.imageURL;
    }
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    FlyingShareWithRecent *shareWithRecnt =[[FlyingShareWithRecent alloc] init];
    shareWithRecnt.message = richMessage;
    
    [appDelegate presentViewController:[[FlyingNavigationController alloc] initWithRootViewController:shareWithRecnt]];
    
    [self activityDidFinish:YES];
}


@end
