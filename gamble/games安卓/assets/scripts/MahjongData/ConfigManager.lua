-- author: OnlynighZhang
-- desc: 该类为统一请求配置管理器，之后所有跟配置相关的请求全部在该类中完成
-- tips: 若变量前带有"_"则表示变量为私有变量，请勿在类外使用该变量，请给需要在外部访问的变量添加get和set方法访问变量
-- usage:
-- time: 2015-1-4
require("MahjongData/MultiRequestManager");
require("MahjongHall/HongBao/HongBaoModel")

ConfigManager = class( MultiRequestManager );

ConfigManager.instance = nil;

function ConfigManager.getInstance()
	if not ConfigManager.instance then
		ConfigManager.instance = new( ConfigManager );
	end
	return ConfigManager.instance;
end



function ConfigManager:getAllRequestCmd()
	local params = {};
	for key,cmdTable in pairs(ConfigManager.cmds) do
		local cmds = self:calculateCmds( cmdTable );
		log( "cmds = "..cmds );
		params[key] = cmds;
	end
	return params;
end

-- 该函数设置为
-- function ConfigManager:onHttpEvent( command , isSuccess, data, jsonData, ... )
-- 	if not isSuccess or not data or not data.data then
-- 		log( "request failed" );
-- 		return;
-- 	end

-- 	if data.data then
-- 		for k,v in pairs(data.data) do
-- 			self:handle( data.data[k], ConfigManager.handler[k] );
-- 		end

-- 		self:initConfig();
-- 	end
-- end

-- 获取发送短信限制时间
function ConfigManager:parseSmsLimitTime( data )
	DebugLog( "ConfigManager.parseSmsLimitTime" );
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
	GameConstant.smsLimitTime = tonumber( data ) or 30;
end

function ConfigManager:parseHongBaoConfig( data )
	HongBaoModel.getInstance():onRequestConfig(data)
end

function ConfigManager:parseEvaluateRateConfig( data )
	GameConstant.trumptp = tonumber(data.trumptp) or 20  --破产弹出概率
	GameConstant.outp = tonumber(data.outp) or 10        --正常牌局概率
end


--弹出礼包界面的概率
ConfigManager.parse_pop_charge_probability = function (self, data)
	DebugLog("[ConfigManager]:parse_pop_charge_probability")
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
    GlobalDataManager.getInstance():set_pop_charge_probability(data);
end

--弹出礼包界面的概率
ConfigManager.parse_FriendBattle_InGameExit = function (self, data)
	DebugLog("[ConfigManager]:parse_FriendBattle_InGameExit")
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
	DebugLog(data);
    -- GameConstant.friendBattle_InGameExit
		if ( tonumber( data ) or 0 ) == 1 then
			GameConstant.friendBattle_InGameExit = true;
		else
			GameConstant.friendBattle_InGameExit = false;
		end
end

ConfigManager.parse_quick_start = function(self, data)
	DebugLog("BaseInfoManager.parse_quick_start")
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
    local xz_n = tonumber(data.xz);
    local xl_n = tonumber(data.xl);
    if xz_n then
        GlobalDataManager.getInstance():set_control_xz(xz_n);
    end
    if xl_n then
        GlobalDataManager.getInstance():set_control_xl(xl_n);
    end
end

-- 获取是否显示去低倍场按钮
function ConfigManager:parseIsShowLowLevelBtn( data )
	DebugLog( "ConfigManager.parseIsShowLowLevelBtn" );
	if not data then
		DebugLog( "数据不完整" );
		return;
	end
	if ( tonumber( data ) or 0 ) == 1 then
		GameConstant.isShowLowLevelBtn = true;
	else
		GameConstant.isShowLowLevelBtn = false;
	end
end

-- 返回第一个参数标示是否需要在netcachemanager中处理请求，不需要则不需要返回任何值
-- 第二个参数为是否需要请求
-- 第三个参数为对应的需要处理的HTTP CMD ID
function ConfigManager:parseIsFirstCharge( data )
	DebugLog( "ConfigManager:parseIsFirstCharge" );
	if not data then
        DebugLog("data is nil");
		return false, nil, -1;
	end
	local status = tonumber( data or 0 );
    DebugLog("status:"..tostring(status));
	return true, status == 1 , PHP_CMD_REQUEST_FIRST_CHARGE_DATA;
end

-- 返回第一个参数标示是否需要在netcachemanager中处理请求，不需要则不需要返回任何值
-- 第二个参数为是否需要请求
-- 第三个参数为对应的需要处理的HTTP CMD ID
function ConfigManager:parseIsSign( data )
	DebugLog( "ConfigManager:parseIsSign" );
	if not data then
		return false, nil, -1;
	end

	local status = tonumber( data or 0 );
	DebugLog(":"..status)
	return true, status == 0 , PHP_CMD_REQUEST_DETAIL_SIGN_INFO;
end

-- 将配置信息初始化，并传递给java
-- 该方法在NetCacheDataManager中被调用
function ConfigManager:initConfig()
	log( "ConfigManager:initConfig" );
	local params = {};
	params.smsLimitTime = GameConstant.smsLimitTime;

	native_to_java( kInitConfig, json.encode(params) );
end

--获取是否开启二次弹框的配置信息
function ConfigManager.secondTipInfo(self, data)
	DebugLog("ConfigManager.secondTipInfo")
	DebugLog(data)
	if not data then
		return ;
	end
	if GameConstant.iosDeviceType > 0  then
		GameConstant.checkType = kCheckStatusClose;
		return;
	else
		GameConstant.iosPingBiFee = false;
	end
	--后台0表示不显示（不是审核状态）， 1代表显示（是审核状态）
	if tonumber(data.paycfgverify or 0) == 1 then
    	GameConstant.checkType = kCheckStatusOpen ;

    	if HallScene_instance then
			HallScene_instance:addCheckTypeScene();
		end
    	EventDispatcher.getInstance():dispatch(GlobalDataManager.addCheckSceneEvent);
    else
    	GameConstant.checkType = kCheckStatusClose;
    	if HallScene_instance then
			HallScene_instance:removeCheckTypeScene();
		end
    	EventDispatcher.getInstance():dispatch(GlobalDataManager.removeCheckTypeScene);
	end
	-- OPPO联运
	--后台0表示不显示（不是审核状态）， 1代表显示（是审核状态）
	GameConstant.backCheckType = tonumber(data.exit or kCheckStatusClose);
	GameConstant.check_addressBook = data.addressBook or nil      --是否屏蔽通讯录
	GameConstant.check_updateVersion = data.updateVersion or nil  --是否屏蔽更新版本
	GameConstant.check_changeAccount = data.changeAccount or nil --屏蔽版本切换账号
	DebugLog("check_...check_addressBook:" .. tostring(GameConstant.check_addressBook) .. ", check_updateVersion:" .. tostring(GameConstant.check_updateVersion))
end

ConfigManager.cmds = {
	-- 最多32个命令字，超出后需要重新添加一个配置表
	s1 = {
		CMD_SMS_PAY_LIMIT_TIME = 0x00000002; -- 裸码支付时间配置接口
		CMD_IS_SHOW_LOW_LEVEL_BTN = 0x00000004; -- 是否显示去低倍场

		CMD_HONG_BAO_CONFIG             = 0x00020000; --红包基本配置
		CMD_EVALUATE_RATE_CONFIG        = 0x00100000;  --评价游戏概率配置

        CMD_Pop_Charge_Probability = 0x02000000,--弹出充值概率
		CMD_FriendBattle_InGameExit = 0x04000000,--好友对战中途退出开关
        CMD_QUICK_START =  0x08000000;--快速开始的配置
	};

	d1 = {
		CMD_IS_FIRST_CHARGE = 0x00000002; -- 是否需要首冲
		CMD_IS_SIGN = 0x00000004; -- 是否需要签到
		CMD_IS_SECONDTIP = 0x00000008; -- 是否要开启二次弹框
	};

};

-- 处理数据
ConfigManager.handler = {
	s1 = {
		-- 解析短信发送限制时间
		[ConfigManager.cmds.s1.CMD_SMS_PAY_LIMIT_TIME] = ConfigManager.parseSmsLimitTime,
		-- 解析是否显示低级场按钮
		[ConfigManager.cmds.s1.CMD_IS_SHOW_LOW_LEVEL_BTN] = ConfigManager.parseIsShowLowLevelBtn,

		[ConfigManager.cmds.s1.CMD_HONG_BAO_CONFIG] = ConfigManager.parseHongBaoConfig,

		[ConfigManager.cmds.s1.CMD_EVALUATE_RATE_CONFIG] = ConfigManager.parseEvaluateRateConfig,


        [ConfigManager.cmds.s1.CMD_Pop_Charge_Probability]        = ConfigManager.parse_pop_charge_probability,--弹出礼包界面的概率
		[ConfigManager.cmds.s1.CMD_FriendBattle_InGameExit]        = ConfigManager.parse_FriendBattle_InGameExit,--弹出礼包界面的概率
        [ConfigManager.cmds.s1.CMD_QUICK_START]                   = ConfigManager.parse_quick_start,
	};

	d1 = {
		-- 解析短信发送限制时间
		[ConfigManager.cmds.d1.CMD_IS_FIRST_CHARGE] = ConfigManager.parseIsFirstCharge,
		-- 解析是否显示低级场按钮
		[ConfigManager.cmds.d1.CMD_IS_SIGN] = ConfigManager.parseIsSign,
	 	--是否要开启二次弹框
	 	[ConfigManager.cmds.d1.CMD_IS_SECONDTIP] = ConfigManager.secondTipInfo,
	};
};
