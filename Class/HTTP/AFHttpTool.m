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
#import "FlyingDataManager.h"
#import "FlyingDownloadManager.h"
#import "NSString+FlyingExtention.h"

//#define ContentType @"text/plain"
//#define ContentType @"text/html"

@implementation AFHttpTool

+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString*)url
                   params:(NSDictionary*)params
 responseSerializerIsJson:(BOOL) isJson
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL* baseURL = [NSURL URLWithString:[FlyingDataManager getServerAddress]];
    
    //获得请求管理者
    AFHTTPSessionManager * mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    if (isJson) {
        
        mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else
    {
        mgr.responseSerializer= [[AFHTTPResponseSerializer alloc] init];
        
        AFHTTPResponseSerializer *responseSerializer = [[AFHTTPResponseSerializer alloc] init];
        responseSerializer.acceptableContentTypes= [NSSet setWithObject:@"text/html"];
    }
    
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {
        //
        [mgr.requestSerializer setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    }
    
    switch (methodType) {
        case RequestMethodTypeGet:
        {
            //GET请求
            [mgr GET:url
          parameters:params
            progress:^(NSProgress * _Nonnull downloadProgress) {
                //
            }
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 
                 if (success) {
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     success(responseObject);
                 }
                 
             }
             failure:^(NSURLSessionDataTask *task, NSError *error) {
                 
                 if (failure) {
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     failure(error);
                 }
             }];
        }
            break;
        case RequestMethodTypePost:
        {
            //POST请求
            [mgr POST:url
           parameters:params
             progress:^(NSProgress * _Nonnull downloadProgress) {
                 //
             }
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if (success) {
                      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                      success(responseObject);
                  }
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (failure) {
                      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                      failure(error);
                  }
              }];
        }
            break;
        default:
            break;
    }
}

+(NSURLSessionDownloadTask *)downloadUrl:(NSString*) urlStr
                         destinationPath:(NSString*) destinationPath
                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                 success:(void (^)(id response))success
                                 failure:(void (^)(NSError* err))failure
{
    AFURLSessionManager *manager = [FlyingDownloadManager shareInstance].getAFURLSessionManager;
    
    NSURL *URL = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    return [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        //
        if (downloadProgressBlock) {
            //
            downloadProgressBlock(downloadProgress);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                
        return [NSURL fileURLWithPath:destinationPath];
        //
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //
        if (error)
        {
            failure(error);
        }
        else{
        
            BOOL isDir = NO;
            NSFileManager *fm = [NSFileManager defaultManager];
            if(!([fm fileExistsAtPath:filePath.absoluteString isDirectory:&isDir] && isDir))
            {
                success(filePath);
            }
            else
            {
                NSLog(@"can't open file downloaded to: %@", filePath);
            }
        }
    }];
}

+(void)getFriendListFromServerSuccess:(void (^)(id))success
                              failure:(void (^)(NSError *))failure
{
    //获取除自己之外的好友信息
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"get_friend"
                           params:nil
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}


+(void)searchFriendListByEmail:(NSString*)email success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"seach_email"
                           params:@{@"email":email}
         responseSerializerIsJson:true
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
         responseSerializerIsJson:true
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
         responseSerializerIsJson:true
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
         responseSerializerIsJson:true
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
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////////////////////////
#pragma 用户信息操作
//////////////////////////////////////////////////////////////////////////////////
//get token
+(void) getTokenWithOpenID:(NSString *) openId
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure
{
    NSDictionary *params = @{@"tuser_key":openId};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_rc_get_urt_from_hp.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

+ (void)requestUploadPotraitWithOpenID:(NSString *) openId
                                  data:(NSData*)upData
                               success:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL* baseURL = [NSURL URLWithString:[FlyingDataManager getServerAddress]];
    
    //获得请求管理者
    AFHTTPSessionManager * mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [mgr POST:@"tu_rc_sync_urp_from_hp.action" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //
        [formData appendPartWithFormData:[openId dataUsingEncoding:NSUTF8StringEncoding] name:@"tuser_key"];
        
        [formData appendPartWithFileData:upData name:@"portrait" fileName:@"portrait.jpg" mimeType:@"application/octet-stream"];
    }
    progress:^(NSProgress * _Nonnull downloadProgress) {
         //
    }
    success:^(NSURLSessionDataTask *task, id responseObject) {
        //
        if (success) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            success(responseObject);
        }
        
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        //
        if (failure) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            failure(error);
        }
    }];
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
    
    if (![NSString isBlankString:name]){

        [params setObject:name forKey:@"name"];
    }
    
    if (![NSString isBlankString:portraitUri]){
        
        [params setObject:portraitUri forKey:@"portrait_uri"];
    }
    
    if (![NSString isBlankString:br_intro]){
        
        [params setObject:br_intro forKey:@"br_intro"];
    }
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_rc_sync_urb_from_hp.action"
                           params:params
         responseSerializerIsJson:true
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
         responseSerializerIsJson:true
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
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

+(void)  getOpenIDFor:(NSString*) userID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_id":userID}];
    [params setObject:@"tuserurms" forKey:@"type"];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_ua_get_info_from_tn.action"
                           params:params
         responseSerializerIsJson:YES
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////////////////////////
#pragma 群相关操作
//////////////////////////////////////////////////////////////////////////////////
+ (void) getAllGroupsForDomainID:(NSString*) domainID
                      DomainType:(NSString*) type
                      PageNumber:(NSInteger) pageNumber
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"sortindex":@"upd_time desc"}];
    
    if ([type isEqualToString:BC_Domain_Business]) {
        
        [params setObject:domainID forKey:@"app_id"];
    }
    else if ([type isEqualToString:BC_Domain_Group]) {
        
        [params setObject:domainID forKey:@"gp_id"];
    }
    else if ([type isEqualToString:BC_Domain_Author]) {
        
        [params setObject:domainID forKey:@"ln_owner"];
    }
    
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_gp_list_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

+(void) getMyGroupsForPageNumber:(NSInteger) pageNumber
                         Success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure
{
    NSString *openID = [FlyingDataManager getOpenUDID];
    
    if (!openID) {
        
        return;
    }
    
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":openID}];
    
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_member_gplist_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

+(void) getGroupByID:(NSString*) groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"gp_id":groupID}];

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_gp_list_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

//加入群组
+(void) joinGroupForAccount:(NSString *)account
                      GroupID:(NSString *) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":account}];
    [params setObject:groupID forKey:@"gp_id"];

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_apply_member_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

//退出群租
+(void) quitForAccount:(NSString *)account
               GroupByID:(NSString *) groupID
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":account}];

    [params setObject:groupID forKey:@"gp_id"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"quit_group"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

+ (void) checkGroupMemberInfoForAccount:(NSString*) account
                                GroupID:(NSString*) groupID
                                success:(void (^)(id response))success
                                failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":account}];
    
    [params setObject:groupID forKey:@"gp_id"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_member_list_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}


+ (void) getMemberListForGroupID:(NSString*) groupID
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"gp_id":groupID}];
    
    [params setObject:[@(BC_GroupMember_Count) stringValue] forKey:@"perPageCount"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ga_get_member_list_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}


//////////////////////////////////////////////////////////////
#pragma  评论相关
//////////////////////////////////////////////////////////////
+ (void) getCommentListForContentID:(NSString*) contentID
                        ContentType:(NSString*) contentType
                         PageNumber:(NSInteger) pageNumber
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"sortindex":@"ins_time desc"}];
    
    [params setObject:contentID forKey:@"ct_id"];
    [params setObject:contentType forKey:@"ct_type"];
    
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_cm_get_ct_list_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}


+ (void) updateComment:(FlyingCommentData*) commentData
               success:(void (^)(id response))success
               failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":commentData.openUDID}];

    if (![NSString isBlankString:commentData.contentID]){
        
        [params setObject:commentData.contentID forKey:@"ct_id"];
    }
    
    if (![NSString isBlankString:commentData.contentType]){
        
        [params setObject:commentData.contentType forKey:@"ct_type"];
    }
    
    if (![NSString isBlankString:commentData.nickName]){
        
        [params setObject:commentData.nickName forKey:@"name"];
    }
    
    if (![NSString isBlankString:commentData.portraitURL]){
        
        [params setObject:commentData.portraitURL forKey:@"portrait_url"];
    }

    if (![NSString isBlankString:commentData.commentContent]){
        
        [params setObject:commentData.commentContent forKey:@"content"];
    }
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_add_ct_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma  用户激活相关
//////////////////////////////////////////////////////////////
+ (void) regOpenUDID:(NSString*) openUDID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":openUDID}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    
    [params setObject:@"reg" forKey:@"type"];
    
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_reg_user_from_hp.action"
                           params:params
         responseSerializerIsJson:false
                          success:success
                          failure:failure];
}

+ (void) verifyOpenUDID:(NSString*) openUDID
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":openUDID}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_ua_get_status_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}


+ (void) updateCurrentID:(NSString*) currentID
            withUserName:(NSString*) userName
                     pwd:(NSString*) password
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key_d":currentID}];
    
    if (![NSString isBlankString:userName]){

        [params setObject:userName forKey:@"tuser_uid_s"];
    }

    if (![NSString isBlankString:password]){
        
        [params setObject:password forKey:@"tuser_pwd_s"];
    }

    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_rk_replace_from_tn.action"
                           params:params
         responseSerializerIsJson:true
                          success:success
                          failure:failure];
}

+ (void) loginWithQR:(NSString*) loginQR
             Account:(NSString*) passport
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_send_prelogin_info_from_hp.action"
                           params:@{@"user_key":passport,@"oth1":loginQR}
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void) boundWithQR:(NSString*) boundQR
             openUDID:(NSString*) openUDID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"type":@"tuserurms"}];
    
    [params setObject:openUDID forKey:@"tuser_key"];
    [params setObject:boundQR  forKey:@"para1"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_ua_send_matrix_info_from_tn.action"
                           params:params
         responseSerializerIsJson:YES
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma  账户信息
//////////////////////////////////////////////////////////////
+ (void) getMembershipForAccount:(NSString*) account
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":account}];
    [params setObject:@"validth" forKey:@"type"];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_get_user_info_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void)  updateMembershipForAccount:account
                           StartDate:(NSDate *)startDate
                             EndDate:(NSDate *)endDate
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":account}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    
    //苹果渠道
    [params setObject:@"11" forKey:@"vthg_type"];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *startDateString = [formatter stringFromDate:startDate];
    NSString *endDateString = [formatter stringFromDate:endDate];
    
    [params setObject:startDateString forKey:@"start_time"];
    [params setObject:endDateString forKey:@"end_time"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_sync_validth_from_hp.action"
                           params:params
         responseSerializerIsJson:YES
                          success:success
                          failure:failure];

}

//////////////////////////////////////////////////////////////
#pragma  金币相关
//////////////////////////////////////////////////////////////

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure
{
    //老API还用user_key
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":openudid}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:@"accobk" forKey:@"type"];

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_get_user_info_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+(void) uploadMoneyDataWithOpenID:(NSString*) openudid
                       MoneyCount:(NSInteger) moneycount
                        GiftCount:(NSInteger) giftCount
                       TouchCount:(NSInteger) touchCount
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure
{
    //老API还用user_key
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":openudid}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:[@(moneycount) stringValue] forKey:@"appletpp_sum"];
    [params setObject:[@(giftCount) stringValue] forKey:@"reward_sum"];
    [params setObject:[@(touchCount) stringValue] forKey:@"consume_sum"];

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_sync_accobk_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void) getQRCountWithOpenID:(NSString*) openudid
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure
{
    //老API还用user_key
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":openudid}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:@"topup_pwd_total" forKey:@"type"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_user_info_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void) chargingCardSysURLWithOpenID:(NSString*) openudid
                              CardID:(NSString *) cardNo
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure
{
    //老API还用user_key
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":openudid}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:cardNo forKey:@"topup_pwd"];

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_topup_pwd_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void) getTouchDataWithOpenID:(NSString*) openudid
                      lessonID:(NSString *) leesonID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure

{
    //老API还用user_key
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":openudid}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:@"lnclick" forKey:@"type"];
    [params setObject:leesonID forKey:@"ln_id"];

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_get_user_info_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void) upadteLessonTouchWithOpenID:(NSString*) openudid
                       lessonAndTouch:(NSString*) orgnizedStr
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError* err))failure
{
    //老API还用user_key
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"user_key":openudid}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:orgnizedStr forKey:@"lncks"];

    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"ua_sync_lnclick_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma  用户关于课程的计费和统计数据
//////////////////////////////////////////////////////////////
+ (void) getLessonRightForAccount:account
                         LessonID:(NSString*) lessonID
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":account}];
    [params setObject:@"lnvalidth" forKey:@"type"];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:lessonID forKey:@"ln_md5"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_ua_get_info_from_tn.action"
                           params:params
         responseSerializerIsJson:YES
                          success:success
                          failure:failure];
}

+ (void)  updateLessonRightForAccount:account
                             LessonID:(NSString*) lessonID
                           StartDate:(NSDate *)startDate
                             EndDate:(NSDate *)endDate
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"tuser_key":account}];
    [params setObject:[FlyingDataManager getAppData].appID forKey:@"app_id"];
    [params setObject:lessonID forKey:@"ln_md5"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *startDateString = [formatter stringFromDate:startDate];
    NSString *endDateString = [formatter stringFromDate:endDate];
    
    [params setObject:startDateString forKey:@"start_time"];
    [params setObject:endDateString forKey:@"end_time"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"tu_sync_lnvalidth_from_tn.action"
                           params:params
         responseSerializerIsJson:YES
                          success:success
                          failure:failure];
    
}


//////////////////////////////////////////////////////////////
#pragma  内容相关
//////////////////////////////////////////////////////////////
//获取课程列表相关
+ (void) lessonListDataByTagForDomainID:(NSString*) domainID
                             DomainType:(NSString*) type
                           PageNumber:(NSInteger) pageNumber
                    lessonConcentType:  (NSString *) contentType
                         DownloadType:  (NSString *) downloadType
                                  Tag:  (NSString *) tag
                        OnlyRecommend:  (BOOL)    isOnlyRecommend
                              success:(void (^)(id response))success
                              failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"vc":@"3",@"page":[@(pageNumber) stringValue]}];
    
    [params setObject:@"upd_time desc" forKey:@"sortindex"];

    
    if (contentType.length!=0 && ![contentType isEqualToString:@"0"])
    {
        [params setObject:contentType forKey:@"res_type"];
    }
    
    if (downloadType.length!=0)
    {
        [params setObject:downloadType forKey:@"url_2_type"];
    }
    
    if (tag.length!=0)
    {
        [params setObject:tag forKey:@"ln_tag"];
    }
    
    if ([type isEqualToString:BC_Domain_Business]) {
        
        [params setObject:domainID forKey:KAPI_BusinessID_KEY];
        
        if(isOnlyRecommend)
        {
            [params setObject:@"1" forKey:@"sys_recom"];
        }
    }
    else if([type isEqualToString:BC_Domain_Group])
    {
        [params setObject:domainID forKey:@"gp_id"];
        
        if(isOnlyRecommend)
        {
            [params setObject:@"1" forKey:@"sys_recom_c"];
        }
    }
    else if([type isEqualToString:BC_Domain_Author])
    {
        [params setObject:domainID forKey:@"ln_owner"];
        
        if(isOnlyRecommend)
        {
            [params setObject:@"1" forKey:@"owner_recom"];
        }
    }
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_ln_list_for_hp.action"
                        params:params
         responseSerializerIsJson:NO
                          success:success
                       failure:failure];
}

//获取课程信息相关
+ (void) lessonDataForLessonID:(NSString*) lessonID
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_ln_detail_for_hp.action"
                           params:@{@"ln_id":lessonID}
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];

}

+ (void) lessonDataForISBN:(NSString*) ISBN
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_ln_detail_for_hp.action"
                           params:@{@"ln_isbn":ISBN}
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void) shareContentUrl:(NSString*) contentURL
             contentType:(NSString*) contentType
             forLessonID:(NSString *) lessonID
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_access_url_from_hp.action"
                           params:@{@"ln_id":lessonID,@"type":contentType,@"url":contentURL}
         responseSerializerIsJson:NO
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
    
    if (![NSString isBlankString:resourceType]){

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

    if (![NSString isBlankString:lessonID]){

        [params setObject:lessonID forKey:@"md5_value"];
    }
    
    if (![NSString isBlankString:contentURL]){

        [params setObject:contentURL forKey:@"req_url"];
    }
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_ln_rel_url_for_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];

}

//反馈课程错误
+ (void) reportLessonErrorType:(NSString*) type
                    contentURL:(NSString *)contentURL
                      lessonID:(NSString *) lessonID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_echo_from_hp.action"
                        params:@{@"type":type,@"ln_id":lessonID,@"url":contentURL}
         responseSerializerIsJson:NO
                          success:success
                       failure:failure];
}


//////////////////////////////////////////////////////////////
#pragma  标签相关
//////////////////////////////////////////////////////////////
+ (void)getTagListForDomainID:(NSString*) domainID
                   DomainType:(NSString*) type
                 TagString:(NSString*) tagString
                     Count:(NSInteger) count
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"vc":@"3"}];
    
    if ([type isEqualToString:BC_Domain_Business]) {
        
        [params setObject:domainID forKey:KAPI_BusinessID_KEY];
    }
    else if ([type isEqualToString:BC_Domain_Group]) {
        
        [params setObject:domainID forKey:@"gp_id"];
    }
    else if ([type isEqualToString:BC_Domain_Author]) {
        
        [params setObject:domainID forKey:@"ln_owner"];
    }
   
    if (![NSString isBlankString:tagString]){

        [params setObject:tagString forKey:@"ln_tag"];
    }
    
    [params setObject:[@(count) stringValue] forKey:@"perPageCount"];
    [params setObject:[@(1) stringValue] forKey:@"page"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_tag_string_for_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

//推荐标签
+ (void) albumListDataForDomainID:(NSString*) domainID
                       DomainType:(NSString*) type
              lessonConcentType:(NSString*) contentType
                     PageNumber:(NSInteger) pageNumber
                  OnlyRecommend:  (BOOL)    isOnlyRecommend
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError* err))failure
{
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"sortindex":@"upd_time desc"}];
    
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    
    if ([type isEqualToString:BC_Domain_Business]) {
        
        [params setObject:domainID forKey:KAPI_BusinessID_KEY];
        
        if(isOnlyRecommend)
        {
            [params setObject:@"1" forKey:@"sys_recom"];
        }
    }
    else if ([type isEqualToString:BC_Domain_Group]) {
        
        [params setObject:domainID forKey:@"gp_id"];
        
        if(isOnlyRecommend)
        {
            [params setObject:@"1" forKey:@"sys_recom_c"];
        }
    }
    else if ([type isEqualToString:BC_Domain_Author]) {
        
        [params setObject:domainID forKey:@"ln_owner"];
        
        if(isOnlyRecommend)
        {
            [params setObject:@"1" forKey:@"owner_recom"];
        }
    }

    if (![NSString isBlankString:contentType])
    {
        [params setObject:contentType forKey:@"res_type"];
    }
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_tag_list_for_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma   字典相关
//////////////////////////////////////////////////////////////
//获取基础字典
+ (void) getShareBaseZIP:(NSString *) type
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_res_url_from_hp.action"
                           params:@{@"type":type}
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

//网络字典
+ (void) dicDataforWord:(NSString *) word
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_dic_list_for_hp.action"
                           params:@{@"word":word}
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

+ (void) getWordListby:(NSString *) word
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"la_get_word_string_for_hp.action"
                           params:@{@"word":word}
         responseSerializerIsJson:NO
                          success:success
                          failure:failure];
}

//////////////////////////////////////////////////////////////
#pragma  供应商相关
//////////////////////////////////////////////////////////////
//供应商选择
+ (void) providerListDataForlatitude:(NSString*)latitude
                           longitude:(NSString*)longitude
                          PageNumber:(NSInteger) pageNumber
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure
{
    
    NSMutableDictionary *params =[NSMutableDictionary dictionary];

    [params setObject:latitude forKey:@"latitude"];
    [params setObject:longitude forKey:@"longitude"];
    [params setObject:[@(pageNumber) stringValue] forKey:@"page"];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"pu_get_user_position_list_from_hp.action"
                           params:params
         responseSerializerIsJson:NO
                          success:success
                       failure:failure];
}

//App供应商广告
+ (void) getAccountBroadURLWithSuccess:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure

{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"aa_get_app_info_from_hp.action"
                        params:nil
         responseSerializerIsJson:NO
                          success:success
                       failure:failure];
}

+ (void) getAppDataforBounldeID:(NSString *) boundleID
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure
{
    [AFHttpTool requestWihtMethod:RequestMethodTypeGet
                              url:@"aa_get_app_list_from_hp.action"
                           params:@{@"st_id":boundleID}
         responseSerializerIsJson:YES
                          success:success
                          failure:failure];
}



@end
