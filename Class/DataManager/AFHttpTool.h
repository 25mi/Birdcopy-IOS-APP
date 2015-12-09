//
//  AFHttpTool.h
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "FlyingStreamData.h"
#import "FlyingCommentData.h"

typedef NS_ENUM(NSInteger, RequestMethodType){
    RequestMethodTypePost = 1,
    RequestMethodTypeGet = 2
};

@interface AFHttpTool : NSObject

/**
 *  发送一个请求
 *
 *  @param methodType   请求方法
 *  @param url          请求路径
 *  @param params       请求参数
 *  @param responseSerializerIsJson       返回形式
 *  @param success      请求成功后的回调（请将请求成功后想做的事情写到这个block中）
 *  @param failure      请求失败后的回调（请将请求失败后想做的事情写到这个block中）
 */
+ (void)requestWihtMethod:(RequestMethodType)methodType
                      url:(NSString*)url
                   params:(NSDictionary*)params
                   responseSerializerIsJson:(BOOL) isJson
                  success:(void (^)(id response))success
                  failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////////////////////////
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

//////////////////////////////////////////////////////////////////////////////////
#pragma 用户信息操作
//////////////////////////////////////////////////////////////////////////////////
//get Rong token
+(void) getTokenWithOpenID:(NSString *) openId
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;

//上传用户头像专用API
+ (void)requestUploadPotraitWithOpenID:(NSString *) openId
                                  data:(NSData*)upData
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
#pragma 群相关操作
//////////////////////////////////////////////////////////////////////////////////
+ (void) getAllGroupsForAPPOwner:(NSString*)  appOwner
                       Recommend:(BOOL) isRecommend
                      PageNumber:(NSInteger) pageNumber
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

+(void) getMyGroupsForPageNumber:(NSInteger) pageNumber
                         Success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

+ (void) getGroupStreamForGroupID:(NSString*) groupID
                     StreamFilter:(StreamFilter) streamFilter
                       PageNumber:(NSInteger) pageNumber
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure;
//////////////////////////////////////////////////////////////
#pragma  活动相关
//////////////////////////////////////////////////////////////
+ (void) getEventDetailsForEventID:(NSString*) eventID
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  评论相关
//////////////////////////////////////////////////////////////
+ (void) getCommentListForContentID:(NSString*) contentID
                        ContentType:(NSString*) contentType
                         PageNumber:(NSInteger) pageNumber
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError* err))failure;


+ (void) updateComment:(FlyingCommentData*) commentData
               success:(void (^)(id response))success
               failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  用户注册、激活相关
//////////////////////////////////////////////////////////////
+ (void) regOpenUDID:(NSString*) openUDID
               AppID:(NSString*) appID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;


+ (void) verifyOpenUDID:(NSString*) openUDID
                  AppID:(NSString*) appID
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;

+ (void) updateCurrentID:(NSString*) currentID
            withSourceID:(NSString*) sourceID
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure;

+ (void) loginWithQR:(NSString*) loginQR
             Account:(NSString*) passport
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  会员相关
//////////////////////////////////////////////////////////////
+ (void) getMembershipForAccount:(NSString*) account
                           AppID:(NSString*) appID
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

+ (void)  updateMembershipForAccount:account
                               AppID:appID
                           StartDate:(NSDate *)startDate
                             EndDate:(NSDate *)endDate
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  金币相关
//////////////////////////////////////////////////////////////

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                         AppID:(NSString*) appID
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;

+(void) uploadMoneyDataWithOpenID:(NSString*) openudid
                            AppID:(NSString*) appID
                       MoneyCount:(NSInteger) moneycount
                        GiftCount:(NSInteger) giftCount
                       TouchCount:(NSInteger) touchCount
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure;

+ (void) getQRCountForUserID:(NSString *) userID
                       AppID:(NSString*) appID
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError* err))failure;

+ (void) chargingCardSysURLForUserID:(NSString *) userID
                               AppID:(NSString*) appID
                              CardID:(NSString *) cardNo
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure;


+ (void) getTouchDataForUserID:(NSString *) userID
                         AppID:(NSString*) appID
                      lessonID:(NSString *) leesonID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure;


+ (void) upadteLessonTouchWithAccount:(NSString*)passport
                                AppID:(NSString*) appID
                    lessonAndTouch:(NSString*) orgnizedStr
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  内容相关
//////////////////////////////////////////////////////////////
//标签相关
+ (void) albumListDataForAuthor:(NSString*) author
              lessonConcentType:(NSString*) contentType
                     PageNumber:(NSInteger) pageNumber
                      Recommend:(BOOL) isRecommend
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError* err))failure;
//获取课程列表相关
+ (void) lessonListDataByTagForAuthor:(NSString*) author
                           PageNumber:(NSInteger) pageNumber
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


//反馈课程错误
+ (void ) reportLessonErrorType:(NSString*) type
                     contentURL:(NSString *)contentURL
                       lessonID:(NSString *) lessonID
                        success:(void (^)(id response))success
                        failure:(void (^)(NSError* err))failure;
//////////////////////////////////////////////////////////////
#pragma   字典相关
//////////////////////////////////////////////////////////////
//获取基础字典
+ (void) getShareBaseZIP:(NSString *) type
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

//网络字典
+ (void) dicDataforWord:(NSString *) word
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma   供应商相关
//////////////////////////////////////////////////////////////

//供应商选择
+ (void) providerListDataForlatitude:(NSString*)latitude
                           longitude:(NSString*)longitude
                          PageNumber:(NSInteger) pageNumber
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure;

//App供应商广告
+ (void) getAccountBroadURLWithSuccess:(void (^)(id response))success
                               failure:(void (^)(NSError* err))failure;

@end

