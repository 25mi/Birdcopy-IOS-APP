
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
#import "FlyingCoverDataParser.h"
#import "FlyingItemParser.h"
#import "FlyingProviderParser.h"
#import "NSString+FlyingExtention.h"
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
        
    }];}

- (void)getAllGroupsWithCompletion:(void (^)(NSMutableArray* result))completion
{
    
    [AFHttpTool getAllGroupsSuccess:^(id response) {
        NSMutableArray *tempArr = [NSMutableArray new];
        NSArray *allGroups = response[@"result"];
        if (allGroups) {
            for (NSDictionary *dic in allGroups) {
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [dic objectForKey:@"id"];
                group.groupName = [dic objectForKey:@"name"];
                group.portraitUri = [dic objectForKey:@"portrait"];
                if (group.portraitUri) {
                    group.portraitUri=@"";
                }
                group.creatorId = [dic objectForKey:@"create_user_id"];
                group.introduce = [dic objectForKey:@"introduce"];
                if (group.introduce) {
                    group.introduce=@"";
                }
                group.number = [dic objectForKey:@"number"];
                group.maxNumber = [dic objectForKey:@"max_number"];
                group.creatorTime = [dic objectForKey:@"creat_datetime"];
                [tempArr addObject:group];
            }
            
            //获取加入状态
            [self getMyGroupsWithBlock:^(NSMutableArray *result) {
                for (RCDGroupInfo *group in result) {
                    for (RCDGroupInfo *groupInfo in tempArr) {
                        if ([group.groupId isEqualToString:groupInfo.groupId]) {
                            groupInfo.isJoin = YES;
                        }
                    }
                }
                if (completion) {
                    completion(tempArr);
                }
                
            }];
            
            
        }
        
    } failure:^(NSError* err){
        
    }];
}


-(void) getMyGroupsWithBlock:(void(^)(NSMutableArray* result)) block
{
    [AFHttpTool getMyGroupsSuccess:^(id response) {
        NSArray *allGroups = response[@"result"];
        NSMutableArray *tempArr = [NSMutableArray new];
        if (allGroups) {
            for (NSDictionary *dic in allGroups) {
                RCDGroupInfo *group = [[RCDGroupInfo alloc] init];
                group.groupId = [dic objectForKey:@"id"];
                group.groupName = [dic objectForKey:@"name"];
                group.portraitUri = [dic objectForKey:@"portrait"];
                if (group.portraitUri) {
                    group.portraitUri=@"";
                }
                group.creatorId = [dic objectForKey:@"create_user_id"];
                group.introduce = [dic objectForKey:@"introduce"];
                if (group.introduce) {
                    group.introduce=@"";
                }
                group.number = [dic objectForKey:@"number"];
                group.maxNumber = [dic objectForKey:@"max_number"];
                group.creatorTime = [dic objectForKey:@"creat_datetime"];
                [tempArr addObject:group];
            }
            
            if (block) {
                block(tempArr);
            }
        }
        
    } failure:^(NSError *err) {
        
    }];
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

//API

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

+ (void) getCoverListWithSuccessCompletion:(void (^)(NSArray *LessonList,NSInteger allRecordCount)) completion
{
    
    [AFHttpTool lessonListDataByTagForPageNumber:1 lessonConcentType:nil DownloadType:nil Tag:nil SortbyTime:YES Recommend:YES success:^(id response) {
        
        
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


+ (void) getCoverListByTagURLForPageNumber:(NSInteger) pageNumber
                                SortbyTime:  (BOOL) time
                                Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion
{
    [AFHttpTool lessonListDataByTagForPageNumber:pageNumber lessonConcentType:nil DownloadType:nil Tag:nil SortbyTime:time Recommend:YES success:^(id response) {
        
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

+ (void) getAlbumListForContentType:(NSString*) contentType
                         PageNumber:(NSInteger) pageNumber
                          Recommend:(BOOL) isRecommend
                         Completion:(void (^)(NSArray *albumList,NSInteger allRecordCount)) completion
{

    [AFHttpTool albumListDataForContentType:contentType
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


+ (void) getLessonListByTagForPageNumber:(NSInteger) pageNumber
                       lessonConcentType:  (NSString *) contentType
                            DownloadType:  (NSString *) downloadType
                                     Tag:  (NSString *) tag
                              SortbyTime:  (BOOL) time
                               Recommend:(BOOL) isRecommend
                              Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion
{
    [AFHttpTool lessonListDataByTagForPageNumber:pageNumber
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
