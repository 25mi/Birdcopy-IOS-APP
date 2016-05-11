//
//  AFHttpTool.h
//  RCloud_liv_demo
//
//  Created by Liv on 14-10-22.
//  Copyright (c) 2014年 胡利武. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "shareDefine.h"

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

+ (NSURLSessionDownloadTask *)downloadUrl:(NSString*) urlStr
                         destinationPath:(NSString*) destinationPath
                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
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

+(void)  getOpenIDFor:(NSString*) userID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;


//////////////////////////////////////////////////////////////////////////////////
#pragma 群相关操作
//////////////////////////////////////////////////////////////////////////////////
+ (void) getAllGroupsForDomainID:(NSString*) domainID
                      DomainType:(NSString*) type
                      PageNumber:(NSInteger) pageNumber
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

+(void) getMyGroupsForPageNumber:(NSInteger) pageNumber
                         Success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

+(void) getGroupByID:(NSString*) groupID
               success:(void (^)(id response))success
               failure:(void (^)(NSError* err))failure;

+(void) joinGroupForAccount:(NSString *) account
                      GroupID:(NSString *) groupID
                      success:(void (^)(id response))success
                      failure:(void (^)(NSError* err))failure;

+(void) quitForAccount:(NSString *) account
               GroupByID:(NSString *) groupID
              success:(void (^)(id response))success
              failure:(void (^)(NSError* err))failure;

+ (void) checkGroupMemberInfoForAccount:(NSString*) account
                                GroupID:(NSString*) groupID
                                success:(void (^)(id response))success
                                failure:(void (^)(NSError* err))failure;

+ (void) getMemberListForGroupID:(NSString*) groupID
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
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;

+ (void) verifyOpenUDID:(NSString*) openUDID
                success:(void (^)(id response))success
                failure:(void (^)(NSError* err))failure;

+ (void) updateCurrentID:(NSString*) currentID
            withUserName:(NSString*) userName
                     pwd:(NSString*) password
                 success:(void (^)(id response))success
                 failure:(void (^)(NSError* err))failure;

+ (void) loginWithQR:(NSString*) loginQR
             Account:(NSString*) passport
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;

+ (void) boundWithQR:(NSString*) boundQR
            openUDID:(NSString*) openUDID
             success:(void (^)(id response))success
             failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  会员相关
//////////////////////////////////////////////////////////////
+ (void) getMembershipForAccount:(NSString*) account
                         success:(void (^)(id response))success
                         failure:(void (^)(NSError* err))failure;

+ (void)  updateMembershipForAccount:account
                           StartDate:(NSDate *)startDate
                             EndDate:(NSDate *)endDate
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  金币相关
//////////////////////////////////////////////////////////////

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;

+(void) uploadMoneyDataWithOpenID:(NSString*) openudid
                       MoneyCount:(NSInteger) moneycount
                        GiftCount:(NSInteger) giftCount
                       TouchCount:(NSInteger) touchCount
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure;

+ (void) getQRCountWithOpenID:(NSString*) openudid
                     success:(void (^)(id response))success
                     failure:(void (^)(NSError* err))failure;

+ (void) chargingCardSysURLWithOpenID:(NSString*) openudid
                              CardID:(NSString *) cardNo
                             success:(void (^)(id response))success
                             failure:(void (^)(NSError* err))failure;


+ (void) getTouchDataWithOpenID:(NSString*) openudid
                      lessonID:(NSString *) leesonID
                       success:(void (^)(id response))success
                       failure:(void (^)(NSError* err))failure;


+ (void) upadteLessonTouchWithOpenID:(NSString*) openudid
                    lessonAndTouch:(NSString*) orgnizedStr
                           success:(void (^)(id response))success
                           failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma  用户关于课程的计费和统计数据
//////////////////////////////////////////////////////////////
+ (void) getLessonRightForAccount:account
                         LessonID:(NSString*) lessonID
                          success:(void (^)(id response))success
                          failure:(void (^)(NSError* err))failure;


+ (void)  updateLessonRightForAccount:account
                             LessonID:(NSString*) lessonID
                            StartDate:(NSDate *)startDate
                              EndDate:(NSDate *)endDate
                              success:(void (^)(id response))success
                              failure:(void (^)(NSError* err))failure;

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
                              Recommend:  (NSString *) recommend
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
#pragma  标签相关
//////////////////////////////////////////////////////////////
+ (void)getTagListForDomainID:(NSString*) domainID
                   DomainType:(NSString*) type
                 TagString:(NSString*) tagString
                     Count:(NSInteger) count
                   success:(void (^)(id response))success
                   failure:(void (^)(NSError* err))failure;

+ (void) albumListDataForDomainID:(NSString*) domainID
                       DomainType:(NSString*) type
                lessonConcentType:(NSString*) contentType
                       PageNumber:(NSInteger) pageNumber
                        Recommend:(NSString*) recommend
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


+ (void) getWordListby:(NSString *) word
               success:(void (^)(id response))success
               failure:(void (^)(NSError* err))failure;

//////////////////////////////////////////////////////////////
#pragma   供应商相关
//////////////////////////////////////////////////////////////

+ (void) getAppDataforBounldeID:(NSString *) boundleID
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

@end

