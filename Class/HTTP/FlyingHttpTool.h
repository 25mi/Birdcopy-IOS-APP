//
//  FlyingHttpTool.h
//  FlyingEnglish
//
//  Created by vincent on 6/3/15.
//  Copyright (c) 2015 BirdEngish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RCUserInfo.h>
#import <RongIMLib/RCGroup.h>
#import "FlyingUserInfo.h"
#import "FlyingPubLessonData.h"
#import "FlyingCommentData.h"
#import "FlyingGroupData.h"
#import "shareDefine.h"

@interface FlyingHttpTool : NSObject

//查看是否好友
-(void) isMyFriendWithUserInfo:(FlyingUserInfo *)userInfo
                    completion:(void(^)(BOOL isFriend)) completion;


//获取好友列表
-(void) getFriends:(void (^)(NSMutableArray* result))friendList;

//按昵称搜素好友
-(void) searchFriendListByName:(NSString*)name
                      complete:(void (^)(NSMutableArray* result))friendList;
//按邮箱搜素好友
-(void) searchFriendListByEmail:(NSString*)email
                       complete:(void (^)(NSMutableArray* result))friendList;

//请求加好友
-(void) requestFriend:(NSString*) userId
             complete:(void (^)(BOOL result))result;
//处理请求加好友
-(void) processRequestFriend:(NSString*) userId withIsAccess:(BOOL)isAccess
                    complete:(void (^)(BOOL result))result;
//删除好友
-(void) deleteFriend:(NSString*) userId
            complete:(void (^)(BOOL result))result;

//////////////////////////////////////////////////////////////////////////////////
#pragma  登录问题
//////////////////////////////////////////////////////////////////////////////////

+(void) loginRongCloud;
//////////////////////////////////////////////////////////////////////////////////
#pragma 个人账户昵称头像
//////////////////////////////////////////////////////////////////////////////////
//获取个人信息(通用版本)
+(void) getUserInfoByopenID:(NSString *) openID
                 completion:(void (^)(RCUserInfo *user)) completion;

//获取个人信息(融云版本)
+(void) getUserInfoByRongID:(NSString *) rongID
                 completion:(void (^)(RCUserInfo *user)) completion;

//上传用户头像图片
+ (void) requestUploadPotraitWithOpenID:openID
                                      data:imageData
                                Completion:(void (^)(BOOL result)) completion;

//////////////////////////////////////////////////////////////
#pragma  社群相关
//////////////////////////////////////////////////////////////
//获取所有群组
+ (void)  getAllGroupsForDomainID:(NSString*)domainID
                       DomainType:(BC_Domain_Type) type
                     PageNumber:(NSInteger) pageNumber
                     Completion:(void (^)(NSArray *groupList,NSInteger allRecordCount)) completion;

//获取我的群组
+ (void) getMyGroupsForPageNumber:(NSInteger) pageNumber
                       Completion:(void (^)(NSArray *groupList,NSInteger allRecordCount)) completion;

//根据id获取单个群组
+ (void) getGroupByID:(NSString *) groupID
      successCompletion:(void (^)(FlyingGroupData *group)) completion;

//加入聊天群组
+ (void) joinGroupForAccount:(NSString*) account
                        AppID:(NSString*) appID
                      GroupID:(NSString*) groupID
                  Completion:(void (^)(NSString* result)) completion;

//退出聊天群组
+ (void)quitGroupForAccount:(NSString*) account
                      AppID:(NSString*) appID
                    GroupID:(NSString*) groupID
                   complete:(void (^)(BOOL))result;

//获取用户在群的信息
+ (void) checkGroupMemberInfoForAccount:(NSString*) account
                                  AppID:(NSString*) appID
                                GroupID:(NSString*) groupID
                             Completion:(void (^)(NSString* result)) completion;

//////////////////////////////////////////////////////////////
#pragma  用户注册、登录、激活相关
//////////////////////////////////////////////////////////////
+ (void) regOpenUDID:(NSString*) openUDID
                  Completion:(void (^)(BOOL result)) completion;

+ (void) verifyOpenUDID:(NSString*) openUDID
                  AppID:(NSString*) appID
                  Completion:(void (^)(BOOL result)) completion;

+ (void) updateCurrentID:(NSString*) currentID
            withUserName:(NSString*) userName
                     pwd:(NSString*) password
              Completion:(void (^)(BOOL result)) completion;

+(void) loginWebsiteWithQR:(NSString*)loginID;

//////////////////////////////////////////////////////////////
#pragma  会员相关
//////////////////////////////////////////////////////////////
+ (void) getMembershipForAccount:(NSString*) account
                           AppID:(NSString*) appID
                      Completion:(void (^)(NSDate * startDate,NSDate * endDate)) completion;

+ (void) updateMembershipForAccount:(NSString*) account
                           AppID:(NSString*) appID
                          StartDate:(NSDate *)startDate
                          EndDate:(NSDate *)endDate
                      Completion:(void (^)(BOOL result)) completion;
//////////////////////////////////////////////////////////////
#pragma  金币相关
//////////////////////////////////////////////////////////////

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                         AppID:(NSString*) appID
                    Completion:(void (^)(BOOL result)) completion;

//向服务器保存金币信息
+(void) uploadMoneyDataWithOpenID:(NSString*) openudid
                            AppID:(NSString*) appID
                       Completion:(void (^)(BOOL result)) completion;

+(void) getQRDataForUserID:(NSString*) openudid
                     AppID:(NSString*) appID
                    Completion:(void (^)(BOOL result)) completion;

+(void) chargingCrad:(NSString*) cardID
               AppID:(NSString*) appID
           WithOpenID:(NSString*) openudid
           Completion:(void (^)(BOOL result)) completion;

//向服务器获课程统计数据
+(void) getStatisticDetailWithOpenID:(NSString*) openudid
                               AppID:(NSString*) appID
                                 Completion:(void (^)(BOOL result)) completion;

+(void) uploadStatisticDetailWithOpenID:(NSString*) openudid
                                  AppID:(NSString*) appID
                                    Completion:(void (^)(BOOL result)) completion;

//////////////////////////////////////////////////////////////
#pragma  内容相关
//////////////////////////////////////////////////////////////
+ (void) getAlbumListForDomainID:(NSString*)domainID
                      DomainType:(BC_Domain_Type) type
                  ContentType:(NSString*) contentType
                   PageNumber:(NSInteger) pageNumber
                OnlyRecommend:(BOOL)    isOnlyRecommend
                   Completion:(void (^)(NSArray *albumList,NSInteger allRecordCount)) completion;

+ (void) getLessonListForDomainID:(NSString*)domainID
                       DomainType:(BC_Domain_Type) type
                    PageNumber:   (NSInteger) pageNumber
             lessonConcentType:  (NSString *) contentType
                  DownloadType:  (NSString *) downloadType
                           Tag:  (NSString *) tag
                 OnlyRecommend:(BOOL)    isOnlyRecommend
                    Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion;

+ (void) getCoverListForDomainID:(NSString*)domainID
                      DomainType:(BC_Domain_Type) type
                    PageNumber:(NSInteger) pageNumber
                    Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion;

+ (void) getLessonForLessonID:(NSString*) lessonID
                   Completion:(void (^)(FlyingPubLessonData *pubLesson)) completion;

+ (void) getLessonForISBN:(NSString*) ISBN
               Completion:(void (^)(FlyingPubLessonData *lesson)) completion;

//////////////////////////////////////////////////////////////
#pragma  内容的评论相关
//////////////////////////////////////////////////////////////
+ (void) getCommentListForContentID:(NSString*) contentID
                        ContentType:(NSString*) contentType
                         PageNumber:(NSInteger) pageNumber
                         Completion:(void (^)(NSArray *commentList,NSInteger allRecordCount)) completion;

+ (void) updateComment:(FlyingCommentData*) commentData
                         Completion:(void (^)(BOOL result)) completion;


//////////////////////////////////////////////////////////////
#pragma  标签相关
//////////////////////////////////////////////////////////////
+ (void)getTagListForDomainID:(NSString*)domainID
                   DomainType:(BC_Domain_Type) type
                 TagString:(NSString*) tagString
                     Count:(NSInteger) count
                Completion:(void (^)(NSArray *tagList)) completion;

//////////////////////////////////////////////////////////////
#pragma  字典相关
//////////////////////////////////////////////////////////////
+ (void) getItemsforWord:(NSString *) word
             Completion:(void (^)(NSArray *itemList,NSInteger allRecordCount)) completion;

//////////////////////////////////////////////////////////////
#pragma  供应商（作者）相关
//////////////////////////////////////////////////////////////
+ (void) getProviderListForlatitude:(NSString*)latitude
                           longitude:(NSString*)longitude
                          PageNumber:(NSInteger) pageNumber
                          Completion:(void (^)(NSArray *providerList,NSInteger allRecordCount)) completion;


@end
