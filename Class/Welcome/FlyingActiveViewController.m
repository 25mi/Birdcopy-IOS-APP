//
//  FlyingActiveViewController.m
//  FlyingEnglish
//
//  Created by vincent sung on 12/7/15.
//  Copyright © 2015 BirdEngish. All rights reserved.
//

#import "FlyingActiveViewController.h"
#import "MBProgressHUD.h"
#import "FlyingDataManager.h"
#import "iFlyingAppDelegate.h"

@interface FlyingActiveViewController ()
{
    MBProgressHUD* hud;
}

@end

@implementation FlyingActiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!hud) {
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"登录中...";
    }
}

//用某个OpenUDID数据激活本设备
-(void) activeWithMyDataForOpenUDID:(NSString*) openUDID
{
    hud.labelText = @"清除以前数据...";

    //清除以前数据
    [FlyingDataManager clearAllUserDate];
  
    hud.labelText = @"准备新数据...";
    //从服务器获取新数据
    [FlyingDataManager creatLocalUSerProfileWithServer];
    
    hud.labelText = @"准备新数据...";

    [iFlyingAppDelegate preparelocalEnvironment];
    
    [hud hide:YES];
    
    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = [appDelegate getMenu];
    [appDelegate.window makeKeyAndVisible];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
