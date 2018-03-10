PluginUtil = {}

local PluginMap = require("MahjongPlatform.pluginConfig");
require("MahjongConstant.GameConstant");

local Plugin2PlatformMap = {}
local Plugin2LoginMap = {}
local Plugin2PayMap = {}

local printInfo = function(fmt, ...)
	print_string(string.format(fmt, ...))
end

function PluginUtil:initMapInfo()
	-- 平台映射
	Plugin2PlatformMap = {
		[PluginMap.MainPlugin[1]] 		= PlatformConfig.platformTrunk,
		[PluginMap.BaiduPlugin[1]]      = PlatformConfig.platformBaiDuCps,
		[PluginMap.BaiduChannelPlugin[1]] = PlatformConfig.platformBaiduChannel,
		[PluginMap.UnicomLianYunPlugin[1]] = PlatformConfig.platformWOSHOP,
		[PluginMap.samSungLianYunPlugin[1]] = PlatformConfig.platformSamSung,
		[PluginMap.BaiduCPSPlugin[1]] = PlatformConfig.platformBaiDuCps,
		[PluginMap.HuaweiPlugin[1]] = PlatformConfig.platformHuawei,
		[PluginMap.QihooPlugin[1]] = PlatformConfig.platformQihoo,
		[PluginMap.MeizuPlugin[1]] = PlatformConfig.platformMeiZu,
		[PluginMap.AnZhiPlugin[1]] = PlatformConfig.platformAnZhi,
		[PluginMap.TencentCustomPlugin[1]] = PlatformConfig.platformThreeNetTencent,
		[PluginMap.TencentYYBPlugin[1]] = PlatformConfig.platformThreeNetTencentYYB,
		[PluginMap.TencentYYSCPlugin[1]] = PlatformConfig.platformThreeNetTencentYYSC,
		[PluginMap.TencentYXZXPlugin[1]] = PlatformConfig.platformThreeNetTencentYXZX,
		[PluginMap.TencentJSPlugin[1]] = PlatformConfig.platformThreeNetTencentJS,
		[PluginMap.TencentQQBrowserPlugin[1]] = PlatformConfig.platformThreeNetTencentQQBrowser,
		[PluginMap.TencentSJJLPlugin[1]] = PlatformConfig.platformThreeNetTencentSJJL,
		[PluginMap.TencentTXSPPlugin[1]] = PlatformConfig.platformThreenetTencentTXSP,
		[PluginMap.WdjPlugin[1]]	= PlatformConfig.platformWDJNet,
		[PluginMap.OppoPlugin[1]]	= PlatformConfig.platformOPPO,
		[PluginMap.MMCpsPlugin[1]] 	= PlatformConfig.platformMMCps,
		[PluginMap.XiaoMiPlugin[1]] = PlatformConfig.platformThreeNetMi,
		[PluginMap.YiXinPlugin[1]]  = PlatformConfig.platformYiXin,
		[PluginMap.EgameLianYunPlugin[1]]  = PlatformConfig.platformNewEgame,
		[PluginMap.ZhuoYiPlugin[1]] = PlatformConfig.platformZhuoYi,
		[PluginMap.YdjdPlugin[1]] = PlatformConfig.platformMobile,
		[PluginMap.YdmmPlugin[1]] = PlatformConfig.platformYidongMM,
		[PluginMap.YiXinPlugin[1]]  = PlatformConfig.platformYiXin,
		[PluginMap.JiuyouPlugin[1]] = PlatformConfig.platformJiuYou,
		[PluginMap.SikaiMPZMPlugin[1]] = PlatformConfig.platformSikaiMPZM,
		[PluginMap.SikaiMPSCPlugin[1]] = PlatformConfig.platformSikaiMPSC,
		[PluginMap.SikaiMPYXPlugin[1]] = PlatformConfig.platformSikaiMPYX,
		[PluginMap.SikaiMPLLQPlugin[1]] = PlatformConfig.platformSikaiMPLLQ,
		[PluginMap.ChubaoPlugin[1]] = PlatformConfig.platformChubao,
		[PluginMap.HuafubaoLianyunPlugin[1]] = PlatformConfig.platformHuafubaoLianyun,

	}

	-- 登录方式映射
	Plugin2LoginMap = {
		[PluginMap.MainPlugin[2]]		= PlatformConfig.GuestLogin,
		[PluginMap.QQPlugin[2]]			= PlatformConfig.QQLogin,
		[PluginMap.WechatPlugin[2]]		= PlatformConfig.WeChatLogin,
		[PluginMap.SinaPlugin[2]]		= PlatformConfig.SinaLogin,	
		[PluginMap.BoyaaPlugin[2]]		= PlatformConfig.BoyaaLogin,
		[PluginMap.OldQQPlugin[2]] 		= PlatformConfig.OldQQLogin,
		[PluginMap.HuaweiPlugin[2]] 	= PlatformConfig.HuaweiLogin,
		[PluginMap.QihooPlugin[2]] 		= PlatformConfig.QiHuLogin,
		[PluginMap.AnZhiPlugin[2]] 		= PlatformConfig.AnZhiLogin,
		[PluginMap.WdjPlugin[2]]		= PlatformConfig.WandouLogin,
		[PluginMap.OppoPlugin[2]]		= PlatformConfig.OppoLogin,
		[PluginMap.YiXinPlugin[2]] 		= PlatformConfig.YiXinLogin,
		[PluginMap.EgameLianYunPlugin[2]] = PlatformConfig.NewEgameLogin,
		[PluginMap.YdjdPlugin[2]]  	      = PlatformConfig.Mobile2Login,
		[PluginMap.ChubaoPlugin[2]]       = PlatformConfig.ChubaoLogin,
 	}


	Plugin2PayMap = {
		[PluginMap.AliPlugin[3]]		= PlatformConfig.MiniStdAliPay,
		[PluginMap.WechatPlugin[3]]		= PlatformConfig.NewWeChatPay,
		[PluginMap.YinLianPlugin[3]]	= PlatformConfig.YinLianPay,
		[PluginMap.YdmmPlugin[3]]		= PlatformConfig.MMPay,
		[PluginMap.YdjdPlugin[3]]		= PlatformConfig.MobilePay,
		[PluginMap.EgameLianYunPlugin[3]] = PlatformConfig.NewEgamePay,
		-- [PluginMap.UnicomPlugin[3]]		= PlatformConfig.UnicomPay,
		[PluginMap.UnicomLianYunPlugin[3]] = PlatformConfig.UnicomOnlyPay,
		[PluginMap.EgamePlugin[3]]		= PlatformConfig.EGamePay,
		[PluginMap.EgameLuoMaPlugin[3]] = PlatformConfig.LoveAnimatePay,
		[PluginMap.HuafubaoComPlugin[3]]= PlatformConfig.HuaFuBaoComPay,
		[PluginMap.HuafubaoPlugin[3]]	= PlatformConfig.HuaFuBaoPay,
		[PluginMap.BaiduChannelPlugin[3]] = PlatformConfig.BaiduPay,
		[PluginMap.HuaweiPlugin[3]] 	= PlatformConfig.HuaweiPay,
		[PluginMap.QihooPlugin[3]] 	 	= PlatformConfig.QihuPay,
		[PluginMap.AnZhiPlugin[3]] 		= PlatformConfig.AnzhiPay,
		[PluginMap.WdjPlugin[3]]		= PlatformConfig.WDJNetPay,
		[PluginMap.OppoPlugin[3]]		= PlatformConfig.OppoPay,
		[PluginMap.MMCpsPlugin[3]] 		= PlatformConfig.MMPay,
		[PluginMap.UnicomPluginNew[3]]  = PlatformConfig.UnicomPay,
		[PluginMap.YiXinPlugin[3]] 		= PlatformConfig.YiXinPay,
		[PluginMap.JiuyouPlugin[3]]     = PlatformConfig.JiuYouPay,
		[PluginMap.ChubaoPlugin[3]]     = PlatformConfig.ChubaoPay,
	};
end

-- 插件id 转 平台id
function PluginUtil:convertPlugin2PlatformId(pluginId)
	return Plugin2PlatformMap[pluginId] or pluginId
end

function PluginUtil:convertToOwnPay()
	if PlatformConfig.platformWOSHOP == GameConstant.platformType then
         Plugin2PayMap[PluginMap.UnicomPluginNew[3]] = PlatformConfig.UnicomOnlyPay;

    elseif PlatformConfig.platformWDJNet == GameConstant.platformType then
         Plugin2PayMap[PluginMap.UnicomPluginNew[3]] = PlatformConfig.WDJUnicomPay;

    else
         Plugin2PayMap[PluginMap.UnicomPluginNew[3]] = PlatformConfig.UnicomPay;
    end
end

function PluginUtil:convertPlatformId2Plugin(platformId)
	for pluginId, val in pairs(Plugin2PlatformMap) do
		if val == platformId then
			printInfo("本地平台Id = %d, 转换为SDK插件Id = %d", platformId, pluginId)
			return pluginId
		end
	end
	return platformId
end

-- 插件id 转 登录id
function PluginUtil:convertPlugin2LoginId(pluginId)
	return Plugin2LoginMap[pluginId] or PlatformConfig.GuestLogin
end

function PluginUtil:convertLoginId2Plugin(loginId)
	for pluginId, val in pairs(Plugin2LoginMap) do
		if val == loginId then
			printInfo("本地登录Id = %d, 转换为SDK插件Id = %d", loginId, pluginId)
			return pluginId
		end
	end
	return loginId
end


-- 插件id 转 支付id 
function PluginUtil:convertPlugin2PayId(pluginId)
	if GameConstant.platformType == PlatformConfig.platformNewEgame then 
		if pluginId == PluginMap.EgameLianYunPlugin[2] then 
			return PlatformConfig.NewEgamePay 
		end
	end
	return Plugin2PayMap[pluginId] or pluginId
end

function PluginUtil:convertPayId2Plugin(payId)
	if PlatformConfig.platformMMCps == GameConstant.platformType then
    	if payId == PlatformConfig.MMPay then
    		return PluginMap.MMCpsPlugin[3]
    	end
    end

    if PlatformConfig.platformNewEgame == GameConstant.platformType then 
    	if payId == PlatformConfig.NewEgamePay then 
    		return PluginMap.EgameLianYunPlugin[3];
    	end
    end

    if PlatformConfig.platformWOSHOP == GameConstant.platformType then 
    	if payId == PlatformConfig.UnicomPay then 
    		return PluginMap.UnicomLianYunPlugin[3];
    	end
    end

	for pluginId, val in pairs(Plugin2PayMap) do
		if val == payId then
			printInfo("本地支付Id = %d, 转换为SDK插件Id = %d", payId, pluginId)
			return pluginId
		end
	end
	return payId
end

PluginUtil:initMapInfo()