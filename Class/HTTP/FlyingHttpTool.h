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
#import "shareDefine.h"
#import "FlyingUserData.h"
#import "FlyingPubLessonData.h"
#import "FlyingCommentData.h"
#import "FlyingGroupUpdateData.h"
#import "FlyingAppData.h"
#import "FlyingUserRightData.h"

@interface FlyingHttpTool : NSObject

//////////////////////////////////////////////////////////////////////////////////
#pragma  登录问题
//////////////////////////////////////////////////////////////////////////////////

+(void) loginRongCloud;

//////////////////////////////////////////////////////////////////////////////////
#pragma 个人账户昵称头像
//////////////////////////////////////////////////////////////////////////////////
//获取个人信息(通用版本)
+(void) getUserInfoByopenID:(NSString *) openID
                 completion:(void (^)(FlyingUserData *userData,RCUserInfo *userInfo)) completion;

//获取个人信息(融云版本)
+(void) getUserInfoByRongID:(NSString *) rongID
                 completion:(void (^)(FlyingUserData *userData,RCUserInfo *userInfo)) completion;

//上传用户头像图片
+ (void) requestUploadPotraitWithOpenID:openID
                                      data:imageData
                                Completion:(void (^)(BOOL result)) completion;

//获取某个作者的终端ID
+(void)  getOpenIDForUserID:(NSString*) userID
           Completion:(void (^)(NSString* openUDID)) completion;
//////////////////////////////////////////////////////////////
#pragma  社群相关
//////////////////////////////////////////////////////////////
//获取所有群组
+ (void)  getAllGroupsForDomainID:(NSString*) domainID
                       DomainType:(NSString*) type
                     PageNumber:(NSInteger) pageNumber
                     Completion:(void (^)(NSArray *groupUpdateList,NSInteger allRecordCount)) completion;

//获取我的群组
+ (void) getMyGroupsForPageNumber:(NSInteger) pageNumber
                       Completion:(void (^)(NSArray *groupUpdateList,NSInteger allRecordCount)) completion;

//根据id获取单个群组
+ (void) getGroupByID:(NSString *) groupID
    successCompletion:(void (^)(FlyingGroupUpdateData*updata)) completion;

//加入聊天群组
+ (void) joinGroupForAccount:(NSString*) account
                      GroupID:(NSString*) groupID
                  Completion:(void (^)(FlyingUserRightData *userRightData)) completion;

//退出聊天群组
+ (void)quitGroupForAccount:(NSString*) account
                    GroupID:(NSString*) groupID
                   complete:(void (^)(BOOL))result;

//获取用户在群的信息
+ (void) checkGroupMemberInfoForAccount:(NSString*) account
                                GroupID:(NSString*) groupID
                             Completion:(void (^)(FlyingUserRightData *userRightData)) completion;

//获取群组成员的信息
+ (void) getMemberListForGroupID:(NSString*) groupID
                      Completion:(void (^)(NSArray *memberList,NSInteger allRecordCount)) completion;
//////////////////////////////////////////////////////////////
#pragma  用户注册、登录、激活相关
//////////////////////////////////////////////////////////////
+ (void) regOpenUDID:(NSString*) openUDID
                  Completion:(void (^)(BOOL result)) completion;

+ (void) verifyOpenUDID:(NSString*) openUDID
                  Completion:(void (^)(BOOL result)) completion;

+ (void) updateCurrentID:(NSString*) currentID
            withUserName:(NSString*) userName
                     pwd:(NSString*) password
              Completion:(void (^)(BOOL result)) completion;

+(void) loginWebsiteWithQR:(NSString*)loginID;

+(void) boundTerminalWithQR:(NSString*)boundID
                 Completion:(void (^)(BOOL result)) completion;

//////////////////////////////////////////////////////////////
#pragma  会员相关
//////////////////////////////////////////////////////////////
+ (void) getMembershipForAccount:(NSString*) account
                      Completion:(void (^)(FlyingUserRightData *userRightData)) completion;

+ (void) updateMembershipForAccount:(NSString*) account
                          StartDate:(NSDate *)startDate
                          EndDate:(NSDate *)endDate
                      Completion:(void (^)(BOOL result)) completion;

//////////////////////////////////////////////////////////////
#pragma  金币相关
//////////////////////////////////////////////////////////////

+(void) getMoneyDataWithOpenID:(NSString*) openudid
                    Completion:(void (^)(BOOL result)) completion;

//向服务器保存金币信息
+(void) uploadMoneyDataWithOpenID:(NSString*) openudid
                       Completion:(void (^)(BOOL result)) completion;

+(void) getQRDataForUserID:(NSString*) openudid
                    Completion:(void (^)(BOOL result)) completion;

+(void) chargingCrad:(NSString*) cardID
           WithOpenID:(NSString*) openudid
           Completion:(void (^)(BOOL result)) completion;

//////////////////////////////////////////////////////////////
#pragma  用户关于课程的计费和统计数据
//////////////////////////////////////////////////////////////
+ (void) getLessonRightForAccount:(NSString*) account
                         LessonID:(NSString*) lessonID
                      Completion:(void (^)(FlyingUserRightData *userRightData)) completion;

+ (void) updateLessonRightForAccount:(NSString*) account
                            LessonID:(NSString*) lessonID
                          StartDate:(NSDate *)startDate
                            EndDate:(NSDate *)endDate
                         Completion:(void (^)(BOOL result)) completion;


//向服务器获课程统计数据
+(void) getStatisticDetailWithOpenID:(NSString*) openudid
                                 Completion:(void (^)(BOOL result)) completion;

+(void) uploadStatisticDetailWithOpenID:(NSString*) openudid
                                    Completion:(void (^)(BOOL result)) completion;

//////////////////////////////////////////////////////////////
#pragma  内容相关
//////////////////////////////////////////////////////////////
+ (void) getAlbumListForDomainID:(NSString*) domainID
                      DomainType:(NSString*) type
                     ContentType:(NSString*) contentType
                      PageNumber:(NSInteger) pageNumber
                       Recommend:(NSString*) recommend
                      Completion:(void (^)(NSArray *albumList,NSInteger allRecordCount)) completion;

+ (void) getLessonListForDomainID:(NSString*) domainID
                       DomainType:(NSString*) type
                       PageNumber:(NSInteger) pageNumber
                lessonConcentType:(NSString *) contentType
                     DownloadType:(NSString *) downloadType
                              Tag:(NSString *) tag
                        Recommend:(NSString *) recommend
                       Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion;

+ (void) getCoverListForDomainID:(NSString*) domainID
                      DomainType:(NSString*) type
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
+ (void)getTagListForDomainID:(NSString*) domainID
                   DomainType:(NSString*) type
                 TagString:(NSString*) tagString
                     Count:(NSInteger) count
                Completion:(void (^)(NSArray *tagList)) completion;

//////////////////////////////////////////////////////////////
#pragma  字典相关
//////////////////////////////////////////////////////////////
+ (void) getItemsforWord:(NSString *) word
             Completion:(void (^)(NSArray *itemList,NSInteger allRecordCount)) completion;

+ (void) getWordListby:(NSString *) word
              Completion:(void (^)(NSArray *wordList,NSInteger allRecordCount)) completion;

//////////////////////////////////////////////////////////////
#pragma  供应商（作者）相关
//////////////////////////////////////////////////////////////

+ (void) getAppDataforBounldeID:(NSString *) boundleID
                     Completion:(void (^)(FlyingAppData *appData)) completion;


@end
