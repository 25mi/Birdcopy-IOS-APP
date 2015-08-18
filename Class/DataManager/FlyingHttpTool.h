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

#define FLYINGHTTPTOOL [FlyingHttpTool shareInstance]

@interface FlyingHttpTool : NSObject


@property (nonatomic,strong) NSMutableArray *allFriends;
@property (nonatomic,strong) NSMutableArray *allGroups;

+ (FlyingHttpTool*)shareInstance;

//查看是否好友
-(void) isMyFriendWithUserInfo:(FlyingUserInfo *)userInfo
                    completion:(void(^)(BOOL isFriend)) completion;


//获取我的群组
-(void) getMyGroupsWithBlock:(void(^)(NSMutableArray* result)) block;

//获取群组列表
- (void) getAllGroupsWithCompletion:(void(^)(NSMutableArray *result)) completion;

//根据id获取单个群组
-(void) getGroupByID:(NSString *) groupID
   successCompletion:(void (^)(RCGroup *group)) completion;

//加入群组
-(void) joinGroup:(int) groupID
         complete:(void (^)(BOOL result))joinResult;

//退出群组
-(void) quitGroup:(int) groupID
         complete:(void (^)(BOOL result))quitResult;

//更新群组信息
-(void)updateGroupById:(int) groupID
         withGroupName:(NSString*)groupName
          andintroduce:(NSString*)introduce
              complete:(void (^)(BOOL result))result;
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


//获取个人信息(通用版本)
+(void) getUserInfoByopenID:(NSString *) openID
                 completion:(void (^)(RCUserInfo *user)) completion;

//获取个人信息(融云版本)
+(void) getUserInfoByRongID:(NSString *) rongID
                 completion:(void (^)(RCUserInfo *user)) completion;

+ (void) getCoverListWithSuccessCompletion:(void (^)(NSArray *LessonList,NSInteger allRecordCount)) completion;

+ (void) getCoverListByTagURLForPageNumber:(NSInteger) pageNumber
                             SortbyTime:  (BOOL) time
                             Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion;

+ (void) getLessonForLessonID:(NSString*) lessonID
                   Completion:(void (^)(FlyingPubLessonData *lesson)) completion;


+ (void) getLessonForISBN:(NSString*) ISBN
               Completion:(void (^)(FlyingPubLessonData *lesson)) completion;

+ (void) getAlbumListForContentType:(NSString*) contentType
                         PageNumber:(NSInteger) pageNumber
                          Recommend:(BOOL) isRecommend
                         Completion:(void (^)(NSArray *albumList,NSInteger allRecordCount)) completion;


+ (void) getLessonListByTagForPageNumber:(NSInteger) pageNumber
                       lessonConcentType:  (NSString *) contentType
                            DownloadType:  (NSString *) downloadType
                                     Tag:  (NSString *) tag
                              SortbyTime:  (BOOL) time
                               Recommend:(BOOL) isRecommend
                              Completion:(void (^)(NSArray *lessonList,NSInteger allRecordCount)) completion;

+ (void) getItemsforWord:(NSString *) word
             Completion:(void (^)(NSArray *itemList,NSInteger allRecordCount)) completion;

+ (void) getProviderListForlatitude:(NSString*)latitude
                           longitude:(NSString*)longitude
                          PageNumber:(NSInteger) pageNumber
                          Completion:(void (^)(NSArray *providerList,NSInteger allRecordCount)) completion;


@end
