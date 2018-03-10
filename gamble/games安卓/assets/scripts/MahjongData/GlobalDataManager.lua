-- 处理多个界面都需要的数据，网络请求等。处理完成后以事件的形式分发出去，或是直接显示相关信息 界面 根节点
require("MahjongCommon/UnautoBanner");
require("MahjongData/ItemManager");

require("Version");
require("MahjongCommon/NoticeItem");
require("MahjongConstant/GameConfig");
require("MahjongSocket/socketCmd")
require("MahjongHall/Friend/SystemMessageData")
require("MahjongSocket/NetConfig")
require("MahjongHall/FriendMatch/roomConfig")
require("MahjongVoice/SCVoiceConfig")
require("MahjongConstant/GameConstant");


GlobalDataManager = class();
GlobalDataManager.instance = nil;
--更新用户信息
GlobalDataManager.updateUserInfoEvent   = EventDispatcher.getInstance():getUserEvent();
--更新主界面社交信息(魅力榜/好友)
GlobalDataManager.updateSocialInfoEvent = EventDispatcher.getInstance():getUserEvent();

--更新主界面
--GlobalDataManager.updateUserInfoEvent = EventDispatcher.getInstance():getUserEvent();

--更新界面事件
GlobalDataManager.updateSceneEvent = EventDispatcher.getInstance():getUserEvent();
--更新界面事件
GlobalDataManager.myItemListUpdated = EventDispatcher.getInstance():getUserEvent();
--用本地金币数据更新界面
GlobalDataManager.updateLocalCoinEvent = EventDispatcher.getInstance():getUserEvent();
-- 更新使用正在使用牌纸
GlobalDataManager.updatePaizhiEvent = EventDispatcher.getInstance():getUserEvent();
--更新vip信息
GlobalDataManager.updateVipSceneEvent = EventDispatcher.getInstance():getUserEvent();
-- 兑换改名卡成功事件
GlobalDataManager.exchangeCNNSEvent = EventDispatcher.getInstance():getUserEvent();
-- 兑换补签卡成功事件
GlobalDataManager.exchangeSignCardEvent = EventDispatcher.getInstance():getUserEvent();
-- 添加审核时候需要的事件
GlobalDataManager.addCheckSceneEvent = EventDispatcher.getInstance():getUserEvent();
-- 删除审核时候需要的事件
GlobalDataManager.removeCheckSceneEvent = EventDispatcher.getInstance():getUserEvent();


GlobalDataManager.hasShowUpdataInfo = false; -- 启动一次游戏，只显示一次更新
GlobalDataManager.isAotuUpdate = false;
GlobalDataManager.isAutoNotice = false;

GlobalDataManager.getInstance = function ( )
	if not GlobalDataManager.instance then
		GlobalDataManager.instance = new(GlobalDataManager);
	end
	return GlobalDataManager.instance;
end

GlobalDataManager.ctor = function ( self )
    self.screenShoting = false;
	self.gonggaoData = nil;
	self.noticeData = {};
    self.m_bCellLogin = false;
    self.m_cellBindAccount = 0;
    self.m_Record = {Timestamp = 0, friendTimerstamp = 0, list = {}, friendList = {}};--牌局记录时间戳
    self.m_lastChooseLayerData = {level = -1, str = ""};
    self.m_b_invite_match = false;--在比赛中邀请好友
    self.fm_match_invite_data = nil;--比赛 报名界面邀请好友数据
    self.m_new_register = {b_pop_charge = false, b_pop_sign = false}; --关闭新手引导后显示一次充值和签到
    self.m_enter_data = {fid = 0, type = 0, level = 0, matchType = 0};--进入游戏后，android传过来的参数 -进入好友对战或者进入比赛场  type 2 进入比赛， 其他未进入 好友对战（1或者其他）
    self.m_pop_chare_probability ={giftpack = 0.3, quick = 0.3};--弹出充值的概率
    self.m_other_config = {qqgroupnum = nil, qqgroupkey = nil, phonenum = nil}; --baseinfo 杂项配置
    self.m_b_hall_init_request_after_net_cache = false;
    self.m_control = {xl_n = 0, xz_n = 0};--每天点击血流和血战控制

    --vip 时间戳
    self.m_vip_show_str = {timestamp = 0, data = {}};

    --活动数量
    self.m_activity_count = -1;

    --商品推荐列表
    self.m_product_tuijian_list = {level = {}, vip = {}};

	self.m_phpEvent = EventDispatcher.getInstance():getUserEvent(); -- php注册回调事件
	EventDispatcher.getInstance():register(self.m_phpEvent, self, self.onUnLoginNoticeInfoCallback);

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onHttpRequestsListenster);
	EventDispatcher.getInstance():register(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);

	---
	self.fmRoomConfig = new(RoomConfig)---好友对战房间配置
	self.fmInviteInfo = nil --------------好友对战 邀请配置

	self.fmVoiceConfig = new(SCVoiceConfig)

	self.lastChestRemainNum = 5----记录最后一次玩牌房间的 再玩X牌局可领宝箱
	self.lastRoomlevel      = -1---记录上次登录的房间
    --加载字典
    --dict_load(kDictNameLoginSuccessSaveAccount);

	self.cacheDataHttpEvent = EventDispatcher.getInstance():getUserEvent();
	NetCacheDataManager.getInstance():register( self.cacheDataHttpEvent, GlobalDataManager.cacheDataHttpCallBackFuncMap , self, self.onCacheDataHttpListener );
end

--每天点击血流和血战控制
GlobalDataManager.get_control_xl = function (self)
    return self.m_control.xl_n;
end
GlobalDataManager.set_control_xl = function (self, num)
    num = tonumber(num);
    if not num then
        return;
    end

    self.m_control.xl_n = num;
end

GlobalDataManager.get_control_xz = function (self)
    return self.m_control.xz_n;
end
GlobalDataManager.set_control_xz = function (self, num)
    num = tonumber(num);
    if not num then
        return;
    end

    self.m_control.xz_n = num;
end

--重置牌局记录信息
GlobalDataManager.reset_record_info = function (self)
    self.m_Record = {Timestamp = 0, friendTimerstamp = 0, list = {}, friendList = {}};--牌局记录时间戳
end

--大厅初始化请求在网络缓存后的标记
GlobalDataManager.get_hall_init_after_net_cache = function (self)
    return self.m_b_hall_init_request_after_net_cache;
end

GlobalDataManager.set_hall_init_after_net_cache = function (self, b)
    if b ~= true then
        b = false;
    end
    self.m_b_hall_init_request_after_net_cache = b;
end

--弹出充值的概率--set
GlobalDataManager.set_pop_charge_probability = function (self,data)
    if not data or not data.giftpack or not data.quik then
        return;
    end
    self.m_pop_chare_probability.giftpack = tonumber(data.giftpack) or 0.3;
    self.m_pop_chare_probability.quick = tonumber(data.quik) or 0.7;
end

GlobalDataManager.get_pop_charge_probability = function (self)
    return self.m_pop_chare_probability
end

GlobalDataManager.get_other_config_data = function (self)
    return self.m_other_config;
end

GlobalDataManager.set_other_config_data = function (self, data)
    if not data then
        return;
    end
    if data.qqgroupnum then
        self.m_other_config.qqgroupnum = data.qqgroupnum;
    end
    if data.qqgroupkey then
        self.m_other_config.qqgroupkey = data.qqgroupkey;
    end
    if data.phonenum then
        local str_phonenum = tostring(data.phonenum )--"20160811165914|2|86|8526|8613|0000|2|8616";
        if str_phonenum then
            local tmp = string.split(str_phonenum, "|")
            if tmp and #tmp >= 2 then
               self.m_other_config.phonenum1 = tmp[1];
               self.m_other_config.phonenum2 = tmp[2];
            end
        end
    end
end



--活动数量
GlobalDataManager.set_activity_count = function (self, count)
    DebugLog("[GlobalDataManager]:set_activity_count:"..tostring(count));
    self.m_activity_count = tonumber(count) or -1;
end
--活动数量
GlobalDataManager.get_activity_count = function (self)
    DebugLog("[GlobalDataManager]:get_activity_count:"..tostring(self.m_activity_count));
    return self.m_activity_count;
end

function GlobalDataManager:requestInviteShareInfo(param)
	--if not self.fmInviteInfo then
		SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_INVITE_SHARE_INFO,param or {})
	--end
end

function GlobalDataManager:requestInviteShareInfoCallback( isSuccess, data )
	DebugLog("GlobalDataManager:requestInviteShareInfoCallback")
	if isSuccess and data then
		if data.status and tonumber(data.status) == 1 then
            self.fmInviteInfo = data.data
        end
		--pyq,qq,sms,weixin
		--icon,url,desc
	end
end

--请求比赛邀请 shareinfo
GlobalDataManager.requestMatchInviteShareInfo = function(self, param)
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_MATCH_INVITE_SHARE_INFO,param or {})
end

--比赛邀请 shareinfo  回调
GlobalDataManager.requestMatchInviteShareInfoCallback = function(self, isSuccess, data )
	DebugLog("GlobalDataManager:requestMatchInviteShareInfoCallback")
	if isSuccess and data then
		if data.status and tonumber(data.status) == 1 then
            self.fm_match_invite_data = data.data
        end
	end
end



GlobalDataManager.updateExitTipInfo = function ( self,level, process , need )
	self.lastChestRemainNum = tonumber(need or 0) - tonumber(process or 0)

	if self.lastChestRemainNum < 0 then
		self.lastChestRemainNum = 0
	end

	self.lastRoomlevel      = level or -1
end

-- 全局的更新界面类型定义
GlobalDataManager.UI_UPDATA_MONEY 			= 1; -- 更新金币
GlobalDataManager.UI_UPDATA_TASK_NUM 		= 2; -- 更新任务数量
GlobalDataManager.UI_UPDATA_FEEBACK_TIP  	= 4; -- 更新反馈数量
GlobalDataManager.UI_UPDATA_EXCHANGE_TIP  	= 5; -- 更新话费券数量
-- 发送更新界面事件
GlobalDataManager.dispatchUpdataUIEvent = function ( self, updata_type, data )
	if not updata_type then
		DebugLog("   ======= Exception : GlobalDataManager.dispatchUpdataUIEvent param updata_type is nil; ");
		return;
	end
	local temp = {};
	temp["data"] = data;
	temp["type"] = updata_type;
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent, temp);
end

GlobalDataManager.requestFriendMatchConfig = function ( self )
	DebugLog("GlobalDataManager.requestFriendMatchConfig")
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_FRIEND_MATCH_CONFIG, {})
end

GlobalDataManager.requestFriendMatchConfigCallBack = function ( self,isSuccess, data )
	DebugLog("GlobalDataManager.requestFriendMatchConfigCallBack")
	if isSuccess and data then
		self.fmRoomConfig:parseNetData(data.data)
	end
end

GlobalDataManager.requestVoiceConfig = function ( self )
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_VOICE_CONFIG, {})
end

GlobalDataManager.requestVoiceConfigCallBack = function ( self,isSuccess, data )
	if isSuccess and data then
		self.fmVoiceConfig:parseNetData(data)
	end
end

-- 请求获取已完成的任务数量
GlobalDataManager.requireTaskNum = function ( self )
	if tonumber(PlayerManager.getInstance():myself().mid) < 0 then
		return;
	end
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack( PHP_CMD_GET_TASK_NNUM, param_data)
end



--请求获取已完成的任务数量返回
GlobalDataManager.getTaskNumSuccess = function ( self, isSuccess, data )
	DebugLog("GlobalDataManager.getTaskNumSuccess")
	if not isSuccess and not data then
    	return;
    end
	if isSuccess then
		local taskNum = data.num
		GameConstant.taskType = data.pos_type or 3--默认第一个 免费福利是3
		self:dispatchUpdataUIEvent(GlobalDataManager.UI_UPDATA_TASK_NUM, taskNum)
	end
end

-- 上报确定支付订单信息
function GlobalDataManager.reportPayProductInfo(self)
	if GameConstant.payPmode and GameConstant.payOrder then
		DebugLog("上报确定支付订单信息");
		local param_data = {};
	    param_data.order = GameConstant.payOrder;
	    param_data.pmode = GameConstant.payPmode;--PHP_CMD_REPORT_PAY_PRODUCT_INFO
	    SocketManager.getInstance():sendPack( PHP_CMD_REPORT_PAY_PRODUCT_INFO, param_data)

	end
end

--请求自己的VIP信息
GlobalDataManager.getMyVipInfo = function( self )
	local param_data = {};--
	SocketManager.getInstance():sendPack( PHP_CMD_GET_USER_VIP_INFO, param_data)
end

--请求自己的VIP信息返回
GlobalDataManager.getUserVipInfoCallBack = function( self, isSuccess, data )
	if not isSuccess and not data then
    	return;
    end
	if isSuccess then
		PlayerManager.getInstance():myself():initVipInfo(data);
		----更新界面上的个人信息
		if HallScene_instance then
			HallScene_instance.m_topLayer:updateUserInfo(HallScene_instance.player);
		end
	end
end


--请求获取能参加的活动数量返回
GlobalDataManager.getActivityNumSuccess = function ( self, isSuccess, data )
	if data then
		local rate 		= data.rate;
		local percent 	= data.percent;
		local url 		= data.url;
		-- local mark 		= data.mark ;
		local showText  = data.showtext;

		self:saveAndCheckActivityPushState(rate, percent, showText);
		GlobalDataManager.pushUrl = url;
		-- GlobalDataManager.pushMark= mark;

	if GlobalDataManager.pushUrl then
		GlobalDataManager.needToPushActivity = 1;
	else
		GlobalDataManager.needToPushActivity = 0;
	end

	else
		GlobalDataManager.needToPushActivity = -1;
	end

end

function GlobalDataManager:showPushActivityWnd( activityType )
	require( "MahjongHall/PushActivity/PushActivityWnd" );
	local wnd = new( PushActivityWnd, HallScene_instance, activityType );
	wnd:setOnOkClickListener( self, function( self )
		if HallScene_instance and HallScene_instance.m_bottomLayer then
			HallScene_instance.m_bottomLayer:onClickedActivityBtn();
		end
	end)
	wnd:showWnd();
end


-- @Deprecated update
-- 0 自动检测更新  1 玩家请求更新
GlobalDataManager.curRequireUpdateType = 0;
-- data 1 玩家请求更新  其他客户端自动检测更新
GlobalDataManager.onRequestGlobelPhpInfo = function ( self, cmd, data )
	local param_data = {};
	if cmd == PHP_CMD_REQUEST_NOTICE_INFO then
		if self.gonggaoData then -- 留有缓存，所以不发php请求了
			if GlobalDataManager.isAutoNotice then
				new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.notice );
			else
				self:showNoticeWindow();
			end
		else
			param_data.mid = PlayerManager.getInstance():myself().mid;
			SocketManager.getInstance():sendPack( cmd, param_data )
		end


	elseif cmd == PHP_CMD_REQUEST_VERSION_INFO then
		GlobalDataManager.curRequireUpdateType = tonumber(data) or 0;
		if GlobalDataManager.updateInfoBuffer then
			GlobalDataManager.getUpdateInfo(self, true, GlobalDataManager.updateInfoBuffer);
		else
			param_data.mid = PlayerManager.getInstance():myself().mid;
			param_data.manual = GlobalDataManager.curRequireUpdateType;
			SocketManager.getInstance():sendPack( cmd, param_data )
		end
	end
end

-- 请求更新相关信息
function GlobalDataManager:requestUpdateVersionInfo( data )
	local param_data = {};
	GlobalDataManager.curRequireUpdateType = tonumber(data) or 0;
	if GlobalDataManager.updateInfoBuffer then
		GlobalDataManager.getUpdateInfo(self, true, GlobalDataManager.updateInfoBuffer);
	else
		param_data.mid = PlayerManager.getInstance():myself().mid;
		param_data.manual = GlobalDataManager.curRequireUpdateType;
		SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_VERSION_INFO, param_data);
	end
end

-- 检查公告数据
GlobalDataManager.checkNoticeData = function ( self )
	local flag  = false;
	self.noticeData = {};
    --for k,v in pairs
    for k,v in pairs(self.gonggaoData) do
        local kt = type(k)
        local kv = type(v)
    end
	for i = 1, #self.gonggaoData do
		if not self.gonggaoData[i].title then
			flag = true;
		elseif not self.gonggaoData[i].content then
			flag = true;
		elseif not self.gonggaoData[i].link_type then
			flag = true;
		elseif not self.gonggaoData[i].link_content then
			flag = true;
		elseif not self.gonggaoData[i].start_time then
			flag = true;
		end


		if not flag then
			table.insert(self.noticeData, self.gonggaoData[i]);
			falg = false;
		end
	end

	return not (1 > #self.noticeData);
end

--根据level自动充值
GlobalDataManager.toAddCoinRecharge = function(self,scene)
	local product;
	if not scene.level or scene.level == 0 then
		product = ProductManager.getInstance():getBankruptAndNotEventProduct();
	else
		product = ProductManager.getInstance():getRecommendProductByEvent(scene.level);
	end
	if not product then
		Banner.getInstance():showMsg("正在获取数据，请稍候...");
		return;
	end
	product.payScene = scene;
	PlatformFactory.curPlatform:pay(product);
end

--指定金额充值
GlobalDataManager.quickPay = function(self , money , scene, moneytype)
	local product = ProductManager.getInstance():getProductByPamount(money, moneytype);
	if not product then
		Banner.getInstance():showMsg("正在获取数据，请稍候...");
		return;
	end
	product.payScene = scene;
	PlatformFactory.curPlatform:pay(product);
end

--拉取推荐商品
GlobalDataManager.getTuiJianProduct = function ( self )
	SocketManager.getInstance():sendPack(PHP_CMD_GET_TUI_JIAN_PRODUCT,{})
end

--拉取推荐商品
GlobalDataManager.getTuiJianProductBack = function ( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end
	DebugLog("拉到了推荐配置");
	GameConstant.isNewLevelRecommendAmount = {}; -- 场次推荐的所有金额
	GameConstant.isNewVipRecmmonedAmount = {}; -- vip推荐的所有金额

    self.m_product_tuijian_list.level = {};
    self.m_product_tuijian_list.vip = {};

	if not data.status then
		return;
	end

	if 1 == tonumber(data.status) and data.data then
		GameConstant.level_tuiJianProduct = data.data.goods;
		GameConstant.vip_tuiJianProduct = data.data.vipgoods;
		for k,v in pairs(GameConstant.level_tuiJianProduct) do
			local flag = false;--flag的作用是去除重复
			for i = 1 , #GameConstant.isNewLevelRecommendAmount do
				if (GameConstant.isNewLevelRecommendAmount[i] == tonumber(v)) then
					flag = true;
					break;
				end
			end
			if not flag then
                table.insert( self.m_product_tuijian_list.level, {_level = k, v = tonumber(v)});
				--table.insert(GameConstant.isNewLevelRecommendAmount,tonumber(v));
			end
		end

		for k,v in pairs(GameConstant.vip_tuiJianProduct) do
			local flag = false;
			for i = 1 , #GameConstant.isNewVipRecmmonedAmount do
				if (GameConstant.isNewVipRecmmonedAmount[i] == tonumber(v)) then
					flag = true;
					break;
				end
			end
			if not flag then
                table.insert( self.m_product_tuijian_list.vip, {_vip = k, v = tonumber(v)});
				--table.insert(GameConstant.isNewVipRecmmonedAmount,tonumber(v));
			end
		end
		if #GameConstant.isNewLevelRecommendAmount ~= 0 then
			table.sort(GameConstant.isNewLevelRecommendAmount,function(s1,s2) return s1 < s2 end);
		end

		if #GameConstant.isNewVipRecmmonedAmount ~= 0 then
			table.sort(GameConstant.isNewVipRecmmonedAmount,function(s1,s2) return s1 < s2 end);
		end

		ProductManager.getInstance():parseRecommendVipProduct();
		ProductManager.getInstance():parseRecommendLevelProduct();
	end
end

GlobalDataManager.get_list_default = function (self)
    local list = {};
    local vip_list = GlobalDataManager.getInstance().m_product_tuijian_list.vip;
    if not vip_list or #vip_list < 1 then
        return list;
    end


    local productList = ProductManager.getInstance().m_productListSource or {};
	for i=1,#vip_list do
         for j = 1,#productList do
            if productList[j].pamount and tonumber(productList[j].pamount) == vip_list[i].v and productList[j].ptype and productList[j].ptype == 0 then
                productList[j]._vip = tonumber(vip_list[i]._vip);
                table.insert(list, productList[j]);
                break;
            end
         end
    end


    local ret_list = {};
    local list_key = {};
    --去除重复价格的列表
    for i = 1, #list do
        if not list_key[list[i].pamount] then
            list_key[list[i].pamount] = true;
            local tmp = Copy(list[i])
            table.insert(ret_list, tmp);
        end
    end

    list = ret_list;
    if #list > 0 then
        --根据pamount 排序
        local sort_paymount = function (v1 , v2)
	        return (tonumber(v1.pamount) or 0) < (tonumber(v2.pamount) or 0)
        end
        table.sort(list, sort_paymount);
    end
    return list;
end

--获取钻石列表
GlobalDataManager.get_list_diamond = function (self)
    local list = {};
    local list_source = ProductManager.getInstance().m_productListSource or {};
    for i = 1, #list_source do
        if list_source[i].ptype == 1 then
            table.insert(list, list_source[i]);
        end
    end
    return list;
end
--[Comment]
--根据level 来挑选 产品列表
GlobalDataManager.get_list_level = function (self)

    local list = {};
    local level_list = GlobalDataManager.getInstance().m_product_tuijian_list.level;
    if not level_list or #level_list < 1 then
        return list;
    end

    local productList = ProductManager.getInstance().m_productListSource;
	for i=1,#level_list do
         for j = 1,#productList do
            local pamount = tonumber(productList[j].pamount) or -1;
            if pamount == level_list[i].v and productList[j] and productList[j].ptype == 0 then
                local tmp = Copy(productList[j])
                tmp._level = tonumber(level_list[i]._level);
                table.insert(list, tmp);
                break;
            end
         end
    end

    if #list > 0 then
        --根据pamount 排序
        local sort_paymount = function (v1 , v2)
	        return (tonumber(v1.pamount) or 0) < (tonumber(v2.pamount) or 0)
        end
        table.sort(list, sort_paymount);
    end
    return list;
end

-- 拉取破产补助
GlobalDataManager.getBankraptcyConfig = function ( self )
	SocketManager.getInstance():sendPack(PHP_CMD_GET_BANKRAPTCY_CONFIG,{})
end

--破产配置返回
GlobalDataManager.getBankraptcyConfigCallBack = function (self, isSuccess, data)
	if not isSuccess or not data then
		return;
	end
	GameConstant.bankruptMoney = GetNumFromJsonTable(data, "bankruptmoney") or 1000;
	DebugLog("【破产配置】破产限额为："..GameConstant.bankruptMoney);
end



-- 拉取大厅配置回调
GlobalDataManager.requestHallConfigCallBack = function (self , isSuccess ,data ,jsonData)
	--
	if not isSuccess or not data then
		NetCacheDataManager.getInstance():realRequestHttpCmd(PHP_CMD_REQUEST_NEW_HALL_CONFIG)
		return;
	end

	if not data.status then
		NetCacheDataManager.getInstance():realRequestHttpCmd(PHP_CMD_REQUEST_NEW_HALL_CONFIG)
		return;
	end

	-- 大厅配置读取成功
	if data.status == 1 then
		local lastTime = 1;
		local hallData = data.data;
		if not HallConfigDataManager.getInstance():isSetHallData() and not hallData then
			g_DiskDataMgr:setAppData(kHallConfigDictKey_Value.HallConfigTime, 1)
			NetCacheDataManager.getInstance():realRequestHttpCmd(PHP_CMD_REQUEST_NEW_HALL_CONFIG)
			return;
		end
		if hallData then
            lastTime = data.data.time;
			HallConfigDataManager.getInstance():setHallDataFromCacheData(hallData);
			g_DiskDataMgr:setAppData(kHallConfigDictKey_Value.HallConfigTime, lastTime)
			g_DiskDataMgr:setFileData(kHallConfigDict, data)
		end

		DebugLog( "GlobalDataManager.requestHallNewConfigCallBack" );
		DebugLog("血战场数据:")
--		--mahjongPrint(HallConfigDataManager.getInstance():returnHallDataForXZ());
		DebugLog("血流场数据:")
--		--mahjongPrint(HallConfigDataManager.getInstance():returnHallDataForXL());
		DebugLog("更多场数据:");
--		--mahjongPrint(HallConfigDataManager.getInstance().m_hallData["lfp"]);

		GameConstant.level = HallConfigDataManager.getInstance():returnAllHallDataLevel();
		table.insert(GameConstant.level , GameConfig.privateRoomLevel);
	elseif data.status == 0 then   --时间戳和本地的相同,直接读取本地的
        if not HallConfigDataManager.getInstance():isSetHallData() then
            local oldData = g_DiskDataMgr:getFileData(kHallConfigDict, nil)
            if oldData then
                HallConfigDataManager.getInstance():setHallDataFromCacheData(oldData);
            end
        end
	else
		NetCacheDataManager.getInstance():realRequestHttpCmd(PHP_CMD_REQUEST_NEW_HALL_CONFIG)
	end

end

--拉取比赛场配置信息
function GlobalDataManager.requestMatchConfig(self)
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_MATCH_CONFIG,{})
end

--拉取比赛场列表相关信息
function GlobalDataManager.requestMatchConfigCallBack(self, isSuccess, data, jsonData)
	if not isSuccess or not data then
		return;
	end

	if tonumber(data.status) == 1 then
		local matchData = data.data;
		if matchData then
			HallConfigDataManager.getInstance():setMatchDataFromCacheData(matchData);
			--DebugLog( "GlobalDataManager.requestMatchNewConfigCallBack" );
			DebugLog("比赛场数据:::");
			mahjongPrint(data);
		else
			self:requestMatchConfig();
		end
	end
end

GlobalDataManager.onRequestMyItemList = function ( self )
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_MY_ITEM_LIST,{})
end

GlobalDataManager.getPayConfig = function(self)
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	param.isnew = 1;
	param.telephone = GameConstant.phone;
	local newurl = "?m=pay&p=payconf";
	local socketType = NetConfig.getInstance():getCurSocketType()
	--if DEBUGMODE == 1 and socketType == 1 then

	--	newurl = DevDefaultNetHost[1] .. newurl;

	--else
		newurl = GameConstant.CommonUrl .. newurl;
	--end
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_PAY_CONFIG,param,newurl)
end

GlobalDataManager.requestPayConfigCallBack = function(self,isSuccess,data)
	if not isSuccess or not data then
		--ios 配置了默认支付配置，如果没拉取到就下次拉取 不需要提示
		if GameConstant.iosDeviceType>0 then
			return ;
		end
		Banner.getInstance():showMsg("连接异常，请检查网络后再试!");
		return;
	end
    GameConstant.useLastPayType = data.uselastpaytype or 0  --默认关闭
	if tonumber(data.status) == 1 then
		-- local data = data.data
		local payTable = {}
		for k ,v in pairs(data.data) do
			local id = tonumber(v.id) or 0
			local tips = tonumber(v.tips) or -1
			local limit = tonumber(v.limit) or -1

			if id == PlatformConfig.UnicomPay and (PlatformConfig.platformWOSHOP == GameConstant.platformType
				or PlatformConfig.platformUnicomWdj == GameConstant.platformType) then
				id = PlatformConfig.UnicomOnlyPay;
			end

			if id == PlatformConfig.WDJMMPay then
				id = PlatformConfig.MMPay;
			end

			if id == PlatformConfig.WDJUnicomPay then
				id = PlatformConfig.UnicomPay;
			end

			if id == PlatformConfig.WDJEgamePay then
				id = PlatformConfig.EGamePay;
			end

			if id == PlatformConfig.EGamePay and (PlatformConfig.platformYiXin == GameConstant.platformType) then
				id = PlatformConfig.YiXinPay;
			end

			if id ~= 0 then
				local data  = {id=id,tips=tips,limit=limit}
				local configData = { pclientid=id, ptips=tips, plimit=limit}
				table.insert(payTable, configData)
			end

		end
		PayController:initPayConfig(payTable)
	end

end

GlobalDataManager.serverNoticeMoneyUpdate = function ( self , data )
	-- body
	--data.mid,data.info
	--
	local myself = PlayerManager.getInstance():myself()
	if data and data.info then
		if data.mid == myself.mid then
			myself.vipLevel = tonumber(data.info.vip) or myself.vipLevel

			myself:setMoney(tonumber(data.info.money) or myself.money) --   =

			local coinRain  = tonumber(data.info.coinflag) or 0 --是否要下金币雨，0不下，1下
			local popDialog = tonumber(data.info.titleflag) or 0 --弹框方式：0没有弹框，1弹下拉框，2弹对话框
			local msg       = data.info.msg or ""--

			if coinRain == 1 then
				showGoldDropAnimation()
			end

			if popDialog == 1 then
				Banner.getInstance():showMsg(msg)
			elseif popDialog == 2 then
				PopuFrame.showNormalAlertView(nil , msg, GameConstant.curGameSceneRef)
			end
		end
	end
end

--比赛：服务器发给客户端的一个通用的消息
GlobalDataManager.server_match_common_tip = function (self, data)
    DebugLog("[GlobalDataManager]:server_match_common_tip");
    if data and data.cmdRequest == SERVER_TO_MSG_CLIENT then---0x044 --服务器发给客户端的通用消息
        local j_str = data.j_str;
        if not j_str then
            DebugLog(data);
            return;
        end
        local msg = j_str.m;

        if tonumber(j_str.t) == 1 then  --类型 1、下拉框  2、弹框   先判断类型，再判断标记
            if msg then
                Banner.getInstance():showMsg(msg);
            end
        elseif tonumber(j_str.t) == 2 then
            local flag = tonumber(j_str.f); --"f":1,		//int,标记 0、默认,只弹框展示 1、用于比赛开赛前提醒
            local title = j_str.ti or "温馨提示"; -- "ti":"温馨提醒",	//string,弹框的标题，下拉框不使用
            local s = tonumber(j_str.s) or 2;  --      "s":弹框大小控制，下拉框不使用，1、大号弹框 2、小号弹框
            local str_matchid = j_str.mid;  --比赛的matchid--通过matchid分解得出level和type

            if not flag then
               return;
            end

	        local content = msg or "";
            local b_use_big = (s ~= 2 and true) or false;
            local b_just_mid = false; --true显示中间的按钮，false显示左右两个按钮
            local b_show_close = false;--是否显示右上角关闭按钮
	        local view = nil

            if flag == 0 then
                b_just_mid = true;
                view = PopuFrame.showNormalDialogForCenter(title, content,nil, nil, nil, b_just_mid, b_use_big,nil,nil,b_show_close);
                if view then
                    view:setConfirmBtnText("确定");
	                view:setConfirmCallback(view, function ( view )

	                end);
                end
            elseif flag == 1 then
                --游戏场内只显示我知道了就可以了
                b_just_mid = HallScene_instance and false or true;
                view = PopuFrame.showNormalDialogForCenter(title, content,nil, nil, nil, b_just_mid, b_use_big,nil,nil,b_show_close);
                if view then
                    if not HallScene_instance then
                        view:setConfirmBtnText("我知道了");
                        view:set_btn_middle_visible(true);
                        view:set_btn_left_right_visible(false);
                    end

	                view:setConfirmCallback(view, function ( view)
                        if HallScene_instance then
                            local matchtype, level = global_get_type_and_level_by_matchid(str_matchid);
                            if not matchtype or not level then
                                DebugLog("error type:"..tostring(matchtype).." level:"..tostring(level));

                                return;
                            end
                            HallScene_instance:onGoToMatchRoom( level, matchtype );
                        end
	                end);
                end
            end
        end
    end
end
--server推送给客户端钻石变化结果
GlobalDataManager.server_notice_update_diamond = function ( self , data )
--  uinfo["type"]=nactid;
--  uinfo["Diamond"]=nDiamond;          // 玩家当前的钻石数
--  uinfo["turnDiamond"]=nTurnDiamond;// 变化了的钻石数
--  uinfo["vip"]=nVip;            //vip等级
--  uinfo["coinflag"]=coinflag;   //是否要下钻石雨，0不下，1下
--  uinfo["titleflag"]=titleflag; //弹框方式：0没有弹框，1弹下拉框，2弹对话框
--  uinfo["msg"]=msg;             //提示内容
	local myself = PlayerManager.getInstance():myself()
	if data and data.info then
		if data.mid == myself.mid then

--            local Diamond = tonumber(data.info.Diamond) or 0;
--            local turnDiamond = tonumber(data.info.turnDiamond) or 0;

			myself.vipLevel = tonumber(data.info.vip) or myself.vipLevel

		    myself:set_diamond(tonumber(data.info.Diamond) or myself.boyaacoin) --   =

			local coinRain  = tonumber(data.info.coinflag) or 0 --是否要下金币雨，0不下，1下
			local popDialog = tonumber(data.info.titleflag) or 0 --弹框方式：0没有弹框，1弹下拉框，2弹对话框
			local msg       = data.info.msg or ""--

			if coinRain == 1 then
				showGoldDropAnimation()
			end

			if popDialog == 1 then
				Banner.getInstance():showMsg(msg)
			elseif popDialog == 2 then
				PopuFrame.showNormalAlertView(nil , msg, GameConstant.curGameSceneRef)
			end
		end
	end
end



GlobalDataManager.socketUpdateMoney = function ( self, data )
    DebugLog("[GlobalDataManager]:socketUpdateMoney");
    if not data then
        DebugLog("data is nil");
        return;
    end
    if data.curType == REQUEST_MAIL then
        --请求系统消息--拉取奖励的邮件
        GlobalDataManager.getInstance():requestSystemMessage()
        return;
    end
	if tonumber(data.curType) == HALL_SERVER_UPDATE_FEEBACK_TIP then
		FeeBackData.getInstance():setFeeBackTipNum(tonumber(data.feeBackTipNum or 0));
		local param = {};
		param.type = GlobalDataManager.UI_UPDATA_FEEBACK_TIP;
		EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent, param);

		--弹出tip (全局范围内)
		Banner.getInstance():showMsg( "您的反馈有新的回复，请及时查看" );
	end

	if tonumber(data.curType) == HALL_SERVER_UPDATE_MONEY then

		data = data.updateMoneyTable;
		local reason = data.reason;  --1:需要更新金币  2:需要更新博雅币  3:需要更新积分 4:道具
		local money = data.money;
		local bycoin = data.bycoin;
		local ptype = data.ptype;
		local msg = data.msg;
		local chips = data.chips;
		local pmode = data.pmode;
		local pdealno = data.pdealno;
		local isNeedDoAnimation = false;
		if reason == 1 then
			PlayerManager.getInstance():myself().money = money;

			FirstChargeView.getInstance():requestFirstChargeData();

			self:getPayConfig();

			--通知其他完成金币变化
			--如果在游戏中
			if RoomScene_instance and not FriendMatchRoomScene_instance then
				local param_data = {};
				param_data.mid = PlayerManager.getInstance():myself().mid;
				SocketSender.getInstance():send(CLIENT_COMMAND_GET_NEW_MONEY, param_data);
				local object = RoomScene_instance;
				object:getRoomActivityInfo();
			end
			AnimationAwardTips.play(msg);
			showGoldDropAnimation();
			if tonumber(ptype) ~= -1 and tonumber(ptype) ~= 0 then
				local param = {};
				param.ptype = ptype;
				param.mid = PlayerManager.getInstance():myself().mid;
				-- native_to_java(kSaveLastPay,json.encode(param));
				g_DiskDataMgr:setUserData(param.mid, kSavePay, param.ptype)
			end
			if pmode and pmode>0 then
				g_DiskDataMgr:setUserData(PlayerManager.getInstance():myself().mid, "savepmode", pmode)
				DebugLog("savepmode:"..tostring(pmode));
				if pdealno then
					DebugLog("pdealno:"..tostring(pdealno));
					if pmode==99 then
						local appleparam = {};
						appleparam.pdealno = pdealno;
						native_to_java("CallApplePayOK",json.encode(appleparam));
					end
				end
			end
		elseif reason == 2 then
			Banner.getInstance():showMsg(msg);
			PlayerManager.getInstance():myself().boyaacoin = bycoin;
			EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent);
			showGoldDropAnimation();
			if pmode and pmode>0 then
				g_DiskDataMgr:setUserData(PlayerManager.getInstance():myself().mid, "savepmode", pmode)
				DebugLog("savepmode:"..tostring(pmode));
				if pdealno then
					DebugLog("pdealno:"..tostring(pdealno));
					if pmode==99 then
						local appleparam = {};
						appleparam.pdealno = pdealno;
						native_to_java("CallApplePayOK",json.encode(appleparam));
					end
				end
			end
		elseif reason == 3 then
			Banner.getInstance():showMsg(msg);
			PlayerManager.getInstance():myself().chips = chips;
			EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent);
		elseif reason == 4 then --购买oppo 体验vip的返回
			AnimationAwardTips.play(msg);
			--showGoldDropAnimation();
			EventDispatcher.getInstance():dispatch(GlobalDataManager.updateVipSceneEvent);
            if HallScene_instance then
                HallScene_instance.m_topLayer:clearExpData()
            end
            if GameConstant.m_vipExpAnim then
                delete(GameConstant.m_vipExpAnim)
                GameConstant.m_vipExpAnim = nil
            end
            GameConstant.m_vipExpTime = 0
        elseif reason == 5 then--刷新vip
            GlobalDataManager.getInstance():getMyVipInfo();
            EventDispatcher.getInstance():dispatch(GlobalDataManager.updateVipSceneEvent);
		elseif reason == 98 then --oppo 体验vip 刷新操作，保留
			if money == 1000 then  --1000这个值不知道为啥
                GlobalDataManager.getInstance():getMyVipInfo();
                EventDispatcher.getInstance():dispatch(GlobalDataManager.updateVipSceneEvent);
            end
		elseif msg then
			Banner.getInstance():showMsg(msg);
		end
		require( "MahjongData/BaseInfoManager" );
		BaseInfoManager.getInstance():refreshCards();

	elseif data.curType == SERVER_MATCHAWARDHUAFEI_RES then
		PlayerManager.getInstance():myself():setCoupons(data.huafeijuan);
		if 1 == data.showFlag and data.showStr ~= nil and data.showStr ~= "" then
			AnimationAwardTips.load(data.showStr);
		end
	elseif data.curType == HALL_PUSH_MONEY then
		PlayerManager.getInstance():myself().money = data.money;
		EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent);
	elseif data.curType == SERVER_MATCHAWARDCARD_RES then

		if 1 == data.showFlag and data.showStr ~= nil and data.showStr ~= "" then
			AnimationAwardTips.load(data.showStr);
		end

		local info = json.mahjong_decode_node(data.card);
		local laba = info["22"] or 0
		if laba then
			GameConstant.changeNickTimes.propnum = tonumber(laba);
		end

		-- Untested
		require( "MahjongData/BaseInfoManager" );
		BaseInfoManager.getInstance():refreshCards();
	end
end

--通知界面更新金币信息
--在需要更新界面的地方注册GlobalDataManager.updateSceneEvent事件。
GlobalDataManager.updateScene = function( self )
	if GameConstant.isSingleGame then
		return;  --单机游戏中不核对金币数
	end
	DebugLog("【开始与服务器核对金币数据】");
	local param_data = {};
	param_data.fields = {"money","boyaacoin"};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(PHP_CMD_GET_USER_INFO, param_data)
end

GlobalDataManager.updateLocalCoin = function( self )
	EventDispatcher.getInstance():dispatch(GlobalDataManager.updateLocalCoinEvent);
end

--核对用户信息回调
GlobalDataManager.getUserInfo = function ( self, isSuccess, data )
	if not isSuccess and not data then
		return;
	end
	if isSuccess then
		if GameConstant.isSingleGame then
			return;  --单机游戏中不分发金币数
		end
		local money = GetNumFromJsonTable(data, "money", -1);
		local boyaacoin = GetNumFromJsonTable(data, "boyaacoin", -1);
		if money and boyaacoin and money ~= -1 and boyaacoin ~= -1 then
			local player = PlayerManager.getInstance():myself();
			player.money = money;
			player.boyaacoin = boyaacoin;
			DebugLog("【http通知所有界面更新金币】");
			EventDispatcher.getInstance():dispatch(GlobalDataManager.updateSceneEvent);
		end
	end
end

--获取破产补助
GlobalDataManager.getBankraptcyRemedy = function( self )
	local param_data = {};
	param_data.mid = PlayerManager.getInstance():myself().mid;
	param_data.sitemid = SystemGetSitemid();
	SocketManager.getInstance():sendPack(PHP_CMD_GET_BANKRAPTCY_REMEDY,param_data)
end

--破产PHP回调
GlobalDataManager.getBankraptcyRemedyCallBack = function (self, isSuccess, data)
	if not isSuccess and not data then
	    return;
	end
	if GetNumFromJsonTable(data, "status") == 1 then
		local money = GetNumFromJsonTable(data, "money");
		local msg = "您破产了，系统送您"..money.."金币";
		AnimationAwardTips.play(msg);
		showGoldDropAnimation();
		PlayerManager.getInstance():myself().money = PlayerManager.getInstance():myself().money + money;
		self:updateScene();
		GameConstant.hasShowBankTips = false;

		if self.m_bankruptObj and self.m_bankruptObj.bankDlg then
			self.m_bankruptObj.bankDlg:hideWnd()
		end
	else
		if not GameConstant.hasShowBankTips then
			local msg = "您今日的破产次数已经超过上限";
			Banner.getInstance():showMsg(msg);
			GameConstant.hasShowBankTips = true;
		end
	end
end

function GlobalDataManager.requestUnLoginNoticeInfo(self)
	DebugLog("GlobalDataManager.requestUnLoginNoticeInfo")
	if self.isRequestingUnLogin then
		return
	end
	self.isRequestingUnLogin = true
	HttpModule.getInstance():execute(HttpModule.s_cmds.requestUnLoginNotice, {},self.m_phpEvent);
end

function GlobalDataManager.onUnLoginNoticeInfoCallback( self,command, isSuccess, data , jsonData)
 	DebugLog("GlobalDataManager.onUnLoginNoticeInfoCallback-------")
 	if command == HttpModule.s_cmds.requestUnLoginNotice then
 		if isSuccess and data then
 			local status = data.status
 			if status and status == 1 then
 				self:showUnLoginNoticeWindow(data)
 			end
 		else
 			self.isRequestingUnLogin = false
 		end

 	end
end

function GlobalDataManager.showUnLoginNoticeWindow( self,data )
 	require("MahjongCommon/NoticePopWindow");
 	local pop = new(NoticePopWindow, data.data,true);
 	pop:setLevel(100)
 	pop:addToRoot()
 	pop:setOnWindowHideListener(self,function ( self )
 		self.isRequestingUnLogin = false
 	end)
 	pop:showWnd()
end


GlobalDataManager.getNoticeInfo = function ( self, isSuccess, data )
	log( "GlobalDataManager.getNoticeInfo" );
	if isSuccess and data then
		if not data.status then
			self.gonggaoData = nil;
			return;
		end
		self.gonggaoData = data.data;
		if 1 == tonumber(data.status) then
			new_pop_wnd_mgr.get_instance():add_and_show( new_pop_wnd_mgr.enum.notice );
		elseif -1 == tonumber(data.status) then
			-- 无公告时的提示信息
			self.noGonggaoMsg = data.msg or "暂无公告，祝您游戏快乐！";
			new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.notice );
		end
	end

	if GlobalDataManager.isAutoNotice then
		GlobalDataManager.isAutoNotice = false;
	end

end

-- 显示公告窗口
GlobalDataManager.showNoticeWindow = function ( self )
	log( "GlobalDataManager.showNoticeWindow" );
	if GlobalDataManager.isAutoNotice then
		if not self:checkNoticeData() then
			new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.notice );
			return;
		end
		GlobalDataManager.isAutoNotice = false;
	else
		if not self:checkNoticeData() then
			Banner.getInstance():showMsg( self.noGonggaoMsg );
			return;
		end
	end

	if HallScene_instance then
		if not HallScene_instance.showTeachPopFlag then
			-- 显示公告窗口
			require("MahjongCommon/NoticePopWindow");
			HallScene_instance.popuview = new(NoticePopWindow, self.noticeData);
			HallScene_instance.popuview:setLevel(99999)
			HallScene_instance.m_mainView :addChild(HallScene_instance.popuview);
			HallScene_instance.popuview:showWnd();
		end
	end
end

GlobalDataManager.showDownloadPopuFrame = function ( self )
	local view = PopuFrame.showNormalDialog( "下载", "    是否下载游戏资源？", GameConstant.curGameSceneRef, nil, nil, false );
	view:setConfirmCallback(self, function ( self )
		self:downloadRes(GameConstant.DOWNLOAD_RES_TYPE_ALL,true);
	end);
	view:setCallback(view, function ( view, isShow )
		if not isShow then

		end
	end);
	view:setHideCloseBtn(true);
end

-- 获取下载资源信息
GlobalDataManager.getDownloadResInfo = function ( self, isManualDownload )
    DebugLog("getDownloadResInfo:"..tostring(GameConstant.resVer));
	if isFirstStartGame() and not isManualDownload then
		DebugLog("第一次启动,非手动不下载资源");
		return;
	end

	if 1 == GameConstant.downloadstatus then
		return;
	end

	GameConstant.isDownloading = true;

	local post_data = {};
	post_data.api = PlatformFactory.curPlatform.api;
	post_data.ver = GameConstant.resVer or "1.3.0";
	if GameConstant.platformType == PlatformConfig.platformGuangDianTong then
		post_data.ver = GameConstant.resVer or "1.3.1";
	end
	post_data.src = 2;
	SocketManager.getInstance():sendPack(PHP_CMD_DOWNLOAD_RES,post_data)

end

GlobalDataManager.downloadType = GameConstant.DOWNLOAD_RES_TYPE_ALL;

-- 下载资源的接口
-- GameConstant.DOWNLOAD_RES_TYPE_ALL;
GlobalDataManager.downloadRes = function( self, resType, isManualDownload )
	GlobalDataManager.downloadType = resType;
	self:getDownloadResInfo( isManualDownload );
end

GlobalDataManager.isActivityDownload = false; -- 是否是玩家主动下载
GlobalDataManager.getDownloadInfoComplite = function ( self, isSuccess, data )
	if isSuccess and data then
		if tonumber(data.status) == 1 then
			local srctb = data.source;
            if not srctb then
                Banner.getInstance():showMsg("下载失败，请稍后重试");
			    GlobalDataManager.isActivityDownload = false;
                return;
            end
			local url = nil;
			local param = {};
			local param_data = {};
			for i = 1 , #srctb do
				if GameConstant.platformType == PlatformConfig.platformGuangDianTong then
					if GlobalDataManager.downloadType == GameConstant.DOWNLOAD_RES_TYPE_SOUND then
						if tonumber(srctb[i].type) == GameConstant.DOWNLOAD_RES_TYPE_SOUND then
							self:createDownloadResItem( param_data, i, srctb );
							break;
						end
					elseif GlobalDataManager.downloadType == GameConstant.DOWNLOAD_RES_TYPE_FACE then
						if tonumber(srctb[i].type) == GameConstant.DOWNLOAD_RES_TYPE_FACE then
							self:createDownloadResItem( param_data, i, srctb );
							break;
						end
					elseif GlobalDataManager.downloadType == GameConstant.DOWNLOAD_RES_TYPE_FRIEND_ANIM then
						if tonumber(srctb[i].type) == GameConstant.DOWNLOAD_RES_TYPE_FRIEND_ANIM then
							self:createDownloadResItem( param_data, i, srctb );
							break;
						end
					elseif GlobalDataManager.downloadType == GameConstant.DOWNLOAD_RES_TYPE_MP4 then
						if tonumber(srctb[i].type) == GameConstant.DOWNLOAD_RES_TYPE_MP4 then
							self:createDownloadResItem( param_data, i, srctb );
							break;
						end
					else
						self:createDownloadResItem( param_data, i, srctb );
					end
				else
					self:createDownloadResItem( param_data, i, srctb );
				end
			end

			param["result"] = param_data;
			param["wifi"] = 0;
			param["tips"] = 1;
			param["is_repeat"] = GlobalDataManager.isActivityDownload and 1 or 0; -- 重复下载
			local dataStr = json.encode(param);
			DebugLog("下载参数："..(dataStr or "nil"));
			if publ_downloadResLua(dataStr) and GlobalDataManager.isActivityDownload then
				Banner.getInstance():showMsg("开始下载资源");
			elseif GlobalDataManager.isActivityDownload then
				Banner.getInstance():showMsg("下载失败，请稍后重试");
				GlobalDataManager.isActivityDownload = false;
			end
		elseif GlobalDataManager.isActivityDownload then
			Banner.getInstance():showMsg("下载失败，请稍后重试");
			GlobalDataManager.isActivityDownload = false;
		end
	else
		GlobalDataManager.isActivityDownload = false;
	end
end

GlobalDataManager.createDownloadResItem = function( self, param_data, i, srctb )
	local temp={};
	temp.isopen=srctb[i].open
	temp.type  =srctb[i].type
	temp.url   =srctb[i].url
	param_data[#param_data+1] = temp;
end

GlobalDataManager.hasOpenActivity = false;     -- 是否已经打开过活动
GlobalDataManager.callEvent = function ( self, param, data )
	if kDownloadRes == param then
		DebugLog( "GlobalDataManager.callEvent "..kDownloadRes );
		self:downloadEvent(param, data);
	elseif param == kActivityGoFunction then   -- 活动跳转

	elseif kUpdateVersion == param then        --更新下载进度
		local progress_value = data.current
		local total_size = data.total_size
        if not GameConstant.totalSizeTemp then
            GlobalDataManager.NewUpDateWnd:set_package_size( total_size );
        end
		GameConstant.totalSizeTemp = total_size
		self:updateDownload(progress_value, total_size);
        DebugLog("[更新下载进度]:GameConstant.totalSizeTemp:"..tostring(GameConstant.totalSizeTemp));

	elseif kUpdateSuccess == param then       -- 下载更新完成
		self:updateSuccess(param, data);
		self:updateDownload(100, GameConstant.totalSizeTemp);
        DebugLog("[下载更新完成]:GameConstant.totalSizeTemp:"..tostring(GameConstant.totalSizeTemp));
	elseif kUpdating == param then            -- 更新过程中的异常
		self:updatingAlert(param, data)
	elseif kGeTuiGetClientId == param then    --得到个推ClientId
		self:getGeTuiClientId(param, data)
	elseif kGeTuiGetMessage == param then     --得到个推的消息
		self:getGeTuiMessage(param, data)
	elseif kGeTuiCell == param then           --得到个推的Cell
		self:getGeTuiCell(param, data)
	elseif "umengUpdataCallback" == param then--umeng更新回调
		self:umengCallback(param, data)
	elseif kMutiShare == param then           --分享回调
		local param_data = {};
		param_data.mid 		= PlayerManager.getInstance():myself().mid;
		SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_NOTICE_PHP_SHARE, param_data)
	elseif kStartActivty == param then        -- 活动关闭事件
		DebugLog("activityClose:" .. tostring(GameConstant.activityJumpToOtherView) .. ", HallScene_instance:" .. tostring(HallScene_instance))
		if PlatformFactory.curPlatform and PlayerManager.getInstance():myself().mid > 0 then -- 更新一次金币
			GlobalDataManager.getInstance():updateScene();
		end
		--GameConstant.switchAnimIsOpen
		if not GameConstant.activityJumpToOtherView then
			if HallScene_instance then
				HallScene_instance:preEnterHallState()
				HallScene_instance:playEnterHallAnim();
			end
		end
		GameConstant.activityJumpToOtherView = nil
	elseif "qqAddGroupFailed" == param then
		Banner.getInstance():showMsg("请确定安装了QQ客户端后重新再试");

	elseif "serviceClose" == param then  -- 关闭服务条款、用户条款

	elseif kSubscribeForMobileGamer == param then
		self:subscribeForMobileGamer(param, data)
	elseif kFetionGetFriendList == param then
		local status 	= data.stat or -1;
		local code 		= data.code or "";
		FriendDataManager.getInstance():onFetionGetFriendList(status, code);
	elseif kDingkaiCoin == param then

	elseif kShowAwardView == param then
		GlobalDataManager.getInstance():gotoScoreMatch();

	elseif param == kCheckWechatInstalled then
		local QQState = data.QQState
		local wechatState = data.wechatState
		DebugLog( "QQState "..QQState );
		DebugLog( "wechatState "..wechatState );

		if QQState and tonumber( QQState ) == 1 then
			GameConstant.isQQInstalled = true;
		else
			GameConstant.isQQInstalled = false;
		end

		if wechatState and tonumber( wechatState ) == 1 then
			GameConstant.isWechatInstalled = true;
		else
			GameConstant.isWechatInstalled = false;
		end
	elseif param == kEnterRoom then
        DebugLog("param == kEnterRoom");
		local fid       = data.fid
		--GameConstant.fid = fid
        GlobalDataManager.getInstance().m_enter_data.fid = fid or 0;
        GlobalDataManager.getInstance().m_enter_data.type = data.type or 0;
        GlobalDataManager.getInstance().m_enter_data.level = data.level or 0;
        GlobalDataManager.getInstance().m_enter_data.matchType = data.matchType or 0;
        if true then
            DebugLog("000000000000000000000000");
            local t = GlobalDataManager.getInstance().m_enter_data.type;
            local fid =  GlobalDataManager.getInstance().m_enter_data.fid
            local level =  GlobalDataManager.getInstance().m_enter_data.level
            local matchType =  GlobalDataManager.getInstance().m_enter_data.matchType

            DebugLog("type:"..tostring(t));
            DebugLog("fid:"..tostring(fid));
            DebugLog("level:"..tostring(level));
            DebugLog("matchType:"..tostring(matchType));
        end
		if HallScene_instance then
            --
            local t = tonumber(GlobalDataManager.getInstance().m_enter_data.type) or 1 ;
            if t == 1 then
                HallScene_instance:checkNeedGotoFMR()
            elseif t == 2 then
                HallScene_instance:check_to_match()
            end

		end
    elseif param == kScreenShot then--截屏，现在参数只返回qrcord 二维码
        if self.screenShoting == true then
            return;
        end
        self.screenShoting = true;

		local filename = data.filename;
        global_share_data.q = tostring(filename)..".png";
        DebugLog("GlobalDataManager.callEvent kScreenShot filename:"..tostring(global_share_data.qrcode));

        --global_show_share_wnd();

        self.screenShoting = false;
	end
end

-- 订阅游戏玩家活动
GlobalDataManager.subscribeForMobileGamer = function( self, param, data )
	DebugLog("subscribeForMobileGamer");
	if not data then
		return;
	end

	local pamount = data.pamount or -1;
	if not pamount or pamount == -1 then
		return;
	end

	local productInfo = ProductManager.getInstance():getItemByPamount(pamount);
	productInfo.payScene = {};
	productInfo.payScene.scene_id = PlatformConfig.MallCoinBuyForPay;

	PlatformFactory.curPlatform:pay( productInfo );
end

-- isActUpdata: 0 游戏自动更新  1 玩家请求更新
-- isDeltaUpdate: 0 增量更新  1 整包更新
-- isForceUpdate: 0 可选更新  1 强制更新
-- isSilentUpdate 没用到
-- isCheckProc 0 更新 1检测更新
GlobalDataManager.startOrCheckUmengUpdate = function ( self, isActUpdata, isDeltaUpdate, isForceUpdate, isSilentUpdate, isCheckProc )
	local post_data = {};
	post_data.isCheckForProcess = isCheckProc;
	if 0 == isCheckProc then
		GameConstant.isUpdating = true;
	end
	post_data.isActUpdata = isActUpdata;
	post_data.isDeltaUpdate = isDeltaUpdate;
	post_data.isForceUpdate = isForceUpdate;
	local dataStr = json.encode(post_data);
	dict_set_string(kUmengUpdate, kUmengUpdate..kparmPostfix, dataStr);
	native_to_java(kUmengUpdate);
end

-- -- 开始游戏更新
-- GlobalDataManager.startGameUpdate = function ( self, url_update, update_control, update_content )
-- 	GameConstant.isUpdating = true;
-- 	local data = {};
-- 	data.url_update = url_update;
-- 	data.platform_type = GameConstant.platformType;
-- 	data.update_control = update_control;
-- 	data.update_content = update_content;
-- 	local dataStr = json.encode(data);
-- 	native_to_java(kUpdateVersion,dataStr);
-- end

-- 开始游戏更新
GlobalDataManager.startGameUpdate = function ( self, url_update )
	if not (GameConstant.iosDeviceType>0) then
		GameConstant.isUpdating = true;
	end
	local data = {};
	data.url_update = url_update;
	data.platform_type = GameConstant.platformType;
	-- data.update_control = update_control;
	-- data.update_content = update_content;
	local dataStr = json.encode(data);
	native_to_java(kUpdateVersion,dataStr);
end


GlobalDataManager.STATUS_UPDATE = 5; -- 更新
GlobalDataManager.CALLBACK_TYPE_OPER = 1; -- 玩家对话框操作回调
GlobalDataManager.DOWNLOADSTATUS_TYPE = 2; -- 下载
GlobalDataManager.DOWNLOAD_STEP_START = 1;-- 下载开始
GlobalDataManager.DOWNLOAD_STEP_ING = 2; -- 下载中
GlobalDataManager.DOWNLOAD_STEP_END = 3; -- 下载结束
GlobalDataManager.DOWNLOAD_COMPLETE_FAIL = 0; -- 下载失败
GlobalDataManager.DOWNLOAD_COMPLETE_SUCCESS = 1; -- 下载成功
GlobalDataManager.umengCallback = function ( self, param, data )
	local resType = tonumber(data.type);
	if GlobalDataManager.CALLBACK_TYPE_OPER == resType then
		local playerOperatorType = tonumber(data.playerActionType); -- 玩家操作类型：5 更新
		if 1 == GameConstant.update_control and 5 ~= playerOperatorType then -- 是强制更新且玩家选择了不更新，则退出游戏
			native_muti_exit()
		end
		return;
	end
	if GlobalDataManager.DOWNLOADSTATUS_TYPE == resType then
		local step = tonumber(data.step);
		local size = tonumber(data.size) or 0;
		if GlobalDataManager.DOWNLOAD_STEP_START == step then
			Banner.getInstance():showMsg("开始下载更新");
		elseif GlobalDataManager.DOWNLOAD_STEP_ING == step then
			local progress = tonumber(data.progress);
			self:updateDownload(progress, size);
		elseif GlobalDataManager.DOWNLOAD_STEP_END == step then
			local res = tonumber(data.compliteResult);
			if GlobalDataManager.DOWNLOAD_COMPLETE_FAIL == res then
				Banner.getInstance():showMsg("下载更新包失败, 请重试");
				GameConstant.isUpdating = false;
			elseif GlobalDataManager.DOWNLOAD_COMPLETE_SUCCESS == res then
				Banner.getInstance():showMsg("下载更新包成功");
				self:updateDownload(100, size);
				GameConstant.isUpdating = false;
			end
		end
	end
end

GlobalDataManager.getGeTuiClientId = function(self, param, data)
	if data then
		local clientId = data.getui_cid
		DebugLog("这里是Lua层，打印个推ClientId");
		GameConstant.GeTuiClientId = clientId;
		if tonumber(PlayerManager.getInstance():myself().mid) >= 0 then
			self:requestGeTuiPHP();
		end
		if 1 == DEBUGMODE then
			Banner.getInstance():showMsg("个推ID"..tostring(clientId));
		end
	end
end

GlobalDataManager.requestGeTuiPHP = function(self)
	local param = {};
	param.clientId  = GameConstant.GeTuiClientId;
	param.mid 	    = PlayerManager.getInstance():myself().mid;
	param.version   = GameConstant.Version;
	param.api 		= GameConstant.api

	SocketManager.getInstance():sendPack(PHP_CMD_UPLOAD_GE_TUI_CID, param)
end

GlobalDataManager.uploadGeTuiCid = function(self,isSuccess,data)
	if not isSuccess and not data then
	    return;
	end
	if isSuccess then
		if data.status then
			-- Banner.getInstance():showMsg("PHP记录个推ID成功!");
		end
		return;
	end
	-- self:requestGeTuiPHP();
end

GlobalDataManager.getGeTuiMessage = function(self, param, data)
	local message = data.getui_payload
	-- Banner.getInstance():showMsg(message);
end

GlobalDataManager.getGeTuiCell = function(self, param, data)
	local cell = data.getui_cell
	DebugLog("这里是Lua层，打印个推Cell");
	DebugLog(cell);
	-- Banner.getInstance():showMsg(cell);
end

GlobalDataManager.downloadEvent = function ( self, param, data )
	local tips=data.tips  --1
	local progrssValue=data.progress
	local downloadType=data.type  --1
	local isOver=data.isOver
	GameConstant.downloadstatus = 1; --资源下载中...
    DebugLog("[GlobalDataManager] downloadEvent: progrssValue:"..tostring(progrssValue).." downloadType:"..tostring(downloadType).." isOver:"..tostring(isOver));
	if(isOver and tonumber(isOver) == -1) then--资源下载失败
		GameConstant.downloadstatus=0;
		local msg="";
		if(tonumber(downloadType) == 2)then
			msg="声音资源下载失败了,请查看网络情况";
		elseif(tonumber(downloadType) == 1)then
			msg="表情资源下载失败了,请查看网络情况";
		elseif(tonumber(downloadType) == 3)then
			msg="好友动画资源下载失败了,请查看网络情况";
		end
		UnautoBanner.getInstance():hide();
		if GlobalDataManager.isActivityDownload then
			Banner.getInstance():showMsg(msg);
			GlobalDataManager.isActivityDownload = false;
		end
		GlobalDataManager.isActivityDownload = false;
	elseif(tonumber(tips) == 1 and progrssValue and downloadType)then -- 正在下载资源
		local msg="";
		if(tonumber(downloadType) == 2)then
			if(tonumber(progrssValue) == 100)then
				msg="声音下载完成";
			else
				msg="声音下载"..progrssValue.."%...".."您可以先进行游戏";
			end
		elseif(tonumber(downloadType) == 1)then
			if(tonumber(progrssValue) == 100)then
				msg="表情下载完成";
			else
				msg="表情下载"..progrssValue.."%...".."您可以先进行游戏";
			end
		elseif(tonumber(downloadType) == 3)then
			if(tonumber(progrssValue) == 100 )then
				msg="动画下载完成";
			else
				msg="动画下载"..progrssValue.."%...".."您可以先进行游戏";
			end
		elseif(tonumber(downloadType) == 5)then
			if(tonumber(progrssValue) == 100 )then
				msg="开机动画下载完成";
			else
				msg="开机动画下载"..progrssValue.."%...".."您可以先进行游戏";
			end
		end
		-- DebugLog( "表情下载" );
		DebugLog( "显示下载进度" )
		DebugLog( "显示下载进度 "..msg );
		if GlobalDataManager.isActivityDownload then
			DebugLog( "GlobalDataManager.isActivityDownload");
			UnautoBanner.getInstance():showMsg(msg);
		end
	elseif(isOver and tonumber(isOver) ==1 )then --资源下载完成
		GameConstant.isDownloading = false;
		GameConstant.resdownload = 1;    --资源下载完成
		GameConstant.downloadstatus = 2; --下载完成
		if (tonumber(data.type) == 1) then --表情下载完成
			GameConstant.faceIsCanUse = 1;
			UnautoBanner.getInstance():hide();
		elseif (tonumber(data.type) == 2) then --声音下载完成
			GameConstant.soundDownload = 1;
			UnautoBanner.getInstance():hide();
			initDownloadAudio(GameConstant.resVer);
			GlobalDataManager.isActivityDownload = false;
		elseif(tonumber(data.type) == 3 ) then
			UnautoBanner.getInstance():hide();
		elseif (tonumber(data.type) == 5) then
			UnautoBanner.getInstance():hide();
		end
	end
end

GlobalDataManager.canGetUpdateRewardOrHasUpdate = function ( self )
	local data = GlobalDataManager.updateInfoBuffer;
	if not data then
		return false;
	end

	local isNeed = (1 == tonumber(data.award_status)) or (1 == tonumber(data.flag));
	if 1 == tonumber(data.status) and isNeed then
		return true;
	end
end

GlobalDataManager.showBankruptDlg = function(self, level , obj , func,closeListener)
	local param_data = {};
	self.m_bankLevel = level;
	self.m_bankruptObj = obj;
	self.m_bankruptFunc = func;
	self.m_bankruptCloseListener = closeListener;

	SocketManager.getInstance():sendPack(PHP_CMD_NEW_BANKRUPTCY, param_data)
end

GlobalDataManager.showBankruptThings = function(self)
	-- DebugLog("bankrupt showAwardView" .. GameConstant.showAwardView .. ";isShowAwardView" .. GameConstant.isShowAwardView);

	if GameConstant.showAwardView == 1 then
		if GameConstant.isShowAwardView == 1 then
			local mid = PlayerManager.getInstance():myself().mid or "";
			local old_day = g_DiskDataMgr:getUserData(mid, "showAwardrupt",1)
			local today = os.date("%Y%m%d");
			if today - old_day >= 1 then
				g_DiskDataMgr:setUserData(mid,"showAwardrupt", os.date("%Y%m%d"))
				-- 要显示奖励
				native_to_java(kShowAwardView);
			end

			return;
		end
	end

	self:gotoScoreMatch();
end

GlobalDataManager.gotoScoreMatch = function ( self )
	if GameConstant.shouldPopBankruptWin == 1 then
		--goto "您已经破产,是否进入免费比赛场赢取更多金币?"
		GameConstant.shouldPopBankruptWin = 0
		local popView = PopuFrame.showNormalDialog( "温馨提示", "您已经破产,是否进入免费比赛场赢取更多金币?", GameConstant.curGameSceneRef, nil, nil, true, false );
		popView:setConfirmCallback(self, function ( self )
			if HallScene_instance then
				HallScene_instance:onGotoScoreMatch()
			elseif RoomScene_instance then
				GameConstant.gotoScoreMatch = 1
				RoomScene_instance:exitGame()
			end
		end);
	end
end


GlobalDataManager.requestIsShowBankruptDlgCallBack = function(self,isSuccess,data)
	if not isSuccess and not data or not data.data then
		return;
	end
	if isSuccess then
		local status = data.status or 0;
		local time = data.data.time or 0;
		GameConstant.showAwardView = data.data.view or 0; -- 是否显示奖励界面
		GameConstant.shouldPopBankruptWin = data.data.open or 0;
		if 1 == status then
			self:createBankruptDlg( time, false );
		else
			self:createBankruptDlg( 0, true );
		end
	end
end

GlobalDataManager.createBankruptDlg = function( self, time, isUpperLimit )
	if PlayerManager.getInstance():myself().mid > 0 then
		require("MahjongCommon/BankruptcyDlg");
		if self.m_bankruptObj then
			if self.m_bankruptObj.bankDlg then
				self.m_bankruptObj.bankDlg = nil;
			end
			self.m_bankruptObj.bankDlg = new(BankruptcyDlg ,self.m_bankLevel , self.m_bankruptObj , self.m_bankruptFunc, time, isUpperLimit);
			self.m_bankruptObj.bankDlg:showWnd();
			self.m_bankruptObj.bankDlg:setOnWindowHideListener(self,function ( self )
				self.m_bankruptObj = nil
			end)
		else
			local bankDlg = new(BankruptcyDlg ,self.m_bankLevel , self.m_bankruptObj , self.m_bankruptFunc, time, isUpperLimit );
			bankDlg:addToRoot();
		end
	end
end

GlobalDataManager.updateInfoBuffer = nil; -- 更新数据缓存
GlobalDataManager.NewUpDateWnd = nil;  --更新界面变量
GlobalDataManager.CurrentUpdataProcees = 0; -- 当前下载到了多少
GlobalDataManager.getUpdateInfo = function ( self, isSuccess, data )
	log( "GlobalDataManager.getUpdateInfo" );
	if not isSuccess or not data then
		return;
	end

	if 1 ~= tonumber(data.status or 0) then
		Banner.getInstance():showMsg(data.msg or "");
		return;
	end
	--更新方式  0本地更新  1友盟更新
	self.updateMode = tonumber(data.mode);
	self.deltaUpdate = 0;
	--友盟更新方式  0增量更新  1全量更新
	if self.updateMode == 1 then
		self.deltaUpdate = tonumber(data.umeng);
	end
	--版本号
	self.app_version = data.version or ""
	-- 更新地址
	self.url_update = data.url or ""
	--0更新 1强制更新
	self.update_control = tonumber(data.force or 0)

	if GameConstant.platformType == PlatformConfig.platformAssistant91 or GameConstant.platformType == PlatformConfig.platformSouGou then
		return;
	end

	GameConstant.update_control = self.update_control
	self.update_content = data.content or ""
	GlobalDataManager.updateInfoBuffer = data
	if HallScene_instance and HallScene_instance.m_topLayer then
		HallScene_instance.m_topLayer:displayUpdateTip()
		--GameConstant.curGameSceneRef:getControl(HallScene.s_controls.settingNumText):setVisible(self:canGetUpdateRewardOrHasUpdate());
	end

	--是否有更新
	local flag = tonumber(data.flag or 0)
	log( "flag = "..flag )

	require("MahjongPopu/NewUpdateWindow");
	if flag == 1 then -- 有更新
		if PlatformFactory.curPlatform:needToShowUpdataView() then
			log( "PlatformFactory.curPlatform:needToShowUpdataView()" );
			--自动下载更新
			log( GlobalDataManager.curRequireUpdateType );
			if "wifi" == GameConstant.net and tonumber(GlobalDataManager.curRequireUpdateType) ~= 1  then
				if not GlobalDataManager.NewUpDateWnd then
					GlobalDataManager.NewUpDateWnd = new (NewUpdateWindow);
				end
				GlobalDataManager.NewUpDateWnd:setData( data );
				--NewUpdateWindow.getInstance():setData( data );
				if GameConstant.isUpdating then
					return;
				end
				if self.updateMode == 1 then
					self:startOrCheckUmengUpdate(tonumber(GlobalDataManager.curRequireUpdateType), self.deltaUpdate, tonumber(self.update_control), 1, 0);
				else
					-- self:startGameUpdate( self.url_update, self.update_control, self.update_content );
					self:startGameUpdate( self.url_update );
				end
				--通知php本地请求更新
				local param = {};
				param.mid = PlayerManager.getInstance():myself().mid;
				param.version = GlobalDataManager.updateInfoBuffer.version or 0;
				SocketManager.getInstance():sendPack(PHP_CMD_UPDATE_REPORT, param)

			else
				if not GlobalDataManager.NewUpDateWnd then
					GlobalDataManager.NewUpDateWnd = new (NewUpdateWindow);
				end
				GlobalDataManager.NewUpDateWnd:setData( data );

				--不在进行更新时，查询一次更新进度
				if self.updateMode == 1 and not GameConstant.isUpdating then
					self:startOrCheckUmengUpdate(tonumber(GlobalDataManager.curRequireUpdateType), self.deltaUpdate, tonumber(self.update_control), 0, 1); -- 检测下载进度
				end
			end
		end
	else -- 没有更新
		if 1 == GlobalDataManager.curRequireUpdateType then
			if not GlobalDataManager.NewUpDateWnd then
				GlobalDataManager.NewUpDateWnd = new (NewUpdateWindow);
			end
			GlobalDataManager.NewUpDateWnd:setData( data );
		else
			delete(GlobalDataManager.NewUpDateWnd);
			GlobalDataManager.NewUpDateWnd = nil; -- 如果不需要显示出来，则删除，当点击更新显示出来的时候再加载。
			new_pop_wnd_mgr.get_instance():hide_and_show( new_pop_wnd_mgr.enum.update );
		end
	end
end

-- 更新领奖
GlobalDataManager.onGetUpdateReward = function ( self, data )
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack(PHP_CMD_UPDATE_REWARD,param)
end

GlobalDataManager.onClickUpdate = function ( self, data )
	if GameConstant.iosDeviceType>0 then
		self:startGameUpdate( self.url_update );
	else
		if GameConstant.isUpdating then
			Banner.getInstance():showMsg("正在更新，请稍后！");
			return;
		end
		if self.updateMode == 1 then
			self:startOrCheckUmengUpdate(tonumber(GlobalDataManager.curRequireUpdateType), self.deltaUpdate, tonumber(self.update_control), 0, 0);
		else
			-- self:startGameUpdate( self.url_update, self.update_control, self.update_content );
			self:startGameUpdate( self.url_update );
		end
	end
	-- 通知php本地请求更新
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	param.version = GlobalDataManager.updateInfoBuffer.version or 0;
	SocketManager.getInstance():sendPack(PHP_CMD_UPDATE_REPORT, param)
end

GlobalDataManager.updateReport = function (  self, isSuccess, data  )
    DebugLog("GlobalDataManager.updateReport ");
	-- body
end

GlobalDataManager.updateReward = function (  self, isSuccess, data  )
	if not isSuccess and not data then
	    return;
	end
	if isSuccess then
		if 1 ~= tonumber(data.status) then
			Banner.getInstance():showMsg(data.msg);
			GlobalDataManager.updateInfoBuffer = nil;

			self:requestUpdateVersionInfo( 0 );
			return;
		end
        if not data.data then
            return;
        end

		local money = tonumber(data.data.money) or 0;
		local coin = tonumber(data.data.bycoin) or 0;
		PlayerManager.getInstance():myself():addMoney(money);
		PlayerManager.getInstance():myself().boyaacoin = PlayerManager.getInstance():myself().boyaacoin + coin;
		Banner.getInstance():showMsg(data.msg)
		GlobalDataManager.updateInfoBuffer = nil;
		self:requestUpdateVersionInfo( 0 );

		--掉金币
		if money > 0 then
			showGoldDropAnimation();
		end
	else
		Banner.getInstance():showMsg(data);
	end
end

GlobalDataManager.updateDownload = function(self, progress_value, size)
	if not progress_value then
		return;
	end
	GlobalDataManager.CurrentUpdataProcees = progress_value or 0; --记录当前下载到的
	if GlobalDataManager.NewUpDateWnd then
		GlobalDataManager.NewUpDateWnd:setProgress(progress_value or 0, size);
	end

	--GlobalDataManager.NewUpDateWnd:setProgress(progress_value or 0, size);
	--NewUpdateWindow.getInstance():setProgress(progress_value or 0, size);
end

GlobalDataManager.updateSuccess = function(self, callParam, data)
	GameConstant.isUpdating = false;
	Banner.getInstance():showMsg("下载成功");
	local isInGame = data.isInGame
	--在游戏中
	if tonumber(isInGame) == 1 then
	native_to_java(kUpdate);
	end
end

--更新过程出现异常情况
GlobalDataManager.updatingAlert = function(self, callParam, data)
	GameConstant.isUpdating = false;
	Banner.getInstance():showMsg("更新失败，请检查是否有SD卡！");
end

GlobalDataManager.onSocketPackEvent = function ( self, param, cmd )
	if GlobalDataManager.scoketEventFuncMap[cmd] then
		DebugLog("GlobalDataManager deal socket cmd "..cmd);
		GlobalDataManager.scoketEventFuncMap[cmd](self, param);
	end
end

GlobalDataManager.pushDirTag = "activityPush_";
GlobalDataManager.pushTimeStamp = "pushTimeStamp"; -- 当前以保存强推的日期
GlobalDataManager.timesLimit = "timesLimit"; -- 次数限制
GlobalDataManager.probability = "probability"; -- 推荐概率
GlobalDataManager.pushTimes = "hasPushTimesInDay"; -- 一天内已推荐的次数
GlobalDataManager.showTextType = "showTextType";
GlobalDataManager.needToPushActivity = -1; -- 是否需要强推 1:用 -1:还未获取数据 0：不用
GlobalDataManager.pushUrl = nil; -- 强推url
GlobalDataManager.pushMark= nil;
-- timesLimit 每天限制的次数
-- probability 弹出的概率
GlobalDataManager.saveAndCheckActivityPushState = function ( self, timesLimit, probability, showText )
	local mid = PlayerManager.getInstance():myself().mid or 0
	local time = os.time();
	local curTime = os.date("%x", time);
	-- 以保存的强推时间
	local curSaveTime = g_DiskDataMgr:getUserData(mid, GlobalDataManager.pushTimeStamp,"") or ""
	if curSaveTime ~= curTime then -- 更新一次本地数据，并更新保存时间
		g_DiskDataMgr:setUserData(mid, GlobalDataManager.pushTimes, 0)
		g_DiskDataMgr:setUserData(mid, GlobalDataManager.pushTimeStamp, curTime)
	end

	g_DiskDataMgr:setUserData(mid, GlobalDataManager.timesLimit,  tonumber(timesLimit) or 0)
	g_DiskDataMgr:setUserData(mid, GlobalDataManager.probability, tonumber(probability) or 0)
	g_DiskDataMgr:setUserData(mid, GlobalDataManager.showTextType,tonumber(showText) or 0)
end

-- 检测是否需要活动弹窗
GlobalDataManager.checkNeedToPushActivity = function ( self )
	if -1 == GlobalDataManager.needToPushActivity then -- 还没请求过强推配置或是请求失败
		-- self:requireGetActivityNum();
		return false;
	end
	if 0 == GlobalDataManager.needToPushActivity then
		return false;
	end

	if GameConstant.isSingleGameBackToHall then
		GameConstant.isSingleGameBackToHall = false;
		return false;
	end

    --在报名界面不弹出强推界面
    if GameConstant.isInApplyWindow then
        GameConstant.isInApplyWindow = false;
        return false;
    end

	if not GlobalDataManager.pushUrl then
		return false;
	end

	local mid = PlayerManager.getInstance():myself().mid or 0
	local probability = g_DiskDataMgr:getUserData(mid, GlobalDataManager.probability, 0)
	local timelimit   = g_DiskDataMgr:getUserData(mid, GlobalDataManager.timesLimit, 0)
	local useTime     = g_DiskDataMgr:getUserData(mid, GlobalDataManager.pushTimes, 0);

	log( "timelimit = "..timelimit.." useTime = "..useTime );

	if useTime >= timelimit then
		return false;
	end
	-- math.randomseed(tostring(os.time()):reverse():sub(1,9));
	-- local num = math.random(1, 100);
	-- if num > tonumber(probability) then
	-- 	return false;
	-- end
	return true;
end

-- 请求活动弹窗
GlobalDataManager.askToshowActivityPopu = function ( self, isRss )
	if self:checkNeedToPushActivity() then -- 条件满足，显示弹窗

		local mid = PlayerManager.getInstance():myself().mid or 0
		local useTime = g_DiskDataMgr:getUserData(mid, GlobalDataManager.pushTimes, 0)
		g_DiskDataMgr:setUserData(mid, GlobalDataManager.pushTimes, useTime + 1)
		local activityType = g_DiskDataMgr:getUserData(mid, GlobalDataManager.showTextType, 1)
		self:showPushActivityWnd( activityType );
	end
end


function GlobalDataManager.requestSystemMessage(self)
    DebugLog("[GlobalDataManager]:requestSystemMessage");
	local param = {};
	param.mid 	    = PlayerManager.getInstance():myself().mid;
	param.version   = GameConstant.Version;
	param.api 		= GameConstant.api
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_SYSTEM_MESSAGE, param)

end


function GlobalDataManager.requestSystemMessageCallback( self, isSuccess, data, jsonData )
	DebugLog("GlobalDataManager.requestSystemMessageCallback ")
	local netSysData,cancelData-- = nil
	if isSuccess and data then
		netSysData = rawget(data,"data")
		cancelData = rawget(data,"repeal")
		--netSysData = data.data or nil
		--cancelData = data.repeal or nil
	end
	self.systemData = SystemMessageData.loadMessageFromHistory( PlayerManager.getInstance():myself().mid,netSysData, cancelData)
end

function GlobalDataManager.requestTrumpetMessage(self)
	DebugLog("GlobalDataManager.requestTrumpetMessage")
	local param = {};
	param.mid 	    = PlayerManager.getInstance():myself().mid;
	param.version   = GameConstant.Version;
	param.api 		= GameConstant.api
	SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_TRUMPET_MESSAGE_CONFIG,param)

end

function GlobalDataManager.requestTrumpetMessageCallback( self, isSuccess, data, jsonData )
	DebugLog("GlobalDataManager.requestTrumpetMessageCallback")
	self.trumpetMessageList = {}
	if isSuccess and data then
		local status = data.status
		if status == 1 then
			if data.data then
				for k,v in pairs(data.data) do
				 	self.trumpetMessageList[#self.trumpetMessageList + 1] = {}
				 	self.trumpetMessageList[#self.trumpetMessageList].id    =  v.id
				 	self.trumpetMessageList[#self.trumpetMessageList].type  =  v.type
				 	self.trumpetMessageList[#self.trumpetMessageList].desc  =  v.desc
				end
			end
		end
	end

	DebugLog("hahahhahahhahha")
	mahjongPrint(self.trumpetMessageList)
end

function GlobalDataManager.getUnReadSystemMessageNum( self )
	local count = 0
	if self.systemData and #self.systemData > 0 then
		for i=1,#self.systemData do
			if not self.systemData[i].isRead then--有未读的系统消息
				count = count + 1
			end
		end
	end
	return count
end


function GlobalDataManager:onCacheDataHttpListener( httpCmd, data )
	local isSuccess = (data ~= nil);
	if GlobalDataManager.cacheDataHttpCallBackFuncMap[httpCmd] then
		GlobalDataManager.cacheDataHttpCallBackFuncMap[httpCmd]( self, isSuccess, data );
	end
end

-- 道具
GlobalDataManager.requestMyItemListCallBack = function ( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end

	if data and type(data) == "string" then
		return
	end

	if data.paizhi then
		local player = PlayerManager.getInstance():myself();
		local paizhi = tostring( data.paizhi);
		player.paizhi = paizhi or "10000";
	end

	local itemManager = ItemManager.getInstance();
	itemManager.myItemList = {};
	if isSuccess then
		local t = nil;
		for k,v in pairs(data) do
			if k == "info" then
				t = v;
				break;
			end
		end
        if t == nil then
            return;
        end
		if t == "" then
			GameConstant.changeNickTimes.propnum = 0;
			EventDispatcher.getInstance():dispatch(GlobalDataManager.myItemListUpdated);
			return;
		end
		GameConstant.changeNickTimes.propnum = 0;
		for k,v in pairs(t) do
			local item = new(Prop);
			local itemInfoTable = {};
			itemInfoTable.name = v.name
			itemInfoTable.image = v.image
			itemInfoTable.goodsdes = v.goodsdes
			itemInfoTable.num = v.num or 0
			itemInfoTable.cid = v.cid
			itemInfoTable.type = v.type or 0
			-- if ItemManager.TOUXIANG1_CID == tonumber(itemInfoTable.cid) then -- 龙纹头像框
			-- 	PlayerManager.getInstance():myself().circletype = 1;
			-- end
			if ItemManager.LABA_CID == tonumber(itemInfoTable.cid) then
				GameConstant.changeNickTimes.propnum = GameConstant.changeNickTimes.propnum + itemInfoTable.num;
			end
			itemInfoTable.endtime = v.endtime
			item:parseData(itemInfoTable)
			itemManager:addItem(item)
		end
	else -- 自己的道具列表为空，或获取失败
	end

	DebugLog("【道具HTTP请求返回 分发事件】");
	EventDispatcher.getInstance():dispatch(GlobalDataManager.myItemListUpdated);
end

--获取是否帐号已经绑定 set/get m_isBound == 1时才是绑定成功
GlobalDataManager.getIsCellAcccountBind = function (self)
    DebugLog("GlobalDataManager.getIsCellAcccountBind:"..tostring(self.m_bCellLogin));
    DebugLog("GlobalDataManager.getIsCellAcccountBind:"..tostring(self.m_cellBindAccount));

    if self.m_bCellLogin == true  then
        return true;
    else
        return self:getCellBindAccount() > 0 ;
    end

end

--存储绑定的帐号 get/set
GlobalDataManager.setIsCellAcccountLogin = function (self, bCellLogin)
    self.m_bCellLogin = (bCellLogin == true) or false;
end

GlobalDataManager.setBindCellAcccount = function (self, bBound)
    DebugLog("GlobalDataManager.setBindCellAcccount:"..tostring(bBound or -1));
    bBound = tonumber(bBound) or 0;
    if not bBound then
        return;
    end
    self.m_cellBindAccount = bBound;
end

--获取是否手机帐号登录set/get
GlobalDataManager.getIsCellAcccountLogin= function (self)
    DebugLog("GlobalDataManager.getIsCellAcccountLogin:"..tostring(self.m_bCellLogin));
    return (self.m_bCellLogin == true)  or false;
end



--获取手机绑定的帐号
GlobalDataManager.getCellBindAccount= function (self)
    DebugLog("GlobalDataManager.getCellBindAccount:"..tostring(self.m_cellBindAccount or 0));
    return self.m_cellBindAccount or 0;
end

GlobalDataManager.setCellBindAccount = function (self, ac)
    ac = ac or 0;
    ac = tonumber(ac) or 0;
    DebugLog("GlobalDataManager.setCellBindAccount:"..ac);
    self.m_cellBindAccount = ac;
end

--获取登录成功的手机帐号,mima
GlobalDataManager.getLoginSuccessAcPwd= function (self)
    local ac  = g_DiskDataMgr:getAppData(kDictKeyLoginSuccessSaveAccount, "")
    local pwd = g_DiskDataMgr:getAppData(kDictKeyLoginSuccessSavePwd, "")
    return ac,pwd;
end

GlobalDataManager.setLoginSuccessAcPwd = function (self, ac, pwd)
    ac = ac or "";
    pwd = pwd or "";
    ac = tostring(ac);
    pwd = tostring(pwd) ;
    g_DiskDataMgr:setAppData(kDictKeyLoginSuccessSaveAccount, ac)
    g_DiskDataMgr:setAppData(kDictKeyLoginSuccessSavePwd,     pwd)
end


--保存兑换信息
GlobalDataManager.getExchangeDictInfo = function (self)
    local phoneNum = self:getCellBindAccount();
    local phone   = g_DiskDataMgr:getUserData(phoneNum,kDictKeyExchangePhone,"")
    local name    = g_DiskDataMgr:getUserData(phonenum,kDictKeyExchangeName,"")
    local address = g_DiskDataMgr:getUserData(phonenum,kDictKeyExchangeAddress,"")
    DebugLog("GlobalDataManager.getExchangeDictInfo:"..kDictKeyExchangeName..tostring(phoneNum));
    DebugLog("GlobalDataManager.getExchangeDictInfo:"..kDictKeyExchangeAddress..tostring(phoneNum));
    return phone,name,address;
end

--保存兑换信息
GlobalDataManager.setExchangeDictInfo = function (self, phoneNum, name, address)
    phoneNum = phoneNum or "";
    name = name or "";
    address = address or "";
    phoneNum = tostring(phoneNum);
    name = tostring(name) ;
    address = tostring(address) ;
    local minLen = 2;
    if string.len(phoneNum) > minLen then
    	g_DiskDataMgr:setUserData(phoneNum,kDictKeyExchangePhone,phoneNum)
    end
    if string.len(name) > minLen then
    	g_DiskDataMgr:setUserData(phoneNum,kDictKeyExchangeName,name)
    end
    if string.len(address) > minLen then
    	g_DiskDataMgr:setUserData(phoneNum,kDictKeyExchangeAddress,address)
    end

    DebugLog("GlobalDataManager.setExchangeDictInfo:"..kDictKeyExchangePhone..tostring(phoneNum)..":"..phoneNum);
    DebugLog("GlobalDataManager.setExchangeDictInfo:"..kDictKeyExchangeAddress..tostring(phoneNum)..":"..name);
    DebugLog("GlobalDataManager.setExchangeDictInfo:"..kDictKeyExchangeAddress..tostring(phoneNum)..":"..address);
end

--设置手机登录的唯一性 --ps :请使用get/set 方法，直接获取值的话，获取的不一定是true或者false
GlobalDataManager.setPlatformLogining = function (self, bLogining)
    self.m_bPlatformLgoining = bLogining;
end

--2级界面的数据data
GlobalDataManager.setChooseLayerData = function (self, level, str)
    self.m_lastChooseLayerData.level = level or -1;
    self.m_lastChooseLayerData.str = str or "-1";
end

GlobalDataManager.getChooseLayerData = function (self)
    --去掉进入血流返回2级界面的方案；
    return nil;--self.m_lastChooseLayerData;
end


GlobalDataManager.getPlatformLogining = function (self)
    if self.m_bPlatformLgoining == nil then
        return false;
    elseif self.m_bPlatformLgoining == true then
        return true;
    else
        return false;
    end
end

function GlobalDataManager:checkVipExpTime()
	local param_data = {};--
	SocketManager.getInstance():sendPack( PHP_CMD_OPPO_REQUEST_VIP_EXP_REMIND, param_data)
end

GlobalDataManager.requestVipExpRemindCallBack = function(self, isSuccess, data )
	if not isSuccess and not data then
    	return;
    end
	if isSuccess then
        if tonumber(data.status) == 1 then
            local seconds = tonumber(data.data.left_time or 0)
            GameConstant.m_vipExpTime = seconds
            if seconds > 0 then --启动定时器
                if GameConstant.m_vipExpAnim then  --先删除定时器
                    delete(GameConstant.m_vipExpAnim)
                    GameConstant.m_vipExpAnim = nil
                end

                GameConstant.m_vipExpAnim = new(AnimInt,kAnimRepeat,0, 100, 1000, -1)
                GameConstant.m_vipExpAnim:setDebugName("GameConstant.m_vipExpAnim")
                GameConstant.m_vipExpAnim:setEvent(nil,function()
                    GameConstant.m_vipExpTime = GameConstant.m_vipExpTime - 1
                    if HallScene_instance then
                        HallScene_instance.m_topLayer:updateTimeLbl(GameConstant.m_vipExpTime)
                    end
                    if GameConstant.m_vipExpTime <= 0 then
                        delete(GameConstant.m_vipExpAnim)
                        GameConstant.m_vipExpAnim = nil
                    end
                end);
            else               --隐藏界面
                if HallScene_instance then
                    HallScene_instance.m_topLayer:clearExpData()
                end
            end
        end
    end
end

GlobalDataManager.getLastGameData = function (self)
    return self.m_lastGameData;
end

GlobalDataManager.setLastChestNeedJu = function (self, num)
    if self.m_lastGameData == nil then
        self.m_lastGameData = {};
    end
    self.m_lastGameData.chestNeedJu = num;
end

GlobalDataManager.setLastGameLevel = function (self, level)
    if self.m_lastGameData == nil then
        self.m_lastGameData = {};
    end
    self.m_lastGameData.level = level;
end

GlobalDataManager.scoketEventFuncMap = {
	[HALL_SERVER_UPDATE_INFO] 					 = GlobalDataManager.socketUpdateMoney,
	[SC_MONEY_UPDATE_RES]						 = GlobalDataManager.serverNoticeMoneyUpdate,
    [SC_DIAMOND_UPDATE_RES]						 = GlobalDataManager.server_notice_update_diamond,
    [SERVER_MATCHSERVER_CMD]                     = GlobalDataManager.server_match_common_tip, --比赛：服务器发给客户端的一个通用的消息
}

-- GlobalDataManager.onHttpRequestsListenster = function ( self,command,... )
-- 	if GlobalDataManager.httpRequestMap[command] then
-- 		DebugLog("GlobalDataManager deal http cmd "..command);
-- 		GlobalDataManager.httpRequestMap[command](self,...);
-- 	end
-- end

GlobalDataManager.onHttpRequestsListenster = function ( self, param, cmd, isSuccess )
	if self.httpRequestMap[cmd] then
		self.httpRequestMap[cmd](self,isSuccess,param)
	end
end


GlobalDataManager.dtor = function ( self )
	self.noticeData = {};
	EventDispatcher.getInstance():unregister(self.m_phpEvent, self, self.onUnLoginNoticeInfoCallback);
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onHttpRequestsListenster);
	EventDispatcher.getInstance():unregister(SocketManager.s_serverMsg, self, self.onSocketPackEvent);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
	NetCacheDataManager.getInstance():unregister( self.cacheDataHttpEvent, self, self.onCacheDataHttpListener );
end

GlobalDataManager.httpRequestMap = {

	[PHP_CMD_REQUEST_VERSION_INFO] 		= GlobalDataManager.getUpdateInfo,
	[PHP_CMD_GET_BANKRAPTCY_REMEDY] 	= GlobalDataManager.getBankraptcyRemedyCallBack,
	[PHP_CMD_GET_USER_INFO] 			= GlobalDataManager.getUserInfo,
	[PHP_CMD_DOWNLOAD_RES] 				= GlobalDataManager.getDownloadInfoComplite,
	[PHP_CMD_REQUEST_MY_ITEM_LIST] 		= GlobalDataManager.requestMyItemListCallBack,
	[PHP_CMD_GET_TASK_NNUM] 			= GlobalDataManager.getTaskNumSuccess,

	[PHP_CMD_GET_USER_VIP_INFO] 		= GlobalDataManager.getUserVipInfoCallBack,
	[PHP_CMD_UPLOAD_GE_TUI_CID] 		= GlobalDataManager.uploadGeTuiCid,
	[PHP_CMD_UPDATE_REPORT] 			= GlobalDataManager.updateReport,
	[PHP_CMD_UPDATE_REWARD] 			= GlobalDataManager.updateReward,
	[PHP_CMD_GET_TUI_JIAN_PRODUCT] 		= GlobalDataManager.getTuiJianProductBack,

	[PHP_CMD_TASK_ENFORCEPUSH] 			= GlobalDataManager.ActivityPushCallBack,
	[PHP_CMD_REQUEST_IS_SUBSCRIBE_MOBILE_GAMER] = GlobalDataManager.requestIsSubscribeMobileGamerCallBack,
    [PHP_CMD_REQUEST_MATCH_CONFIG]	    = GlobalDataManager.requestMatchConfigCallBack,
    [PHP_CMD_NEW_BANKRUPTCY] 			= GlobalDataManager.requestIsShowBankruptDlgCallBack,
    [PHP_CMD_REQUEST_SYSTEM_MESSAGE] 	= GlobalDataManager.requestSystemMessageCallback,
    [PHP_CMD_REQUEST_TRUMPET_MESSAGE_CONFIG] = GlobalDataManager.requestTrumpetMessageCallback,
    [PHP_CMD_REQUEST_PAY_CONFIG] 		= GlobalDataManager.requestPayConfigCallBack,

    [PHP_CMD_REQUEST_FRIEND_MATCH_CONFIG] = GlobalDataManager.requestFriendMatchConfigCallBack,
    [PHP_CMD_REQUEST_VOICE_CONFIG]        = GlobalDataManager.requestVoiceConfigCallBack,
    [PHP_CMD_REQUEST_INVITE_SHARE_INFO]   = GlobalDataManager.requestInviteShareInfoCallback,
    [PHP_CMD_REQUEST_MATCH_INVITE_SHARE_INFO] = GlobalDataManager.requestMatchInviteShareInfoCallback,

    [PHP_CMD_OPPO_REQUEST_VIP_EXP_REMIND] = GlobalDataManager.requestVipExpRemindCallBack,
};

-- 缓存处理函数
GlobalDataManager.cacheDataHttpCallBackFuncMap = {
	[PHP_CMD_REQUEST_NOTICE_INFO] 		= GlobalDataManager.getNoticeInfo,
	[PHP_CMD_REQUEST_NEW_HALL_CONFIG] 	= GlobalDataManager.requestHallConfigCallBack,
	[PHP_CMD_GET_BANKRAPTCY_CONFIG] 	= GlobalDataManager.getBankraptcyConfigCallBack,
};
