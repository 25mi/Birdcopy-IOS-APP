//
//  AFHttpTool.h
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RequestMethodType){
    RequestMethodTypePost = 1,
    RequestMethodTypeGet = 2
};

@interface AFHttpTool : NSObject


//上传用户头像专用API
+ (void)requestUploadPotraitWithOpenID:(NSString *) openId
                                  data:(NSData*)upData
                               success:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure;

/**
 *  发送一个请求
 *
 *  @param methodType   请求方法
 *  @param url          请求路径
 *  @param params       请求参数
 *  @param success      请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure      请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+(void) requestWihtMethod:(RequestMethodType)
          methodType url : (NSString *)url
                   params:(NSDictionary *)params
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError *err))failure;

//get Rong token
+(void) getTokenWithOpenID:(NSString *) openId
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;

//Fresh user data
+(void) refreshUesrWithOpenID:(NSString *) openId
                         name:(NSString *) name
                  portraitUri:(NSString *) portraitUri
                     br_intro:(NSString*) br_intro
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure;

//Get User info
+(void)getUserInfoWithRongID:(NSString*) rongUserId
            success:(void (^)(id response))success
            failure:(void (^)(NSError* err))failure;

+(void)getUserInfoWithOpenID:(NSString*) openId
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////////////////////////
//get groups
+(void) getMyGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;
+(void) getAllGroupsSuccess:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;
//get group by id
+(void) getGroupByID:(int) groupID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;

//create group
+(void) createGroupWithName:(NSString *) name
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure;

//join group
+(void) joinGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//quit group
+(void) quitGroupByID:(int) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//update group
+(void) updateGroupByID:(int) groupID withGroupName:(NSString*) groupName andGroupIntroduce:(NSString*) introduce
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//获取好友列表
+(void)getFriendListFromServerSuccess:(void (^)(id response))success
                              failure:(void (^)(NSError* err))failure;

//按昵称搜素好友
+(void)searchFriendListByName:(NSString*)name success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure;
//按邮箱搜素好友
+(void)searchFriendListByEmail:(NSString*)email success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure;

//请求加好友
+(void)requestFriend:(NSString*) userId
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;
//处理请求加好友
+(void)processRequestFriend:(NSString*) userId
               withIsAccess:(BOOL)isAccess
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure;
//删除好友
+(void)deleteFriend:(NSString*) userId
            success:(void (^)(id response))success
            failure:(void (^)(NSError* err))failure;

//以前的官方API

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;


//供应商选择
+ (void) providerListDataForlatitude:(NSString*)latitude
                       longitude:(NSString*)longitude
                      PageNumber:(NSInteger) pageNumber
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

//App供应商广告
+ (void) getAccountBroadURLWithSuccess:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure;

//帐户同步相关
+ (void) chargingCardSysURLForUserID:(NSString *) userID
                              CardID:(NSString *) cardNo
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure;

+ (void) getAccountDataForUserID:(NSString *) userID
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

+ (void) getQRCountForUserID:(NSString *) userID
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError* err))failure;

+ (void) getTouchDataForUserID:(NSString *) userID
                      lessonID:(NSString *) leesonID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure;

+ (void) sysOtherMoneyWithAccount:(NSString*)passport
                       MoneyCount:(NSInteger) moneycount
                        GiftCount:(NSInteger) giftCount
                       TouchCount:(NSInteger) touchCount
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure;

+ (void) sysLessonTouchWithAccount:(NSString*)passport
                    lessonAndTouch:(NSString*) orgnizedStr
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError* err))failure;

+ (void) loginWithQR:(NSString*) loginQR
             Account:(NSString*) passport
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;

//标签相关
+ (void) albumListDataForContentType:(NSString*) contentType
                      PageNumber:(NSInteger) pageNumber
                       Recommend:(BOOL) isRecommend
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;
//获取课程列表相关
+ (void) lessonListDataByTagForPageNumber:(NSInteger) pageNumber
                       lessonConcentType:  (NSString *) contentType
                            DownloadType:  (NSString *) downloadType
                                     Tag:  (NSString *) tag
                              SortbyTime:  (BOOL) time
                               Recommend:(BOOL) isRecommend
                                 success:(void (^)(id response))success
                                 failure:(void (^)(NSError* err))failure;
//获取课程信息相关
+ (void) lessonDataForLessonID:(NSString*) lessonID
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure;

+ (void) lessonDataForISBN:(NSString*) ISBN
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure;

+ (void) shareContentUrl:(NSString*) contentURL
             contentType:(NSString*) contentType
             forLessonID:(NSString *) lessonID
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure;

+ (void) lessonResourceType:(NSString*) resourceType
                   lessonID:(NSString *) lessonID
                 contentURL:(NSString *)contentURL
                      isURL:(BOOL) isURL
                    success:(void (^)(id response))success
                    failure:(void (^)(NSError* err))failure;

//获取基础字典
+ (void) shareBaseZIP:(NSString *) type
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//反馈错误
+ (void ) reportLessonErrorType:(NSString*) type
                      contentURL:(NSString *)contentURL
                        lessonID:(NSString *) lessonID
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError* err))failure;

//网络字典
+ (void) dicDataforWord:(NSString *) word
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;



@end

