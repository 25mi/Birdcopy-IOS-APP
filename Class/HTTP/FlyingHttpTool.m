
//
//  FlyingHttpTool.m
//  FlyingEnglish
//
//  Created by vincent on 6/3/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//


#import "FlyingHttpTool.h"
#import "shareDefine.h"
#import "AFHttpTool.h"
#import "RCDRCIMDataSource.h"
#import "RCDataBaseManager.h"

#import "FlyingLessonParser.h"
#import "FlyingItemParser.h"
#import "NSString+FlyingExtention.h"
#import "FlyingCoverDataParser.h"

#import "FlyingGroupData.h"
#import "FlyingGroupMemberData.h"
#import "FlyingPubLessonData.h"

#import "FlyingStatisticData.h"
#import "FlyingStatisticDAO.h"

#import "FlyingTouchDAO.h"
#import "FlyingTouchRecord.h"

#import "FlyingNowLessonDAO.h"
#import "FlyingLessonData.h"

#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"

#import "FlyingDataManager.h"
#import <UICKeyChainStore.h>
#import "FlyingGroupUpdateData.h"
#import "iFlyingAppDelegate.h"

@implementation FlyingHttpTool

//////////////////////////////////////////////////////////////////////////////////
#pragma  登录问题
//////////////////////////////////////////////////////////////////////////////////

+(void) loginRongCloud
{
    NSString *rongDeviceKoken = [UICKeyChainStore keyChainStore][kRongCloudDeviceToken];
    
    if(!rongDeviceKoken || rongDeviceKoken.length==0)
    {
        NSString *openID = [FlyingDataManager getOpenUDID];
        
        if (!openID) {
            
            return;
        }
        
        [AFHttpTool getTokenWithOpenID:openID
                               success:^(id response) {
                                   //
                                   if (response) {
                                       NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                       
                                       if ([code isEqualToString:@"1"]) {
                                           
                                           NSString *rongDeviceKoken = response[@"token"];
                                           
                                           [self connectWithRongCloud:rongDeviceKoken];
                                       }
                                       else
                                       {
                                           NSLog(@"Get rongcloud Token %@",response[@"rm"]);
                                       }
                                   }
                               } failure:^(NSError *err) {
                                   //
                                   NSLog(@"Get rongcloud Token %@",err.description);
                                   
                               }];
    }
    else
    {
        [self connectWithRongCloud:rongDeviceKoken];
    }
    
}

+(void)  connectWithRongCloud:(NSString*)rongDeviceKoken
{
    static int tryTimes=0;
    //连接融云服务器
    [[RCIM sharedRCIM] connectWithToken:rongDeviceKoken
                                success:^(NSString *userId) {
                                    //
                                    //保存Token
                                    [UICKeyChainStore keyChainStore][kRongCloudDeviceToken] = rongDeviceKoken;
                                    
                                    RCUserInfo *currentUserInfo=[[RCDataBaseManager shareInstance] getUserByUserId:userId];
                                    if (currentUserInfo==nil)
                                    {
                                        [FlyingHttpTool getUserInfoByRongID:userId
                                                                 completion:^(FlyingUserData *userData,RCUserInfo *userInfo) {
                                                                     //
                                                                 }];
                                    }
                                    else
                                    {
                                        [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
                                    }
                                }
                                  error:^(RCConnectErrorCode status) {
                                      //
                                      NSLog(@"Get rongcloud Token %@",@(status));
                                      [UICKeyChainStore keyChainStore][kRongCloudDeviceToken] = @"";
                                  }
     
                         tokenIncorrect:^{
                             
                             NSLog(@"Get rongcloud tokenIncorrect");
                             //
                             [UICKeyChainStore keyChainStore][kRongCloudDeviceToken] = @"";
                             
                             tryTimes++;
                             
                             if(tryTimes<3)
                             {
                                 [FlyingHttpTool loginRongCloud];
                             }
     }];
}

//////////////////////////////////////////////////////////////////////////////////
#pragma 个人账户昵称头像
//////////////////////////////////////////////////////////////////////////////////

+(void) getUserInfoByopenID:(NSString *) openID
                 completion:(void (^)(FlyingUserData *userData,RCUserInfo *userInfo)) completion;
{
    [AFHttpTool getUserInfoWithOpenID:openID
                              success:^(id response) {
                                  //
                                  if (response) {
                                      
                                      NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                      
                                      if ([code isEqualToString:@"1"]) {
                                          
                                          //系统用户数据
                                          FlyingUserData * userData = [FlyingUserData new];
                                          
                                          userData.openUDID = response[@"tuser_key"];
                                          userData.name     = response[@"name"];
                                          userData.portraitUri=response[@"portraitUri"];
                                          userData.digest   = response[@"br_intro"];
                                          
                                          [FlyingDataManager saveUserData:userData];
                                          
                                          RCUserInfo *userInfo = [RCUserInfo new];
                                          
                                          userInfo.userId= [openID MD5];
                                          userInfo.name=response[@"name"];
                                          userInfo.portraitUri=response[@"portraitUri"];
                                          
                                          //用户融云数据库
                                          [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                                          //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                          [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                                          
                                          if (completion) {
                                              
                                              completion(userData,userInfo);
                                          }
                                      }
                                      else
                                      {
                                          
                                          //系统用户数据
                                          FlyingUserData * userData = [[FlyingUserData alloc] init];
                                          userData.openUDID = [FlyingDataManager getOpenUDID];

                                          [FlyingDataManager saveUserData:userData];

                                          RCUserInfo *userInfo = [RCUserInfo new];
                                          userInfo.userId= [openID MD5];
                                          
                                          //用户融云数据库
                                          [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                                          //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                          [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                                          
                                          NSLog(@"getUserInfoWithOpenID:%@",response[@"rm"]);
                                      }
                                  }
                              } failure:^(NSError *err) {
                                  //
                                  
                                  NSLog(@"Get rongcloud Toke %@",err.description);
                                  
                              }];
}


+(void) getUserInfoByRongID:(NSString *) rongID
                 completion:(void (^)(FlyingUserData *userData,RCUserInfo *userInfo)) completion
{
    [AFHttpTool getUserInfoWithRongID:rongID
                              success:^(id response) {
                                  //
                                  if (response) {
                                      
                                      NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                      
                                      if ([code isEqualToString:@"1"]) {
                                          
                                          //系统用户数据
                                          FlyingUserData * userData = [FlyingUserData new];
                                          
                                          userData.openUDID = response[@"tuser_key"];
                                          userData.name     = response[@"name"];
                                          userData.portraitUri=response[@"portraitUri"];
                                          userData.digest   = response[@"br_intro"];
                                          
                                          RCUserInfo *userInfo = [RCUserInfo new];
                                          
                                          userInfo.userId= rongID;
                                          userInfo.name=response[@"name"];
                                          userInfo.portraitUri=response[@"portraitUri"];
                                          
                                          [FlyingDataManager saveUserData:userData];
                                          
                                          //用户融云数据库
                                          [[RCDataBaseManager shareInstance] insertUserToDB:userInfo];
                                          //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                          [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
                                          
                                          if (completion) {
                                              
                                              completion(userData,userInfo);
                                          }
                                      }
                                      else
                                      {
                                          NSLog(@"getUserInfoByRongID:%@",response[@"rm"]);
                                      }
                                  }
                              } failure:^(NSError *err) {
                                  //
                                  
                                  NSLog(@"Get rongcloud Toke %@",err.description);
                              }];
}

+ (void) requestUploadPotraitWithOpenID:openID
                                   data:imageData
                             Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool requestUploadPotraitWithOpenID:openID
                                          data:imageData
                                       success:^(id response) {
                                           //
        if (response)
        {
            NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
            
            //上传图片到服务器，成功后通知融云服务器更新用户信息
            if ([code isEqualToString:@"1"])
            {
                NSString *portraitUri = [NSString stringWithFormat:@"%@",response[@"portraitUri"]];
                
                if (portraitUri.length!=0) {
                    
                    [AFHttpTool refreshUesrWithOpenID:openID
                                                 name:nil
                                          portraitUri:portraitUri
                                             br_intro:nil
                                              success:^(id response) {
                                                  
                                                  NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                                  
                                                  BOOL result=false;
                                                  
                                                  //上传图片到服务器，成功后通知融云服务器更新用户信息
                                                  if ([code isEqualToString:@"1"])
                                                  {
                                                      result=true;
                                                      
                                                      FlyingUserData * currentUserData = [FlyingDataManager getUserData:nil];
                                                      currentUserData.portraitUri = portraitUri;
                                                      //更新本地信息
                                                      [FlyingDataManager saveUserData:currentUserData];
                                                      
                                                      //更新融云信息
                                                      RCUserInfo *currentUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
                                                      currentUserInfo.portraitUri=portraitUri;
                                                      [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
                                                      [[RCDataBaseManager shareInstance] insertUserToDB:currentUserInfo];
                                                      
                                                      //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                                      [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
                                                  }
                                                  
                                                  completion(result);
                                              }
                                              failure:^(NSError *err) {
                                                  //
                                                  NSLog(@"requestUploadPotraitWithOpenID:%@",err.description);
                                                  completion(false);
                                              }];
                }
            }
            else
            {
                NSLog(@"requestUploadPotraitWithOpenID:%@",response[@"rm"]);
                completion(false);
            }
        }
    }
    failure:^(NSError *err) {
        //
        NSLog(@"requestUploadPotraitWithOpenID:%@",err.description);
        completion(false);
    }];
}

//////////////////////////////////////////////////////////////
#pragma  group related (not IM)
//////////////////////////////////////////////////////////////
+ (void)  getAllGroupsForDomainID:(NSString*) domainID
                       DomainType:(NSString*) type
                        PageNumber:(NSInteger) pageNumber
                         Completion:(void (^)(NSArray *groupList,NSInteger allRecordCount)) completion
{
    [AFHttpTool getAllGroupsForDomainID:domainID
                             DomainType:type
                               PageNumber:pageNumber
                                  success:^(id response) {
                                      
                                      NSMutableArray *tempArr = [NSMutableArray new];
                                      NSArray *allGroups = response[@"rs"];
                                      
                                      if (allGroups) {
                                          
                                          for (NSDictionary *dic in allGroups)
                                          {
                                              FlyingGroupData *group = [[FlyingGroupData alloc] init];
                                              
                                              group.gp_id    = [dic objectForKey:@"gp_id"];
                                              group.gp_name  = [dic objectForKey:@"gp_name"];
                                              group.gp_owner = [dic objectForKey:@"gp_owner"];
                                              group.gp_desc  = [dic objectForKey:@"gp_desc"];
                                              
                                              group.logo     = [dic objectForKey:@"logo"];
                                              group.cover     = [dic objectForKey:@"cover"];
                                              
                                              group.is_audit_join = [[dic  objectForKey:@"is_audit_join"] isEqualToString:@"1"]?YES:NO ;
                                              group.is_rc_gp = [[dic  objectForKey:@"is_rc_gp"] isEqualToString:@"1"]?YES:NO ;
                                              
                                              group.is_audit_rcgp = [[dic  objectForKey:@"is_audit_rcgp"] isEqualToString:@"1"]?YES:NO ;
                                              group.owner_recom = [[dic  objectForKey:@"owner_recom"] isEqualToString:@"1"]?YES:NO ;
                                              group.sys_recom = [[dic  objectForKey:@"sys_recom"] isEqualToString:@"1"]?YES:NO ;
                                              group.is_public_access= [[dic  objectForKey:@"is_public"] isEqualToString:@"1"]?YES:NO ;
                                              
                                              NSDictionary *groupSum = [dic objectForKey:@"gp_stat"];
                                              group.gp_member_sum = [groupSum[@"gp_member_sum"] stringValue];
                                              group.gp_ln_sum = [groupSum[@"gp_ln_sum"] stringValue];
                                              
                                              
                                              FlyingGroupUpdateData * updata = [[FlyingGroupUpdateData alloc] init];
                                              updata.groupData = group;
                                              
                                              NSDictionary *upadateLessonDataDic = [dic objectForKey:@"latest_ln"];
                                              
                                              if(![upadateLessonDataDic isKindOfClass:[NSNull class]])
                                              {
                                                  FlyingPubLessonData *lesson = [[FlyingPubLessonData alloc] init];
                                                  
                                                  lesson.lessonID         = [upadateLessonDataDic objectForKey:@"ln_id"];
                                                  lesson.title            = [upadateLessonDataDic objectForKey:@"ln_title"];
                                                  lesson.desc             = [upadateLessonDataDic objectForKey:@"ln_desc"];
                                                  lesson.imageURL         = [upadateLessonDataDic objectForKey:@"img_file"];
                                                  lesson.contentType      = [upadateLessonDataDic objectForKey:@"res_type"];
                                                  lesson.tag              = [upadateLessonDataDic objectForKey:@"ln_tag"];
                                                  lesson.coinPrice        = [[upadateLessonDataDic objectForKey:@"ln_price"] integerValue];
                                                  
                                                  lesson.author           = [upadateLessonDataDic objectForKey:@"ln_owner"];
                                                  lesson.commentCount     = [upadateLessonDataDic objectForKey:@"ln_cmt_sum"];
                                                  lesson.timeLamp         = [upadateLessonDataDic objectForKey:@"upd_time"];
                                                  
                                                  updata.recentLessonData = lesson;
                                              }
                                              
                                              [tempArr addObject:updata];
                                          }
                                      }
                                      
                                      if (completion) {
                                          completion(tempArr,[response[@"allRecordCount"] integerValue]);
                                      }

                                  } failure:^(NSError *err) {
                                      //
                                  }];
}

+ (void) getMyGroupsForPageNumber:(NSInteger) pageNumber
                       Completion:(void (^)(NSArray *groupUpdateList,NSInteger allRecordCount)) completion;
{
    [AFHttpTool getMyGroupsForPageNumber:pageNumber
    Success:^(id response) {
       
        NSMutableArray *tempArr = [NSMutableArray new];
        NSDictionary *allGroups = response[@"rs"];
        
        if (![allGroups isKindOfClass:[NSNull class]]) {
            
            for (NSDictionary *dic in allGroups) {
                
                FlyingGroupData *group = [[FlyingGroupData alloc] init];
                
                group.gp_id    = [dic objectForKey:@"gp_id"];
                group.gp_name  = [dic objectForKey:@"gp_name"];
                group.gp_owner = [dic objectForKey:@"gp_owner"];
                group.gp_desc  = [dic objectForKey:@"gp_desc"];
                
                group.logo     = [dic objectForKey:@"logo"];
                group.cover     = [dic objectForKey:@"cover"];
                
                group.is_audit_join = [[dic  objectForKey:@"is_audit_join"] isEqualToString:@"1"]?YES:NO ;
                group.is_rc_gp = [[dic  objectForKey:@"is_rc_gp"] isEqualToString:@"1"]?YES:NO ;
                
                group.is_audit_rcgp = [[dic  objectForKey:@"is_audit_rcgp"] isEqualToString:@"1"]?YES:NO ;
                group.owner_recom = [[dic  objectForKey:@"owner_recom"] isEqualToString:@"1"]?YES:NO ;
                group.sys_recom = [[dic  objectForKey:@"sys_recom"] isEqualToString:@"1"]?YES:NO ;
                group.is_public_access= [[dic  objectForKey:@"is_public"] isEqualToString:@"1"]?YES:NO ;

                NSDictionary *groupSum = [dic objectForKey:@"gp_stat"];
                group.gp_member_sum = [groupSum[@"gp_member_sum"] stringValue];
                group.gp_ln_sum = [groupSum[@"gp_ln_sum"] stringValue];
                
                
                FlyingGroupUpdateData * updata = [[FlyingGroupUpdateData alloc] init];
                updata.groupData = group;
                
                NSDictionary *upadateLessonDataDic = [dic objectForKey:@"latest_ln"];
                
                if(![upadateLessonDataDic isKindOfClass:[NSNull class]])
                {
                    FlyingPubLessonData *lesson = [[FlyingPubLessonData alloc] init];
                    
                    lesson.lessonID         = [upadateLessonDataDic objectForKey:@"ln_id"];
                    lesson.title            = [upadateLessonDataDic objectForKey:@"ln_title"];
                    lesson.desc             = [upadateLessonDataDic objectForKey:@"ln_desc"];
                    lesson.imageURL         = [upadateLessonDataDic objectForKey:@"img_file"];
                    lesson.contentType      = [upadateLessonDataDic objectForKey:@"res_type"];
                    lesson.tag              = [upadateLessonDataDic objectForKey:@"ln_tag"];
                    lesson.coinPrice        = [[upadateLessonDataDic objectForKey:@"ln_price"] integerValue];
                    
                    lesson.author           = [upadateLessonDataDic objectForKey:@"ln_owner"];
                    lesson.commentCount     = [upadateLessonDataDic objectForKey:@"ln_cmt_sum"];
                    lesson.timeLamp         = [upadateLessonDataDic objectForKey:@"upd_time"];
                    
                    updata.recentLessonData = lesson;
                }
                
                [tempArr addObject:updata];
            }
        }
        
        if (completion) {
            completion(tempArr,[response[@"allRecordCount"] integerValue]);
        }
        
    } failure:^(NSError *err) {
        
    }];
}

//根据id获取单个群组
+ (void) getGroupByID:(NSString *) groupID
    successCompletion:(void (^)(FlyingGroupData *group)) completion
{

    [AFHttpTool getGroupByID:groupID
                     success:^(id response) {
                         //
                         NSMutableArray *tempArr = [NSMutableArray new];
                         NSArray *allGroups = response[@"rs"];
                         
                         if (allGroups) {
                             for (NSDictionary *dic in allGroups) {
                                 FlyingGroupData *group = [[FlyingGroupData alloc] init];
                                 group.gp_id    = [dic objectForKey:@"gp_id"];
                                 group.gp_name  = [dic objectForKey:@"gp_name"];
                                 group.gp_owner = [dic objectForKey:@"gp_owner"];
                                 group.gp_desc  = [dic objectForKey:@"gp_owner"];
                                 
                                 group.logo     = [dic objectForKey:@"logo"];
                                 group.cover    = [dic objectForKey:@"cover"];
                                 group.is_audit_join = [[dic  objectForKey:@"is_audit_join"] isEqualToString:@"1"]?YES:NO ;
                                 group.is_audit_join = [[dic  objectForKey:@"is_rc_gp"] isEqualToString:@"1"]?YES:NO ;
                                 
                                 group.is_audit_rcgp = [[dic  objectForKey:@"is_audit_rcgp"] isEqualToString:@"1"]?YES:NO ;
                                 group.owner_recom = [[dic  objectForKey:@"owner_recom"] isEqualToString:@"1"]?YES:NO ;
                                 group.sys_recom = [[dic  objectForKey:@"sys_recom"] isEqualToString:@"1"]?YES:NO ;
                                 
                                 [tempArr addObject:group];
                             }
                         }
                         
                         if (tempArr) {
                             completion(tempArr[0]);
                         }

                     } failure:^(NSError *err) {
                         //
                     }];
}

//加入聊天群组
+ (void) joinGroupForAccount:(NSString*) account
                      GroupID:(NSString*) groupID
                   Completion:(void (^)(FlyingUserRightData *userRightData)) completion
{
    
    [AFHttpTool joinGroupForAccount:account
                              GroupID:groupID
                              success:^(id response) {
                                  //
                                  FlyingUserRightData * userRightData = nil;

                                  if (response) {
                                      
                                      NSString *code = response[@"rc"];
                                      
                                      if ([code isEqualToString:@"1"]) {
                                          
                                          userRightData = [[FlyingUserRightData alloc] init];
                                          userRightData.domainID = groupID;
                                          userRightData.domainType = BC_Domain_Group;
                                          
                                          if([response[@"rm"] isEqualToString:BC_Member_Noexisted])
                                          {
                                              userRightData.memberState = BC_Member_Noexisted;
                                          }
                                          else{
                                              
                                              userRightData.memberState = response[@"ay_join_status"];
                                          }
                                          
                                          [FlyingDataManager saveUserRightData:userRightData];
                                          
                                      }
                                  }
                                  
                                  if (completion) {
                                      //
                                      completion(userRightData);
                                  }

                              } failure:^(NSError *err) {
                                  //
                                  
                                  if (completion) {
                                      //
                                      completion(nil);
                                  }
                              }];
}


//退出聊天群组
+ (void)quitGroupForAccount:(NSString*) account
                              GroupID:(NSString*) groupID
                             complete:(void (^)(BOOL))result
{

    [AFHttpTool quitForAccount:account
                       GroupByID:groupID
                         success:^(id response) {
                             //
                             
                         } failure:^(NSError *err) {
                             //
                         }];
}

+ (void) checkGroupMemberInfoForAccount:(NSString*) account
                                GroupID:(NSString*) groupID
                             Completion:(void (^)(FlyingUserRightData *userRightData)) completion;
{
    [AFHttpTool checkGroupMemberInfoForAccount:account
                                       GroupID:groupID
                                       success:^(id response) {
                                           //
                                           FlyingUserRightData * userRightData = nil;

                                           if (response) {
                                               
                                               NSString *code = response[@"rc"];
                                               
                                               if ([code isEqualToString:@"1"]) {
                                                   
                                                   userRightData = [FlyingUserRightData new];
                                                   userRightData.domainID = groupID;
                                                   userRightData.domainType = BC_Domain_Group;
                                                   
                                                   if([response[@"allRecordCount"] integerValue]==0)
                                                   {
                                                       userRightData.memberState = BC_Member_Noexisted;
                                                   }
                                                   else{
 
                                                       NSArray *allMembers = response[@"rs"];
                                                       
                                                       NSDictionary * dic = allMembers[0];
                                                       
                                                       if (dic) {
                                                           
                                                           userRightData.memberState = [dic objectForKey:@"ay_join_status"];

                                                           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                           [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                           
                                                           NSString * startTimeStr = [dic objectForKey:@"start_time"];
                                                           NSString * endTimeStr = [dic objectForKey:@"end_time"];
                                                           
                                                           if(![NSString isBlankString:startTimeStr])
                                                           {
                                                               userRightData.startDate = [dateFormatter dateFromString:startTimeStr];
                                                           }
                                                           
                                                           if (![NSString isBlankString:endTimeStr]) {
                                                               
                                                               userRightData.endDate = [dateFormatter dateFromString:endTimeStr];
                                                           }
                                                       }
                                                   }
                                                   
                                                   [FlyingDataManager saveUserRightData:userRightData];
                                               }
                                           }
                                           
                                           if (completion) {
                                               //
                                               completion(userRightData);
                                           }

                                       } failure:^(NSError *err) {
                                           //
                                           if (completion) {
                                               //
                                               completion(nil);
                                           }

                                       }];
}


+ (void) getMemberListForGroupID:(NSString*) groupID
                      Completion:(void (^)(NSArray *memberList,NSInteger allRecordCount)) completion
{
    [AFHttpTool getMemberListForGroupID:groupID
                                success:^(id response) {
                                    //
                                    
                                    NSMutableArray *tempArr = [NSMutableArray new];
                                    NSArray *allMembers = response[@"rs"];
                                    
                                    if (allMembers) {
                                        
                                        for (NSDictionary *dic in allMembers) {
                                            
                                            FlyingGroupMemberData *memberData = [[FlyingGroupMemberData alloc] init];
                                            memberData.openUDID    = [dic objectForKey:@"tuser_key"];
                                            memberData.ayJoinTime  = [dic objectForKey:@"ay_join_time"];
                                            memberData.ayJoinStatus  = [dic objectForKey:@"ay_join_status"];
                                            memberData.rpJoinDesc  = [dic objectForKey:@"rp_join_desc"];
                                            memberData.ayRcgpTime  = [dic objectForKey:@"ay_rcgp_time"];
                                            memberData.ayRcgpStatus  = [dic objectForKey:@"ay_rcgp_status"];
                                            memberData.rpJoinDesc  = [dic objectForKey:@"rp_join_desc"];
                                            memberData.ayRcgpTime  = [dic objectForKey:@"ay_rcgp_time"];
                                            memberData.ayRcgpStatus  = [dic objectForKey:@"ay_rcgp_status"];
                                            memberData.rpRcgpDesc  = [dic objectForKey:@"rp_rcgp_desc"];
                                            memberData.ownerRecom = [[dic  objectForKey:@"owner_recom"] isEqualToString:@"1"]?YES:NO ;
                                            memberData.sysRecom = [[dic  objectForKey:@"sys_recom"] isEqualToString:@"1"]?YES:NO ;

                                            
                                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                            
                                            memberData.startDate = [dateFormatter dateFromString:response[@"start_time"]];
                                            memberData.endDate = [dateFormatter dateFromString:response[@"end_time"]];

                                            
                                            memberData.token  = [dic objectForKey:@"token"];
                                            memberData.name     = [dic objectForKey:@"name"];
                                            memberData.portrait_url    = [dic objectForKey:@"portrait_url"];
                                            
                                            [tempArr addObject:memberData];
                                        }
                                    }

                                    if (completion && tempArr) {
                                        completion(tempArr,[response[@"allRecordCount"] integerValue]);
                                    }

                                    
                                } failure:^(NSError *err) {
                                    //
                                }];
}


//////////////////////////////////////////////////////////////
#pragma  用户注册、登录、激活相关
//////////////////////////////////////////////////////////////
+ (void) regOpenUDID:(NSString*) openUDID
                  Completion:(void (^)(BOOL result)) completion;
{
    [AFHttpTool regOpenUDID:openUDID
                    success:^(id response) {
                                //
                                if (response) {
                                    
                                    NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                    
                                    BOOL result =false;
                                    
                                    if ([tempStr isEqualToString:@"1"]) {
                                        result =true;
                                    }
                                    if (completion) {
                                        completion(result);
                                    }
                                }

                            } failure:^(NSError *err) {
                                //
                            }];
}

+ (void) verifyOpenUDID:(NSString*) openUDID
             Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool verifyOpenUDID:openUDID
                       success:^(id response) {
                           //
                           if (response) {
                               
                               BOOL result =false;
                               
                               NSString *code = [NSString stringWithFormat:@"%@",response[@"rs"]];
                               
                               if (![code isEqualToString:@"-1"]) {
                                   result =true ;
                               }
                               
                               if (completion) {
                                   completion(result);
                               }
                           }

                       } failure:^(NSError *err) {
                           //
                       }];
}

+ (void) updateCurrentID:(NSString*) currentID
            withUserName:(NSString*) userName
                     pwd:(NSString*) password
              Completion:(void (^)(BOOL result)) completion
{

    
    [AFHttpTool updateCurrentID:currentID
                   withUserName:(NSString*) userName
                            pwd:(NSString*) password
                        success:^(id response) {
                            //
                            
                            if (response) {
                                
                                BOOL result =false;
                                
                                NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                
                                if ([code isEqualToString:@"1"]) {
                                    result =true;
                                }
                                
                                if (completion) {
                                    completion(result);
                                }
                            }

                        } failure:^(NSError *err) {
                            //
                            if (completion) {
                                completion(false);
                            }

                        }];
}

//用终端登录官网后台
+(void) loginWebsiteWithQR:(NSString*)loginID
{
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    if(!openID)
    {
        return;
    }
    
    [AFHttpTool loginWithQR:loginID
                    Account:openID
                    success:^(id response) {
                        //
                        if (response) {
                            
                            NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                            
                            if([NSString isPureInt:tempStr]){
                                
                                NSInteger resultNum =[tempStr integerValue];
                                
                                // 登录成功
                                if(resultNum==1){
                                    
                                    NSLog(@"扫描登录成功");
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:KBERQloginOK object:nil];
                                }
                            }
                        }
                        
                    } failure:^(NSError *err) {
                        //
                        NSLog(@"loginWithQR:%@",err.description);
                        
                    }];
}
//////////////////////////////////////////////////////////////
#pragma  会员相关
//////////////////////////////////////////////////////////////
+ (void) getMembershipForAccount:(NSString*) account
                      Completion:(void (^)(FlyingUserRightData *userRightData)) completion
{
    [AFHttpTool getMembershipForAccount:account
                                success:^(id response) {
                                    //
                                    FlyingUserRightData * userDataRight=nil;

                                    if (response) {
                                        
                                        NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                        
                                        NSArray *tempArray = [tempStr componentsSeparatedByString:@";"];
                                        
                                        if (tempArray.count==3) {
                                            
                                            NSString *startDateStr = tempArray[0];
                                            NSString *endDateStr  = tempArray[1];
                                            
                                            if([startDateStr containsString:@"-"] && [endDateStr containsString:@"-"])
                                            {
                                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                
                                                NSDate *startDate = [dateFormatter dateFromString:startDateStr];
                                                NSDate *endDate = [dateFormatter dateFromString:endDateStr];
                                                
                                                userDataRight =[[FlyingUserRightData alloc] init];

                                                userDataRight.domainID = [FlyingDataManager getBusinessID];
                                                userDataRight.domainType = BC_Domain_Business;
                                                userDataRight.memberState= BC_Member_Verified;
                                                userDataRight.startDate = startDate;
                                                userDataRight.endDate = endDate;
                                                
                                                [FlyingDataManager saveUserRightData:userDataRight];
                                            }
                                        }
                                    }
                                    
                                    if (completion) {
                                        
                                        completion(userDataRight);
                                    }
                                } failure:^(NSError *err) {
                                    //
                                    if (completion) {
                                        
                                        completion(nil);
                                    }
                                }];
}

+ (void) updateMembershipForAccount:(NSString*) account
                          StartDate:(NSDate *)startDate
                            EndDate:(NSDate *)endDate
                         Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool updateMembershipForAccount:account
                                 StartDate:startDate
                                   EndDate:endDate
                                success:^(id response) {
                                    
                                    if (response) {
                                        
                                        BOOL result =false;
                                        
                                        NSString *code = response[@"rc"];
                                        
                                        if ([code isEqualToString:@"1"]) {
                                            
                                            result =true;
                                            
                                            FlyingUserRightData * userDataRight =[[FlyingUserRightData alloc] init];
                                            userDataRight.domainID = [FlyingDataManager getBusinessID];
                                            userDataRight.domainType = BC_Domain_Business;
                                            userDataRight.memberState= BC_Member_Verified;
                                            userDataRight.startDate = startDate;
                                            userDataRight.endDate = endDate;

                                            [FlyingDataManager saveUserRightData:userDataRight];
                                            
                                            //提醒系统备份没有备份成功的重要数据
                                            if (result) {
                                                
                                                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KShouldSysMembership];
                                                
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                            else
                                            {
                                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KShouldSysMembership];
                                                
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                        }
                                        
                                        if (completion) {
                                            completion(result);
                                        }
                                    }
                                    
                                } failure:^(NSError *err) {
                                    //
                                }];
}

//////////////////////////////////////////////////////////////
#pragma  金币相关
//////////////////////////////////////////////////////////////

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                    Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool getMoneyDataWithOpenID:openudid
                               success:^(id response) {
        //
        if (response) {
            
            NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSArray *tempArray = [tempStr componentsSeparatedByString:@";"];
            
            
            BOOL result =false;

            if (tempArray.count==4) {
                
                result =true;
                
                NSInteger BEMONEYCOUNT = [tempArray[0] integerValue];
                NSInteger BEGIFTCOUNT  = [tempArray[1] integerValue];
                NSInteger BETOUCHCOUNT = [tempArray[2] integerValue];
                NSInteger BEQRCOUNT    = [tempArray[3] integerValue];
                
                //查询现有数据库是否初始化
                FlyingStatisticDAO * statDAO = [[FlyingStatisticDAO alloc] init];
                FlyingStatisticData *userData = [statDAO selectWithUserID:openudid];
                
                if(!userData){
                    
                    userData = [[FlyingStatisticData alloc] initWithUserID:openudid
                                                                MoneyCount:0
                                                                TouchCount:0
                                                              LearnedTimes:0
                                                                 GiftCount:0
                                                                   QRCount:0
                                                                 TimeStamp:0];
                }
                
                //更新本地数据
                userData.BEQRCOUNT    = BEQRCOUNT;
                userData.BEMONEYCOUNT = BEMONEYCOUNT;
                userData.BETOUCHCOUNT = BETOUCHCOUNT;
                userData.BEGIFTCOUNT  = BEGIFTCOUNT;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
                userData.BETIMESTAMP = destDateString;
                
                [statDAO insertWithData:userData];
            }
            
            if (completion) {
                completion(result);
            }
        }
        
    } failure:^(NSError *err) {
        //
        NSLog(@"getMoneyDataWithOpenID:%@",err.description);
    }];
}

//向服务器保存金币信息
+(void) uploadMoneyDataWithOpenID:(NSString*) openudid
                       Completion:(void (^)(BOOL result)) completion;
{
    FlyingStatisticData * staticDat = [[[FlyingStatisticDAO alloc] init] selectWithUserID:openudid];
    
    [AFHttpTool uploadMoneyDataWithOpenID:openudid
                              MoneyCount:staticDat.BEMONEYCOUNT
                               GiftCount:staticDat.BEGIFTCOUNT
                              TouchCount:staticDat.BETOUCHCOUNT
                                 success:^(id response) {
                                     //
                                     if (response) {
                                         
                                         BOOL result =false;
                                         
                                         NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                         
                                         if([NSString isPureInt:tempStr]){
                                             
                                             NSInteger resultNum =[tempStr integerValue];
                                             
                                             //上传消费值成功
                                             if(resultNum==1){
                                                 
                                                 result =true;
                                                 
                                                 NSLog(@"上传备份消费值成功");
                                             }
                                         }
                                         
                                         if (completion) {
                                             completion(result);
                                         }
                                     }
                                     
                                 } failure:^(NSError *err) {
                                     //
                                     NSLog(@"sysOtherMoneyWithAccount:%@",err.description);
                                 }];
}

+(void) getQRDataForUserID:(NSString*) openudid
                Completion:(void (^)(BOOL result)) completion
{
    //向服务器获取最新QR数据
    [AFHttpTool getQRCountWithOpenID:openudid
                            success:^(id response) {
                                //
                                if (response) {
                                    
                                    BOOL result =false;
                                    
                                    NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                    
                                    if([NSString isPureInt:tempStr]){
                                        
                                        NSInteger resultNum =[tempStr integerValue];
                                        
                                        if(resultNum>=0){
                                            
                                            result =true;
                                            
                                            FlyingStatisticDAO * statDAO = [[FlyingStatisticDAO alloc] init];
                                            FlyingStatisticData *userData = [statDAO selectWithUserID:openudid];
                                            
                                            if(!userData){
                                                
                                                userData = [[FlyingStatisticData alloc] initWithUserID:openudid
                                                                                            MoneyCount:0
                                                                                            TouchCount:0
                                                                                          LearnedTimes:0
                                                                                             GiftCount:0
                                                                                               QRCount:0
                                                                                             TimeStamp:0];
                                            }
                                            
                                            userData.BEQRCOUNT = resultNum;
                                            
                                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                                            NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
                                            userData.BETIMESTAMP = destDateString;
                                            
                                            [statDAO insertWithData:userData];
                                        }
                                    }
                                    
                                    if (completion) {
                                        completion(result);
                                    }
                                }
                                
                            } failure:^(NSError *err) {
                                //
                                NSLog(@"getQRCountForUserID:%@",err.description);
                            }];
}

+(void) chargingCrad:(NSString*) cardID
           WithOpenID:(NSString*) openudid
           Completion:(void (^)(BOOL result)) completion;
{
    @synchronized(self)
    {
        //向服务器帐户进行充值
        [AFHttpTool chargingCardSysURLWithOpenID:openudid
                                         CardID:cardID
                                        success:^(id response) {
                                            //
                                            if (response) {
                                                
                                                BOOL result =false;
                                                
                                                NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                                
                                                if([NSString isPureInt:tempStr]){
                                                    
                                                    NSInteger resultNum =[tempStr integerValue];
                                                    
                                                    NSString * responseStr=nil;
                                                    FlyingStatisticDAO * statDAO = [[FlyingStatisticDAO alloc] init];
                                                    FlyingStatisticData *userData = [statDAO selectWithUserID:openudid];
                                                    
                                                    switch (resultNum) {
                                                        case -1:
                                                            responseStr = @"必须参数缺少";
                                                            break;
                                                        case -11:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -12:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -13:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -21:
                                                            responseStr = @"充值卡无效";
                                                            break;
                                                        case -22:
                                                            responseStr = @"充值卡未出售";
                                                            break;
                                                        case -23:
                                                            responseStr = @"充值卡被锁定";
                                                            break;
                                                        case -24:
                                                            responseStr = @"充值卡失效";
                                                            break;
                                                        case -31:
                                                            responseStr = @"充值卡已充值";
                                                            break;
                                                        case -32:
                                                            responseStr = @"充值卡已充值";
                                                            break;
                                                        case -99:
                                                            responseStr = @"中途出错(系统原因)";
                                                            break;
                                                        default:
                                                            
                                                            result =true;

                                                            [statDAO updateWithUserID:openudid QRMoneyCount:resultNum];
                                                            
                                                            responseStr = [NSString stringWithFormat:@"充值成功:充值金币数目:%@",[@(resultNum-userData.BEQRCOUNT) stringValue]];
                                                    }
                                                    
                                                    iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                    [appDelegate makeToast:responseStr];
                                                }
                                                
                                                if (completion) {
                                                    completion(result);
                                                }
                                            }
                                            else
                                            {
                                                NSString *message = @"服务器繁忙或者网络故障请稍后再试！";
                                                
                                                iFlyingAppDelegate *appDelegate = (iFlyingAppDelegate *)[[UIApplication sharedApplication] delegate];
                                                [appDelegate makeToast:message];

                                                if (completion) {
                                                    completion(false);
                                                }
                                            }
                                            
                                        } failure:^(NSError *err) {
                                            //
                                            if (completion) {
                                                completion(false);
                                            }
                                            NSLog(@"chargingCardSysURLForUserID:%@",err.description);
                                        }];
    }
}

//////////////////////////////////////////////////////////////
#pragma  用户关于课程的计费和统计数据
//////////////////////////////////////////////////////////////

+ (void) getLessonRightForAccount:(NSString*) account
                         LessonID:(NSString*) lessonID
                       Completion:(void (^)(FlyingUserRightData *userRightData)) completion
{

    [AFHttpTool getLessonRightForAccount:account
                                LessonID:(NSString*) lessonID
                                success:^(id response) {
                                    //
                                    
                                    FlyingUserRightData * userDataRight =[[FlyingUserRightData alloc] init];

                                    if (response) {
                                        
                                        NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                        
                                        if ([code isEqualToString:@"1"]) {

                                            NSString * isExisted = response[@"isExisted"];
                                            
                                            if ([isExisted isEqualToString:@"1"]) {
                                             
                                                NSString *startDateStr = response[@"start_time"];
                                                NSString *endDateStr  = response[@"end_time"];
                                                
                                                if([startDateStr containsString:@"-"] && [endDateStr containsString:@"-"])
                                                {
                                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                    
                                                    NSDate *startDate = [dateFormatter dateFromString:startDateStr];
                                                    NSDate *endDate = [dateFormatter dateFromString:endDateStr];
                                                    
                                                    
                                                    userDataRight.domainID = lessonID ;
                                                    userDataRight.domainType = BC_Domain_Content;
                                                    userDataRight.memberState= BC_Member_Verified;
                                                    userDataRight.startDate = startDate;
                                                    userDataRight.endDate = endDate;
                                                }
                                            }
                                        }
                                    }

                                    [FlyingDataManager saveUserRightData:userDataRight];
                                    
                                    if (completion) {
                                        
                                        completion(userDataRight);
                                    }
                                } failure:^(NSError *err) {
                                    //
                                    if (completion) {
                                        
                                        completion(nil);
                                    }
                                }];
}

+ (void) updateLessonRightForAccount:(NSString*) account
                            LessonID:(NSString*) lessonID
                           StartDate:(NSDate *)startDate
                             EndDate:(NSDate *)endDate
                          Completion:(void (^)(BOOL result)) completion
{

    [AFHttpTool updateLessonRightForAccount:account
                                   LessonID:lessonID
                                 StartDate:startDate
                                   EndDate:endDate
                                   success:^(id response) {
                                       
                                       if (response) {
                                           
                                           BOOL result =false;
                                           
                                           NSString *code = response[@"rc"];
                                           
                                           if ([code isEqualToString:@"1"]) {
                                               
                                               result =true;
                                               
                                               FlyingUserRightData * userDataRight =[[FlyingUserRightData alloc] init];
                                               userDataRight.domainID = lessonID;
                                               userDataRight.domainType = BC_Domain_Content;
                                               userDataRight.memberState= BC_Member_Verified;
                                               userDataRight.startDate = startDate;
                                               userDataRight.endDate = endDate;
                                               
                                               [FlyingDataManager saveUserRightData:userDataRight];
                                           }
                                           
                                           if (completion) {
                                               completion(result);
                                           }
                                       }
                                       
                                   } failure:^(NSError *err) {
                                       //
                                   }];

}

+(void) getStatisticDetailWithOpenID:(NSString*) openudid
                                 Completion:(void (^)(BOOL result)) completion;
{
    NSArray *lessonIDlist = [[[FlyingNowLessonDAO alloc] init] selectIDWithUserID:openudid];
    
    FlyingLessonDAO * lessonDao= [[FlyingLessonDAO alloc] init];
    FlyingTouchDAO * touchDAO = [[FlyingTouchDAO alloc] init];
    
    if (lessonIDlist.count==0) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activeBETouchAccount"];
    }
    else{
        
        [lessonIDlist enumerateObjectsUsingBlock:^(NSString* lessonID, NSUInteger idx, BOOL *stop) {
            
            FlyingLessonData * lessonData=[lessonDao selectWithLessonID:lessonID];
            
            if (lessonData.BEOFFICIAL==YES) {
                
                //向服务器获取最新课程相关统计数据
                [AFHttpTool getTouchDataWithOpenID:openudid
                                         lessonID:lessonID
                                          success:^(id response) {
                                              //
                                              if (response) {
                                                  
                                                  NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                                  
                                                  [touchDAO insertDataForUserID:openudid
                                                                       LessonID:lessonID
                                                                     touchTimes:[tempStr integerValue]];
                                              }
                                              
                                              if (idx==lessonIDlist.count-1) {
                                                  
                                                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activeBETouchAccount"];
                                              }
                                              
                                          } failure:^(NSError *err) {
                                              //
                                              NSLog(@"getTouchDataForUserID:%@",err.description);
                                              
                                          }];
            }
        }];
    }
}

//向服务器获备份课程消费数据
+(void) uploadStatisticDetailWithOpenID:(NSString*) openudid
                                    Completion:(void (^)(BOOL result)) completion;
{
    FlyingTouchDAO * touchDAO = [[FlyingTouchDAO alloc] init];
    NSArray *recordList = [touchDAO selectWithUserID:openudid];
    
    __block NSMutableString * updateStr =[NSMutableString new];
    
    __block BOOL first=YES;
    
    [recordList enumerateObjectsUsingBlock:^(FlyingTouchRecord* toucRecord, NSUInteger idx, BOOL *stop) {
        
        if (first) {
            
            [updateStr appendFormat:@"%@;%d",toucRecord.BELESSONID,toucRecord.BETOUCHTIMES];
            
            first=NO;
        }
        else{
            
            [updateStr appendFormat:@"|%@;%d",toucRecord.BELESSONID,toucRecord.BETOUCHTIMES];
        }
    }];
    
    
    [AFHttpTool upadteLessonTouchWithOpenID:openudid
                           lessonAndTouch:updateStr
                                  success:^(id response) {
                                      //
                                      if (response) {
                                          
                                          NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                          
                                          if([NSString isPureInt:tempStr]){
                                              
                                              NSInteger resultNum =[tempStr integerValue];
                                              
                                              //上传课程具体消费值成功
                                              if(resultNum==1){
                                                  
                                                  NSLog(@"上传课程具体消费值成功");
                                              }
                                          }
                                          
                                          
                                          if (completion) {
                                              completion(true);
                                          }
                                      }
                                      
                                  } failure:^(NSError *err) {
                                      //
                                      
                                      if (completion) {
                                          completion(false);
                                      }

                                      NSLog(@"sysLessonTouchWithAccount:%@",err.description);
                                  }];
}

//////////////////////////////////////////////////////////////
#pragma  内容相关
//////////////////////////////////////////////////////////////
+ (void) getAlbumListForDomainID:(NSString*) domainID
                      DomainType:(NSString*) type
                  ContentType:(NSString*) contentType
                   PageNumber:(NSInteger) pageNumber
                OnlyRecommend:  (BOOL)    isOnlyRecommend
                   Completion:(void (^)(NSArray *albumList,NSInteger allRecordCount)) completion
{
    [AFHttpTool albumListDataForDomainID:domainID
                              DomainType:type
                     lessonConcentType:contentType
                                 PageNumber:pageNumber
                                  OnlyRecommend:isOnlyRecommend
                                    success:^(id response) {
                                        //
                                        FlyingCoverDataParser *parser = [[FlyingCoverDataParser  alloc] init];
                                        
                                        [parser SetData:response];
                                        
                                        parser.completionBlock = ^(NSArray *tagCoverList,NSInteger allRecordCount)
                                        {
                                            if(tagCoverList.count!=0 && completion) {
                                                completion(tagCoverList,allRecordCount);
                                            }
                                        };
                                        
                                        parser.failureBlock = ^(NSError *error)
                                        {
                                            NSLog(@"FlyingCoverDataParser:%@",error.description);
                                        };
                                        
                                        [parser parse];
                                    } failure:^(NSError *err) {
                                        //
                                        NSLog(@"albumListDataForContentType:%@",err.description);

                                    }];
}


+ (void) getLessonListForDomainID:(NSString*)  domainID
                       DomainType:(NSString*)  type
                     PageNumber:   (NSInteger) pageNumber
              lessonConcentType:  (NSString *) contentType
                   DownloadType:  (NSString *) downloadType
                            Tag:  (NSString *) tag
                 OnlyRecommend:  (BOOL)    isOnlyRecommend
                     Completion:(void (^)
                                 (NSArray *lessonList,NSInteger allRecordCount)) completion
{
    
    [AFHttpTool lessonListDataByTagForDomainID:domainID
                                    DomainType:type
                                  PageNumber:pageNumber
                              lessonConcentType:contentType
                                   DownloadType:downloadType
                                            Tag:tag
                                      OnlyRecommend:isOnlyRecommend
                                        success:^(id response) {
                                            //
                                            
                                            FlyingLessonParser *parser = [[FlyingLessonParser alloc] init];
                                            [parser SetData:response];
                                            
                                            parser.completionBlock = ^(NSArray *LessonList,NSInteger allRecordCount)
                                            {
                                                if(LessonList.count!=0 && completion) {
                                                    completion(LessonList,allRecordCount);
                                                }
                                            };
                                            
                                            parser.failureBlock = ^(NSError *error)
                                            {
                                                NSLog(@"FlyingLessonParser:%@",error.description);
                                            };
                                            
                                            [parser parse];

                                        } failure:^(NSError *err) {
                                            //
                                            NSLog(@"lessonListByTagURLForPageNumber:%@",err.description);
                                        }];
}

+ (void) getCoverListForDomainID:(NSString*) domainID
                      DomainType:(NSString*) type
                    PageNumber:(NSInteger) pageNumber
                    Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion
{
    [AFHttpTool lessonListDataByTagForDomainID:domainID
                                    DomainType:type
                                 PageNumber:pageNumber
                           lessonConcentType:nil
                                DownloadType:nil
                                         Tag:nil
                                   OnlyRecommend:YES
                                     success:^(id response) {
                                         
                                         if (response) {
                                             FlyingLessonParser * lessonParser = [[FlyingLessonParser alloc] init];
                                             [lessonParser SetData:response];
                                             
                                             lessonParser.completionBlock = ^(NSArray *LessonList,NSInteger allRecordCount)
                                             {
                                                 if(LessonList.count!=0 && completion) {
                                                     completion(LessonList,allRecordCount);
                                                 }
                                             };
                                             
                                             lessonParser.failureBlock = ^(NSError *error)
                                             {
                                                 NSLog(@"FlyingLessonParser:%@",error.description);
                                             };
                                             
                                             [lessonParser parse];
                                         }
                                     }
                                     failure:^(NSError *err) {
                                         //
                                         
                                         NSLog(@"coverListWithSuccessCompletion %@",err.description);
                                         
                                     }];
}

+ (void) getLessonForLessonID:(NSString*) lessonID
                   Completion:(void (^)(FlyingPubLessonData *pubLesson)) completion
{
    
    [AFHttpTool lessonDataForLessonID:lessonID success:^(id response) {
        //
        
        FlyingLessonParser * lessonParser = [[FlyingLessonParser alloc] init];
        
        [lessonParser SetData:response];
        
        lessonParser.completionBlock = ^(NSArray *LessonList,NSInteger allRecordCount)
        {
            
            if(LessonList.count!=0 && completion) {
                completion([LessonList objectAtIndex:0]);
            }
        };
        
        lessonParser.failureBlock = ^(NSError *error)
        {
            NSLog(@"FlyingLessonParser:%@",error.description);
        };
        
        [lessonParser parse];
        
    } failure:^(NSError *error) {
        //
        NSLog(@"getLessonForLessonID:%@",error.description);
        
    }];
}

+ (void) getLessonForISBN:(NSString*) ISBN
               Completion:(void (^)(FlyingPubLessonData *lesson)) completion
{
    [AFHttpTool lessonDataForISBN:ISBN success:^(id response) {
        //
        
        FlyingLessonParser * lessonParser = [[FlyingLessonParser alloc] init];
        
        [lessonParser SetData:response];
        
        lessonParser.completionBlock = ^(NSArray *LessonList,NSInteger allRecordCount)
        {
            
            if(LessonList.count!=0 && completion) {
                completion([LessonList objectAtIndex:0]);
            }
        };
        
        lessonParser.failureBlock = ^(NSError *error)
        {
            NSLog(@"FlyingLessonParser:%@",error.description);
        };
        
        [lessonParser parse];
        
    } failure:^(NSError *error) {
        //
        NSLog(@"getLessonForISBN:%@",error.description);
        
    }];
}

//////////////////////////////////////////////////////////////
#pragma  内容的评论相关
//////////////////////////////////////////////////////////////
+ (void) getCommentListForContentID:(NSString*) contentID
                        ContentType:(NSString*) contentType
                         PageNumber:(NSInteger) pageNumber
                         Completion:(void (^)(NSArray *commentList,NSInteger allRecordCount)) completion
{
    [AFHttpTool getCommentListForContentID:contentID
                                 ContentType:contentType
                             PageNumber:pageNumber
                                success:^(id response) {
                                    
                                    NSMutableArray *tempArr = [NSMutableArray new];
                                    NSArray *allComments = response[@"rs"];
                                    
                                    if (allComments) {
                                        
                                        for (NSDictionary *dic in allComments)
                                        {
                                            FlyingCommentData  *commentDate = [[FlyingCommentData alloc] init];
                                            
                                            commentDate.contentID      = [dic objectForKey:@"contentID"];
                                            commentDate.contentType    = [dic objectForKey:@"contentType"];
                                            commentDate.userID         = [dic objectForKey:@"userID"];
                                            commentDate.nickName       = [dic objectForKey:@"nickName"];
                                            commentDate.portraitURL    = [dic objectForKey:@"portraitURL"];
                                            
                                            commentDate.commentContent = [dic objectForKey:@"commentContent"];
                                            
                                            commentDate.commentTime = [dic objectForKey:@"commentTime"];
                                            
                                            [tempArr addObject:commentDate];
                                        }
                                    }
                                    
                                    if (completion) {
                                        completion(tempArr,[response[@"allRecordCount"] integerValue]);
                                    }
                                    
                                } failure:^(NSError *err) {
                                    //
                                    NSLog(@"Error:%@",err.description);
                                }];
}


+ (void) updateComment:(FlyingCommentData*) commentData
            Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool updateComment:commentData
                      success:^(id response) {
                          //
                          
                          if (response) {
                              
                              BOOL result =false;
                              
                              NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                              
                              if ([code isEqualToString:@"1"]) {
                                  result =true;
                              }
                              
                              if (completion) {
                                  completion(result);
                              }
                          }
                      } failure:^(NSError *err) {
                          //
                          if (completion) {
                              completion(false);
                          }
                      }];
}

//////////////////////////////////////////////////////////////
#pragma  标签相关
//////////////////////////////////////////////////////////////
+ (void)getTagListForDomainID:(NSString*)domainID
                   DomainType:(NSString*) type
                 TagString:(NSString*) tagString
                     Count:(NSInteger) count
                Completion:(void (^)(NSArray *tagList)) completion
{
    
    [AFHttpTool getTagListForDomainID:domainID
                           DomainType:type
                         TagString:tagString
                             Count:count
                           success:^(id response) {
                               //
                               NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                               
                               if (temStr && completion) {
                                   
                                   completion([temStr  componentsSeparatedByString:@","]);
                               }
                               
                           } failure:^(NSError *err) {
                               //
                           }];
}


//////////////////////////////////////////////////////////////
#pragma  字典相关
//////////////////////////////////////////////////////////////
+ (void) getItemsforWord:(NSString *) word
             Completion:(void (^)(NSArray *itemList,NSInteger allRecordCount)) completion;
{
    
    [AFHttpTool dicDataforWord:word
                       success:^(id response) {
                           //
                           
                           NSString * temStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                           NSRange segmentRange = [temStr rangeOfString:@"所请求映射类文件不存在"];
                           
                           if ( (segmentRange.location==NSNotFound) && (response!=nil) ) {
                               
                               FlyingItemParser *itemParser = [[FlyingItemParser alloc] init];
                               
                               [itemParser SetData:response];
                               
                               itemParser.completionBlock = ^(NSArray *itemList,NSInteger allRecordCount)
                               {
                                   if (itemList.count!=0 && completion) {
                                       
                                       completion(itemList,allRecordCount);
                                   }
                               };
                               
                               [itemParser parse];
                           }
                           else{
                               
                               NSLog(@"需要补充词典！");
                           }

                       } failure:^(NSError *err) {
                           //
                           NSLog(@"dicDataforWord:%@",err.description);

                       }];
}


+ (void) getWordListby:(NSString *) word
            Completion:(void (^)(NSArray *wordList,NSInteger allRecordCount)) completion
{

    [AFHttpTool getWordListby:word
                       success:^(id response) {
                           //
                           if (response) {
                               
                               NSString *wordListStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                               NSRange segmentRange = [wordListStr rangeOfString:@"所请求映射类文件不存在"];
                               
                               if (segmentRange.location==NSNotFound) {
                                   
                                   
                                   if (![NSString isBlankString:wordListStr]) {
                                       
                                       if (completion) {
                                           
                                           NSArray * array = [wordListStr  componentsSeparatedByString:@";"];
                                           
                                           completion(array,array.count);
                                       }
                                   }
                               }
                           }
                       } failure:^(NSError *err) {
                           //
                           NSLog(@"dicDataforWord:%@",err.description);
                           
                       }];

}


//////////////////////////////////////////////////////////////
#pragma  供应商（作者）相关
//////////////////////////////////////////////////////////////

+ (void) getAppDataforBounldeID:(NSString *) boundleID
                     Completion:(void (^)(FlyingAppData *appData)) completion;
{
    [AFHttpTool getAppDataforBounldeID:boundleID
                               success:^(id response) {
                                   //
                                   
                                   NSMutableArray *tempArr = [NSMutableArray new];
                                   NSArray *allApps = response[@"rs"];
                                   
                                   if (allApps) {
                                       
                                       for (NSDictionary *dic in allApps)
                                       {
                                           FlyingAppData  *appData = [[FlyingAppData alloc] init];
                                                                                      
                                           appData.appID         = [dic objectForKey:@"app_id"];
                                           appData.boundleID     = [dic objectForKey:@"st_id"];
                                           appData.domainID      = [dic objectForKey:@"app_owner"];
                                           appData.webaddress    =  [dic objectForKey:@"domain"];
                                           appData.rongAppKey    =  [dic objectForKey:@"rc_app_key"];
                                           appData.wexinID       = [dic objectForKey:@"wx_id"];
                                           appData.appNname      = [dic objectForKey:@"app_name"];
                                           appData.authors      = [dic objectForKey:@"user_id"];
                                           appData.logo      = [dic objectForKey:@"logo_file"];
                                           
                                           [tempArr addObject:appData];
                                       }
                                   }
                                   
                                   if (completion && tempArr.count>0) {
                                       completion(tempArr[0]);
                                   }

                                   
                               } failure:^(NSError *err) {
                                   //
                               }];
}

@end
