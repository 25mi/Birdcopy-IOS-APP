//
//  shareDefine.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/16/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#ifndef FlyingEnglish_shareDefine_h
#define FlyingEnglish_shareDefine_h

//搜索资源类型
typedef enum BESearchType
{
    BEFindLesson,
    BEFindWord,
    BEFindGroup,
    BEFindPeople
} BESearchType;

//获取资源类型
#define BC_Domain_Business     @"BC_Domain_Business"
#define BC_Domain_Group        @"BC_Domain_Group"
#define BC_Domain_Author       @"BC_Domain_Author"
#define BC_Domain_Content      @"BC_Domain_Content"

//成员权利状态
#define BC_Member_Noexisted     @"noexisted"
#define BC_Member_Reviewing     @"0"
#define BC_Member_Verified      @"1"
#define BC_Member_Refused       @"4"

#define BC_GroupMember_Count    2000
#define BC_GroupMember_AlertDays    7

#define BC_GroupStream_MaxCount  100

typedef enum BC_NextType
{
    BC_Next_Chatroom,
    BC_Next_Favor,
    BC_Next_Members,
} BC_NextType;


//APP相关
#define APP_SERVER_ENGLISH         @"http://e.birdcopy.com"
#define APP_WEIXINID_BEYOND        @"wx120047123f35e00e"
#define APP_RONGKEY_ENGLISH        @"e5t4ouvptjtsa"

#define KAPI_BusinessID_KEY         @"app_id"

//文件夹以及数据库管理
#define BC_FileName_DicBase       @"mydic.db"
#define BC_FileName_userBase      @"myuser.db"

#define BC_DIR_MyLocalData        @"MyData"
#define BC_DIR_UserData           @"UserData"
#define BC_DIR_Downloads          @"Downloads"
#define BC_DIR_Dictionary         @"Dictionary"
#define BC_DIR_RongCloud          @"RongCloud"

//瀑布布局相关
#define TileHeight_iphone  20
#define TileHeight_ipad    30

//虚拟金币相关
#define KBEFreeTouchCount         200
#define KBEGoldAwardCount         50

#define KBETouchCountNow          @"KBETouchCountNow"
#define KBEMoneyCountNow          @"KBEMoneyCountNow"

#define KKEYCHAINServiceName      @"com.birdcopy.SSKeyService"
#define KOPENUDIDKEY              @"com.birdcopy.openudid"

#define KBEAccountChange          @"KBEAccountChange"

#define KAPPBuyFail               @"KAPPBuyFail"

#define KBELoadingCount           6

//商店UI
#define KLandscapeShopWith        320
#define KLandscapeShopHeight      250

#define KPortraitShopWith         350
#define KPortraitShopHeight       275

//社会化管理
#define kBELoginWeixin_URL        @"weixin://qr/QnWWjkvEjhbxrQ-t9yBQ"
#define kBEAppstore_China_URL     @"https://itunes.apple.com/cn/app/cai-niao-ying-yu/id622328549?mt=8"

#define KBEWeixinAPPID            @"wx6ff0856d58d6e397"
#define KBYWeixinAPPID            @"wx120047123f35e00e"

#define KBDWeixinAPPID            @"wx2eeb16e9571e3c88"

#define KINETWeixinAPPID          @"wx9f8b646d050ff6d2"
#define KFDWeixinAPPID            @"wx73a97518db1cff0f"

// IM管理
#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"

#define KlessonStateChange        @"KlessonStateChange"
#define KNotificationMessage      @"KNotificationMessage"

#define KMAX_GROUPS_VALUE         100

#define KNoticeNewMessage         @"KNoticeNewMessage"
#define KNoticeDetailMessage      @"KNoticeDetailMessage"
#define KNoticeVoiceMessage       @"KNoticeVoiceMessage"
#define KNoticeShockMessage       @"KNoticeShockMessage"

//IM相关
#define kRongCloudDeviceToken     @"kRongCloudDeviceToken"

#define kUserName                 @"kUserName"
#define kUserPassWord             @"kUserPassWord"

//同步任务相关
#define KShouldSysMembership      @"KShouldSysMembership"
#define KEverLaunchedRecord       @"KEverLaunchedRecord"

//UI
#define kNavigationBackColor      @"kNavigationBackColor"
#define kNavigationTextColor      @"kNavigationTextColor"

#define KTabBarHeight             @"KTabBarHeight"

//文件格式和文件名
#define KUserDBResource           @"userModel"
#define KDBType                   @"db"
#define kLessonVedioType          @"mp4"
#define kLessonAudioType          @"mp3"
#define kLessonHtmlType           @"html"
#define kLessonVedioLivingType    @"m3u8"
#define kLessonSubtitleType       @"srt"
#define kLessonCoverType          @"jpg"
#define kLessonProType            @"zip"
#define kLessonRelativeType       @"zip"
#define kLessonUnkownType         @"beunknown"

#define KGiftCountNow             @"giftCountNow"

#define KPNGType                  @"png"
#define KJPGType                  @"jpg"

#define K_BEID_MD5_DIGEST_LENGTH  1024    /* digest length in bytes */

#define kWebCommand_Play_Vedio    @"BE_Local_Play_Vedio"
#define kM3U8_NotFound            @"BE_M3U8_NotFound"


#define PlayWebIcon               @"webpage"
#define PlayDocIcon               @"Document"
#define PlayVideoIcon             @"PlayVideo"
#define PlayAudioIcon             @"PlayAudio"

#define KPriceIDstr               @"金币"

//服务机构相关
#define KLessonOwnerTempKind      @"t"
#define KLessonOwnerPersonKind    @"0"
#define KLessonOwnerCompanyKind   @"1"

//搜索相关
//#define kTagListStr_URL           @"%@/la_get_tag_string_for_hp.action?vc=3&perPageCount=%@&page=%@&ln_tag=%@&ln_owner=%@"
#define kWordListStr_URL          @"%@/la_get_word_string_for_hp.action?word=%@"

#define KEnglishServerAddress     @"http://e.birdcopy.com"

#define KDoctorServerAddress      @"http://d.birdcopy.com"
#define KITServerAddress          @"http://it.birdcopy.com"
#define KFDServerAddress          @"http://fd.birdcopy.com"

#define KUpdateM3U8FileURL        @"la_access_file_from_hp.action"

#define kResource_Title           @"title" //标题(字符串)
#define kResource_Sub             @"cap"   //字幕url
#define kResource_Cover           @"img"   //封面url
#define kResource_Vedio           @"vio"   //视频url
#define kResource_description     @"des"   //描述(字符串)
#define kResource_Duration        @"dur"   //时长(字符串)
#define kResource_Pro             @"pro"   //语音字典(字符串)

#define kResource_Keypoint        @"sp_desc" //相关重点
#define kResource_KeyWord         @"sp_word" //相关单词

#define kResource_Background      @"bmu_doc_url" //相关音乐

#define kResource_Background_filenmae  @"background.mp3"

#define kMd5_Vedio                @"vioh"
#define kMd5_WebURL               @"url1"
#define kMd5_mURL                 @"url2"
#define kMd5_M3U8                 @"url3"

//内容类型
#define KContentTypePageWeb       @"web_pg"
#define KContentTypeVideo         @"video"
#define KContentTypeAudio         @"audio"
#define KContentTypeText          @"docu"
#define KContentTypeEvent         @"event"

//字典相关
#define kShareBaseTempFile        @"tempdic.zip"

#define KBaseDicAllType           @"dic800_all_n"
#define KBaseDicMp3Type           @"dic800_mp3"
#define KBaseDicDefineType        @"dic800_define_n"

#define KLessonDicXMLFile         @"dic_mend_n.xml"

#define KItemDefaultType           9

enum {
    BEText=0,              //文本
    BEImage,               //图片
    BEVedio,               //视频
    BEAudio,               //音频
    BEXHML,                //网页或者XML
    BEUnknown              //未知
};
typedef NSInteger BE_Item_Content_Type;


//扫描服务相关
#define KQRTyepeChargeCard       @"KQRTyepeChargeCard"
#define KQRTyepeWebURL           @"KQRTyepeWebURL"
#define KQRTyepeCode             @"KQRTyepeCode"
#define KQRTypeLogin             @"KQRTypeLogin"
#define KQRTypemagnet            @"KQRTypeMagnet"
#define KQRTypeBound             @"KQRTypeBound"

#define KBELesssonIDFlag          @"ffa_ld="
#define KBELesssonIDFlag1         @"comment_id="
#define KBELesssonIDFlag2         @"_lnviewlnid="

#define KBELoginFlag              @"_loginsenid="
#define KBEboundFlag              @"matrix_tuserurms="

#define KBERQloginOK              @"KBERQloginOK"
#define KBERQBoundsOK             @"KBERQBoundsOK"
#define KBERQloginFail            @"KBERQloginFail"
#define KBERQBoundsFail           @"KBERQBoundsFail"


//下载相关
#define NSOffState   0
#define NSOnState    1
#define NSMixedState 2

#define KDownloadTypeNormal       @"mp4"
#define KDownloadTypeM3U8         @"m3u8"
#define KDownloadTypeMagnet       @"magnet"


#define KlessonStateChange        @"KlessonStateChange"
#define KlessonFinishTask         @"KlessonFinishTask"
#define KGodIsComing             @"KGodIsComing"

//本地文件操作相关
#define KDocumentStateChange      @"KDocumentStateChange"
#define KBELocalCacheClearOK      @"KBELocalCacheClearOK"

//网页跳转到内部相关
#define KBEJumpToLesson          @"KBEJumpToLesson"

//系统播放支持资源文件格式
enum {
    BELocalMp4Vedio=0,           //本地原始视频文件
    BEWebMp4Vedio,               //本地原始视频文件
    
    BELocalM3U8Vedio,            //本地M3U8视频文件
    BEWebM3U8Vedio,              //网络M3U8视频地址
    
    BELocalMp3Audio,             //本地原始视频文件
    BEWebMp3Audio,               //本地原始视频文件

    BEWebSourceURL,              //网络原始视频地址
    
    BELocalOtherVedio,           //本地原始视频文件(非Mp4)
};
typedef NSInteger BE_Vedio_Type;

#define kTracksKey		      @"tracks"
#define kStatusKey		      @"status"
#define kRateKey			  @"rate"
#define kPlayableKey		  @"playable"
#define kCurrentItemKey	      @"currentItem"
#define kTimedMetadataKey	  @"currentItem.timedMetadata"

#define K_Fetauture_Index          1024     /* digest length in bytes */

#define kMargin 8.0



enum {
    BEAISubHideBackgroundStyle=0,      //隐藏背景字幕
    BEAINoAISubStyle,                  //原始效果
};
typedef NSInteger BE_AI_SubStytle;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//隔空传课用，保留
#define kBEDeviceType             @"BEDeviceType"
#define kBEDeviceIsIPhone         @"iphone"
#define kBEDeviceSize             @"BEDeviceSize"
#define kBEDeviceIsFive           @"iphone5"


// 手势方向
typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

// muPDF
enum
{
	// use at most 128M for resource cache
	ResourceCacheMaxSize = 128<<20	// use at most 128M for resource cache
};

//字体
#define KLargeFontSize   (INTERFACE_IS_PAD ? 20.0f : 16.0f)
#define KNormalFontSize  (INTERFACE_IS_PAD ? 18.0f : 13.0f)
#define KLittleFontSize  (INTERFACE_IS_PAD ? 16.0f : 12.0f)
#define KSmallFontSize   (INTERFACE_IS_PAD ? 12.0f : 10.0f)

//加载
#define  kLoadMoreIndicatorTag  7

// 常见系数
#define ZOOM_FACTOR 1.4f
#define RATIO_HeightToWidth 9.0/16.0

#define font_iphone_size 13
#define font_ipad_size   20

#define MARGIN_iphone 8.0
#define MARGIN_ipad 16.0

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

#endif





