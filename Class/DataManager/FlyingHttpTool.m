
//
//  FlyingHttpTool.m
//  FlyingEnglish
//
//  Created by vincent on 6/3/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import "FlyingHttpTool.h"
#import "AFHttpTool.h"
#import "RCDGroupInfo.h"
#import "FlyingUserInfo.h"
#import "RCDRCIMDataSource.h"
#import "FlyingLessonParser.h"
#import "FlyingItemParser.h"
#import "FlyingProviderParser.h"
#import "NSString+FlyingExtention.h"
#import "FlyingCoverDataParser.h"


#import "FlyingGroupData.h"
#import "FlyingPubLessonData.h"

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
                                    if (response) {
                                        
                                        NSString * tempStr =[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                                        
                                        NSArray *tempArray = [tempStr componentsSeparatedByString:@";"];
                                        
                                        if (tempArray.count==3) {
                                            
                                            NSString* startDateStr = tempArray[0];
                                            NSString* endDateStr  = tempArray[1];
                                            
                                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                            
                                            NSDate *startDate = [dateFormatter dateFromString:startDateStr];
                                            NSDate *endDate = [dateFormatter dateFromString:endDateStr];

                                            if (completion) {
                                                completion(startDate,endDate);
                                            }
                                        }
                                    }

                                } failure:^(NSError *err) {
                                    //
                                    NSLog(@"错误是：%@",err.description);
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
                                    NSLog(@"错误");
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

+ (void) getCommentListForSreamType:(NSString*) streamType
                          ContentID:(NSString*) contentID
                         PageNumber:(NSInteger) pageNumber
                         Completion:(void (^)(NSArray *commentList,NSInteger allRecordCount)) completion
{
    [AFHttpTool getCommentListForSreamType:streamType
                              ContentID:contentID
                             PageNumber:pageNumber
                                success:^(id response) {
                                    
                                    NSMutableArray *tempArr = [NSMutableArray new];
                                    NSArray *allComments = response[@"rs"];
                                    
                                    if (allComments) {
                                        
                                        for (NSDictionary *dic in allComments)
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
