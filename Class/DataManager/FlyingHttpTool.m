
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
#import "RCDGroupInfo.h"
#import "FlyingUserInfo.h"
#import "RCDRCIMDataSource.h"
#import "RCDataBaseManager.h"

#import "FlyingLessonParser.h"
#import "FlyingItemParser.h"
#import "FlyingProviderParser.h"
#import "NSString+FlyingExtention.h"
#import "FlyingCoverDataParser.h"

#import "FlyingGroupData.h"
#import "FlyingPubLessonData.h"

#import "FlyingStatisticData.h"
#import "FlyingStatisticDAO.h"

#import "FlyingTouchDAO.h"
#import "FlyingTouchRecord.h"

#import "FlyingNowLessonDAO.h"
#import "FlyingLessonData.h"

#import "FlyingLessonDAO.h"
#import "FlyingLessonData.h"

#import "SIAlertView.h"

@implementation FlyingHttpTool

+ (FlyingHttpTool*)shareInstance
{
    static FlyingHttpTool* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        instance.allGroups = [NSMutableArray new];
    });
    return instance;
}

-(void) isMyFriendWithUserInfo:(FlyingUserInfo *)userInfo
                    completion:(void(^)(BOOL isFriend)) completion
{
    [self getFriends:^(NSMutableArray *result) {
        for (FlyingUserInfo *user in result) {
            if ([user.userId isEqualToString:userInfo.userId] && completion && [@"1" isEqualToString:userInfo.status]) {
                completion(YES);
            }else if(completion){
                completion(NO);
            }
        }
    }];
}
//根据id获取单个群组
-(void) getGroupByID:(NSString *) groupID
   successCompletion:(void (^)(RCGroup *group)) completion
{
    /*
    [AFHttpTool getAllGroupsSuccess:^(id response) {
        NSArray *allGroups = response[@"result"];
        if (allGroups) {
            for (NSDictionary *dic in allGroups) {
                RCGroup *group = [[RCGroup alloc] init];
                group.groupId = [dic objectForKey:@"id"];
                group.groupName = [dic objectForKey:@"name"];
                group.portraitUri = (NSNull *)[dic objectForKey:@"portrait"] == [NSNull null] ? nil: [dic objectForKey:@"portrait"];
                
                if ([group.groupId isEqualToString:groupID] && completion) {
                    completion(group);
                }
            }
            
        }
        
    } failure:^(NSError* err){
        
    }];
     */
}

- (void)joinGroup:(int)groupID complete:(void (^)(BOOL))joinResult
{
    [AFHttpTool joinGroupByID:groupID success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        if (joinResult) {
            if ([code isEqualToString:@"200"]) {
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    joinResult(YES);
                });
                
            }else{
                joinResult(NO);
            }
            
        }
    } failure:^(id response) {
        if (joinResult) {
            joinResult(NO);
        }
    }];
}

- (void)quitGroup:(int)groupID complete:(void (^)(BOOL))result
{
    [AFHttpTool quitGroupByID:groupID success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                result(YES);
            }else{
                result(NO);
            }
            
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

- (void)updateGroupById:(int)groupID withGroupName:(NSString*)groupName andintroduce:(NSString*)introduce complete:(void (^)(BOOL))result

{
    __block typeof(id) weakGroupId = [NSString stringWithFormat:@"%d", groupID];
    [AFHttpTool updateGroupByID:groupID withGroupName:groupName andGroupIntroduce:introduce success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                
                for (RCDGroupInfo *group in _allGroups) {
                    if ([group.groupId isEqualToString:weakGroupId]) {
                        group.groupName=groupName;
                        group.introduce=introduce;
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
                
            }else{
                result(NO);
            }
            
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

- (void)getFriends:(void (^)(NSMutableArray*))friendList
{
    NSMutableArray* list = [NSMutableArray new];
    
    [AFHttpTool getFriendListFromServerSuccess:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        if (friendList) {
            if ([code isEqualToString:@"200"]) {
                [_allFriends removeAllObjects];
                NSArray * regDataArray = response[@"result"];
                
                for(int i = 0;i < regDataArray.count;i++){
                    NSDictionary *dic = [regDataArray objectAtIndex:i];
                    if([[dic objectForKey:@"status"] intValue] != 1)
                        continue;
                    
                    FlyingUserInfo*userInfo = [FlyingUserInfo new];
                    NSNumber *idNum = [dic objectForKey:@"id"];
                    userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                    userInfo.portraitUri = [dic objectForKey:@"portrait"];
                    userInfo.userName = [dic objectForKey:@"username"];
                    userInfo.email = [dic objectForKey:@"email"];
                    userInfo.status = [dic objectForKey:@"status"];
                    [list addObject:userInfo];
                    [_allFriends addObject:userInfo];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    friendList(list);
                });
                
            }else{
                friendList(list);
            }
            
        }
    } failure:^(id response) {
        if (friendList) {
            friendList(list);
        }
    }];
}

- (void)searchFriendListByEmail:(NSString*)email complete:(void (^)(NSMutableArray*))friendList
{
    NSMutableArray* list = [NSMutableArray new];
    [AFHttpTool searchFriendListByEmail:email success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (friendList) {
            if ([code isEqualToString:@"200"]) {
                
                id result = response[@"result"];
                if([result respondsToSelector:@selector(intValue)]) return ;
                if([result respondsToSelector:@selector(objectForKey:)])
                {
                    FlyingUserInfo*userInfo = [FlyingUserInfo new];
                    NSNumber *idNum = [result objectForKey:@"id"];
                    userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                    userInfo.portraitUri = [result objectForKey:@"portrait"];
                    userInfo.userName = [result objectForKey:@"username"];
                    [list addObject:userInfo];
                    
                }
                else
                {
                    NSArray * regDataArray = response[@"result"];
                    
                    for(int i = 0;i < regDataArray.count;i++){
                        
                        NSDictionary *dic = [regDataArray objectAtIndex:i];
                        FlyingUserInfo*userInfo = [FlyingUserInfo new];
                        NSNumber *idNum = [dic objectForKey:@"id"];
                        userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                        userInfo.portraitUri = [dic objectForKey:@"portrait"];
                        userInfo.userName = [dic objectForKey:@"username"];
                        [list addObject:userInfo];
                    }
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    friendList(list);
                });
                
            }else{
                friendList(list);
            }
            
        }
    } failure:^(id response) {
        if (friendList) {
            friendList(list);
        }
    }];
}

- (void)searchFriendListByName:(NSString*)name complete:(void (^)(NSMutableArray*))friendList
{
    NSMutableArray* list = [NSMutableArray new];
    [AFHttpTool searchFriendListByName:name success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (friendList) {
            if ([code isEqualToString:@"200"]) {
                
                NSArray * regDataArray = response[@"result"];
                for(int i = 0;i < regDataArray.count;i++){
                    
                    NSDictionary *dic = [regDataArray objectAtIndex:i];
                    FlyingUserInfo*userInfo = [FlyingUserInfo new];
                    NSNumber *idNum = [dic objectForKey:@"id"];
                    userInfo.userId = [NSString stringWithFormat:@"%d",idNum.intValue];
                    userInfo.portraitUri = [dic objectForKey:@"portrait"];
                    userInfo.userName = [dic objectForKey:@"username"];
                    [list addObject:userInfo];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    friendList(list);
                });
                
            }else{
                friendList(list);
            }
            
        }
    } failure:^(id response) {
        if (friendList) {
            friendList(list);
        }
    }];
}
- (void)requestFriend:(NSString*)userId complete:(void (^)(BOOL))result
{
    [AFHttpTool requestFriend:userId success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
                
            }else{
                result(NO);
            }
            
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}
- (void)processRequestFriend:(NSString*)userId withIsAccess:(BOOL)isAccess complete:(void (^)(BOOL))result
{
    [AFHttpTool processRequestFriend:userId withIsAccess:isAccess success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
                
            }else{
                result(NO);
            }
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

- (void)deleteFriend:(NSString*)userId complete:(void (^)(BOOL))result
{
    [AFHttpTool deleteFriend:userId success:^(id response) {
        NSString *code = [NSString stringWithFormat:@"%@",response[@"code"]];
        
        if (result) {
            if ([code isEqualToString:@"200"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    result(YES);
                });
                
            }else{
                result(NO);
            }
            
        }
    } failure:^(id response) {
        if (result) {
            result(NO);
        }
    }];
}

+(void) getUserInfoByopenID:(NSString *) openID
                 completion:(void (^)(RCUserInfo *user)) completion
{
    [AFHttpTool getUserInfoWithOpenID:openID
                              success:^(id response) {
                                  //
                                  if (response) {
                                      NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                      
                                      if ([code isEqualToString:@"1"]) {
                                          
                                          RCUserInfo *userInfo = [RCUserInfo new];
                                          
                                          userInfo.userId= [openID MD5];
                                          userInfo.name=response[@"name"];
                                          userInfo.portraitUri=response[@"portraitUri"];
                                          
                                          completion(userInfo);
                                      }
                                      else
                                      {
                                          NSLog(@"getUserInfoWithOpenID:%@",response[@"rm"]);
                                      }
                                  }
                              } failure:^(NSError *err) {
                                  //
                                  
                                  NSLog(@"Get rongcloud Toke %@",err.description);
                                  
                              }];
}


+(void) getUserInfoByRongID:(NSString *) rongID
                 completion:(void (^)(RCUserInfo *user)) completion
{
    [AFHttpTool getUserInfoWithRongID:rongID
                              success:^(id response) {
                                  //
                                  if (response) {
                                      NSString *code = [NSString stringWithFormat:@"%@",response[@"rc"]];
                                      
                                      if ([code isEqualToString:@"1"]) {
                                          
                                          RCUserInfo *userInfo = [RCUserInfo new];
                                          
                                          userInfo.userId= rongID;
                                          userInfo.name=response[@"name"];
                                          userInfo.portraitUri=response[@"portraitUri"];
                                          
                                          completion(userInfo);
                                      }
                                      else
                                      {
                                          NSLog(@"getUserInfoWithRongID:%@",response[@"rm"]);
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
                                                                                         
                                                                                         //更新本地信息
                                                                                         [NSString setUserPortraitUri:portraitUri];
                                                                                         
                                                                                         //更新融云信息
                                                                                         RCUserInfo *currentUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
                                                                                         currentUserInfo.portraitUri=portraitUri;
                                                                                         [RCIMClient sharedRCIMClient].currentUserInfo = currentUserInfo;
                                                                                         
                                                                                         //* 本地用户信息改变，调用此方法更新kit层用户缓存信息
                                                                                         [[RCIM sharedRCIM] refreshUserInfoCache:currentUserInfo withUserId:currentUserInfo.userId];
                                                                                         
                                                                                         [[RCDataBaseManager shareInstance] insertUserToDB:currentUserInfo];
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

+ (void)  getAllGroupsForAPPOwner:(NSString*)  appOwner
                        Recommend:(BOOL) isRecommend
                        PageNumber:(NSInteger) pageNumber
                         Completion:(void (^)(NSArray *groupList,NSInteger allRecordCount)) completion
{
    [AFHttpTool getAllGroupsForAPPOwner:appOwner
                            Recommend:isRecommend
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
                                              group.is_audit_join = [[dic  objectForKey:@"is_rc_gp"] isEqualToString:@"1"]?YES:NO ;
                                              
                                              group.is_audit_rcgp = [[dic  objectForKey:@"is_audit_rcgp"] isEqualToString:@"1"]?YES:NO ;
                                              group.owner_recom = [[dic  objectForKey:@"owner_recom"] isEqualToString:@"1"]?YES:NO ;
                                              group.sys_recom = [[dic  objectForKey:@"sys_recom"] isEqualToString:@"1"]?YES:NO ;
                                              
                                              NSDictionary *groupSum = [dic objectForKey:@"gp_stat"];
                                              
                                              group.gp_member_sum = [groupSum objectForKey:@"gp_member_sum"];
                                              group.gp_ln_sum     = [groupSum objectForKey:@"gp_ln_sum"];
                                              
                                              [tempArr addObject:group];
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
                       Completion:(void (^)(NSArray *groupList,NSInteger allRecordCount)) completion;
{
    [AFHttpTool getMyGroupsForPageNumber:pageNumber
    Success:^(id response) {
       
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
                group.is_audit_join = [[dic  objectForKey:@"is_audit_join"] isEqualToString:@"1"]?YES:NO ;
                group.is_audit_join = [[dic  objectForKey:@"is_rc_gp"] isEqualToString:@"1"]?YES:NO ;
                
                group.is_audit_rcgp = [[dic  objectForKey:@"is_audit_rcgp"] isEqualToString:@"1"]?YES:NO ;
                group.owner_recom = [[dic  objectForKey:@"owner_recom"] isEqualToString:@"1"]?YES:NO ;
                group.sys_recom = [[dic  objectForKey:@"sys_recom"] isEqualToString:@"1"]?YES:NO ;
                
                [tempArr addObject:group];
            }
        }
        
        if (completion) {
            completion(tempArr,[response[@"allRecordCount"] integerValue]);
        }
        
    } failure:^(NSError *err) {
        
    }];
}

//获取群公告流
+ (void) getGroupBoardNewsForGroupID:(NSString*) groupID
                          PageNumber:(NSInteger) pageNumber
                          Completion:(void (^)(NSArray *streamList,NSInteger allRecordCount)) completion
{
    [AFHttpTool getGroupStreamForGroupID:groupID StreamFilter:StreamFilterNewsOnly PageNumber:pageNumber success:^(id response) {
        //
        
        NSMutableArray *tempArr = [NSMutableArray new];
        NSArray *allGroups = response[@"rs"];
        
        if (allGroups) {
            
            for (NSDictionary *dic in allGroups)
            {
                if ([dic objectForKey:@"lessonID"]) {
                    FlyingPubLessonData * lessonData = [FlyingPubLessonData new];
                    [tempArr addObject:lessonData];
                }
            }
        }
        
        if (completion) {
            completion(tempArr,[response[@"allRecordCount"] integerValue]);
        }

    } failure:^(NSError *err) {
        //
    }];
}

//获取群Post流
+ (void) getGroupStreamForGroupID:(NSString*) groupID
                       PageNumber:(NSInteger) pageNumber
                       Completion:(void (^)(NSArray *streamList,NSInteger allRecordCount)) completion
{
    [AFHttpTool getGroupStreamForGroupID:groupID StreamFilter:StreamFilterAllType PageNumber:pageNumber success:^(id response) {
        //
        NSMutableArray *tempArr = [NSMutableArray new];
        NSArray *allGroups = response[@"rs"];
        
        if (allGroups) {
            
            for (NSDictionary *dic in allGroups)
            {
                if ([dic objectForKey:@"lessonID"]) {
                    FlyingPubLessonData * lessonData = [FlyingPubLessonData new];
                    [tempArr addObject:lessonData];
                }
            }
        }
        
        if (completion) {
            completion(tempArr,[response[@"allRecordCount"] integerValue]);
        }
        
    } failure:^(NSError *err) {
        //
    }];
}

//////////////////////////////////////////////////////////////
#pragma  活动相关
//////////////////////////////////////////////////////////////

+ (void) getEventDetailsForEventID:(NSString*) eventID
                        Completion:(void (^)(FlyingCalendarEvent *event)) completion
{
    [AFHttpTool getEventDetailsForEventID:eventID
                                  success:^(id response) {
                                      //
                                      FlyingCalendarEvent *event = [[FlyingCalendarEvent alloc] init];
                                      event.eventID    = response[@"eventID"];
                                      
                                      if (completion) {
                                          completion(event);
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
                      AppID:[NSString getAppID]
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
                  AppID:(NSString*) appID
             Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool verifyOpenUDID:openUDID
                         AppID:(NSString*) appID
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
    NSString *openID = [NSString getOpenUDID];
    
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
                           AppID:(NSString*) appID
                      Completion:(void (^)(NSDate * startDate,NSDate * endDate)) completion
{
    [AFHttpTool getMembershipForAccount:account
                                  AppID:appID
                                success:^(id response) {
                                    //
                                    NSDate *startDate = nil;
                                    NSDate *endDate =nil;

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
                                                
                                                startDate = [dateFormatter dateFromString:startDateStr];
                                                endDate = [dateFormatter dateFromString:endDateStr];
                                                
                                                [[NSUserDefaults standardUserDefaults] setObject:startDateStr forKey:KMembershipStartTime];
                                                [[NSUserDefaults standardUserDefaults] setObject:endDateStr forKey:KMembershipEndTime];
                                                
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                        }
                                    }
                                    
                                    if (completion) {
                                        completion(startDate,endDate);
                                    }

                                } failure:^(NSError *err) {
                                    //
                                    if (completion) {
                                        completion(nil,nil);
                                    }

                                }];
}

+ (void) updateMembershipForAccount:(NSString*) account
                              AppID:(NSString*) appID
                          StartDate:(NSDate *)startDate
                            EndDate:(NSDate *)endDate
                         Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool updateMembershipForAccount:account
                                  AppID:appID
                                 StartDate:(NSDate *)startDate
                                   EndDate:(NSDate *)endDate
                                success:^(id response) {
                                    
                                    if (response) {
                                        
                                        BOOL result =false;
                                        
                                        NSString *code = response[@"rc"];
                                        
                                        if ([code isEqualToString:@"1"]) {
                                            
                                            result =true;
                                            
                                            //本地记录
                                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                            
                                            NSString *startDateStr = [dateFormatter stringFromDate:startDate];
                                            NSString *endDateStr = [dateFormatter stringFromDate:endDate];
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:startDateStr forKey:KMembershipStartTime];
                                            [[NSUserDefaults standardUserDefaults] setObject:endDateStr forKey:KMembershipEndTime];
                                            
                                            [[NSUserDefaults standardUserDefaults]  synchronize];
                                            
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
                         AppID:(NSString*) appID
                    Completion:(void (^)(BOOL result)) completion
{
    [AFHttpTool getMoneyDataWithOpenID:openudid
                                 AppID:(NSString*) appID
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
                            AppID:(NSString*) appID
                       Completion:(void (^)(BOOL result)) completion;
{
    FlyingStatisticData * staticDat = [[[FlyingStatisticDAO alloc] init] selectWithUserID:openudid];
    
    [AFHttpTool uploadMoneyDataWithOpenID:openudid
                                   AppID:appID
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
                     AppID:(NSString*) appID
                Completion:(void (^)(BOOL result)) completion
{
    //向服务器获取最新QR数据
    [AFHttpTool getQRCountForUserID:openudid
                              AppID:(NSString*) appID
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
               AppID:(NSString*) appID
           WithOpenID:(NSString*) openudid
           Completion:(void (^)(BOOL result)) completion;
{
    @synchronized(self)
    {
        //向服务器帐户进行充值
        [AFHttpTool chargingCardSysURLForUserID:openudid
                                          AppID:(NSString*) appID
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
                                                    
                                                    NSString *title = @"充值提醒";
                                                    
                                                    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                                                                     andMessage:responseStr];
                                                    [alertView addButtonWithTitle:@"知道了"
                                                                             type:SIAlertViewButtonTypeDefault
                                                                          handler:^(SIAlertView *alertView) {}];
                                                    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                                                    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
                                                    [alertView show];
                                                }
                                                
                                                if (completion) {
                                                    completion(result);
                                                }
                                            }
                                            else
                                            {
                                                NSString *title = @"充值提醒！";
                                                NSString *message = @"服务器繁忙或者网络故障请稍后再试！";
                                                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
                                                [alertView addButtonWithTitle:@"知道了"
                                                                         type:SIAlertViewButtonTypeDefault
                                                                      handler:^(SIAlertView *alertView) {}];
                                                alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
                                                alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
                                                [alertView show];
                                                
                                                
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

+(void) getStatisticDetailWithOpenID:(NSString*) openudid
                               AppID:(NSString*) appID
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
                [AFHttpTool getTouchDataForUserID:openudid
                                            AppID:(NSString*) appID
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
                                  AppID:(NSString*) appID
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
    
    
    [AFHttpTool upadteLessonTouchWithAccount:openudid
                                       AppID:appID
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
+ (void) getAlbumListForAuthor:(NSString*)author
                   ContentType:(NSString*) contentType
                         PageNumber:(NSInteger) pageNumber
                          Recommend:(BOOL) isRecommend
                         Completion:(void (^)(NSArray *albumList,NSInteger allRecordCount)) completion
{
    [AFHttpTool albumListDataForAuthor:author
                     lessonConcentType:contentType
                                 PageNumber:pageNumber
                                  Recommend:isRecommend
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


+ (void) getLessonListForAuthor:   (NSString *) author
                     PageNumber:   (NSInteger) pageNumber
              lessonConcentType:  (NSString *) contentType
                   DownloadType:  (NSString *) downloadType
                            Tag:  (NSString *) tag
                     SortbyTime:  (BOOL) time
                      Recommend:(BOOL) isRecommend
                     Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion
{
    [AFHttpTool lessonListDataByTagForAuthor:author
                                  PageNumber:pageNumber
                              lessonConcentType:contentType
                                   DownloadType:downloadType
                                            Tag:tag
                                     SortbyTime:time
                                      Recommend:isRecommend
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

+ (void) getCoverListForAuthor:(NSString*)author
         WithSuccessCompletion:(void (^)(NSArray *LessonList,NSInteger allRecordCount)) completion
{
    
    [AFHttpTool lessonListDataByTagForAuthor:author
                                  PageNumber:1
                           lessonConcentType:nil
                                DownloadType:nil
                                         Tag:nil
                                  SortbyTime:YES
                                   Recommend:YES
                                     success:^(id response) {
                                         
                                         
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
                                     failure:^(NSError *err) {
                                         //
                                         NSLog(@"coverListWithSuccessCompletion %@",err.description);
                                     }];
}

+ (void) getCoverListForAuthor:(NSString*) author
                    PageNumber:(NSInteger) pageNumber
                    SortbyTime:  (BOOL) time
                    Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion
{
    [AFHttpTool lessonListDataByTagForAuthor:author
                                  PageNumber:pageNumber
                           lessonConcentType:nil
                                DownloadType:nil
                                         Tag:nil
                                  SortbyTime:time
                                   Recommend:YES
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
                   Completion:(void (^)(FlyingPubLessonData *lesson)) completion
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

//////////////////////////////////////////////////////////////
#pragma  供应商（作者）相关
//////////////////////////////////////////////////////////////

+ (void) getProviderListForlatitude:(NSString*)latitude
                           longitude:(NSString*)longitude
                          PageNumber:(NSInteger) pageNumber
                          Completion:(void (^)(NSArray *providerList,NSInteger allRecordCount)) completion
{

    [AFHttpTool providerListDataForlatitude:latitude
                                  longitude:longitude
                                 PageNumber:pageNumber
                                    success:^(id response) {
                                        //
                                        
                                        FlyingProviderParser *parser = [[FlyingProviderParser alloc] init];
                                        
                                        [parser SetData:response];
                                        
                                        parser.completionBlock = ^(NSArray *providerList,NSInteger allRecordCount)
                                        {
                                            if (providerList.count!=0 && completion) {
                                                
                                                completion(providerList,allRecordCount);
                                            }
                                        };
                                        
                                        parser.failureBlock = ^(NSError *error)
                                        {
                                            NSLog(@"FlyingProviderParser:%@",error.description);
                                        };
                                        
                                        [parser parse];

                                    } failure:^(NSError *err) {
                                        //
                                        NSLog(@"providerListDataForlatitude:%@",err.description);
                                    }];
}


@end
