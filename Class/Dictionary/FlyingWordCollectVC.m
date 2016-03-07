//
//  FlyingWordCollectVC.m
//  FlyingEnglish
//
//  Created by vincent on 4/4/15.
//  Copyright (c) 2015 vincent sung. All rights reserved.
//

#import "FlyingWordCollectVC.h"
#import "FlyingItemDao.h"
#import "FlyingItemParser.h"
#import "NSString+FlyingExtention.h"
#import <AFNetworking.h>
#import "shareDefine.h"
#import "SIAlertView.h"
#import "FlyingTagTransform.h"
#import "FlyingItemData.h"
#import <MediaPlayer/MPMoviePlayerController.h>

#import "UIImageView+WebCache.h"

#import "MMParallaxPresenter.h"
#import "MMParallaxPage.h"
#import "FlyingHttpTool.h"
#import "UIView+Toast.h"

@interface FlyingWordCollectVC ()

@property (strong, nonatomic) MMParallaxPresenter *mmParallaxPresenter;
@property (strong, nonatomic) UIImageView         *dismissImageView;

@end


@implementation FlyingWordCollectVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    FlyingItemDao * pubDAO = [[FlyingItemDao alloc] init];
    self.itemList = [pubDAO selectWithWord:self.theWord];
    
    self.mmParallaxPresenter = [[MMParallaxPresenter alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.mmParallaxPresenter];
    
    self.dismissImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"close"]];
    self.dismissImageView.userInteractionEnabled=YES;
    
    if (INTERFACE_IS_PAD) {
        
        self.dismissImageView.frame=CGRectMake(2*MARGIN_ipad, 2*MARGIN_ipad, 63, 63);
    }
    else
    {
        self.dismissImageView.frame=CGRectMake(2*MARGIN_iphone, 2*MARGIN_iphone, 42, 42);
    }
    
    [self.view addSubview:self.dismissImageView];
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    singleTapOne.numberOfTouchesRequired = 1;
    singleTapOne.numberOfTapsRequired = 1;
    [self.dismissImageView addGestureRecognizer:singleTapOne];


    if (self.itemList.count==0) {
        
        [self loadDataFromServer];
    }
    else
    {
        [self showWordItemList];
    }
}


- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


-(void) showWordItemList
{
    float screenWidth =self.view.bounds.size.width;
    FlyingTagTransform *tagTrasform = [[FlyingTagTransform alloc] init];
    
    [self.itemList enumerateObjectsUsingBlock:^(FlyingItemData  *item, NSUInteger idx, BOOL *stop)
     {
         FlyingItemData * itemData = self.itemList[idx];
         
         UIImageView  *coverView   = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectorRect"]];
         NSString     *coverText   = [tagTrasform wordForIndex:itemData.BEINDEX];
         UIImage      *tagImage    = [tagTrasform corlorMagnetForIndex:itemData.BEINDEX];
         
         NSMutableString* contentText  =  [NSMutableString string];
         
         BOOL isMediaData=NO;
         
         switch ([itemData contentType]) {
                 
             case BEText:
             case BEUnknown:
             {
                 NSString *temp=[itemData textContent];
                 if (temp) {
                     [contentText appendString:temp];
                 }
             }
                 break;
                 
             case BEImage:
             {
                 isMediaData=YES;
                 [coverView sd_setImageWithURL:[NSURL URLWithString:[itemData imageURLOnly]]];
             }
                 break;
                 
            /*
             case BEVedio:
             {
                 // Create custom movie player
                 
                 isMediaData=YES;
                 MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[itemData vedioURLOnly]]];
                 
                 [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
                 [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
                 [moviePlayer setFullscreen:FALSE];
             }
                 break;
                 
             case BEAudio:
             {
                 // Create custom movie player
                 isMediaData=YES;
                 MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[itemData audioURLOnly]]];
                 
                 [moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
                 [moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
                 [moviePlayer setFullscreen:FALSE];
                 
             }
             
                 break;
             */
             default:
                 break;
         }
         
         NSString *temp=[itemData tagContent];
         if (temp)
         {
             [contentText appendString:@"\n\n"];
             [contentText appendString:temp];
         }
         
         float coverRatio=2.0/16;
         
         if (isMediaData) {
             coverRatio=9.0/16;
         }
         
         if (isMediaData) {
             
             [contentText appendString: @"多媒体解释,请看上图：）"];
         }
         
         MMParallaxPage *page = [[MMParallaxPage alloc] initWithScrollFrame:self.mmParallaxPresenter.frame
                                                           withHeaderHeight:screenWidth*coverRatio
                                                            withContentText:contentText
                                                            andContextImage:tagImage];
         [page.headerLabel setText:coverText];
         [page.headerView addSubview:coverView];
         [page setTitleAlignment:MMParallaxPageTitleNSTexCentertAlignment];
         
         [self.mmParallaxPresenter addParallaxPage:page];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//////////////////////////////////////////////////////////////
#pragma mark - Download data from Web Dictionary
//////////////////////////////////////////////////////////////

- (void) loadDataFromServer
{
    
    [FlyingHttpTool getItemsforWord:self.theWord
                         Completion:^(NSArray *itemList,NSInteger allRecordCount) {
                             //
                             self.itemList = [itemList mutableCopy];
                             [self parserOK];
                         }];
}

-(void) parserOK
{
    if (self.itemList.count>=1) {
        
        [self showWordItemList];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            FlyingItemDao * dao= [[FlyingItemDao alloc] init];
            
            [self.itemList enumerateObjectsUsingBlock:^(FlyingItemData  *item, NSUInteger idx, BOOL *stop) {
                
                [dao insertWithData:item];
            }];
        });
    }
    else{
        
        [self.view makeToast:@"感谢提醒,我们会尽快补充词典！"];
    }
}

@end
