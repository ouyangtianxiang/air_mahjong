---- GameConstant.lua
-- Date: 2013-09-11
-- Last modification : 2013-09-11
-- Description: scmahjong game constants and definition

require("MahjongPlatform/PlatformConfig");

GameConstant = {};

GameConstant.CreateGuestInfoMapListKey = "CreateGuestInfoMapListKey";

--平台类设置平台
GameConstant.platformType = PlatformConfig.platformTrunk; -- 具体定义在 PlatformConfig 中的 平台定义

GameConstant.Version = "5.3.7";  --版本号
GameConstant.resVer  = "1.4.2"; -- 资源版本号 (4.0.0以后用1.3.0) (1.2.1预装版)  (1.2.0主版本)  --引擎升级后资源版本 号为1.4.1

--if GameConstant.platformType == PlatformConfig.platformGuangDianTong then
--    GameConstant.resVer = "1.3.1"; -- 资源版本号
--elseif GameConstant.platformType == PlatformConfig.platformTrunkPre then
--  GameConstant.resVer = "1.2.1"; -- 资源版本号
--else
--  -- 资源版本号
--  if GameConstant.Version <= "3.4.7" then
--    GameConstant.resVer = "1.2.0";
--  elseif
--      GameConstant.resVer = "1.3.0";
--  end
--end

--
-- 单机使用的变量begin
GameConstant.isSingleGame = false;
GameConstant.isSingleGameBackToHall = false;
GameConstant.myMid = 0;
GameConstant.midChanged = false;
GameConstant.singleToOnline = false;
GameConstant.singleBankruptTime = 600;
GameConstant.noPopEvaluate = true   --单机不弹评价
GameConstant.needEvaluate = false

--评价弹出的概率
GameConstant.trumptp = 20 --破产弹出概率
GameConstant.outp = 10    --正常牌局概率

-- 是否是MiUi系统
GameConstant.isMiUiSystem = true;

-- 新手教程快速标记
GameConstant.teachRoomQuickStart = false;

-- 单机使用的变量end
GameConstant.isNeedReconnectGame = false; -- 游戏切换到后台事件过久的重连事件

GameConstant.api = "273694720"     --默认主版本
GameConstant.appName = ""; -- 包名称
GameConstant.hasWechatPackage = false; -- 是否包含微信的包
GameConstant.isWechatInstalled = true; -- 检查微信是否安装
GameConstant.isQQInstalled = true; --检查是否安装QQ
GameConstant.propLimit = 0; -- 使用道具的限制金额

-- 是否显示游戏玩家活动
GameConstant.isShowMobileGamer = false;
--当前是否在报名界面
GameConstant.isInApplyWindow = false;
-- 活动强推请求是否订阅
GameConstant.isPushRequestRss = false;

GameConstant.oppoNBaoRate = 100; -- n宝兑换率，100 n宝 == 1 rmb

--更高场次拉取
GameConstant.gameTipOdds = 0.3; --提示概率(0-1之间的数)
GameConstant.gameTipCount = 10; -- 防打扰场次

GameConstant.isMessagePopupFlag = true;
GameConstant.shareMessage = {}

GameConstant.toVipTag = false; --从别处直接进入商城VIP标签的事件
GameConstant.curGameSceneRef = nil; -- 当前显示的游戏场景引用
GameConstant.isInRoom = false; -- 是否在房间内中

GameConstant.curMaxMusic = 0; -- 当前的最大音乐音量
GameConstant.curMaxVoiceEffect = 0; -- 当前最大的音效音量

GameConstant.needShowTip = 0;--是否要显示提示 0 要 1 不用

GameConstant.chatMaxCharNum = 60; -- 聊天最长字符数

--加番相关 --
GameConstant.out_card_first = false; -- 仅供测试使用的参数，标志发完牌进行打牌
GameConstant.addFanPai = ""; --加番标志


GameConstant.isNeedShowFirstCharge = 0; -- 弹出新手指引时，是否显示首冲,0不显示,1显示
GameConstant.isBackToHallActivitely = false; -- 返回大厅标记
GameConstant.FreshmanFlag = false;     -- 新手
GameConstant.showFreshmanFirstCharge = 0; -- 新手第一次返回大厅显示首冲

--登录时候需要传的参数
GameConstant.sitemid = nil;
GameConstant.token = nil;
GameConstant.name = nil;
GameConstant.isLogin = kNoLogin;
GameConstant.isBidBoyaaLogin = kNotBoyaaBide;
GameConstant.isDisplayView = false;

GameConstant.saveBid = nil;--博雅通行证相关

GameConstant.picIconUrl = nil; -- 头像图片下载url
GameConstant.isAdult = -2;

-- 进入大厅的哪个页面
GameConstant.HallViewType = nil;

GameConstant.higherInviteRefuse = false;
GameConstant.playedCountAtferRefuse = 0;  --拒绝高场次邀请后的游戏计数

GameConstant.bankruptMoney = 1000;  --破产金额限度

GameConstant.curRoomLevel = 0;
GameConstant.boxRoomFlag = false;
GameConstant.matchId = "";
GameConstant.matchType = 0;
GameConstant.timeMatchFlag = 0;
GameConstant.matchName = "";
GameConstant.traceMatchFlag = 0;



GameConstant.wantToPlayGame = false; -- 想去玩游戏
GameConstant.wantToLookHelp = false; -- 想去看帮助

--好友信息相关
GameConstant.m_leftOnlineIcon = {};
GameConstant.oneFriendList = {};
GameConstant.level = {};
GameConstant.isLevelProductFlag = false;

GameConstant.isInvited = false;
GameConstant.traceFlag = false;
--邀请时间   数据格式 {mid={time=}}
GameConstant.inviteTime = {};
--添加好友时间 数据格式 {mid ={time=}}
GameConstant.addTime = {};

--更新相关
GameConstant.update_control = kNotToUpdate;
GameConstant.loginPopList = {};  -- 登陆时弹窗列表

--标识是否成功下载但还在游戏中 true-->成功下载在游戏中  false-->未在游戏中
GameConstant.updateFinishButInGame  = false;
GameConstant.isUpdating = false;

GameConstant.playType = 0x1F;--7 = 0111(1为支持该玩法),第0位为定缺玩法,第1位为血流玩法,第2位为换3张玩法,每个版本上了新的玩法要添加.

GameConstant.isTest = false;

GameConstant.soundDownload = 0; --声音是否可用: 0 不可 1 可
GameConstant.faceIsCanUse = 1; --表情是否可用
GameConstant.resdownload = 0; --资源是否下载完成了
GameConstant.appid = "";
GameConstant.appkey = "";
GameConstant.isSdCard = 0;
GameConstant.model_name = "guess";

GameConstant.simType =2; -- 1 "移动" 2 "联通" 3 "电信" ;

GameConstant.imei = 0; -- 不知道用来干嘛的
GameConstant.imei2 = 0; -- 设备号
GameConstant.imsi = ""; -- imsi用于设置下单限制，支付限额，唯一标识手机卡
GameConstant.rat = "";   --分辨率
GameConstant.phone = ""; --手机号
GameConstant.net = "";   --联网方式
GameConstant.macAddress = "";  --联网mac地址
GameConstant.osv = "";  --操作系统
GameConstant.simnum = ""; --sim序列号

GameConstant.Two_Mahjong_Type = 1;
GameConstant.SC_Mahjong_Type = 3;
GameConstant.SC_Match_Mahjong_Type = 15;

GameConstant.HallIp = nil;
GameConstant.HallPort = nil;

GameConstant.contestHallIp = "192.168.103.20";
GameConstant.contestHallPort = 4441;


GameConstant.CommonUrl = ""; -- 当前使用的域名
GameConstant.needToLogin = true;
GameConstant.isFirst = true;

GameConstant.contestLevel = 51;

GameConstant.tablePlayerNum = {};  -- 场次人数

GameConstant.GeTuiClientId = nil; -- 个推ClientId
GameConstant.outCardTimeLists = {3, 5, 7, 10}; -- 创建房间时的出牌限时选择
GameConstant.privateDiZhuList = {}; -- 低注（从网络拉取）
GameConstant.privateLFPDiZhuList = {}; -- (两房牌)低注（从网络拉取）

GameConstant.MahjongTypeNormal = 0x0;  ---普通玩法
GameConstant.MahjongTypeDingQue = 0x1; --定缺
GameConstant.MahjongTypeXueLiu = 0x2;  --血流
GameConstant.MahjongTypeHuanShanZhang = 0x4;--换三张=======
GameConstant.MahjongTypeLiangFangPai  = 0x10;--两房牌=======

GameConstant.TIAN_HU_SC = 0x1;             --天胡
GameConstant.DI_HU_SC = 0x02;                --地胡
GameConstant.QING_LONG_QI_DUI_SC = 0x03;     --清龙七对
GameConstant.LONG_QI_DUI_SC = 0x04;          --龙七对
GameConstant.QING_QI_DUI_SC = 0x05;          --清七对
GameConstant.QING_YAO_JIU_SC = 0x06;         --清幺九
GameConstant.QING_DUI_SC = 0x07;             --清对
GameConstant.JIANG_DUI_SC = 0x08;            --将对
GameConstant.QING_YI_SE_SC = 0x09;           --清一色
GameConstant.DAI_YAO_JIU_SC = 0x0A;          --带幺九
GameConstant.QI_DUI_SC = 0x0B;               --七对
GameConstant.DUI_DUI_HU_SC = 0x0C;           --对对胡
GameConstant.PING_HU_SC = 0x0D;              --平胡
GameConstant.QIANG_GANG_HU = 0x11;           --抢杠胡
GameConstant.GANG_SHANG_PAO = 0x12;          --杠上炮
GameConstant.GANG_SHANG_HUA = 0x13;          --杠上花
GameConstant.GEN = 0x14;                     --跟
GameConstant.GANG = 0x15;                    --杠
GameConstant.JGD = 0x16;                     --金钩吊
GameConstant.JZ = 0x17;                      --绝张
GameConstant.HDLY = 0x18;                    --海底捞月

GameConstant.isHotUpdate = true;             --是否启动热更新
GameConstant.inFetionRoom = false;           --启用飞信的相关配置

GameConstant.matchChangeTableFlag = 0;       -- 重新进房间时判断是换桌引起的
GameConstant.matchHuAdvanceFlag = 0;         -- 提前胡标志
GameConstant.continueMatchFlag = 0;          -- 继续报名按钮触发的
GameConstant.matchResultStatus = {};         -- 比赛
GameConstant.matchStatus       = {};

-- 动画表
GameConstant.DaFanAnimMap = {};
GameConstant.DaFanAnimMap[GameConstant.TIAN_HU_SC] = "天胡";
GameConstant.DaFanAnimMap[GameConstant.DI_HU_SC] = "地胡";
GameConstant.DaFanAnimMap[GameConstant.QING_LONG_QI_DUI_SC] = "清龙七对";
GameConstant.DaFanAnimMap[GameConstant.LONG_QI_DUI_SC] = "龙七对";
GameConstant.DaFanAnimMap[GameConstant.QING_QI_DUI_SC] = "清七对";
GameConstant.DaFanAnimMap[GameConstant.QING_YAO_JIU_SC] = "清幺九";
GameConstant.DaFanAnimMap[GameConstant.QING_DUI_SC] = "清对";
GameConstant.DaFanAnimMap[GameConstant.JIANG_DUI_SC] = "将对";

GameConstant.paixingfanshu = {
    [GameConstant.TIAN_HU_SC] = "天胡 6番",
    [GameConstant.DI_HU_SC] = "地胡 6番",
    [GameConstant.QING_LONG_QI_DUI_SC] = "清龙七对 6番",
    [GameConstant.LONG_QI_DUI_SC] = "龙七对 5番",
    [GameConstant.QING_QI_DUI_SC] = "清七对 5番",
    [GameConstant.QING_YAO_JIU_SC] = "清幺九 5番",
    [GameConstant.QING_DUI_SC] = "清对 4番",

    [GameConstant.JIANG_DUI_SC] = "将对 4番",
    [GameConstant.QING_YI_SE_SC] = "清一色 3番",
    [GameConstant.DAI_YAO_JIU_SC] = "带幺九 3番",
    [GameConstant.QI_DUI_SC] = "七对 3番",
    [GameConstant.DUI_DUI_HU_SC] = "对对胡 2番",
    [GameConstant.PING_HU_SC] = "平胡 1番",

    [GameConstant.QIANG_GANG_HU]  = "抢杠胡 1番",
    [GameConstant.GANG_SHANG_PAO] = "杠上炮 1番",
    [GameConstant.GANG_SHANG_HUA] = "杠上花 1番",

    [GameConstant.JGD]  = "金钩吊 1番",
    [GameConstant.JZ]   = "绝张 1番",
    [GameConstant.HDLY] = "海底捞月 1番",
}

--自定义IP,自定义Port，自定义level
GameConstant.customIp = "";
GameConstant.customPort = "";
GameConstant.customLevel = "";
GameConstant.isFirstPopu    = 1;

GameConstant.isDirtPlayGame = false; -- 是否是快速进入房间

GameConstant.propAnimList = {};  --动画列表
GameConstant.propColdDownTime = 0;
GameConstant.isFirstPopu = 1; -- 1表示需要打开，0表示不需要打开
GameConstant.propInterval = 5;  --道具使用间隔

local RoomUserInfoPin_map = require("qnPlist/RoomUserInfoPin")

GameConstant.roomPropMap = {
  [1]  = RoomUserInfoPin_map["egg.png"],
  [2]  = RoomUserInfoPin_map["hand.png"],
  [3]  = RoomUserInfoPin_map["soap.png"],
  [4]  = RoomUserInfoPin_map["kiss.png"],
  [5]  = RoomUserInfoPin_map["tomato.png"],
  [6]  = RoomUserInfoPin_map["beer.png"],
  [7]  = RoomUserInfoPin_map["stone.png"],
  [8]  = RoomUserInfoPin_map["rose.png"],
  [9]  = RoomUserInfoPin_map["flower.png"],
  [10] = RoomUserInfoPin_map["bomb.png"],
};

GameConstant.isDownloading = false; -- 是否正在下载中
-- 资源下载类型
GameConstant.DOWNLOAD_RES_TYPE_ALL  = 0; -- 下载全部
GameConstant.DOWNLOAD_RES_TYPE_SOUND = 2; -- 声音
GameConstant.DOWNLOAD_RES_TYPE_FACE = 1; -- 图片
GameConstant.DOWNLOAD_RES_TYPE_FRIEND_ANIM = 3;  -- 动画
GameConstant.DOWNLOAD_RES_TYPE_MP4 = 5; -- mp4格式动画

GameConstant.uploadHeadIconName = nil; -- 上传头像后，将该值置为非空

GameConstant.smsLimitTime = 30; -- 如果未拉取到配置文件，则默认为30s
GameConstant.isShowLowLevelBtn = true; -- 是否显示进入低级场按钮
GameConstant.isLowLevelClicked = false; -- 点击去低倍场按钮
GameConstant.lowSuitableLevel = -1; -- 默认为-1表示没有合适场次
GameConstant.iscontainstartMedia = "0"; -- 是否启动界面包含mp4视频

GameConstant.isDisplayBroadcast = 0;-- 1代表显示 0代表隐藏  (跑马灯玩家所发喇叭内容)

--全局的是否需要二次确认框，是否需要取消按钮，是否需要兑换
GameConstant.checkType = kCheckStatusClose or 0; -- 0表示不审核，1表示是审核
GameConstant.backCheckType = kCheckStatusClose or 0;
GameConstant.isShowAwardView = 0; -- 是否显示奖励推送

GameConstant.iosPingBiFee = true;--默认屏蔽状态
GameConstant.iosMorePay = false;--默认屏蔽支付

GameConstant.changeNickTimes = {}; -- 用户改名次数
GameConstant.changeNickTimes.vipTimes = 0;
GameConstant.changeNickTimes.cardsNum = 0;--改名卡
GameConstant.changeNickTimes.bqknum   = 0;--补签卡
GameConstant.changeNickTimes.rednum   = 0;--红包
GameConstant.changeNickTimes.propnum  = 0;--喇叭
--GameConstant.changeNickTimes.rednum      = 0

GameConstant.isRoomTopNewsLinkType = -1; -- 房间内置顶消息跳转

GameConstant.rankListItemNameLimit = 18

--此变量用来区分是不是启动游戏后 第一次进入大厅
--是，则要展示闪屏界面淡出动画
GameConstant.isFirstRun = true --

GameConstant.displayScoreMatchLimit = 0  --比赛场次列表里面 是否显示积分赛的限额
GameConstant.shouldPopBankruptWin   = 0  --是否弹积分赛窗口--
GameConstant.gotoScoreMatch   = 0
--此变量用来区分进房间是否是被好友邀请的，被好友邀请 房间登录要走1001
                                        --其他走0x119
GameConstant.isInvitedByFriendInHall = false -- 在大厅被好友邀请了

GameConstant.switchAnimIsOpen = 1 --关闭动画特效

--是否已经发送过更多游戏的php
--GameConstant.isSendPhpMoreGames = false;

----房间内麻将四方缩放比例
GameConstant.leftMahjongScale    = 1--0.9
GameConstant.rightMahjongScale   = 1--0.9
GameConstant.topMahjongScale     = 1--0.95
GameConstant.bottomMahjongScale  = 1.0
GameConstant.discardMahjongScale = 1--0.88

GameConstant.chatTime            = nil
GameConstant.matchTypeConfig = {playerNum = 1, award = 2, playTime = 3};--比赛类型 1:人满赛 2:大奖赛（旧定时赛） 3:新定时赛
GameConstant.shareConfig = {exchange = 1, game = 2, friendMatch = 3, hongbao = 4, certificate = 5};

GameConstant.roomReconnectTimeoutId = 1001;-- 设置一个timeout, 到期时如果是在房间则重连要重连 NativeManager
GameConstant.exitGameTimeoutId = 1002; --设置一个timeout,当其到达时关闭程序 NativeManager

GameConstant.NewUserLoginRegTime = "0"

GameConstant.fm_money_type = {coin = 0, diamond = 1}--0是金币，1是钻石  --好友对战的金币类型
GameConstant.mall_money_type = {coin = 0, diamond = 1}--0是金币，1是钻石  --商品的金币类型
GameConstant.exchange_money_type = {coin = 1, diamond = 2}--1是金币，2是钻石  商城兑换的金币类型
GameConstant.sc_money_type = {coin = 100, diamond = 101}--自定义的moneytype方便转化上面两个moneytype 0是金币，1是钻石  商城兑换的金币类型
--ios 是iphone:1还是ipad:2
GameConstant.iosDeviceType = 0;
GameConstant.devjailbreak = 0;
GameConstant.factoryid = "";
GameConstant.feedBackExtraString = "";
--GameConstant.matchStatus.matchStage : = 1:报名阶段 2:预赛阶段 3:淘汰赛阶段 4:决赛阶段 5:比赛结束 8:定时赛预赛阶段 9:定时赛预赛结束排名阶段
GameConstant.match_stage = {
    baoming = 1,
    yusai = 2,
    taotai = 3,
    juesai = 4,
    match_end = 5,
    dingshisai_yusai = 8,
    dingshisai_yusai_end = 9,
}

GameConstant.k_per_day_open = "per_day_open"--文件名字 ：文件保存的名字，关于每天的记录都可以放在这个文件里，区分不同key
GameConstant.k_per_day_xz = "per_day_xz"--文件保存的名字，关于每天的记录
GameConstant.k_per_day_xl = "per_day_xl"--文件保存的名字，关于每天的记录
GameConstant.k_per_day_xz_n = "per_day_xz_n"--文件保存的名字，关于每天的记录
GameConstant.k_per_day_xl_n = "per_day_xl_n"--文件保存的名字，关于每天的记录
GameConstant.k_per_day_gift = "per_day_gift"--文件保存的名字，关于每天的记录

GameConstant.friendBattle_InGameExit = true;--好友对战中途是否可以退出

GameConstant.level_tuiJianProduct = {};  --init
GameConstant.vip_tuiJianProduct = {};

GameConstant.isReconnectGame = false;
GameConstant.lastLoginType = 0; 
GameConstant.useLastPayType = 0                  --上次支付开关0表示不开，1表示开启

--统一的view level 后续修改所有的显示level在這里
GameConstant.view_level = {
    CertificateWindow = 30000, 
    bankrupt = 30001,
    max = 9999999,
};
 
--二级界面 标识tag
GameConstant.view_tag = {
    hall = 1,    --大厅界面
    hall_more = 2,--更多界面
    userinfo = 3, --个人信息界面
    message = 4, --消息界面
    help = 5,   --帮助界面
    exchange = 6,--兑换界面
    mall = 7,    --商城界面
    friend = 8,  --好友界面
    activity = 9,--活动界面
    task = 10,  --奖励界面
    rank = 11,   --排行榜界面
    xz = 12, --血战
    xl = 13, --血流
    match_list = 14,--比赛列表界面
    match_apply = 15, --比赛报名界面
    rules = 16, --用户条款，服务条款
    game = 17, --游戏场
};

