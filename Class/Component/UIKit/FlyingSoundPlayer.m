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

+(void) soundEffect:(NSString *)sound
{
    
    NSString *type = @"mp3";
    
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle] pathForResource:sound ofType:type];
    
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:sound ofType:@"wav"];
    }
    
    if (!path) {
        NSString *tempPath = NSTemporaryDirectory();
        NSString * fileName =[sound stringByAppendingString:@".mp3"];
        path= [tempPath stringByAppendingPathComponent:fileName];
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID ((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

+ (void) soundWordMp3:(NSString *)wordMP3File
{
    [FlyingSoundPlayer cancelPreviousPerformRequestsWithTarget:self];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:wordMP3File]){
        
        NSURL *url = [NSURL fileURLWithPath:wordMP3File];
        SystemSoundID soundID;
        
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)url, &soundID);
        AudioServicesPlaySystemSound(soundID);
        
        /*
         AVAudioPlayer * palyer  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
         palyer.numberOfLoops = 0;
         [palyer play];
         */
    }
}

- (void) speechWord:(NSString *) word LessonID:(NSString *) lessonID
{
    NSString *type = @"mp3";
    
    NSString * sahreDir = [FlyingFileManager getUserShareDir];
    
    NSString *wordMP3File = [sahreDir stringByAppendingPathComponent:[word stringByAppendingPathExtension:type]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:wordMP3File]){
        
        [FlyingSoundPlayer soundWordMp3:wordMP3File];
    }
    else{
        
        NSString * lessonDir = [[FlyingFileManager getDownloadsDir] stringByAppendingPathComponent:lessonID];
        wordMP3File = [lessonDir stringByAppendingPathComponent:[word stringByAppendingPathExtension:type]];
        
        if([fm fileExistsAtPath:wordMP3File]){
            
            [FlyingSoundPlayer soundWordMp3:wordMP3File];
        }
        else{
            
            if ([AFNetworkReachabilityManager sharedManager].reachable) {
                
                _textToSpeech=word;
                _lessonID=lessonID;

                [self speechByGoogle];
            }
            else
            {
                [FlyingSoundPlayer soundSentence:word];
            }
        }
    }
}

- (void) speechByGoogle
{
    NSString* userAgent = @"Mozilla/5.0";
    NSString* requestUrlStr = [NSString stringWithFormat:@"http://www.translate.google.com/translate_tts?tl=en&q=%@",_textToSpeech];
    NSURL *url = [NSURL URLWithString:[requestUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[appDelegate get_flyingSoundPlayer_queue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               
                               if (error != nil)
                               {
                                   [self handleError:error];
                               }
                               else if ([httpResponse statusCode] != 200)
                               {
                                   NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Google发音服务出问题了！" };
                                   
                                   NSError *error = [NSError
                                                     errorWithDomain:NSCocoaErrorDomain
                                                     code:kCFFTPErrorUnexpectedStatusCode
                                                     userInfo:userInfo];
                                   
                                   [self handleError:error];
                               }
                               else
                               {
                                   
                                   NSString * fileName =[_textToSpeech stringByAppendingString:@".mp3"];
                                   
                                   NSString * downloadDir = [FlyingFileManager getDownloadsDir];
                                   NSString * lessonDir = [downloadDir stringByAppendingPathComponent:_lessonID];
                                   
                                   NSString * filePath= [lessonDir stringByAppendingPathComponent:fileName];
                                   
                                   //如果没有课程目录就创建一个
                                   BOOL isDir = NO;
                                   NSFileManager *fm = [NSFileManager defaultManager];
                                   if(!([fm fileExistsAtPath:lessonDir isDirectory:&isDir] && isDir))
                                   {
                                       [fm createDirectoryAtPath:lessonDir withIntermediateDirectories:YES attributes:nil error:nil];
                                   }
                                   
                                   if ([data writeToFile:filePath atomically:YES]) {
                                       
                                       [FlyingSoundPlayer soundWordMp3:filePath];
                                   }
                                   else{
                                       
                                       [FlyingSoundPlayer soundEffect:SECalloutLight];
                                   }
                               }
                           }];
    
}

- (void)handleError:(NSError *)error
{
    [FlyingSoundPlayer soundEffect:SECalloutLight];
}

@end
