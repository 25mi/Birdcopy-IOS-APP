//
//  FlyingSoundPlayer.m
//  FlyingEnglish
//
//  Created by vincent sung on 9/24/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingSoundPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking.h>
#import "shareDefine.h"
#import "iFlyingAppDelegate.h"
#import "FlyingFileManager.h"
#import "AFHttpTool.h"
#import "FlyingDataManager.h"

@interface FlyingSoundPlayer ()
{
    NSString  *_textToSpeech;
    NSString  *_lessonID;
}

@end

@implementation FlyingSoundPlayer

+ (void) soundSentence:(NSString*)sentence
{
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:sentence];
    
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    utterance.rate = 0.3;
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate getSpeechSynthesizer] speakUtterance:utterance];
}

+ (void) soundWordMp3:(NSString *)wordMP3File
{
    [FlyingSoundPlayer cancelPreviousPerformRequestsWithTarget:self];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:wordMP3File]){
        
        NSURL *url = [NSURL fileURLWithPath:wordMP3File];
        SystemSoundID soundID;
        
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)url, &soundID);        
        AudioServicesPlaySystemSoundWithCompletion(soundID,nil);
        
        /*
         AVAudioPlayer * palyer  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
         palyer.numberOfLoops = 0;
         [palyer play];
         */
    }
}

+  (void)noticeSound
{
    SystemSoundID refreshSound;

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"pullrefresh" withExtension:@"aif"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url) , &refreshSound);
    
    AudioServicesPlaySystemSound(refreshSound);
}

- (void) speechWord:(NSString *) word LessonID:(NSString *) lessonID
{
    NSString *type = @"mp3";
    
    NSString * sahreDir = [FlyingFileManager getMyDictionaryDir];
    
    NSString *wordMP3File = [sahreDir stringByAppendingPathComponent:[word stringByAppendingPathExtension:type]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:wordMP3File]){
        
        [FlyingSoundPlayer soundWordMp3:wordMP3File];
    }
    else{
        
        NSString * lessonDir = [FlyingFileManager getMyLessonDir:lessonID];
        wordMP3File = [lessonDir stringByAppendingPathComponent:[word stringByAppendingPathExtension:type]];
        
        if([fm fileExistsAtPath:wordMP3File]){
            
            [FlyingSoundPlayer soundWordMp3:wordMP3File];
        }
        else{
            
            if ([AFNetworkReachabilityManager sharedManager].reachable) {
                
                _textToSpeech=word;
                _lessonID=lessonID;

                [self speechByBirdCopy];
            }
            else
            {
                [FlyingSoundPlayer soundSentence:word];
            }
        }
    }
}

- (void) speechByBirdCopy
{
    
    NSString * fileName =[[_textToSpeech lowercaseString] stringByAppendingString:@".mp3"];
    NSString * filePath= [[FlyingFileManager getMyDictionaryDir] stringByAppendingPathComponent:fileName];
    
    
    NSString * wordMp3WebPath =[NSString stringWithFormat:@"%@/public/mp3/21055_Word_MP3/%@/%@",
                                [FlyingDataManager  getServerAddress],
                                [[fileName substringToIndex:1] lowercaseString],
                                fileName];
    
    NSURLSessionDownloadTask * downloadTask = [AFHttpTool downloadUrl:wordMp3WebPath
                                                      destinationPath:filePath
                                                             progress:nil
                                                              success:^(id response) {
                                                                  //
                                                                  [FlyingSoundPlayer soundWordMp3:filePath];

                                                              } failure:^(NSError *err) {
                                                                  //
                                                                  NSFileManager *fm = [NSFileManager defaultManager];
                                                                  [fm removeItemAtPath:filePath error:nil];
                                                              }];
    
    [downloadTask resume];
}

- (void)handleError:(NSError *)error
{
    [FlyingSoundPlayer noticeSound];
}

@end
