--[[
	fileName    	     :  GameDefine.lua
	Description  	     :  scmahjong game config constants and definition
	last-modified-date   :  Dec.13 2013
	create-time 	     :  Sep.11 2013
	last-modified-author :  ClarkWu
	create-author        :  JkinLiu
]]
--系统常量
kFontTextBold 			= "<b>"; -- 加粗
kFontTextItalic 		= "<i>"; -- 斜体
kFontTextUnderLine 		= "<u>"; -- 下划线
kFontTextDeleteLine 	= "<s>"; -- 中划线

--语言选择
kSichuanese             = 1;   --四川话
kMandarin               = 2;   --普通话

--****************************************************登录相关常量设定**********************************************************************************--
--博雅通行证从Java传给lua的值
kBoyaaBid 				=	"bid";
kBoyaaEmail				= 	"email";
kBoyaaPhone				=	"phone";
kBoyaaDevideType 		=	"deviceType";
kBoyaaSig				=	"sig";
kBoyaaAvatar 			=	"avatar";
kBoyaaCity 				=	"city";
kBoyaaCode 				=	"code";
kBoyaaCountry 			=	"country";
kBoyaaGender 			=	"gender";
kBoyaaProvince			= 	"province";

kDingkaiCoin			=   "dingkaiCoin";
kSubmitPay 				=  	"SubmitPay";
kNotBoyaaBide 			= 	0;
kIsBoyaaBide 			= 	1;
--博雅通行证游客登录从Java传给lua的值
kBoyaaGuest 			=	"guest";
--博雅通行证保存在Map.xml文件中的值
kBoyaaLoginBid 			= 	"boyaaLoginBid";
kBoyaaLoginNick 		= 	"boyaaLoginNick";
kBoyaaLoginSid 			= 	"boyaaLoginSid";

kLocalToken 			= 	"localtoken";     ----php返回的token
kLocalSDKToken          =   "localSDKToken"   ----sdk返回的token or openId
kLocalSDKOpenId         =   "localSdkOpenId"

--华为登录从Java传给lua的值
kHuaWeiNickName 		= 	"nickName";
kHuaweiToken 			= 	"token";
kHuaweiOpenId 			= 	"openId";
kHuaweiType 			= 	"huawei_type";
kHuaweiBid 				= 	"huawei_bid";
kHuaweiAvator			= 	"huawei_avator";
kHuaweiGener 			= 	"huawei_gener";

--新浪登录从Java传给lua的值
kSinaSitemid			= 	"sitemid";
kSinaSessionKey 		= 	"session_key";

--登录需要传的公共参数
kLoginName				=	"name";
kLoginSid 				= 	"sitemid";
kLoginStyle 			= 	"loginStyle";
kToken 					= 	"access_token";

--360登录从Java返回的参数
k360Appid				= 	"appid";
k360Appkey 				= 	"appkey";
k360AppSecret 			= 	"appsecret";
k360Authocode			= 	"authocode";
k360Accesscode          =   "access_token";
--360登录从官网PHP拉取Token Get参数
k360ClientId 			= 	"&client_id=";
k360ClientSecret 		=	"&client_secret=";
k360ClientScope			= 	"&scope=basic";

--QQ登录从Java返回
kQQOpenId 				= 	"openid";
kQQToken 				= 	"access_token";

--微信登录从java返回
kWeChatId 				= 	"code";

--统一登录方法、统一注册方法、统一登出方法、统一切换用户方法、统一充值方法、统一快捷支付方法
--统一显示精灵、统一隐藏精灵方法、统一检查登录方法、统一离开方法
kLoginPlatform  		= "loginPlatform";
kRegistPlatform  		= "registPlatform";
kLogoutPlatform  		= "logoutPlatform";
kSwitchPlatform  		= "switchPlatform";
kPayPlatform  	 		= "payPlatform";
kQuickPayPlatform  		= "quickPayPlatform";
kShowSpritePlatform 	= "showSpritePlatform";
kHideSpritePlatform 	= "hideSpritePlatform";
kCheckLoginPlatform 	= "checkLoginPlatform";
kExitPlatform 			= "exitPlatform";
kExit 					= "Exit";
kPayForWebPay 			= "payForWebPay";

kPayForMM 				= "payForMM";
kPayForUnicom 			= "payForUnicom";
kPayForNormal 			= "payForNormal";
kPayForTele 			= "payForTele";
kPayForZhiFuBao 		= "payForZhiFuBao";
kPayForYinLian 			= "payForYinLian";
kPayForCreditCard 		= "payForCreditCard"; 
kPayForDingkaiQuick 	= "payForDingkaiQuick";
kPayForDingkaiExchange  = "payForDingkaiExchange";

kHotUpdate				= "hotUpdate";	       --热更新
kCallPay 				= "pay";		       --支付调用Java函数
kGetAllPhoneNumbers     = "getAllPhoneNumbers" --获取所有手机记录

-- 联运框架
kMutiLogin				= "MutiLogin"
kMutiLogout				= "MutiLogout"
kMutiPay				= "MutiPay"
kMutiShare				= "MutiShare"
kMutiShowSprite			= "MutiShowSprite"
kMutiHideSprite			= "MutiHideSprite"
kMutiViewMore			= "MutiViewMore"
kMutiExit				= "MutiExit"

--联想登录
kLenovoLoginConfig = {
	
};

-- 新浪登陆
kSinaLoginConfig = {
	sina_AppKey					= "733944639",
	--sina_AppSecret			= "e925f6547744d90f9212749f7b6c70e4",
	--sina_PayId 				= "YOUR_PAY_ID";
	sinaDefaultLoginSID 		= "1995728583",
	sinaDefaultLoginSessionKey  = "MJSINAWBTOKEN:2.00hKsDLC0lWYfn5931d95064XJNTbD"
}

-- QQ登陆
kQQLoginConfig = {
	qqDefaultLoginOpenId = "17DF0D029ACBD6C50AAF8CA729920A77",
	qqDefaultLoginToken  = "D797494B1865E99FD3B6FDA66D37BF3D"
}

-- 微信登陆
kWeChatLoginConfig = {
	wechatDefaultLoginOpenId = "oZMBPtwRMVVo0kiwXhvTS0GDFYDc",
	wechatDefaultLoginToken  = "OezXcEiiBSKSxW0eoylIeLsqFZQelvf3GDQYou8pGj7kiusbONjNvO29GcerwGDrBCs8xh8wHM7hgODRUd2VxcB49wMCuaULZLOmbZ2BURPRDKKntwU3aNwoU-xAdhdUAOnZyH2ohUzfu0ZGLIXpjA"
}

--飞信登陆
kFetionLoginConfig = {
	fetionDefaultLoginToken  = "630dac8cde0270d15e7c1d96f1c1d5dc"
}
--游客登陆
kGuestLoginConfig = {
	guestDefaultImei = "AF3B5CECA7C8A95A43438FF35F3CA50B",
	guestDefaultName = "guest_F3B"
}

kFetionGetFriendList = "fetionGetFriendList";
kFetionUploadHeadicon= "fetionUploadHeadicon";

--博雅登陆
kBoyaaLoginConfig = { 
	boyaaType 		    	= "",
	boyaaDefaultAvatar  	= "http:\/\/usspuc01.static.17c.cn\/icon\/app\/avatar\/10.jpg",
	boyaaDefaultBid 		= "119259",
	boyaaDefaultCity 		= "深圳",
	boyaaDefaultCode 		= "200",
	boyaaDefaultCountry 	= "中国",
	boyaaDefaultDeviceType  = "PHONE",
	boyaaDefaultEmail 		= "",
	boyaaDefaultGender 		= "1",
	boyaaDefaultImei 		= "869323001662119",
	boyaaDefaultName 		= "MI-ONE",
	boyaaDefaultPhone 		= "13725585126",
	boyaaDefaultProvince 	= "广东",
	boyaaDefaultSig 		= "364543edb76ee9687df4df3303c9b84d"
}

--手机登陆
kCellphoneLoginConfig = { 
	cellphoneType 		    	= "",
}

--华为登录
kHuaweiLoginConfig = {
	huaweiDefaultNick   = "008613725585126";
	huaweiDefaultToken  = "BFMFvJpRJWj9KSQ83kIZI600C7CdxQKGZ8249Hln3Fspjh1mMZQ=";
	huaweiDefaultOpenId = "HUAWEI_" .. "900086000020136295";
	huaweiDefaultType   = 0;
	huaweiDefaultBid    = "101055";
	huaweiDefaultAvator = "";
	huaweiDefaultGener  = 0;
}

--奇虎360登录
kQihuLoginConfig = {
	guestDefaultImei = "AF3B5CECA7C8A95A43438FF35F3CA50B",
	guestDefaultName = "guest_F3B"
};

-- 91登录
k91LoginConfig = {
	guestDefaultImei = "AF3B5CECA7C8A95A43438FF35F3CA50B",
	guestDefaultName = "guest_F3B"
};

-- 搜狗登录
kSouGouLoginConfig = {
	userId = "8417934",
	sessionKey = "73361b12f3d3394d081db390c6a26f85d3f3fd682ce33655931c35b7dc454b97"
}

--百度多酷登录
kBaiduLoginConfig = {
	kTimeStemp = "2014-04-22_17:42:56",
	kUid = "80598839",
	kSid = "3F869E40D59E32C4F2F8FEB5A4EFF0E5",
	kNickName = "test",
	kValidation = "9486d610c437f5fa8c74055f606174e5",
}

--鼎开的登录数据
kDingkaiLoginConfig = {
	dingkai_id = "1",
}

--豌豆荚的信息
kWandouLoginConfig = {
	
}

kNoLogin 	  	= 0;
kAlreadyLogin 	= 1;

kLastLoginType 	= "lastLoginType";
kMap 			= "constantValue";
kFriendRequestBlack  = "RejectFriendBlackList";--拒绝再接受此人的好友请求

--登录房间错误loginError的错误码定义
kERROR_KICK_OTHER_USER  	= 2;  -- 踢出异地登录帐号
kERROR_USERKEY 				= 3;  -- mtk值重复
kERROR_MYSQL  				= 4;  -- 服务器访问mysql出错
kERROR_TABLE_NOT_EXIST  	= 5;  -- 桌子不存在
kERROR_USER_NOT_LOGIN_TABLE = 6;  -- 无法正常登录桌子
kERROR_TABLE_MAX_COUNT 		= 7;  -- 桌子已满
kERROR_NO_EMPTY_SEAT 		= 8;  -- 桌子已满
kERROR_NOT_ENOUCH_MONEY 	= 9;  -- 钱不够
kERROR_UNKNOWN 				= 10; -- 未知
kERROR_NO_THIS_MAHJONG_TYPE = 11; -- 服务器未知麻将类型
kERROR_MTKEY				= 12; -- mtk出错
kERROR_MATCH_ROOM_NOT_EXIST = 13; -- 比赛桌不存在
kERROR_SAME_IP 				= 14; -- 相同IP不能进入同一个房间
kERROR_TOO_MANY_MONEY 		= 15; -- 钱太多
kERROR_FCM 					= 16; -- 防沉迷
kERROR_ROOM_VIP_LIMIT       = 26   --vip准入限制

--****************************************************好友相关常量设定************************************************************************************--
--请求好友列表后PHP返回界面响应字符串
kFriendRequestByPHP 			=	"onRequestFriends";
--请求好友详细列表后PHP返回界面响应字符串
kFriendDetailByPHP 				=	"onGetFriendDetail";
--请求好友在线列表后Socket返回界面响应字符串
kFriendOnlinesBySocket 			=	"isOnlineState";
--请求好友不在线列表后Socket返回界面响应字符串
kFriendNotOnlineSocket  		= 	"NotOnlineState";
--请求删除好友后PHP返回界面响应字符串
kFriendDeleteByPHP 				= 	"deleteFriendReceive";
--请求添加好友成功Socket返回界面响应字符串
kFriendAddSuccessBySocket 		= "addFriendSuccess";
--请求所有在线好友信息Socket返回界面响应字符串
kFriendAllOnlineFriendsBySocket = "requestAllOnline";
--读取好友消息数量PHP返回界面响应字符串
kRequestFriendNoticeNumByPHP 	= "onRequestFriendNoticeNum";
--追踪好友请求PHP返回界面
kTrackFriendByPHP				= "onTrackFriend";
--查找好友
kFriendSearchByPHP 				= "onSearchFriendById";
--收到好友消息
kFriendRecvMsgBySockect 		= "onFriendMsgRecvMsg"
--收到发送状态消息
kFriendRecvSendStateBySockect 	= "onFriendMsgRecvSendStateBySockect"

--收到好友动态
kFriendNewsRequestByPHP			= "onRequestFriendNews"
--收到的好友动态数量
kFriendNewsNumRequestByPHP		= "onRequestFriendNewsNum"
--修改好友备注
kFriendModifyAliasRequestByPHP	= "onModifyFriendAlias" 
--赠送金币
kFriendGiveRequestByPHP 		= "onGive" 
--面对面加好友:进入频道
kFriendFace2FaceEnterChanel 		= "onFace2FaceEnterChanel" 
--面对面加好友:离开频道
kFriendFace2FaceLeaveChanel 		= "onFace2FaceLeaveChanel" 
--面对面加好友:频道加好友
kFriendFace2FaceAddFriend 		= "onFace2FaceAddFriend" 
--面对面加好友:有人加你为好友的通知消息
kFriendFace2FaceNoticeAddFriend 		= "onFace2FaceNoticeAddFriend" 


--定义好友对应的命令字命令
kAddPassiveFriendCmd 	= "addPasiveFriend";
kAddFriendSocketCmd 	= "addSocketFriend";
kDeleteFriendCmd 	    = "deleteFriend";
kInviteFriendCmd 	 	= "inviteFriend";
kTrackFriendCmd 		= "trackFriend";
kDeleteFriendCmd        = "deleteFriend"; 
kOnlineFriendCmd  		= "onlineFriend";
kShowFriendCmd          = "showFriend";
kDeleteFriendNoticeCmd  = "deleteFriendNotice";
kInvitingFriendInRoom 	= "roomInviting";
kInvitingFriendInHall 	= "friendDataControlled";
kInvitingResultNoLine 	= "changeColor";

kFriendComeBySocket 	= "onFriendOnLine"
kFriendGoneBySocket 	= "onFriendOutLine"
kFriendMoneyUpdateByPHP = "onUdateFreindMoney"

kFriendDetailInfoByPHP  = "onFriendDetailInfo"

--好友需要读取的PHP的值
kNum 					= "num";
kAllNum 				= "allnum";
kIsOnline 				= "isOnline";

--好友的一些默认值
kJuStr 					= "局";

--好友最大限制
kMaxFriendNum 			=	50;
--加好友临时返回值
kFriendAddReturn 		=	-100;

--*************************************************蜘蛛相关数据常量设定***********************************************************************************--

kLoginSpider 			=	"LoginSpider";
kOpenSpider 			=	"OpenSpider";
kOpenSpiderUserInfo 	=	"OpenSpiderUserInfo";

--**************************************************防沉迷参数设定*****************************************************************************************--
kFangchenmiYear			= 	1900;
--map.xml文件中保存的值
kIsAdultVerify 			= 	"isAdultVerify";
--**************************************************支付相关参数设定***************************************************************************************--
--订单给PHP get的字段
kOrderProductId 		=	"&id=";
kOrderSiteMid 			= 	"&sitemid=";
kOrderPayMode 			= 	"&pmode=";

--支付类型参数设定
kPChips 				= 	"PCHIPS";
kPCoins 				= 	"PCOINS";
kBuyCoin 				=	"BuyCoin";
-- 获取发货请求所需的签名
kGetSig 				= 	"GetSig"; 

kUmengUpdate  			=  "umengUpdate";

kMobileSmsPay			=  1; 	-- 移动支付
kUnicomSmsPay 			=  2; 	-- 联通支付
kTelecomSmsPay			=  3;	-- 电信支付
kThirdPay 				=  0;	-- 第三方支付

--**************************************************帮助界面参数设定***************************************************************************************--
--获取历史提问PHP参数设定
kHelpViewParam 			= {
							appid 	 = "4005",
    						fcontact = "1.0",
    						ftype 	 = 1,
    						game 	 = "mjsc"
						};
--反馈url
kFeedbackURL 			= "http://feedback.kx88.net/api/api.php";--"http://feedback.boyaagame.com/api/api.php"--
--上传历史提问信息PHP参数设置
kHelpViewPHPSendingView ={
							appid 	 = "4005",
    						ftitle 	 = "feedback content",
    						ftype 	 = 1,
    						game 	 = "mjsc"
						};
--上传历史提问图片给Java的参数设定
kHelpToJavaImg 		 	= {
							method 	= "Feedback.mSendFeedBackPicture",
							appid 	= "4005",
							game 	= "mjsc",
							pfile 	= "myScreenshot.png",
							iName 	= "myScreenshot",
							ftype 	= 2
						};

--上传反馈头像定义
kUploadFeedBackImage 	= "myScreenshot";
kSuccess 				= "success";
--上传图片类型
kUpdatePicType 			=  1;
kUpLoadImage 			= "UpLoadImage";
kUploadFeed 			= "UpLoadFeed";

--**************************************************活动相关常量设定***************************************************************************************--

kHall					= "lobby";    --大厅
kTask 					= "task";  --任务
kStore 					= "store";   --商场
kFeedback 				= "feedback";  --反馈
kRank 					= "rank";      --排行榜
kFriend 				= "friend";    --好友
kInfo 					= "info";      --用户信息
kSign 					= "sign";      --签到
kBypass 				= "bypass";    --博雅登陆
kGame 					= "game";	   --开始游戏
kBox 					= "box";	   --包箱
kQuickBuy 				= "quickbuy"   --快速购买
kPropStore  			= "propstore"  --兑换
kActivityGoFunction 	= "ActivityGoFunction";  -- 活动跳转回调
kBuy					= "recharge" ;  --充值
kRoom					= "room"	;	--房间（包括快速开始，包厢）
kBuyCoinsForActivityMM	= "buyCoinsForActivityMM"; -- 直接弹出MM支付
kCreateBattle           = "createRoom"-----好友比赛创建房间

--**************************************************更新相关常量设定***************************************************************************************--
kIsForceUpdate 			= 1;
kIsNormalUpdate 		= 0 ;
kNotToUpdate 			= -1;

kUpdateVersion 			= "updateVersion";
kUpdateSuccess 			= "UpdateSuccess";
kGameStart 				= "GameStart";
kGameOver 				= "GameOver";
kUpdate 				= "Update";
kUpdating 				= "Updating";
kRemoveUpdate 			= "RemoveUpdate";

--**************************************************个推相关常量设定***************************************************************************************--
kGeTuiGetClientId		= "MutiGetuiCid";
kGeTuiGetMessage 		= "GetuiPayLoad";
kGeTuiCell 				= "GeTuiCell";

--**************************************************初始化参数设定*****************************************************************************************--
KGetQuDaoValue 			= "GetQuDaoValue";
kDownloadRes			= "DownloadRes";
ksubString  			= "subString";
kgameCloseIMM           = "gameCloseIMM";
kurlEncode 				= "urlEncode";
kCloseLoadingProe 		= "closeStartScreen";
kOpenStartScreen        = "openStartScreen"
kShowpopupwindow  		= "Showpopupwindow";
kReportFaultInfo  		= "ReportFaultInfo";
kStartActivty 			= "StartActivty";

-- 按照字节长度剪切字符串
kcutStringByByte  		= "cutStringByByte";
kcutStringByByte_str  	= "cutStringByByte_str";
kcutStringByByte_len 	= "cutStringByByte_len";

kgetInitValue  			= "getInitValue";

kDelayBtn 				= "DelayBtn";
kCloseDelyBtn 			= "CloseDelyBtn";
kGetPhoneNetIp  		= "GetPhoneNetIp"; 
kGetPhoneMachineId  	= "GetPhoneMachineId"; 
kBindUid 				= "BindUid";

kLoadSoundRes 			= "LoadSoundRes";

kDownLoadImages 		= "DownLoadImages";
kDownloadImageOne 		= "DownLoadImage";
kIsFileExist 			= "isFileExist";
kIsResDownloaded		= "isResDownloaded";
kFriendAnimExist		= "friendAnimExist";
kLocalWebview  			= "localWebview"
kShowMemory  			= "showMemory"
kshowJavaLocalTime      = "javaLocalTime";   --获取JAVA的本地时间

kSelectImage 			= "SelectImage";

kDeleteImageByName 		= "DeleteImageByName";
kPlayBGMusic			= "PlayBGMusic";
kStopBGMusic			= "StopBGMusic";
kOpenTutorialPopup 		= "OpenTutorialPopup";
kChooseServer 			= "ChooseServer";
kShowSprite 			= "ShowSprite";

kShowEditText 			= "ShowEditText";

kExchangeTime 			= "ExchangeTime";

kNetSwitch 				= "NetSwitch";

kIsNeedTeach 			= "kIsNeedTeach";
kCleanData 				= "CleanData";
kGetDownloadPackageStatus = "getDownloadPackageStatus"
kDownloadPackage        = "downloadPackage"
kInstallPackage         = "installPackage"
kOpenPackage            = "openPackage"
kGetMarketNum           = "getMarketNum"
kCreateQr               = "createQr"
kGetSupportPayConfig    = "native_getSupportPayConfig"   --获得支付支持配置
kStartRecordVoice       = "native_startRecordVoice"      --开始录音
kStopRecordVoice        = "native_stopRecordVoice"       --结束录音
kStartPlayVoice         = "native_startPlayVoice"        --开始播放录音
kStopPlayVoice          = "native_stopPlayVoice"         --结束播放录音

kRequireMobileGamer		= "requireMobileGamer"; -- 请求游戏玩家游戏界面
kSubscribeForMobileGamer = "subscribeForMobileGamer"; -- 游戏玩家活动购买商品
kMobileGamerSubCallBack = "mobileGamerSubCallBack"; -- 游戏玩家订阅回调

kCheckStatusOpen 		= 1; --审核
kCheckStatusClose 		= 0; -- 不审核
--**************************************************其他常量设定*******************************************************************************************--
--屏幕定义
kScreenWidth 			=  800;
kScreenHeight 			=  480;

--Socket值定义
kSocketEvent 			=  "SocketEvent";

--空字符串定义
kNullStringStr			=	"";
--0字符串定义
kNumStrZero				=	"0";
---1字符串定义
kNumStrMinusOne 		= 	"-1";

--数字定义
kNumZero 				= 	0;
kNumOne 				= 	1;
kNumTwo 				=   2;
kNUmThree 				= 	3;
kNumFour 				=   4;
kNumFive 				= 	5;
kNumSix 				= 	6;
kNumSeven 				= 	7;
kNumEight 				= 	8;
kNumNine 				= 	9;
kNumTen 				= 	10;
kNumEleven 				= 	11;
kNumTwelve 				= 	12;
kNumThirteen 			= 	13;
kNumFourteen 			= 	14;
kNumFifteen 			= 	15;
kNumSixteen 			= 	16;
kNumSeventeen 			=	17;
kNumEighteen 			= 	18;
kNumMinusOne 			=	-1;
kNumMinusTwo 			=	-2;
kNumMinusThree 			= 	-3;
kNumMinusFour 			= 	-4;
kNumMinusHundred 		= 	-100;
kNumSixty 			 	= 	60;
kNumHundred 			= 	100;
kNumThousand			=	1000;
kNumMillion 			= 	10000;
kNumOneHourSecond		= 	3600;
kPercent 				= 	"%";
kPoint 					=	".";

--大厅数据获取参数字符串定义
kLevel 					= 	"level";
kDq 					= 	"dq";
kXlch 					= 	"xlch";
kHsz 					= 	"hsz";

--读取Php需要读取的常量定义
kStatus 				= 	"status";
kMsg 					= 	"msg";
kIsAdult 				= 	"isAdult";
kSavedBid 				= 	"savedBid";
kGuestBided				= 	"guestBound";
kParamData 				= 	"param_data";
kMid 					= 	"mid";

--反馈时PHP读取的常量定义
kFid 					= 	"fid";
--反馈标题
kMsgId 					= 	"id"
kMsgTitle 				= 	"msgtitle";
kRptTitle 				= 	"rptitle";
kVotescore				=	"votescore"
kReaded 				=	"readed"

--人名长度截取
kMaxNameLength 			= 	24;
--默认图片后缀名
kPicStr 				= 	".png";

-- 性别常量
kSexMan 				= 	0;
kSexWomen 				= 	1;
kSexUnknow 				= 	2;

-- 座位编号
kSeatMine 				= 	0;
kSeatRight 				= 	1;
kSeatTop 				= 	2;
kSeatLeft 				= 	3;

-- 麻将每个人的手牌最大数
kMahjongMaxNum 			= 	13;

-- 麻将类型
kWanMahjongType 		= 	0;
kTongMahjongType 		= 	1;
kTiaoMahjongType 		= 	2;

-- 卡片Id
kHuanSanZhangCardId 	= 	1;
kXueLiuChengHeCardId 	= 	7;
kQianDaoCardId 			= 	1;

-- 持久化数据Dict的名字
kHallConfigDict 		 = "kHallConfigDict"
kHallConfigDictKey_Value = {
	HallConfig = "HallConfig",
	HallConfigTime = "HallConfigTime4_4_0",--为了不与老版本冲突
	HallBoxDiZhuInfo = "HallBoxDiZhuInfo" 
};

--持久化比赛场数据
kMatchConfigDict        = "kMatchConfigDict";
kMatchConfigDictKey_Value = {
    HallMatchSpaceConfig = "HallMatchSpaceConfig",
    HallMatchConfigTime = "HallMatchTime4_4_0",--为了不与老版本冲突
};

kFMRConfigDict  = "kFMRConfigDict"
-- kTaskInfoDict 		= "kTaskInfoDict"
-- kTaskInfoDictKey_Value = 
-- {

-- }

kSystemConfigDict 			= 	"kSystemConfigDict"
kSystemConfigDictKey_Value  = {
	HostConfig  = "HostConfig", -- 主机配置
	HttpDomain  = "HttpDomain",  --域名
	RankTop = "RankTop",
	RankTopAward = "RankTopAward",
	RankCharmAward = "RankCharmAward",	RankMoney = "RankMoney",
	RankWin = "RankWins",
	RankCharm = "RankCharm",
	FastDomain  = "FastDomain",  -- 请求返回最快的域名
	LocalSocketType  = "LocalSocketType",  -- 服务器类型
	signInfoData = "signInfoData",  --签到展示配置
	signInfoTime = "signInfoTime",   --签到展示时间
	loginConfigTime = "loginConfigTime",  --登录以后配置时间
	gameTipOdds = "gameTipOdds",  --配置高场次拉取几率
	gameTipCount = "gameTipCount"  --配置高场次拉取计数
};

kNotClearDict = "kNotClearDict";
kNotClearDictKey_Value = {
	LoaclDomain = "LoaclDomain",
}


kFriendChatMessageHistory  =  "FriendChatMessageHistory";
kSystemMessageHistory  	   =  "SystemMessageHistory"
kFeedbackRecords           =  "FeedbackRecords"

-----------产量配置--------------------
kDeviceTypeIOS	  	= 1;
kDeviceTypeIPHONE 	= 1;
kDeviceTypeIPAD 	= 2;
kDeviceTypePC		= 3;
kDeviceTypeANDROID  = 4;
kDeviceTypeWIN7 	= 5;

-- 物理方向按键键值配置
KLeftKey 			= "LeftKey";
KRightKey 			= "RightKey";
KUpKey 				= "UpKey";
KDownKey 			= "DownKey";
KCenterKey 			= "CenterKey";

-- 屏幕震动
kScreenShock        = "screenShock";

-- 反馈点击电话号码，拨打电话
kCallPhone			= "callPhone";
kCheckWechatInstalled		= "checkWechatInstalled"; --检查是否安装了微信


------------------------------------------------------飞信相关 ------------------------------------------------------------------
kFetionMessage        = "fetionMessage";       -- 消息邀请
kFetionSMS            = "fetionSMS";           -- 短信邀请
kFetionShareInside  = "fetionShareInside"  -- 分享至好友
kFetionShareOutside = "fetionShareOutside" -- 分享至朋友圈

------------------------------------------------------分享相关 ------------------------------------------------------------------
kScreenShot	  		= "screenShot";	-- 截图请求

kQQShare		= "QQShare"; -- qq分享
kQZoneShare		= "QZoneShare"; --qq空间分享
kYx_FriendShare	= "yxFriendShare"; -- 易信好友分享
kYx_FriendCircleShare = "yxFriendCircleShare";--易信朋友圈分享
kWechatShare		= "wechatShare"; -- 微信分享
kFriendCircleShare	= "friendCircleShare"; -- 朋友圈分享

kShareMessage = "shareOnlyMessage"; -- 分享信息


--------------------------------------背景音乐
kNoticeLoopCallLua = "notifyLoopCallLua"-----lua->java
---邀请进房间
kEnterRoom         = "enterRoom"

-- 分享文字描述
kShareTextContent = {
	[0] = "就是这么爽！",
	[1] = "成就雀神梦！",
	[2] = "好玩根本停不下来！",
	[3] = "轻轻松松胡大牌！",
	[4] = "我的实力逆天了！",
	[5] = "看我一秒当富豪！",
	[6] = "好运来了挡都挡不住！"
};

-------------------------------------------------支付相关-------------------------------------------------------------------------
kSaveLastPay = "saveLastPay";
kSetMiuiSettingWndShowed = "setMiuiSettingWndShowed"; -- 设置今天显示过了设置窗口
kGotoMiuiSmsSettingPage = "gotoMiuiSmsSettingPage"; -- 跳转到miui权限设置窗口


-- 检查用户名称和ID,是否是同一登陆方式下第二次登陆
kcheckLoginTypeAndMid = "checkLoginTypeAndMid";
kSaveCertificateImg = "saveCertificateImg"; -- 奖状截图key

kInitConfig = "initConfig"; -- 初始化配置文件信息
kSetLocalPush = "setLocalPush"; -- 设置本地推送

-- kShowCrossPromotion = "showCrossPromotion";   -- 显示交叉推广悬浮窗
-- kShowExitConfigPromission = "showExitConfigPromission"; -- 显示退出插屏
-- kSetAwardConfigPromission = "setAwardConfigPromission"; -- 设置是否推广奖励
-- kShowAwardView = "showAwardView"; -- 显示奖励界面

kNetCacheFilePrefix = "net_cache_timestamp_"; -- 网络缓存时间戳文件名前缀
kNetCacheFileKeyPrefix = "key_"; -- 字典key前缀
kNetCacheDataFilename = "net_cache";

kyixinAddFriend = "yixinAddFriend"; -- 易信添加好友
kLaunchMarket = "launchMarket"      --跳转应用商店

kIpPorts = "IpPort"--上次登录成功的 ip,port记录
kCDNLocalFile = "CDNLocalFile1"

kDictNameLoginSuccessSaveAccount = "cellphoneLogin_dict"
kDictKeyLoginSuccessSaveAccount = "accout_login_success_save_ac"--字典key值 保存登录成功后的帐号 密码
kDictKeyLoginSuccessSavePwd = "accout_login_success_save_pwd"--字典key值 保存登录成功后的帐号 密码

kDictNameExchange = "exchange_info_dict" -- 兑换信息
kDictKeyExchangePhone = "exchange_info_k_phone"-- 兑换信息 电话
kDictKeyExchangeName = "exchange_info_k_name"-- 兑换信息 姓名
kDictKeyExchangeAddress = "exchange_info_k_address"--- 兑换信息 地址

kDictNameMatchExchange = "exchange_Matchinfo_dict" -- 兑换信息
kDictKeyMatchExchangePhone = "exchange_Matchinfo_k_phone"-- 兑换信息 电话
kDictKeyMatchExchangeName = "exchange_Matchinfo_k_name"-- 兑换信息 姓名
kDictKeyMatchExchangeAddress = "exchange_Matchinfo_k_address"--- 兑换信息 地址

kCopyClipBoard = "copyClipBoard"; -- 拷贝剪切板
kGoToQQOrWechat = "goToQQOrWechat"; -- 去QQ或者微信
kOnlineService = "native_onlineService"  --在线客服
kSavePay = "savePay"                     --保存支付方式

--m_xxreference["D:_Mahjong_SCMahjong_Lua_SCMahjong_Lua_1.6_Resource_scripts_MahjongConstant_GameDefine.lua"]=1;
