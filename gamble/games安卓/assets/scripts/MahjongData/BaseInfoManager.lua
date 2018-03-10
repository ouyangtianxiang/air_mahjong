-- author: OnlynighZhang
-- desc: 该类为统一请求配置管理器，之后所有跟配置相关的请求全部在该类中完成
-- tips: 若变量前带有"_"则表示变量为私有变量，请勿在类外使用该变量，请给需要在外部访问的变量添加get和set方法访问变量
-- usage:
-- time: 2015-1-4
require("MahjongData/MultiRequestManager");

BaseInfoManager = class(MultiRequestManager);

BaseInfoManager.instance = nil;

function BaseInfoManager.getInstance()
	if not BaseInfoManager.instance then
		BaseInfoManager.instance = new( BaseInfoManager );
	end
	return BaseInfoManager.instance;
end

-- 将所有命令行位与以后请求
function BaseInfoManager:requestConfig()
	DebugLog( "BaseInfoManager.requestConfig" );
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	param.infoParam = self:getAllRequestCmd();

	self:request( PHP_CMD_REQUEST_BASE_INFO, param );
end

function BaseInfoManager:getAllRequestCmd()
	local params = {};
	for key,cmdTable in pairs(BaseInfoManager.cmds) do
		local cmds = self:calculateCmds( cmdTable );
		params[key] = cmds;
	end
	return params;
end

-- 刷新卡片
function BaseInfoManager:refreshCards()
	local tempCmds = {
		s1 = {
			CMD_USER_PAIZHI 				= 0x00000001, -- 牌纸
			CMD_LOCATION 					= 0x00000002,--玩家地理位置信息
			CMD_HEAD_PIC 					= 0x00000004, -- 头像框
			CMD_BANKRUPT_LIMIT_TO_SCORE_MATCH = 0x00000010,--比赛场次列表里面 是否显示积分赛的限额
			CMD_SHARE_MESSAGE_CONFIG = 0x00000020; -- 分享内容配置
            
		};
		d1 = {
			CMD_CHANGE_NICKNAME_TIMES = 0x00000001,--玩家的改名次数和改名卡、补签卡、喇叭数量
		};
	};

	self:requestParts( tempCmds, PHP_CMD_REQUEST_BASE_INFO );
end

-- 该函数设置为
BaseInfoManager.onPhpMsgResponse = function ( self, data, command, isSuccess,jsonData )
	if command ~= PHP_CMD_REQUEST_BASE_INFO then
		return
	end
	if not isSuccess or not data or not data.data then
		log( "request failed" );
		return;
	end

	if data.data then
		for k,v in pairs(data.data) do
			self:handle( data.data[k], BaseInfoManager.handler[k] );
		end
	end
end

-- 获取发送短信限制时间
function BaseInfoManager:parseUserPaizhi( data )
	DebugLog( "BaseInfoManager.parseUserPaizhi" );
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
	local player = PlayerManager.getInstance():myself();
	player.paizhi = tostring(data) or "10000";
end

function BaseInfoManager.parseLocation( self, data )
	DebugLog( "BaseInfoManager.parseLocation" );
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
	local player = PlayerManager.getInstance():myself();
	player.location = tostring(data) or ""
end

function BaseInfoManager:parseHeadIcon( data )
	DebugLog( "BaseInfoManager:parseHeadIcon" );
	if not data then
		return;
	end
	local player = PlayerManager.getInstance():myself();
	player.circletype = tonumber( data or 10002 ) or 10002;
	DebugLog( "player.circletype = "..player.circletype );
end

function BaseInfoManager:parseBankruptLimitToScoreMatch( data )
	DebugLog( "BaseInfoManager:parseBankruptLimitToScoreMatch" );
	if not data then
		return;
	end
	GameConstant.displayScoreMatchLimit = tonumber( data or 0 ) or 0
	DebugLog( "parseBankruptLimitToScoreMatch = "..GameConstant.displayScoreMatchLimit );
end

function BaseInfoManager:parseChangeNicknameTimes( data )
	DebugLog("BaseInfoManager:parseChangeNicknameTimes")
	if not data then
		return;
	end
	updateChangeNicknameTimes( data );
end

function BaseInfoManager:parseLabaTopNews( data )
	DebugLog("BaseInfoManager:parseLabaTopNews")
	if not data then
		return;
	end

	require( "MahjongCommon/BroadcastTopNewsItem" );

	BroadcastMsgManager.getInstance():clearTopNews();
	for k,v in pairs(data) do
		local td = new(BroadcastTopNewsData,v);
		BroadcastMsgManager.getInstance():addTopNews( td );
	end
end

function BaseInfoManager:parseShareMessage(data)
	DebugLog("BaseInfoManager.parseShareMessage")
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
	GameConstant.shareMessage = {};
	GameConstant.shareMessage.desc = data.desc or "";
	GameConstant.shareMessage.url = data.url or "";
	GameConstant.shareMessage.logo = data.logo or "";
  GameConstant.shareMessage.title = data.title or "";
end

function BaseInfoManager:parseShareQQWechatMessage(data)
	DebugLog("BaseInfoManager.parseShareQQWechatMessage")
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
	GameConstant.shareQQWechatMessage = {};
	GameConstant.shareQQWechatMessage.desc = data.desc or "";
	GameConstant.shareQQWechatMessage.url = data.url or "";
	GameConstant.shareQQWechatMessage.logo = data.logo or "";
    GameConstant.shareQQWechatMessage.wechat = data.weixin or "";
    GameConstant.shareQQWechatMessage.title = data.title or "";

end

function BaseInfoManager:parse_config_other(data)
	DebugLog("BaseInfoManager.parse_config_other")
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
    GlobalDataManager.getInstance():set_other_config_data(data);
end




BaseInfoManager.cmds = {

	-- 最多32个命令字，超出后需要重新添加一个配置表
	s1 = {
		CMD_USER_PAIZHI = 0x00000001, -- 牌纸
		CMD_LOCATION = 0x00000002,
		CMD_HEAD_PIC = 0x00000004, -- 头像框
		CMD_BANKRUPT_LIMIT_TO_SCORE_MATCH = 0x00000010,--比赛场次列表里面 是否显示积分赛的限额
		CMD_SHARE_MESSAGE_CONFIG = 0x00000020; -- 分享内容配置
        CMD_SHARE_QQ_WECHAT_CONFIG = 0x00000040; -- 分享QQ wechat内容配置
        CMD_OTHER_CONFIG = 0x00000080; --杂项配置
        

	};

	s2 = {
	};

	d1 = {
		CMD_CHANGE_NICKNAME_TIMES = 0x00000001,
		CMD_LABA_TOP_NEWS = 0x00000002,
	};
};

-- 处理数据
BaseInfoManager.handler = {

	s1 = {
		[BaseInfoManager.cmds.s1.CMD_USER_PAIZHI] 					= BaseInfoManager.parseUserPaizhi, -- 解析牌纸信息
		[BaseInfoManager.cmds.s1.CMD_LOCATION] 						= BaseInfoManager.parseLocation, -- 解析位置信息
		[BaseInfoManager.cmds.s1.CMD_HEAD_PIC] 						= BaseInfoManager.parseHeadIcon, -- 解析头像框信息
		[BaseInfoManager.cmds.s1.CMD_BANKRUPT_LIMIT_TO_SCORE_MATCH] = BaseInfoManager.parseBankruptLimitToScoreMatch,--比赛场次列表里面 是否显示积分赛的限额]
		[BaseInfoManager.cmds.s1.CMD_SHARE_MESSAGE_CONFIG] 			= BaseInfoManager.parseShareMessage,
        [BaseInfoManager.cmds.s1.CMD_SHARE_QQ_WECHAT_CONFIG] 			= BaseInfoManager.parseShareQQWechatMessage,--qq微信 分享配置
        [BaseInfoManager.cmds.s1.CMD_OTHER_CONFIG]                  = BaseInfoManager.parse_config_other,
        
        
	};

	d1 = {
		[BaseInfoManager.cmds.d1.CMD_CHANGE_NICKNAME_TIMES] = BaseInfoManager.parseChangeNicknameTimes, -- 解析当前修改昵称的次数
		[BaseInfoManager.cmds.d1.CMD_LABA_TOP_NEWS] = BaseInfoManager.parseLabaTopNews, -- 解析置顶消息
	};
};
