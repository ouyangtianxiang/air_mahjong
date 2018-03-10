--[[
	------------------ Please ReadMe ------------------
	业务侧必须要做的事
	1.配置并实现二次确认弹框，请参考 ctor 函数
	2.初始化 PayController，请参考 ctor 函数
	3.初始化支付配置 请参考函数 initPayConfig
	4.配置支付选择框
	4.点击商品，请参考函数 payForGoods
	5.配置实现下单接口，在 payConfigMap 文件中配置 PayConfigMap.createOrderIdObj 和 PayConfigMap.createOrderIdFuc
	6.下单成功则调用下单回调，请参考函数 createOrderCallback
]]

local PayController = class()

--[[
	func ：初始化PayController
	mapPath : (string)
]]
function PayController:ctor(mapPath)
	EventDispatcher.getInstance():register(NativeManager._Event, self,self.onNativeCallDone)
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onHttpRequestListenster);

	require(mapPath.."payConfigMap")
	self.m_supportConfigTable = {}
	self.m_canPayConfig = {}
	self.m_curPayInfo = {}
	self.m_nativePayConfigTable = {}
	-- 关于商品配置
	self.m_sid = nil
	self.m_appid = nil
	-- 商品列表
	self.m_goodsTable = {}
	self:privateInitSupportConfig()
	if GameConstant.iosDeviceType>0 then
		DebugLog("default support");
		self:initPayConfig(PayConfigMap.m_default_iosSupportPayConfig);
	end
end

-- 析构函数
function PayController:dtor()
	EventDispatcher.getInstance():unregister(NativeManager._Event, self,self.onNativeCallDone)
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onHttpRequestListenster)
end

PayController.requestCheckMorePayCallBack = function ( self, isSuccess, param)
	DebugLog("requestCheckMorePayCallBack");
	if param then
		local data = param.data;
		if data then
			local open = data.open;
			if open and open==1 then
				DebugLog("open == 1");
				GameConstant.iosMorePay = true;
			end
		end
	end

if DEBUGMODE==1 then
	GameConstant.iosMorePay = true;
end

	if self.ios_goodInfo then
		self:privatePayForGoods(self.ios_isQuickPay, self.ios_goodInfo, self.ios_isShowChoose)
	end
end

PayController.httpRequestMap = {
	[PHP_CMD_CHECK_MORE_PAY] = PayController.requestCheckMorePayCallBack,
}

PayController.onHttpRequestListenster = function ( self, param, cmd, isSuccess )
	DebugLog("onHttpRequestListenster");
	if self.httpRequestMap[cmd] then
		self.httpRequestMap[cmd](self,isSuccess,param)
	end
end

function PayController:containsPamountSmsPay(pamount)
	for i = 1,#self.m_canPayConfig do
		if self.m_canPayConfig[i].pamountTable and self.m_canPayConfig[i].plimit >= tonumber(pamount or 0) then
			return true;
		end

		if self.m_canPayConfig[i].plimit >= tonumber(pamount or 0) then
			return true;
		end
	end
	return false;
end

function PayController:callThirdPay(productInfo,clientId)
	if not productInfo then
		return;
	end

	local payConfig = {};
	for p,q in pairs(PayConfigMap.m_allPayConfig) do
		if(tonumber(q.pclientid) == clientId) then
			payConfig = q;
			break;
		end
	end

	if not payConfig then return end

	productInfo.pmode = payConfig.pmode;
	productInfo.pclientid = payConfig.pclientid;
	self:payForGoods(false,productInfo);
end

-- 初始化支付配置, 必须调用，
-- 调用时机，登陆成功后拉取配置/支付成功或支付失败
--[[
	configTable table{
		pclientid : (int or string)   支付方式
		plimit : (int or string)  今天还能支付多少钱 -1是不限制
		ptips : (int or string)   0/1 是否有二次弹框
	}
]]
function PayController:initPayConfig(configTable)
	self:privateInitPayConfig(configTable)
end

-- 获取商品列表
function PayController:request( )
	-- body
end

--[[
	func : 获取商品列表成功,从业务侧给到
	param table{
		{
			id : (int or string)     商品ID
			ptype : (int)            商品类型 0:金币
	        pamount : (int)          商品价格
	        pchips : (int)       对等金币
	        pcoins : (int)              对等博雅币
	        pcard : (int)                对等道具ID
	        pnum : (int)            数量
	        pname : (string)  商品名称
	        pimg : (string)  商品图片
	        pdesc : (string) 商品描述
	        psort : (int)    商品排序
		} 
	}
]]
function PayController:requestGoodsTableCallback(goodsTable)
	self:privateRequestGoodsTableCallback(goodsTable)
end

--[[
	func : 获得能支持该商品的支付方式

	goodInfo : table{    商品信息
		pamount : (int or string) 商品金额
		pid  : (int or string) 商品id
		pname : (string) 商品名称
		ptype : (int or string) 商品类型，金币/钻石/博雅币(支付中心定义)
	}

	return : table{

	}
]]
function PayController:getPaySelectInfo(goodInfo)
	return self:privateGetPaySelectInfo(goodInfo)
end

--[[
	func : 调用支付的唯一入口
	isQuickPay : (bool) 是否为快速支付
		true : 快速支付，先判断第一优先级的支付方式是否可用，如果不行则使用第二优先级，以此类推...
		false : 弹出支付选择框
	goodInfo : table{    商品信息
		pamount : (int or string) 商品金额
		pid  : (int or string) 商品id
		pname : (string) 商品名称
		ptype : (int or string) 商品类型，金币/钻石/博雅币(支付中心定义)
		pmode : (int) 支付方式，由支付中心定义，(快速支付可以不传)
		pclientid : (int) 客户端自定义支付类型，(快速支付可以不传)
	}
	isShowChoose : (bool) 取消快速支付后显示选择支付框,(如果不是快速支付，可以忽略)
]]
function PayController:payForGoods(isQuickPay, goodInfo, isShowChoose)
	DebugLog("PayController:payForGoods");
	if isQuickPay and GameConstant.iosDeviceType>0 then
		self.ios_isQuickPay = isQuickPay;
		self.ios_goodInfo = goodInfo;
		self.ios_isShowChoose = isShowChoose;
		SocketManager.getInstance():sendPack(PHP_CMD_CHECK_MORE_PAY);
		return ;
	end
	self:privatePayForGoods(isQuickPay, goodInfo, isShowChoose)
end

--[[
	func : 显示支付选择框

	goodInfo table{
		pamount : (int or string) 商品金额
		pid  : (int or string) 商品id
		pname : (string) 商品名称
		ptype : (int or string) 商品类型，金币/钻石/博雅币(支付中心定义)
	}

	return : bool 如果为false,则表示没有可用的支付方式
]]
function PayController:showPaySelectWindow(goodInfo)
	self:privateShowPaySelectWindow(goodInfo)
end

--[[
	func : 创建订单成功，从业务侧给到
	param table{
		order : (table) 支付中心下单的信息
		mid   :  (string or int) 业务侧的用户id
	}
]]
function PayController:createOrderCallback( orderTable )
	self:privateCreateOrderCallback(orderTable)
end

--[[
	func : 支付场景上报
]]
function PayController:requestPaySceneReport( orderTable )
	DebugLog("PayController:requestPaySceneReport")
	if not self.m_curPayInfo.goodInfo.payScene then
		return
	end
	local payScene = self.m_curPayInfo.goodInfo.payScene
	DebugLog(self.m_curPayInfo.goodInfo.payScene)
	local param = {};
	param.scene_id = payScene.scene_id or 0                           -- 场景id
	param.sitemid = PlayerManager.getInstance():myself().mid or ""    -- 平台用户id
	param.order_id = orderTable.ORDER or ""                           -- 订单号
	param.party_type = payScene.levelType or 0                        -- 一级场次level
	param.party_level = payScene.level or 0                           -- 二级场次level
	param.basechip = payScene.basechip or 0                           -- 底注
	param.bankrupt = payScene.bankrupt or 0                           -- 是否破产
	param.pmode = orderTable.PMODE
	param.pcoins = payScene.pcoins or 0                               --博雅币
	param.pchips = payScene.pchips or 0                               -- 金币
	param.current_type = 1                                            --人民币
	param.current_num = payScene.pamount or 0                         --币种数量

	SocketManager.getInstance():sendPack(PHP_CMD_REPORT_ORDER, param)
end

--[[
	func : 获取所有商品列表

	return : (table) 商品列表
]]
function PayController:getAllGoodsTable()
	return self:privateGetAllGoodsTable()
end

--[[
	func : 获取特定額度的商品信息
	pamount : (int) 商品額度

	return : (table) 商品信息
]]
function PayController:getGoodsInfoByPamount(pamount)
	self:privateGetGoodsInfoByPamount(pamount)
end

--[[
	func : 清除商品列表
]]
function PayController:clear()
	self:privateClear()
end

-- private
------------------------------ 这里是私有函数，不得侵犯 -------------------------------


-- 先初始化该平台下支持的支付方式
function PayController:privateInitSupportConfig()
	self.m_supportConfigTable = {}
	local config = self:paivateGetSupportPayConfig()
	if config and config.payInfo then
		self.m_nativePayConfigTable = config.payInfo
	end
	if config and config.id then
		self.m_sid = config.id.sid or 0
	end
	if GameConstant.iosDeviceType>0 then
		self.m_sid = 5;
		self.m_appid = 117;
		self.m_nativePayConfigTable = {{payType = 27},{payType = 24},{payType = 6},{payType = 999}}
		PayConfigMap.m_allPayConfig = PayConfigMap.m_all_iosPayConfig;
	end
	for k , v in pairs(self.m_nativePayConfigTable) do
		local pclientid = 0;
		if GameConstant.iosDeviceType>0 then
			pclientid = v.payType
		else
			pclientid = PluginUtil:convertPlugin2PayId(v.pluginId) or 0;
			v.payType = pclientid
		end
		for p, q in pairs(PayConfigMap.m_allPayConfig) do
			if pclientid == tonumber(q.pclientid) then
				q.pamountTable = v.pamountTable
				v.pmode = q.pmode
				self.m_supportConfigTable[#self.m_supportConfigTable + 1] = q
				break
			end
		end
	end
		DebugLog("self.m_supportConfigTable");
		DebugLog(self.m_supportConfigTable);
end


-- 初始化支付配置
function PayController:privateInitPayConfig(configTable)
	-- 这里必须先强校验
	if not self:checkConfigTable(configTable) then return end
	-- 将支持的支付方式和配置合并
	self.m_canPayConfig = {}
	for k, v in pairs(configTable) do
		for p, q in pairs(self.m_supportConfigTable) do
			if tonumber(v.pclientid) == tonumber(q.pclientid) then
				q.plimit = tonumber(v.plimit)
				q.ptips = tonumber(v.ptips)
				self.m_canPayConfig[#self.m_canPayConfig + 1] = q
			end
		end
	end
end

-- 获得能支持该商品的支付方式
function PayController:privateGetPaySelectInfo(goodInfo)
	local paySelectTable = {}
	if not goodInfo or not goodInfo.pamount then return paySelectTable end
	local pamount = tonumber(goodInfo.pamount)
	local tempTable = {}
	-- 先查找是否支付该额度,且短信只加一個
	local hasSms = false
	for k, v in pairs(self.m_canPayConfig) do
		local pamountTable = {}
		if v.pamountTable ~= nil and v.pamountTable[goodInfo.ptype] ~= nil then
			pamountTable = v.pamountTable[goodInfo.ptype]
		end
		if #pamountTable > 0 then
            if v.ptypesim ~= kNoneSIM and not hasSms then
                for p, q in pairs(pamountTable) do
                    if tonumber(q) == pamount then
                        hasSms = true
                        tempTable[#tempTable + 1] = v
                    end
                end
            elseif v.ptypesim == kNoneSIM then
                tempTable[#tempTable + 1] = v
            end
		else
			if v.ptypesim ~= kNoneSIM and not hasSms then
				hasSms = true
				tempTable[#tempTable + 1] = v
			end
			if v.ptypesim == kNoneSIM then
				tempTable[#tempTable + 1] = v
			end
		end
	end
	paySelectTable = tempTable
	tempTable = {}
	-- 当前限额是否满足该额度
	for k, v in pairs(paySelectTable) do
		plimit = v.plimit or -1
		if plimit == -1 or plimit >= pamount then
			tempTable[#tempTable + 1] = v
		end
	end
	paySelectTable = tempTable
	tempTable = {}
	return paySelectTable
end

-- 调用支付的唯一入口
function PayController:privatePayForGoods(isQuickPay, goodInfo, isShowChoose)
	DebugLog("......................" .. tostring(goodInfo) .. ", num:" .. tostring(#self.m_canPayConfig))
	if #self.m_canPayConfig <= 0 then
		Banner.getInstance():showMsg("没有相应的支付方式，支付失败")
		return
	end
	if not goodInfo then
		Banner.getInstance():showMsg("商品信息出错，请检查网络后重新登录再试")
		return
	end
	local paySelectTable = self:privateGetPaySelectInfo(goodInfo)
	if #paySelectTable <= 0 then
		Banner.getInstance():showMsg("该卡支付额度已达上限，支付失败")
		return
	end
	if GameConstant.iosDeviceType>0 then
		DebugLog(goodInfo);
		if isQuickPay then
			local getpmode = g_DiskDataMgr:getUserData(PlayerManager.getInstance():myself().mid, "savepmode", 0)
			DebugLog("GameConstant.useLastPayType = "..GameConstant.useLastPayType);
			DebugLog("getpmode"..getpmode);
			if GameConstant.useLastPayType ~= 1 then
				--不用上次支付成功的支付方式 用配置的支付方式的顺序
				getpmode=0
			end
			if getpmode==0 then
				local localpmode = self.m_canPayConfig[1].pmode;
				if localpmode==463 and not GameConstant.isWechatInstalled then
					localpmode = self.m_canPayConfig[2].pmode
				end
				getpmode = localpmode;
				g_DiskDataMgr:setUserData(PlayerManager.getInstance():myself().mid, "savepmode", getpmode)
			else
				if getpmode==463 then
					--如果没安装微信就其他
					if not GameConstant.isWechatInstalled then
						getpmode = 620;
						g_DiskDataMgr:setUserData(PlayerManager.getInstance():myself().mid, "savepmode", getpmode)
					end
				end
			end
			DebugLog("check ios more pay info");
			DebugLog("GameConstant.iosPingBiFee:"..tostring(GameConstant.iosPingBiFee));
			DebugLog("GameConstant.iosMorePay:"..tostring(GameConstant.iosMorePay));
			if not GameConstant.iosMorePay then
				--审核关闭其他支付
				getpmode = 99;
			end
			if getpmode>0 then
				for k, v in pairs(paySelectTable) do
					if getpmode == v.pmode then
						self.m_curPayInfo = {}
						self.m_curPayInfo.goodInfo = goodInfo
						self.m_curPayInfo.isShowChoose = isShowChoose
						self.m_curPayInfo.goodInfo.pmode = v.pmode
						self.m_curPayInfo.pclientid = v.pclientid
						self:privateCreateOrder()
						break
					end
				end
			else
				self:privateShowPaySelectWindow(goodInfo);
			end
			return
		else
		end
	end
	local config = nil
	self.m_curPayInfo = {}
	self.m_curPayInfo.goodInfo = goodInfo
	-- 如果是快速充值，则直接走下单流程
	if isQuickPay then
		config = self:getQuickPay(paySelectTable)
		self.m_curPayInfo.isShowChoose = isShowChoose
	else
		-- 从可用支付中找到该支付方式
		local pclientid = tonumber(goodInfo.pclientid)
		self.m_curPayInfo.pclientid = pclientid
		self.m_curPayInfo.goodInfo.pclientid = nil
		for k, v in pairs(paySelectTable) do
			if pclientid == v.pclientid then
				config = v
				break
			end
		end
	end
	if not config then return end
	-- 判断是否有营销页
	if config.ptips == 1 then
		if self:privateIsShowXiaoMiWindow() then return end
		local obj = PayConfigMap.showPayConfirmWindowObj
		local func = PayConfigMap.showPayConfirmWindowFuc

		local cancelFuc = self.closePayConfirmView
		local confrimFuc = self.privateCreateOrder
		func(obj, self.m_curPayInfo.goodInfo, confrimFuc, cancelFuc)
	else
		self:privateCreateOrder()
	end
end

--快速下单流程
function PayController:getQuickPay( paySelectTable )
	local curPayConfig = nil
	DebugLog("PayController:getQuickPay, useLastPayType:" .. tostring(GameConstant.useLastPayType))
	if GameConstant.useLastPayType ~= 1 then    --不使用上次支付方式
		curPayConfig = paySelectTable[1]        --取当前拥有的支付的顺序第一个
	else
		--先找到本地是否已经有支付成功的支付方式
		local mid = PlayerManager.getInstance():myself().mid
		local lastPayId = MahjongCacheData_getDictKey_IntValue(kMap, mid .. kSavePay, 0)
		local payIds = {lastPayId}              --按照上次支付成功
		curPayConfig = self:getPayConfigByPayIds(paySelectTable, payIds)
		if curPayConfig == nil then             --都找不到
			curPayConfig = paySelectTable[1]    --取当前拥有的支付的顺序第一个
		end
	end
	self.m_curPayInfo.goodInfo.pmode = curPayConfig.pmode
	self.m_curPayInfo.pclientid = curPayConfig.pclientid
	return curPayConfig
end

function PayController:getPayConfigByPayIds( paySelectTable, payIds )
	for k, payId in ipairs(payIds) do
		for m, v in ipairs(paySelectTable) do
			if v.pclientid == payId then
				return v
			end
		end
	end
	return nil
end

-- 私有显示支付选择框
function PayController:privateShowPaySelectWindow(goodInfo)
	local paySelectInfo = self:getPaySelectInfo(goodInfo)
	-- printInfo("#paySelectInfo : %s", #paySelectInfo)
	DebugLog("paySelectInfo");
	DebugLog(paySelectInfo);
	if not paySelectInfo or #paySelectInfo <= 0 then  return false end
	local payInfo = {}
	payInfo.goodInfo = goodInfo
	payInfo.paySelectInfo = paySelectInfo
	local obj = PayConfigMap.showPaySelectWindowObj
	local func = PayConfigMap.showPaySelectWindowFuc
	func(obj, payInfo)
	return true
end

-- 调用原生获得该平台支持的支付方式
function PayController:paivateGetSupportPayConfig()
	if GameConstant.iosDeviceType>0 then
		return nil;
	end
	native_to_get_value(kGetSupportPayConfig)
	local payStr = dict_get_string(kGetSupportPayConfig, kGetSupportPayConfig..kResultPostfix)

	if not payStr then
    payStr = [[
        {
            "id": {
                "sid": "7",
                "appid": "186"
            },
            "payInfo": [
                {
                    "payType": "3"
                },
                {
                    "payType": "6"
                },
                {
                    "payType": "1005"
                },
                {
                    "payType": "4"
                },
                {
                    "payType": "9"
                },
                {
                    "payType": "24"
                },
                {
                    "payType": "27"
                },
                {
                    "payType": "26"
                },
                {
                    "appname": "博雅四川麻将",
                    "imei": "865174029451074",
                    "appversion": "5.1.5",
                    "payType": "5",
                    "serviceids": "130426000651,130426000652,130426000653,140326030379,140326030380",
                    "mac": "3c:47:11:66:85:2a",
                    "pmode": "109"
                }
            ]
        }
        ]]
	end
	local retTable
	if payStr then
		retTable = json.decode(payStr)
		-- DebugLog("payStr:" .. tostring(payStr))
	end
	--将计费码插入表中
	for k, v in pairs(retTable.payInfo) do
		local pclientid = PluginUtil:convertPlugin2PayId(v.pluginId) or 0
		for m, payConfig in pairs(GameConstant.iosDeviceType==0 and PayConfigMap.m_allPayConfig or PayConfigMap.m_all_iosPayConfig) do
			if pclientid == payConfig.pclientid then
				if PayConfigMap.m_allPayCodeLimit[payConfig.pmode] ~= nil then
					v.pamountTable = PayConfigMap.m_allPayCodeLimit[payConfig.pmode]
				end
			end
		end
	end
	-- mahjongPrint(retTable)
	return retTable
end

-- 取消营销页
function PayController:closePayConfirmView(isShowChoose)
	-- printInfo("PayController:closePayConfirmView")
	if self.m_curPayInfo.isShowChoose then
		-- printInfo("self.m_curPayInfo.isShowChoose is true")
		self:privateShowPaySelectWindow(self.m_curPayInfo.goodInfo)
	end
end

-- 是否顯示小米的提示信息
function PayController:privateIsShowXiaoMiWindow()
	-- 通過pmode找到支付方式
	local payConfig = {}
	for p, q in pairs(PayConfigMap.m_allPayConfig) do
		if tonumber(self.m_curPayInfo.goodInfo.pmode) == tonumber(q.pmode) then
			payConfig = q
			break
		end
	end
	if not payConfig then return end
	if payConfig.ptypesim ~= kNoneSIM then
		local func = PayConfigMap.showXiaoMiSmsWindowFuc
		local obj = PayConfigMap.showXiaoMiSmsWindowObj
		local cancelFuc = self.closePayConfirmView
		if func and obj and func(obj, cancelFuc) then
			self.m_curPayInfo.isShowChoose = true
			return true
		end
	end
end

-- 下单, 即创建订单
function PayController:privateCreateOrder()
	if not self.m_curPayInfo.goodInfo then return end
	if self:privateIsShowXiaoMiWindow() then return end
 	local obj = PayConfigMap.createOrderIdObj
	local func = PayConfigMap.createOrderIdFuc
	self.m_appid = PlatformFactory.curPlatform:getLoginAppId() or 0
	if self.m_sid and self.m_appid then
		-- self.m_curPayInfo.goodInfo.pmode = 109
		-- self.m_curPayInfo.goodInfo.pclientid = 5
		self.m_curPayInfo.goodInfo.sid = self.m_sid
		self.m_curPayInfo.goodInfo.appid = self.m_appid
		if GameConstant.iosDeviceType>0 then
				self.m_curPayInfo.goodInfo.iscn = 1;
				if tonumber(self.m_curPayInfo.pclientid)==999 then
					self.m_curPayInfo.goodInfo.iscn = 0;
				end
		end
		-- 联通沃支付特殊处理
		local pmode = tonumber(self.m_curPayInfo.goodInfo.pmode)
		if pmode == 109 or pmode == 437 then
			-- 首先从原生支持支付方式中找到联通沃的信息
			local pclientid = tonumber(self.m_curPayInfo.pclientid)
			for k, v in pairs(self.m_nativePayConfigTable) do
				local tpclientid = tonumber(v.payType) or 0
				if pclientid == tpclientid then
					self.m_curPayInfo.goodInfo.appname = v.appname or ""
					self.m_curPayInfo.goodInfo.feename = self.m_curPayInfo.goodInfo.pname
					self.m_curPayInfo.goodInfo.mac = v.mac or "00000000"
					self.m_curPayInfo.goodInfo.mac = string.gsub(self.m_curPayInfo.goodInfo.mac, ":", "")
					self.m_curPayInfo.goodInfo.imei = v.imei or ""
					self.m_curPayInfo.goodInfo.appversion = v.appversion or ""
					self.m_curPayInfo.goodInfo.channelid = v.channelid or PlatformFactory.curPlatform:getUnicomChannelId()
				end
			end
		end
		-- dump(self.m_curPayInfo.goodInfo)
		if GameConstant.iosDeviceType>0 then
			if self.m_curPayInfo.goodInfo.pmode==99 and self.m_curPayInfo.goodInfo.pamount>648 then
				self:privateShowPaySelectWindow(self.m_curPayInfo.goodInfo);
				return;
			end
    end
		func(obj, self.m_curPayInfo.goodInfo)
	else
		DebugLog("mid or sid is nil :" .. tostring(self.m_id) .. ", sid:" .. tostring(self.m_sid))
	end
end

-- 调起支付进行支付
function PayController:callPay(orderTable)
	orderTable.payType = self.m_curPayInfo.pclientid
	orderTable.pluginId = PluginUtil:convertPayId2Plugin(tonumber(orderTable.payType))
	orderTable.productName = self.m_curPayInfo.goodInfo.pname or ""   --商品名称
	orderTable.desc = self.m_curPayInfo.goodInfo.pdesc or ""          --商品描述
	orderTable.sitemid = self.m_curPayInfo.goodInfo.sitemid or "" ;   -- 设备号
	orderTable.nickName = self.m_curPayInfo.goodInfo.nickName or "";  -- 昵称
	orderTable.productType = self.m_curPayInfo.goodInfo.ptype or 0    --默认金币
	if GameConstant.iosDeviceType>0 then
		orderTable.iden = self.m_curPayInfo.goodInfo.iden or "";  -- iden;
	end
	if GameConstant.platformType == PlatformConfig.platformHuawei then --华为，去掉不规范文字
		orderTable.productName = string.gsub(orderTable.productName, ",", "")
		orderTable.desc = string.gsub(orderTable.desc, ",", "")
		orderTable.desc = string.gsub(orderTable.desc, "*", "x")
		DebugLog("商品名称为:" .. orderTable.productName)
	end
	native_to_java(kMutiPay, json.encode(orderTable))
end

-- 校验支付配置是否合理
function PayController:checkConfigTable(configTable)
	if type(configTable) ~= "table" then return end
	for k, v in pairs(configTable) do
		if not tonumber(v.pclientid) then return end
		if not tonumber(v.plimit) then return end
		if not tonumber(v.ptips) then return end
	end
	return true
end

-- 校验下单数据是否完整
function PayController:checkOrderTable(orderTable)
	if type(orderTable) ~= "table" then return end
	local orderId = orderTable.ORDER
	if not orderId or tonumber(orderId) == 0 or tostring(orderId) == "0" or tostring(orderId) == "" then
		return
	end
	return true
end

-- 原生调用,支付失败，或者取消
function PayController:onNativeCallDone( key, data )
	DebugLog("PayController:onNativeCallDone" .. ", key:" .. tostring(key))
	if kMutiPay == key then
		local status = tonumber(data.status) or 0
	 	-- 支付取消，失败，限制等等
		if 1 ~= status then
			if self.m_curPayInfo.isShowChoose then
				self:privateShowPaySelectWindow(self.m_curPayInfo.goodInfo)
			end
		end
	elseif "CallLuaShowMorePay" == key then
		if data and data.isopen then
			if data.isopen==1 then
				GameConstant.iosMorePay = true;
				if data.showmorepay and data.showmorepay==1  then
					if self.m_curPayInfo.goodInfo then
						self:privateShowPaySelectWindow(self.m_curPayInfo.goodInfo)
					end
				end
			else
				GameConstant.iosMorePay = false;
			end
		end
	elseif "AppleCheckPingBi" == key then
		if data and data.pingbi then
			if data.pingbi==1 then
				GameConstant.iosPingBiFee = true;
				if HallScene_instance then
					HallScene_instance:addCheckTypeScene();
				end
			else
				GameConstant.iosPingBiFee = false;
				if HallScene_instance then
					HallScene_instance:removeCheckTypeScene();
				end
			end
			DebugLog("AppleCheckPingBi GameConstant.iosPingBiFee = "..tostring(GameConstant.iosPingBiFee));
		end
	end
end

-- 创建订单成功，从业务侧给到
function PayController:privateCreateOrderCallback(orderTable)
	-- 校验数据
	if not self:checkOrderTable(orderTable) then return end
	-- 调用原生开启支付之路
	self:callPay(orderTable)
end

-- 获取商品列表成功，从业务侧给到
function PayController:privateRequestGoodsTableCallback(goodsTable)
	-- printInfo("PayController:privateRequestGoodsTableCallback")
	if not goodsTable or #goodsTable <= 0 then return end
	self.m_goodsTable = goodsTable
end

-- 获取所有商品列表
function PayController:privateGetAllGoodsTable()
	return self.m_goodsTable or {}
end

-- 获取特定額度的商品信息
function PayController:privateGetGoodsInfoByPamount(pamount)
	if not pamount then return end
	self.m_goodsTable = self.m_goodsTable or {}
	for k, v in pairs(self.m_goodsTable) do
		if tonumber(pamount) == tonumber(v.pamount) then
			return v
		end
	end
end

-- 清除商品列表
function PayController:privateClear()
	self.m_goodsTable = {}
end

return PayController
