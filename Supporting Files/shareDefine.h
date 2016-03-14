//
//  shareDefine.h
//  FlyingEnglish
//
//  Created by vincent sung on 1/16/13.
//  Copyright (c) 2013 vincent sung. All rights reserved.
//

#ifndef FlyingEnglish_shareDefine_h
#define FlyingEnglish_shareDefine_h

typedef enum BESearchType
{
    BEFindLesson,
    BEFindWord,
    BEFindGroup,
    BEFindPeople
} BESearchType;


//获取资源类型
typedef enum BC_Domain_Type
{
    BC_Business_Domain,
    BC_Group_Domain,
    BC_Author_Domain,
} BC_Domain_Type;

//APP相关
#define KAPP_Birdcopy_APPID         @"KAPP_Birdcopy_APPID"
#define KAPP_Domain_ID              @"KAPP_Domain_ID"

#define KAPP_SERVER_ADDRESS         @"KAPP_SERVER_ADDRESS"
#define KAPP_Weixin_ID              @"KAPP_Weixin_ID"
#define KAPP_RongCloud_Key          @"KAPP_RongCloud_Key"

#define SERVER_DOMAIN               @"http://e.birdcopy.com"

//产品用户相关
#define KAPI_BusinessID_KEY         @"app_id"

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
#define KBEFIRSTLAUNCH            @"KBEFIRSTLAUNCH"

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


//IM相关

#define kRongCloudDeviceToken     @"kRongCloudDeviceToken"

#define kUserName                 @"kUserName"
#define kUserPassWord             @"kUserPassWord"

#define kUserNickName             @"kUserNickName"
#define kUserPortraitUri          @"kUserPortraitUri"
#define kUserAbstract             @"kUserAbstract"

//同步任务相关
#define KShouldSysMembership      @"KShouldSysMembership"
#define KEverLaunchedRecord       @"KEverLaunchedRecord"

//会员相关
#define KMembershipStartTime      @"KMembershipStartTime"
#define KMembershipEndTime        @"KMembershipEndTime"

//UI
#define kNavigationBackColor      @"kNavigationBackColor"
#define kNavigationTextColor      @"kNavigationTextColor"

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

#define KBaseDatdbaseFilename     @"mydic.db"
#define KUserDatdbaseFilename     @"myuser.db"
#define KUSerDataFoldName         @"MyData"

#define K_BEID_MD5_DIGEST_LENGTH  1024    /* digest length in bytes */

#define kWebCommand_Play_Vedio    @"BE_Local_Play_Vedio"
#define kM3U8_NotFound            @"BE_M3U8_NotFound"


#define PlayWebIcon               @"webpage"
#define PlayDocIcon               @"Document"
#define PlayVideoIcon             @"PlayVideo"
#define PlayAudioIcon             @"PlayAudio"

#define KPriceIDstr               @"金币"

#define KBELesssonIDFlag          @"ffa_ld="
#define KBELesssonIDFlag1         @"comment_id="
#define KBELesssonIDFlag2         @"_lnviewlnid="

#define KBELoginFlag              @"_loginsenid="
#define KBERQloginOK              @"KBERQloginOK"

//服务机构相关
#define KLessonOwnerTempKind      @"t"
#define KLessonOwnerPersonKind    @"0"
#define KLessonOwnerCompanyKind   @"1"

//群组相关
#define KGroupMemberNoexisted     @"noexisted"
#define KGroupMemberVerified      @"1"
#define KGroupMemberReviewing     @"0"
#define KGroupMemberRefused       @"4"

#define kGroupMemberCount         2000



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
#define kShareBaseDir             @"shareBase"

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

//下载相关
#define NSOffState   0
#define NSOnState    1
#define NSMixedState 2

#define KDownloadTypeNormal       @"mp4"
#define KDownloadTypeM3U8         @"m3u8"
#define KDownloadTypeMagnet       @"magnet"

#define KUserDownloadsDir         @"Downloads"

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

#define KNumberOFPIE               3
#define KLoginNickName            @"nickname"

#define KCounts_Average_Screen_Subtitle 30 //
#define KCounts_Gridview_IPHONE  6  //
#define KCounts_Gridview_IPHONE5 8  //
#define KCounts_Gridview_PAD    12  //

#define KMAXCountsLoading       16  //

#define kLessonIPhoneSize         CGSizeMake(140, 110)
#define kLessonIPADSize           CGSizeMake(230, 175)

#define kIPhoneCollectionWidth     140
#define kIPADCollectionWidth       230

#define kLessonAbstractIPADLenth   60
#define kLessonAbstractPhoneLenth  48

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
#define KLargeFontSize   (INTERFACE_IS_PAD ? 32.0f : 16.0f)
#define KNormalFontSize  (INTERFACE_IS_PAD ? 26.0f : 13.0f)
#define KLittleFontSize  (INTERFACE_IS_PAD ? 24.0f : 12.0f)
#define KSmallFontSize   (INTERFACE_IS_PAD ? 20.0f : 10.0f)

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





