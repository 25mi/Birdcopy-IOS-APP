//
//  AFHttpTool.m
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//

#import "AFHttpTool.h"
#import "AFNetworking.h"
#import "shareDefine.h"
#import "UICKeyChainStore.h"
#import "NSString+FlyingExtention.h"

//#define ContentType @"text/plain"
#define ContentType @"text/html"

@implementation AFHttpTool

+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString*)url
                   params:(NSDictionary*)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure
{
    
    NSURL* baseURL = [NSURL URLWithString:[NSString getServerAddress]];
    
    //获得请求管理者
    AFHTTPSessionManager * mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [mgr.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    
    switch (methodType) {
        case RequestMethodTypeGet:
        {
            //GET请求
            [mgr GET:url parameters:params
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 if (success) {
                     success(responseObject);
                 }
                 
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 if (failure) {
                     failure(error);
                 }
             }];

        }
            break;
        case RequestMethodTypePost:
        {
            //POST请求
            [mgr POST:url parameters:params
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if (success) {
                      success(responseObject);
                  }
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (failure) {
                      failure(error);
                  }
              }];
        }
            break;
        default:
            break;
    }
}

+ (void)requestUploadPotraitWithOpenID:(NSString *) openId
                                  data:(NSData*)upData
                               success:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure
{
    NSURL* baseURL = [NSURL URLWithString:[NSString getServerAddress]];

    //获得请求管理者
    AFHTTPSessionManager * mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];

   [mgr POST:@"tu_rc_sync_urp_from_hp.action" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //
       [formData appendPartWithFormData:[openId dataUsingEncoding:NSUTF8StringEncoding] name:@"tuser_key"];

       [formData appendPartWithFileData:upData name:@"portrait" fileName:@"portrait.jpg" mimeType:@"application/octet-stream"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        if (failure) {
            failure(error);
        }
    }];
}

//get token
+(void) getTokenWithOpenID:(NSString *) openId
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{@"tuser_key":openId};

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_rc_get_urt_from_hp.action"
                           params:params
                          success:success
                          failure:failure];
}

//Fresh RongCLoud Account Info
+(void) refreshUesrWithOpenID:(NSString *) openId
                    name:(NSString *) name
                   portraitUri:(NSString *) portraitUri
                     br_intro:(NSString*) br_intro
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure

{
    if (!openId) {
        
        return;
    }
    
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":openId}];
    
    
    if (name.length!=0) {
        [params setObject:name forKey:@"name"];
    }
    
    if (portraitUri.length!=0) {
        
        [params setObject:portraitUri forKey:@"portrait_uri"];
    }
    
    if (br_intro.length!=0) {
        
        [params setObject:br_intro forKey:@"br_intro"];
    }

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_rc_sync_urb_from_hp.action"
                           params:params
                          success:success
                          failure:failure];
}

+(void)getUserInfoWithRongID:(NSString*) rongUserId
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError* err))failure
{

    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_id":rongUserId}];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_rc_get_usr_from_hp.action"
                           params:params
                          success:success
                          failure:failure];
}

+(void)getUserInfoWithOpenID:(NSString*) openId
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":openId}];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_rc_get_usr_from_hp.action"
                           params:params
                          success:success
                          failure:failure];
}

//get group by id
+(void) getGroupByID:(int) groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"get_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID]}
                          success:success
                          failure:failure];

}

//create group
+(void) createGroupWithName:(NSString *) name
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"create_group"
                           params:@{@"name":name}
                          success:success
                          failure:failure];
}

//join group
+(void) joinGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"join_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID]}
                          success:success
                          failure:failure];
}

//quit group
+(void) quitGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"quit_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID]}
                          success:success
                          failure:failure];
}


+(void)updateGroupByID:(int)groupID
         withGroupName:(NSString *)groupName
     andGroupIntroduce:(NSString *)introduce
               success:(void (^)(id))success
               failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"update_group"
                           params:@{@"id":[NSNumber numberWithInt:groupID],@"name":groupName,@"introduce":introduce}
                          success:success
                          failure:failure];
}

+(void)getFriendListFromServerSuccess:(void (^)(id))success
                              failure:(void (^)(NSError *))failure
{
    //获取除自己之外的好友信息
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_friend"
                           params:nil
                          success:success
                          failure:failure];
}


+(void)searchFriendListByEmail:(NSString*)email success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"seach_email"
                           params:@{@"email":email}
                          success:success
                          failure:failure];
}

+(void)searchFriendListByName:(NSString*)name
                      success:(void (^)(id))success
                      failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"seach_name"
                           params:@{@"username":name}
                          success:success
                          failure:failure];
}

+(void)requestFriend:(NSString*)userId
             success:(void (^)(id))success
             failure:(void (^)(NSError *))failure
{
    NSLog(@"%@",NSLocalizedStringFromTable(@"Request_Friends_extra", @"RongCloudKit", nil));
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"request_friend"
                           params:@{@"id":userId, @"message": NSLocalizedStringFromTable(@"Request_Friends_extra", @"RongCloudKit", nil)} //Request_Friends_extra
                          success:success
                          failure:failure];
}

+(void)processRequestFriend:(NSString*)userId
               withIsAccess:(BOOL)isAccess
                    success:(void (^)(id))success
                    failure:(void (^)(NSError *))failure
{

    NSString *isAcept = isAccess ? @"1":@"0";
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"process_request_friend"
                           params:@{@"id":userId,@"is_access":isAcept}
                          success:success
                          failure:failure];
}

+(void) deleteFriend:(NSString*)userId
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypePost
                              url:@"delete_friend"
                           params:@{@"id":userId}
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma  group related (not IM)
//////////////////////////////////////////////////////////////
//get groups

+ (void) getAllFlyingGroupForRecommend:(BOOL) isRecommend
                            PageNumber:(NSInteger) pageNumber
                               success:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"sortindex":@"upd_time desc"}];
    
    NSInteger pagecount=kperpageLessonCount;
    if (INTERFACE_IS_PAD)
    {
        pagecount=kperpageLessonCountPAD;
    }
    
    [params setObject:[@(pagecount) stringValue] forKey:@"perPageCount"];
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    
    
    NSString * lessonOwner = [UICKeyChainStore keyChainStore][KLessonOwner];
    
    if(isRecommend)
    {
        if(lessonOwner)
        {
            [params setObject:@"1" forKey:@"owner_recom"];
        }
        else
        {
            [params setObject:@"1" forKey:@"sys_recom"];
        }
    }

    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_gp_list_from_tn.action"
                           params:params
                          success:success
                          failure:failure];
}


//get groups
+(void) getMyGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure
{
    NSString *passport = [UICKeyChainStore keyChainStore][KOPENUDIDKEY];
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":passport}];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_member_gplist_from_tn.action"
                           params:params
                          success:success
                          failure:failure];
}


+ (void) getGroupNewsListForGroupID:(NSString*) groupID
                         PageNumber:(NSInteger) pageNumber
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"gp_id":groupID}];
    
    NSInteger pagecount=kperpageLessonCount;
    if (INTERFACE_IS_PAD)
    {
        pagecount=kperpageLessonCountPAD;
    }
    
    [params setObject:[@(pagecount) stringValue] forKey:@"perPageCount"];
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_member_gplist_from_tn.action"
                           params:params
                          success:success
                          failure:failure];
}


//////////////////////////////////////////////////////////////
#pragma  old API, not jason
//////////////////////////////////////////////////////////////
+ (void)requestWithUrl:(NSString*)url
                params:(NSDictionary*)params
               success:(void (^)(id response))success
               failure:(void (^)(NSError* err))failure
{
    
    NSURL* baseURL = [NSURL URLWithString:[NSString getServerAddress]];
    
    //获得请求管理者
    AFHTTPSessionManager * mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    mgr.responseSerializer= [[AFHTTPResponseSerializer alloc] init];
    
    AFHTTPResponseSerializer *responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    responseSerializer.acceptableContentTypes= [NSSet setWithObject:@"text/html"];

    mgr.responseSerializer = responseSerializer;
    
    if ([AFNetworkReachabilityManager sharedManager].reachable)
    {
        [mgr.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    
    //GET请求
    [mgr GET:url parameters:params
     success:^(NSURLSessionDataTask *task, id responseObject) {
         if (success) {
             success(responseObject);
         }
         
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
         if (failure) {
             failure(error);
         }
     }];
}

//////////////////////////////////////////////////////////////
#pragma  provider Related
//////////////////////////////////////////////////////////////
//供应商选择
+ (void) providerListDataForlatitude:(NSString*)latitude
                          longitude:(NSString*)longitude
                         PageNumber:(NSInteger) pageNumber
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError* err))failure
{
    NSInteger pagecount=kperpageLessonCount;
    if (INTERFACE_IS_PAD)
    {
        pagecount=kperpageLessonCountPAD;
    }
    
    [AFHttpTool requestWithUrl:@"pu_get_user_position_list_from_hp.action"
                           params:@{@"latitude":latitude,@"longitude":longitude,@"perPageCount":[@(pagecount) stringValue],@"page":[@(pageNumber) stringValue]}
                          success:success
                          failure:failure];
}

//App供应商广告
+ (void) getAccountBroadURLWithSuccess:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWithUrl:@"aa_get_app_info_from_hp.action"
                           params:nil
                          success:success
                          failure:failure];
}

//帐户同步相关
+ (void) chargingCardSysURLForUserID:(NSString *) userID
                                 CardID:(NSString *) cardNo
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWithUrl:@"la_topup_pwd_from_hp.action"
                        params:@{@"user_key":userID,@"topup_pwd":cardNo}
                       success:success
                       failure:failure];
}

+ (void) getAccountDataForUserID:(NSString *) userID
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"ua_get_user_info_from_hp.action"
                        params:@{@"user_key":userID}
                       success:success
                       failure:failure];

}

+ (void) getQRCountForUserID:(NSString *) userID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"la_get_user_info_from_hp.action"
                        params:@{@"user_key":userID,@"type":@"topup_pwd_total"}
                       success:success
                       failure:failure];
}

+ (void) getTouchDataForUserID:(NSString *) userID
                      lessonID:(NSString *) leesonID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWithUrl:@"ua_get_user_info_from_hp.action"
                        params:@{@"user_key":userID,@"type":@"lnclick",@"ln_id":leesonID}
                       success:success
                       failure:failure];
}

+ (void) sysOtherMoneyWithAccount:(NSString*)passport
                          MoneyCount:(NSInteger) moneycount
                           GiftCount:(NSInteger) giftCount
                          TouchCount:(NSInteger) touchCount
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"ua_sync_accobk_from_hp.action"
                           params:@{@"user_key":passport,@"appletpp_sum":[@(moneycount) stringValue],@"reward_sum":[@(giftCount) stringValue],@"consume_sum":[@(touchCount) stringValue]}
                          success:success
                          failure:failure];
}

+ (void) sysLessonTouchWithAccount:(NSString*)passport
                       lessonAndTouch:(NSString*) orgnizedStr
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"ua_sync_lnclick_from_hp.action"
                           params:@{@"user_key":passport,@"lncks":orgnizedStr}
                          success:success
                          failure:failure];
}

+ (void) loginWithQR:(NSString*) loginQR
                Account:(NSString*) passport
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"ua_send_prelogin_info_from_hp.action"
                           params:@{@"user_key":passport,@"oth1":loginQR}
                          success:success
                          failure:failure];
}

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"ua_get_user_info_from_hp.action"
                        params:@{@"user_key":openudid,@"type":@"accobk"}
                       success:success
                       failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma  Tag Related
//////////////////////////////////////////////////////////////
//标签相关
+ (void) albumListDataForContentType:(NSString*) contentType
                             PageNumber:(NSInteger) pageNumber
                            Recommend:(BOOL) isRecommend
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"sortindex":@"upd_time desc"}];
    
    NSInteger pagecount=kperpageLessonCount;
    if (INTERFACE_IS_PAD)
    {
        pagecount=kperpageLessonCountPAD;
    }
    
    [params setObject:[@(pagecount) stringValue] forKey:@"perPageCount"];
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    

    NSString * lessonOwner = [UICKeyChainStore keyChainStore][KLessonOwner];
    if (lessonOwner)
    {
        [params setObject:lessonOwner forKey:@"tag_owner"];
    }
    
    if (contentType)
    {
        [params setObject:contentType forKey:@"res_type"];
    }
    
    if(isRecommend)
    {
        if(lessonOwner)
        {
            [params setObject:@"1" forKey:@"owner_recom"];
        }
        else
        {
            [params setObject:@"1" forKey:@"sys_recom"];
        }
    }
    
    [AFHttpTool requestWithUrl:@"la_get_tag_list_for_hp.action"
                           params:params
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma  lesson  List Related
//////////////////////////////////////////////////////////////
//获取课程列表相关
+ (void) lessonListDataByTagForPageNumber:(NSInteger) pageNumber
                          lessonConcentType:  (NSString *) contentType
                               DownloadType:  (NSString *) downloadType
                                        Tag:  (NSString *) tag
                                 SortbyTime:  (BOOL) time
                                  Recommend:(BOOL) isRecommend
                                    success:(void (^)(id response))success
                                    failure:(void (^)(NSError* err))failure
{
    NSInteger pagecount=kperpageLessonCount;
    if (INTERFACE_IS_PAD)
    {
        pagecount=kperpageLessonCountPAD;
    }

    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"vc":@"3",@"perPageCount":[@(pagecount) stringValue],@"page":[@(pageNumber) stringValue]}];

    
    if (contentType && ![contentType isEqualToString:@"0"])
    {
        [params setObject:contentType forKey:@"res_type"];
    }
    
    if (downloadType)
    {
        [params setObject:downloadType forKey:@"url_2_type"];
    }
    
    if (tag)
    {
        [params setObject:tag forKey:@"ln_tag"];
    }
    
    if(time)
    {
        [params setObject:@"upd_time desc" forKey:@"sortindex"];
        
    }
    
    NSString * lessonOwner = [UICKeyChainStore keyChainStore][KLessonOwner];
    if (lessonOwner)
    {
        [params setObject:lessonOwner forKey:@"ln_owner"];
    }
    
    if(isRecommend)
    {
        if(lessonOwner)
        {
            [params setObject:@"1" forKey:@"owner_recom"];
        }
        else
        {
            [params setObject:@"1" forKey:@"sys_recom"];
        }
    }
    
    [AFHttpTool requestWithUrl:@"la_get_ln_list_for_hp.action"
                           params:params
                          success:success
                          failure:failure];
}


//////////////////////////////////////////////////////////////
#pragma  lesson  Related
//////////////////////////////////////////////////////////////
//获取课程信息相关
+ (void) lessonDataForLessonID:(NSString*) lessonID
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWithUrl:@"la_get_ln_detail_for_hp.action"
                           params:@{@"ln_id":lessonID}
                          success:success
                          failure:failure];

}

+ (void) lessonDataForISBN:(NSString*) ISBN
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWithUrl:@"la_get_ln_detail_for_hp.action"
                           params:@{@"ln_isbn":ISBN}
                          success:success
                          failure:failure];
}

+ (void) shareContentUrl:(NSString*) contentURL
             contentType:(NSString*) contentType
             forLessonID:(NSString *) lessonID
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWithUrl:@"la_access_url_from_hp.action"
                           params:@{@"ln_id":lessonID,@"type":contentType,@"url":contentURL}
                          success:success
                          failure:failure];

}

+ (void) lessonResourceType:(NSString*) resourceType
                   lessonID:(NSString *) lessonID
                 contentURL:(NSString *)contentURL
                      isURL:(BOOL) isURL
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionary];
    
    if (resourceType)
    {
        [params setObject:resourceType forKey:@"type"];
    }

    if (isURL)
    {
        [params setObject:@"url" forKey:@"getType"];
    }
    else
    {
        [params setObject:@"content" forKey:@"getType"];
    }

    if (lessonID)
    {
        [params setObject:lessonID forKey:@"md5_value"];
    }
    
    if (contentURL) {
        
        [params setObject:contentURL forKey:@"req_url"];
    }
    
    [AFHttpTool requestWithUrl:@"la_get_ln_rel_url_for_hp.action"
                           params:params
                          success:success
                          failure:failure];

}

+ (void) shareBaseZIP:(NSString *) type
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"la_get_res_url_from_hp.action"
                           params:@{@"type":type}
                          success:success
                          failure:failure];
}


+ (void) reportLessonErrorType:(NSString*) type
                      contentURL:(NSString *)contentURL
                     lessonID:(NSString *) lessonID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"la_echo_from_hp.action"
                           params:@{@"type":type,@"ln_id":lessonID,@"url":contentURL}
                          success:success
                          failure:failure];
}

+ (void) dicDataforWord:(NSString *) word
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWithUrl:@"la_get_dic_list_for_hp.action"
                           params:@{@"word":word}
                          success:success
                          failure:failure];
}
@end
