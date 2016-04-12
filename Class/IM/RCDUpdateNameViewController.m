//
//  RCDUpdateNameViewController.m
//  RCloudMessage
//
//  Created by Liv on 15/4/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUpdateNameViewController.h"

#import <RongIMLib/RongIMLib.h>
#import "UIColor+RCColor.h"


@interface RCDUpdateNameViewController()<UIViewControllerRestoration>

@end

@implementation RCDUpdateNameViewController

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    UIViewController *vc = [self new];
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

- (id)init
{
    if ((self = [super init]))
    {
        // Custom initialization
        self.restorationIdentifier = NSStringFromClass([self class]);
        self.restorationClass = [self class];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"0195ff" alpha:1.0f]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonItemClicked:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemClicked:)];
    
    self.tfName.text = self.displayText;
    
}

-(void) backBarButtonItemClicked:(id) sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void) rightBarButtonItemClicked:(id) sender
{
    //保存讨论组名称
    if(self.tfName.text.length == 0){

        NSString *title = @"提示";
        NSString *message = @"请输入讨论组名称!";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:^{
            //
        }];

        return;
    }
    
    //回传值
    if (self.setDisplayTextCompletion) {
        self.setDisplayTextCompletion(self.tfName.text);
    }
    
    //保存设置
    [[RCIMClient sharedRCIMClient] setDiscussionName:self.targetId name:self.tfName.text success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //收起键盘
    [self.tfName resignFirstResponder];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12.0f;
}
@end
