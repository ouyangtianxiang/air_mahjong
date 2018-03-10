require("MahjongHttp/MahjongHttpManager")
require("MahjongData/PlayerManager")
require('MahjongData/MahjongCacheData')
function Joins(t, mtkey)
    local str = "K";
    if t == nil or type(t) == "boolean"  or type(t) == "byte" then
        return str;
    elseif type(t) == "number" or type(t) == "string" then
        str = string.format("%sT%s%s", str.."", mtkey, string.gsub(t, "[^a-zA-Z0-9]",""));
    elseif type(t) == "table" then
        for k,v in orderedPairs(t) do
            str = string.format("%s%s=%s", str, tostring(k), Joins(v, mtkey));
        end
    end
    return str;
end

HttpModule = class();


HttpModule.s_event = EventDispatcher.getInstance():getUserEvent();

HttpModule.getInstance = function()
	if not HttpModule.s_instance then
		HttpModule.s_instance = new(HttpModule);
	end
	return HttpModule.s_instance;
end

HttpModule.releaseInstance = function()
	delete(HttpModule.s_instance);
	HttpModule.s_instance = nil;
end

HttpModule.ctor = function(self)
	DebugLog("HttpModule ctor");
	self.testDomain = nil;
	self.httpRequestArray = {};
	self.m_httpManager = new(MahjongHttpManager,HttpModule.s_config, HttpModule.postDataOrganizer,HttpModule.urlOrganizer);
	EventDispatcher.getInstance():register(HttpManager.s_event,self,self.onHttpResponse);

	self:initPreventConcurrent();
end

HttpModule.initPreventConcurrent = function( self )
	self.preventConcurrentParam = {};
	self.preventConcurrentParam.lastCmdCode = -1; -- 上一次请求的命令行
	self.preventConcurrentParam.lastReqTime = -1; -- 上一次请求的时间
end

HttpModule.dtor = function(self)
	DebugLog("HttpModule dtor");
	self.httpRequestArray = {};
	EventDispatcher.getInstance():unregister(HttpManager.s_event,self,self.onHttpResponse);
	delete(self.m_httpManager);
	self.m_httpManager = nil;
end

HttpModule.postDataOrganizer = function(method , data)
	local postStr = "";
	DebugLog("api=" .. json.encode(HttpModule.postParam(method, data)));
	postStr = "api="..publ_urlEncodeLua(json.encode(HttpModule.postParam(method, data)));
	return postStr;
end

HttpModule.postParam = function(method,data)
	local post_data = {};
	--用户Key
	local player = PlayerManager.getInstance():myself();
    -- 下面3个参数用于渠道上报
    post_data.appkey = GameConstant.appkey;
    post_data.appid = GameConstant.appid;
    post_data.old_appid = GameConstant.old_appid;
    post_data.old_appkey = GameConstant.old_appkey;
    post_data.vkey = GameConstant.imei2;

    post_data.mid = data.mid or player.mid;

    post_data.username = "user_"..post_data.mid;
    post_data.time = os.time();
    --post_data.sitemid = SystemGetSitemid();
    post_data.api = tonumber(PlatformFactory.curPlatform.api);

    --新接口需要
    if DEBUGMODE == 1 then
    	if PlatformFactory.curPlatform.curLoginType == -1 then
    		post_data.usertype = tonumber( -1 );
    	else
    		post_data.usertype = tonumber( PlatformFactory.curPlatform.curLoginType or 1);
    	end
    else
    	post_data.usertype = tonumber(PlatformFactory.curPlatform.curLoginType or 1);
    end
    --1:简体 2:繁体
    post_data.langtype = 1;

    post_data.version = GameConstant.Version;
    post_data.mtkey = player.mtkey;

    post_data.sid = tonumber(PlatformFactory.curPlatform.sid); --Android游客:7 sina用户:2 博雅通行证:12 QQ用户:3

    if method and not string.find( method, "#") then
    	post_data.method = method;
    end

    if data then
        post_data.param = data;
    end

    if GameConstant.platformType == PlatformConfig.platform2345 then
    	post_data.ttff = "2345";
    end

    local signature = HttpModule.joins(post_data.mtkey,post_data);
    post_data.sig = string.upper(md5_string(signature));
	return post_data;
end

HttpModule.urlOrganizer = function(url , method , httpType)
	DebugLog("postUrl : "..url);
	if httpType == kHttpGet then
		return url;
	end

	if  string.find(method, "#") then
		local indexs =  string.find( method, "#");
	    local m = "";
	    local p = "";
	    if indexs then
	        m = string.sub(method , 1 , indexs-1);
	        p = string.sub(method , indexs + 1 );
	    end
	    if m ~="" and p ~= "" then
    	 	url = url .. "?m=".. m .. "&p=" .. p;
    	elseif m ~= "" and p == "" then
    		url = url .. "?m=" .. m;
    	elseif m == "" and p ~= "" then
    		url = url .. "?m=" .. p;
    	end
    -- else
    -- 	url=url.."?m="..method;
    end
	return url;
end

HttpModule.joins = function(mtkey,t)
  	return Joins(t,mtkey);
end

HttpModule.addHttpRequest = function(self,command,event)
	if self.httpRequestArray[command] then
		self.httpRequestArray[command].event = event;
		self.httpRequestArray[command].time = os.clock() * 1000;
	else
		self.httpRequestArray[command] = {};
		self.httpRequestArray[command].event = event;
		self.httpRequestArray[command].time = os.clock() * 1000;
	end
end

-------PHP请求调用该函数，参数定义
--command    	需要请求的命令
--subEvent      子事件标示
--data       	请求参数表
HttpModule.execute = function(self, command, data, event, commonUrl)
	if not self:preventConcurrent( command ) then
		log( "preventConcurrent" );
		Loading.hideLoadingAnim();
		return;
	end
	commonUrl = commonUrl or GameConstant.CommonUrl;
	if not commonUrl or not self.m_httpManager:checkCommand(command) then
		return false;
	end
	self:addHttpRequest(command,event);
	self:saveHttpRequestArray(command , "totalNum");
	mahjongPrint(data , "httpPostData");
    DebugLog("HttpModule.execute fuckkkkkkkkkkkkkkkkk");
	local httpRequestID = self.m_httpManager:execute(command,data,commonUrl);
	return true;
end

-- self.preventConcurrentParam.lastCmdCode = -1; -- 上一次请求的命令行
-- self.preventConcurrentParam.lastReqTime = -1; -- 上一次请求的时间
HttpModule.preventConcurrent = function( self, command )
	log( "preventConcurrent = "..command );
	if command == self.preventConcurrentParam.lastCmdCode and command ~= 59 then
		local now = os.clock();
		local delta = now - self.preventConcurrentParam.lastReqTime;
		log( "delta = "..delta );

		self.preventConcurrentParam.lastCmdCode = command;

		if delta > 0 and delta < 1 then
			return false;
		else
			self.preventConcurrentParam.lastReqTime = os.clock();
			return true;
		end
	end
	self.preventConcurrentParam.lastCmdCode = command;
	self.preventConcurrentParam.lastReqTime = os.clock();
	return true;
end

HttpModule.onHttpResponse = function(self, httpRequestID, command, errorCode, data, jsonData)
	local errMsg = nil;
	local httpMethod = HttpModule.s_config[command][2] or "";
	if errorCode == HttpErrorType.NETWORKERROR then
		errMsg = GameString.get("netWorkError") or "";
	elseif errorCode == HttpErrorType.TIMEOUT then
		errMsg = GameString.get("netWorkTimeout") or "";
	elseif errorCode == HttpErrorType.JSONERROR then
		errMsg = GameString.get("netWorkJsonError") or "";
	end
	local flag = nil;
	if HttpModule.s_cmds.requsetCanLogin == command then
		if errorCode == HttpErrorType.JSONERROR then
			flag = true;
		end
	end
	if jsonData then
		DebugLog("command : "..command.."   Receive PHPUrl:"..HttpModule.s_config[command][HttpConfigContants.URL]);
		DebugLog("jsonData : "..jsonData);
		mahjongPrint(data , "jsonData");
	else
		DebugLog("Receive PHPUrl:"..HttpModule.s_config[command][HttpConfigContants.URL].."\n RET : nil");
	end
	if not self.httpRequestArray[command] then
		return;
	end

	if command ~= 1 then
		if data then
			self:saveHttpRequestArray(command , "successNum");
			if data.status and data.status ~= nil then
				local status = data.status
				if tonumber(status) == 0 then
					flag = false;
					if data.msg then
						errMsg = data.msg
					end
				end
			elseif data.flag and data.flag ~= nil then
				flag = data.flag
			else
				flag = false;
				if data.msg then
					errMsg = data.msg
				end
			end

			if data.msg and data.msg then
				if data.msg == "不要这么急啦!" then
					Loading.hideLoadingAnim();
				end
			end
		end
	end

	if flag or errMsg == nil then
		self:calculateHttpTime( command );
	end

	EventDispatcher.getInstance():dispatch(self.httpRequestArray[command].event, command, flag or errMsg == nil, errMsg or data,jsonData);
end

function HttpModule.saveHttpRequestArray( self , cmd , str )
	if 1 ~= DEBUGMODE then
		return;
	end
	if self.httpRequestArray[cmd] then
		DebugLog("cmd : "..cmd.."  str : "..str);
		local num = MahjongCacheData_getDictKey_IntValue("httpDic" , str.."_"..cmd , 0);
		num = num + 1;
		DebugLog("num : "..num);
		MahjongCacheData_setDictKey_IntValue("httpDic" , str.."_"..cmd , num , true);
	end
end

function HttpModule.calculateHttpTime( self , cmd )
	if not cmd or not kOpenReportSocket then
		return;
	end
	if self.httpRequestArray[cmd] and reportPHPDataTable then
		local tmp = {};
		tmp.dataType = HttpModule.s_config[cmd][2];
		tmp.time = os.clock() * 1000 - (self.httpRequestArray[command].time or 0);
		table.insert(reportPHPDataTable , tmp);
	end
end

HttpModule.s_cmds =
{
	requestLogin = 1, -- 登录
	requestPrivateDiZhuList = 5, -- 获取创建房间时的低注列表项
	requestMyItemList = 6, -- 获取我的道具列表
	requestTaskList = 7, -- 获取任务信息
	requestTaskReward = 8, -- 领奖
	requestRankReward = 11, -- 请求排行榜领奖
	requestHallIpPort = 13, -- 获取端口和ip
	requestBaseConfigXML = 14, 	--拉取基础配置xml
	requestBestFanXing = 15, 	--拉取最佳番型
	requestVersionInfo = 18, -- 更新
	requestNoticeInfo = 19, -- 公告
	requestExchangeList = 21, -- 获取兑换列表
	requestNetHost = 22, -- 请求网络网址
	requestUpdateHost = 23, -- 请求更新域名
	requestExchange = 24,
	requsetCanLogin = 25,  -- 用作测试域名
	requsetSendFeedback = 26, --反馈
	requsetFeedbackList = 27, --获取反馈列表
	requsetBestGameInfo = 28,  --最佳番型
	requsetUploadUserInfo = 29, --上传用户信息
	requestFriendList = 30, --得到好友列表
	requestDetailFriendInform = 31,--获得好友详细列表
	requestFriendNotice = 32,--获取好友消息
	requestFriendNoticeNum = 33,--获取好友消息数
	deleteFriendNotice = 34, --删除好友消息
	getBankraptcyRemedy = 36,  --申请破产补助
	getBankraptcyConfig = 37,  --获取破产配置
	downloadRes = 39,
	getUserInfo = 42,  --与PHP核对用户信息
	requestDetailSignInfo = 43,
	requestSign = 44, --
	getFirstRechargeGift = 47, -- 首充奖励
	requestAvoidWallow = 48,  --防沉迷请求
	createOrder = 50,--获得产品订单号
	getTaskNnum = 51, -- 获取完成的任务数量
	getActivityNnum = 52, -- 活动数量
	getProductProxy = 54, -- 获取产品列表
	refresh360Token = 55, --360刷新
	getUserVipInfo = 56, --用户VIP信息获取
	getVipData = 57, --VIP展示信息获取
	uploadGeTuiCid = 58,--上传个推Id
	getRankList = 59,  --新排行榜获取信息
	getApiHost = 60, --得到统一支付的url地址
	requireLoginConfig = 63,  --得到登录以后一些常规配置

	reportOrder = 64, --支付场景上报
	updateReport = 65, -- 更新时通知服务器
	updateReward = 66, -- 更新领奖

	newBankruptcy = 67,--新破产接口(获取时间)
	newBankruptcyGet = 68, --新破产接口(领取补助)
	getTuiJianProduct = 69, --获取推荐商品
	taskEnforcepush = 70, -- 活动强推
	orderPreCheck = 71, -- 检查订单接口

	getRoomActivityInfo = 72,  --获取房间内活动是否开启信息
	getRoomActivityDetail = 73,  --获取房间内活动具体信息
	getRoomActivityAward = 74, --房间内活动领奖
	requestContestRank = 75, -- 获取比赛排行榜数据
	hotUpdate = 76,
	likeIt 		= 77, --好友点赞
	giveMoney 	= 78, --赠送好友金币
	requestFriendNews = 79, --好友动态
	searchFriendById  = 80,--获得好友详细列表

	getRoomPropList = 81,  --获取房间可使用道具列表
	getMoney 		= 82,
	requestFriendNewsNum = 83,
	requestModifyFriendAlias = 84,
	huafubaoLimit = 85, -- 话付宝裸码
	requestFirstChargeData = 86, --请求首充数据
	requestFirstChargeAward = 87, --请求首充奖励
	--微信登录相关的HTTP请求 begin
	requestRefressAccessToken 	= 88, --刷新accessToken
	requestAccessToken 			= 89, --获取accessToken
	--微信登录相关的HTTP请求 end
	requestActivityUrl 			= 91, -- 请求活动地址
	requestPayConfig 			= 92, --获取支付配置信息
	-- 移动基地
	requestIsShowMobileGamer	= 93, -- 请求移动基地游戏玩家是否显示
	requestIsSubscribeMobileGamer = 94, -- 请求查看是否订阅了移动基地游戏玩家
	--飞信
	fetionLogin 				= 95, --飞信登录
	fetionRequestFriendList 	= 96,
	-- 飞信邀请分享
	fetionGetPicAndApk          = 97,
	fetionScore                 = 98,
	requestSecondConfirmWndText = 99, -- 二次确认窗口显示信息
	-- 反馈
	requsetFeedbackSolve 		= 100, --反馈
	requsetFeedbackVote 		= 101, --获取反馈列表

    --比赛场列表相关信息
    requestMatchConfig   		= 102, -- 拉取比赛配置列表
    requestHelpDetail           = 103,

    reportPayProductInfo            = 104, --上报确定支付的订单信息

    requestCommonConfig = 105, -- 统一请求配置信息

    requireChestStatus = 106,
    requireChestPopWnd = 107,
    requireChestAward  = 108,
    requestExchangeHistoryList = 109, -- 获取兑换历史记录
    requestNewHallConfig = 110, 	-- 新大厅配置
    requestFeeBackTipNum = 111, --反馈气泡
    requestFlushFeeBackTipNum = 112, --清除反馈气泡

    requestActivation = 113, -- 激活码兑换接口
    requireCharmRank = 114, -- 魅力值排行榜领奖
    changePaizhi = 115, -- 切换牌纸
    requestBaseInfo = 116, -- 请求动态配置信息
    requestUseBroadcastTrumpet = 117, -- 请求使用喇叭
    requestChangeIcon = 118, -- 请求切换头像框
    -- requestIsFirstCharge = 118, -- 是否需要首冲
    -- requestIsSign = 119, -- 是否需要签到
    requireTopRankReward = 120,
    requireWebPay = 121, -- 检测网页支付
    requestSystemMessage = 122,
    requestSystemReward  = 123,
    requestReport        = 124,
    requestNoticePhpShare= 125,
    requestHongbaoConfig = 126,
    requestSendHongbao   = 127,
    requestTrumpetMessageConfig = 128,
    requestYiXinChipBoard = 129, --获取易信好友列表
    inviteYiXinFriend = 130, --易信邀请好友
    shareYiXin = 131, -- 易信分享
    shareAddFriend = 132,--易信添加好友
    requestGetVerify = 133, --获取验证码
    requestBind = 134, --帐号绑定

    requestNetConfig = 135,--cdn配置
    requestUnLoginNotice = 136,---登录失败的公告
    requestLoginConfig = 137,---拉取登录配置
}

HttpModule.s_config ={
	[HttpModule.s_cmds.getRoomPropList] = {
		"?m=prop&p=get_list",
		"getRoomPropList",
	},
	[HttpModule.s_cmds.getRoomActivityInfo] = {
		"?m=iphoneactivity&p=gdgold&act=open",
		"getRoomActivityInfo",
	},
	[HttpModule.s_cmds.getRoomActivityDetail] = {
		"?m=iphoneactivity&p=gdgold&act=detail",
		"getRoomActivityDetail",
	},
	[HttpModule.s_cmds.getRoomActivityAward] = {
		"?m=iphoneactivity&p=gdgold&act=award",
		"getRoomActivityAward",
	},
	[HttpModule.s_cmds.requestLogin] = {
		"?m=login&p=index",
		"requestLogin",
	},
	[HttpModule.s_cmds.requireLoginConfig] = {
		"?m=login&p=loginconfig",
		"requireLoginConfig",
	},
	[HttpModule.s_cmds.getRankList] = {
		"?m=dailyranking&p=getRankingList",
		"getRankList",
	},
	[HttpModule.s_cmds.requestPrivateDiZhuList] = {
		"?m=room&p=getNewAntes",  --新接口，可控准入限额
		"requestPrivateDiZhuList",
	},
	[HttpModule.s_cmds.requestMyItemList] = {
		"?m=market&p=mypacket",
		"requestMyItemList",
	},
	[HttpModule.s_cmds.requestTaskList] = {
		"?m=newtask&p=tasklist",
		"requestTaskList",
	},
	[HttpModule.s_cmds.requestTaskReward] = {
		"?m=newtask&p=getTaskAward",
		"requestTaskReward",
	},

	[HttpModule.s_cmds.requestVersionInfo] = {
		"?m=system&p=update",
		"requestVersionInfo",
	},
	[HttpModule.s_cmds.requestNoticeInfo] = {
		"?m=system&p=notices",
		"requestNoticeInfo",
	},
	[HttpModule.s_cmds.requestRankReward] = {
		"?m=dailyranking&p=getTodayPeakAward",
		"requestRankReward",
	},
	--新大厅配置接口
	[HttpModule.s_cmds.requestNewHallConfig] = {
		"?m=room&p=getlist",
		"requestNewHallConfigList"
	},
	[HttpModule.s_cmds.requestHallIpPort] = {
		"?m=login&p=sysconf",
		"requestHallIpPort",
	},
	[HttpModule.s_cmds.requestExchangeList] = {
		"?m=market&p=goodslist",
		"requestExchangeList",
	},
	[HttpModule.s_cmds.requestExchangeHistoryList] = {
		"?m=market&p=getchangelog",
		"requestExchangeHistoryList",
	},
	[HttpModule.s_cmds.requestExchange] = {
		"?m=market&p=exchange",
		"requestExchange",
	},

	--弃用了？
	[HttpModule.s_cmds.requestBaseConfigXML] = {
		"?m=basecfg&p=index",
		"requestBaseConfigXML"
	},

	[HttpModule.s_cmds.requsetBestGameInfo] = {
		"?m=user&p=getUserBestInfo",
		"requsetBestGameInfo"
	},
	[HttpModule.s_cmds.requsetUploadUserInfo] = {
		"?m=android&p=updateInfo",
		"requsetUploadUserInfo"
	},
	[HttpModule.s_cmds.getBankraptcyRemedy] = {
		"?m=android&p=androidbankrupt",
		"getBankraptcyRemedy"
	},
	[HttpModule.s_cmds.getBankraptcyConfig] = {
		"?m=bankrupt&p=bankruptconfig",
		"getBankraptcyConfig"
	},
	[HttpModule.s_cmds.getUserInfo] = {
		"?m=user&p=userinfo",
		"getUserInfo"
	},
	[HttpModule.s_cmds.getUserVipInfo] = {
		"?m=vip&p=getVip",
		"getUserVipInfo"
	},
	[HttpModule.s_cmds.getVipData] = {
		"?m=vip&p=vipShow",
		"getVipData"
	},

	----------- 获取商品列表部分(这里不配置地址，通过外部传进来) -----------

	[HttpModule.s_cmds.requestNetHost] = {
		"?m=login&p=gethost",
		"requestNetHost",
	},

	------------好友信息相关-------------------------------
	--获取好友列表
	[HttpModule.s_cmds.requestFriendList] = {
		"?m=friend&p=friend_list",
		"requestFriendListCallBack"
	},
	[HttpModule.s_cmds.requestDetailFriendInform] = {
		"?m=friend&p=userinfo",
		"requestDetailFriendInformCallBack"
	},
	[HttpModule.s_cmds.requestFriendNotice] = {
		"?m=iphonefriend&p=getNotice",
		"requestFriendNoticeCallBack"
	},
	[HttpModule.s_cmds.requestFriendNoticeNum] = {
		"?m=iphonefriend&p=getNoticeNum",
		"requestFriendNoticeNumCallBack"
	},
	[HttpModule.s_cmds.deleteFriendNotice] = {
		"?m=iphonefriend&p=delNotice",
		"deleteFriendNoticeCallBack"
	},
	[HttpModule.s_cmds.likeIt] = {
		"?m=friend&p=like",
		"likeItCallBack"
	},
	[HttpModule.s_cmds.giveMoney] = {
		"?m=friend&p=gift_money",
		"giveMoneyCallBack"
	},
	[HttpModule.s_cmds.getMoney] = {
		"?m=friend&p=award_gift",
		"getMoneyCallBack"
	},

	[HttpModule.s_cmds.requestFriendNews] = {
		"?m=friend&p=offline_msg",
		"requestFriendNewsCallBack"
	},
	[HttpModule.s_cmds.requestFriendNewsNum] = {
		"?m=friend&p=tipsnum",
		"requestFriendNewsNumCallBack"
	},

	[HttpModule.s_cmds.requestModifyFriendAlias] = {
		"?m=friend&p=modify_alias",
		"requestModifyFriendAlias"
	},


	[HttpModule.s_cmds.searchFriendById] = {
		"?m=friend&p=userinfo",
		"searchFriendByIdCallBack"
	},

	[HttpModule.s_cmds.requireWebPay] = {
		"?m=pay&p=checkWebPay",
		"requireWebPayCallback"
	},
	------------好友信息结束--------------------------------
	[HttpModule.s_cmds.downloadRes] = {
		"?m=extsrc&p=extraSource",
		"downloadRes"
	},
	------------防沉迷--------------------------------------
	[HttpModule.s_cmds.requestAvoidWallow] = {
		"?m=verify",
		"requestAvoidWallowCallBack"
	},
	[HttpModule.s_cmds.requestDetailSignInfo] = {
		"?m=qiandao&p=signinfo",
		"requestDetailSignInfo"
	},
	[HttpModule.s_cmds.requestSign] = {
		"?m=qiandao&p=award",
		"requestSign"
	},

	[HttpModule.s_cmds.getTaskNnum] = {
		"?m=newtask&p=getCanRewardTasknum",
		"getTaskNnum"
	},

	---------------个推------------------------------------
	[HttpModule.s_cmds.uploadGeTuiCid] = {
		"?m=igetui&p=update",
		"uploadGeTuiCid"
	},
	---------------请求统一支付的接口地址------------------
	[HttpModule.s_cmds.getApiHost] = {
		"?m=pay&p=getApihost",
		"getApihost",
	},
	-----------------支付上报-------------------------------
	[HttpModule.s_cmds.reportOrder] = {
		"?m=pay&p=reportOrder",
		"reportOrder",
	},
	[HttpModule.s_cmds.updateReport] = {
		"?m=system&p=updateAward&act=update",
		"updateReport",
	},
	[HttpModule.s_cmds.updateReward] = {
		"?m=system&p=updateAward&act=award",
		"updateReward",
	},

	---------------新破产接口(获取时间)-------------------------------
	[HttpModule.s_cmds.newBankruptcy] = {
		"?m=android&p=androidbankrupt&act=gettime",
		"newBankruptcy",
	},

	---------------新破产接口(获取筹码)-------------------------------
	[HttpModule.s_cmds.newBankruptcyGet] = {
		"?m=android&p=androidbankrupt",
		"newBankruptcyGet",
	},
	-- 拉取破产接口
	[HttpModule.s_cmds.getTuiJianProduct] = {
		"?m=market&p=recommond",
		"getTuiJianProduct",
	},
	[HttpModule.s_cmds.taskEnforcepush] = {
		"?m=iphoneactivity&p=enforcepush",
		"taskEnforcepush",
	},
	[HttpModule.s_cmds.orderPreCheck] = {
		"?m=pay&p=checkUnionPay",
		"responseUnionPaymentCheck",
	},
	--比赛大厅接口
	[HttpModule.s_cmds.requestContestRank] = {
		"?m=game&p=gameRanking",
		"responseGameRanking",
	},
	--热更新接口
	[HttpModule.s_cmds.hotUpdate] = {
		"?m=lua&p=version",
		"hotUpdate"
	},
		--话付宝限额接口
	[HttpModule.s_cmds.huafubaoLimit] = {
		"?m=pay&p=dailyPayLimit",
		"huafubaoResponse",
	},
	[HttpModule.s_cmds.requestFirstChargeData] = {
		"?m=iphoneactivity&p=firstpay&act=detail",
		"requestFirstChargeData",
	},
	[HttpModule.s_cmds.requestFirstChargeAward] = {
		"?m=iphoneactivity&p=firstpay&act=award",
		"requestFirstChargeAward",
	},

	[HttpModule.s_cmds.requestActivityUrl] = {
		"?m=iphoneactivity&p=getactivity",
		"requestActivityUrl",
	},

	[HttpModule.s_cmds.requestIsShowMobileGamer] = {
		"?m=cqmobile&p=isShowWeal",
		"requestIsShowMobileGamer"
	},
	[HttpModule.s_cmds.requestIsSubscribeMobileGamer] = {
		"?m=cqmobile&p=isRSS",
		"requestIsSubscribeMobileGamer"
	},
	[HttpModule.s_cmds.fetionLogin] = {
		"?m=login&p=index",
		"fetionLogin",
	},
	[HttpModule.s_cmds.fetionRequestFriendList] = {
		"?m=fxfriend&p=fxFriendList",
		"fetionRequestFriendList",
	},

	[HttpModule.s_cmds.fetionGetPicAndApk] = {
		"?m=fxfriend&p=fxUrl",
		"fetionGetPicAndApk",
	},

	[HttpModule.s_cmds.fetionScore] = {
		"?m=fxfriend&p=getFxJf",
		"fetionScore",
	},

	[HttpModule.s_cmds.requestSecondConfirmWndText] = {
		"?m=pay&p=confimtemp",
		"requestSecondConfirmWndText",
	},



    --比赛场列表相关信息
    [HttpModule.s_cmds.requestMatchConfig] = {
        "?m=match&p=getlist",
        "requestMatchConfig"
    },

    [HttpModule.s_cmds.reportPayProductInfo] = {
        "?m=pay&p=saveOrder",
        "reportPayProductInfo"
    },

    [HttpModule.s_cmds.requestHelpDetail] = {
        "?m=match&p=getdesc",
        "requestHelpDetail"
    },

    -- 统一请求配置信息接口
    [HttpModule.s_cmds.requestCommonConfig] = {
    	"?m=basecfg&p=index",
		"requestCommonConfig"
    };

    [HttpModule.s_cmds.requireChestStatus] = {
    	"?m=box&p=open",
		"requireChestStatus"
    },

    [HttpModule.s_cmds.requireChestPopWnd] = {
    	"?m=box&p=detail",
		"requireChestPopWnd"
    },

    [HttpModule.s_cmds.requireChestAward] = {
    	"?m=box&p=award",
		"requireChestAward"
    },

    [HttpModule.s_cmds.requestFeeBackTipNum] = {
    	"?m=feedback&p=getnum",
		"requestFeeBackTipNum"
    },
    [HttpModule.s_cmds.requestFlushFeeBackTipNum] = {
    	"?m=feedback&p=flush",
		"requestFlushFeeBackTipNum"
    },

    [HttpModule.s_cmds.requestActivation] = {  -- 激活码兑换接口
    	"?m=activation&p=checkActivation",
    	"requestActivation"
	},

	[HttpModule.s_cmds.changePaizhi] = {
		"?m=market&p=changePaizhi",
		"changePaizhi"
	},

	[HttpModule.s_cmds.requestChangeIcon] = {
		"?m=market&p=changeIcon",
		"requestChangeIcon"
	},

	[HttpModule.s_cmds.requireCharmRank] = {
		"?m=dailyranking&p=getPreWeekMeiliAward",
		"requireCharmRank"
	},

	[HttpModule.s_cmds.requireTopRankReward] = {
		"?m=dailyranking&p=getTodayPeakAward",
		"requireTopRankReward"
	},

	[HttpModule.s_cmds.requestBaseInfo] = {
		"?m=baseinfo&p=index",
		"requestBaseInfo"
	},

	[HttpModule.s_cmds.requestUseBroadcastTrumpet] = {
		"?m=prop&p=sendSouna",
		"requestUseBroadcastTrumpet"
	},

	[HttpModule.s_cmds.requestSystemMessage] = {
		"?m=system&p=systemmsg",
		"requestSystemMessage",
	},

	[HttpModule.s_cmds.requestSystemReward] = {
		"?m=system&p=systemmsgAward",
		"requestSystemReward",
	},

	[HttpModule.s_cmds.requestReport] = {
		"?m=report&p=setReport",
		"requestReport",
	},
	[HttpModule.s_cmds.requestNoticePhpShare] = {
		"?m=newtask&p=shareTimes",
		"requestNoticePhpShare",
	},
	[HttpModule.s_cmds.requestSendHongbao] = {
		"?m=redenvelope&p=send",
		"requestSendHongbao"
	},

	[HttpModule.s_cmds.requestTrumpetMessageConfig] = {
		"?m=prop&p=getTrumpet",
		"requestTrumpetMessageConfig"
	},
	[HttpModule.s_cmds.requestYiXinChipBoard] = {
    	"?m=yixin&p=chipBoard",
    	"requestYiXinChipBoardCallBack"
	};
	[HttpModule.s_cmds.inviteYiXinFriend] = {
		"?m=yixin&p=inviteFriend",
		"inviteFriendCallBack"
	};
	[HttpModule.s_cmds.shareYiXin] = {
		"?m=yixin&p=shareTimes",
		"shareYiXinCallBack"
	};
	[HttpModule.s_cmds.shareAddFriend] ={
		"?m=yixin&p=addFriend",
		"shareAddFriendCallBack"
	},

    [HttpModule.s_cmds.requestGetVerify] ={
	"?m=user&p=verifycode",
	"requestGetVerify"
	},

    [HttpModule.s_cmds.requestBind] ={
	"?m=user&p=phonebind",
	"requestGetVerify"
	},
	-- [HttpModule.s_cmds.requestIsFirstCharge] = {
	-- 	"?m=iphoneactivity&p=getStatus",
	-- 	"requestIsFirstCharge"
	-- },

---------------------------------------------------------------------------动态的
	[HttpModule.s_cmds.requestBestFanXing] = {
		"",
		"requestBestFanXing"
	},
	[HttpModule.s_cmds.requsetSendFeedback] = {
		"",
		"Feedback.sendFeedback",
	},
	[HttpModule.s_cmds.requsetFeedbackList] = {
		"",
		"Feedback.mGetFeedback",
	},
	[HttpModule.s_cmds.getFirstRechargeGift] = {
		"",
		"getFirstRechargeGift",
	},
	[HttpModule.s_cmds.getProductProxy] = {
		"",
		"getProductProxy",
	},



	[HttpModule.s_cmds.refresh360Token] = {
		"",
		"refresh360TokenPHP"
	},

	[HttpModule.s_cmds.requestUpdateHost] = {
		"",
		"requestUpdateHost",
	},
	[HttpModule.s_cmds.requsetCanLogin] = {
		"",
		"requsetCanLogin",
	},
	---------订单请求-----------------------------------
	[HttpModule.s_cmds.createOrder] = {
		"",
		"createOrderCallBack"
	},
	[HttpModule.s_cmds.getActivityNnum] = {
		"",
		"getActivityNnum"
	},
	[HttpModule.s_cmds.requestRefressAccessToken] = {
		"",
		"requestRefressAccessToken",
	},
	[HttpModule.s_cmds.requestAccessToken] = {
		"",
		"requestAccessToken",
	},
	[HttpModule.s_cmds.requestPayConfig] = {
		"",
		"requestPayConfig"
	},
	--反馈
	[HttpModule.s_cmds.requsetFeedbackSolve] = {
		"",
		"Feedback.mCloseTicket",
	},
	[HttpModule.s_cmds.requsetFeedbackVote] = {
		"",
		"Feedback.mPostScore",
	},
	[HttpModule.s_cmds.requestNetConfig] = {
		"",
		"requestNetConfig",
	},

	[HttpModule.s_cmds.requestUnLoginNotice] = {
		"?m=system&p=announce",
		"requestUnLoginNotice",
	},
	[HttpModule.s_cmds.requestLoginConfig] = {
		"?m=hallcdn&p=config",
		"requestLoginConfig",
	},
}
