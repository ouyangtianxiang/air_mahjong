require("gameBase/gameLayer");
require("networkex/socketex")
require("MahjongData/GlobalDataManager")

HallBottomLayer = class(GameLayer)

--HallBottomLayer.CONTENT_HEIGHT = 150

HallBottomLayer.ctor = function(self, viewConfig, delegate)
	DebugLog("HallBottomLayer ctor");
--	g_GameMonitor:addTblToUnderMemLeakMonitor("大厅bottom",self)
	self.delegate = delegate
	self:init()
	self:onEnter()
end

HallBottomLayer.dtor = function(self)
	DebugLog("HallBottomLayer dtor");
	self:onExit()
end

HallBottomLayer.init = function (self)
	-- body
end

HallBottomLayer.initRequests = function ( self )
	self:needToPushActivity(); -- 请求一次活动弹窗
end

--HallBottomLayer.getSize = function ( self )
--	return self.m_root:getSize()
--end

HallBottomLayer.onEnter = function(self)
	DebugLog("HallBottomLayer onEnter");
	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():register(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);
end

HallBottomLayer.onExit = function (self)
	DebugLog("HallBottomLayer onExit");
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(GlobalDataManager.updateSceneEvent, self, self.updataUIByGlobalEvent);

end



HallBottomLayer.updataUIByGlobalEvent = function(self, param)
	DebugLog("HallBottomLayer.updataUIByGlobalEvent")
	if not param then
		return
	end
	mahjongPrint(param)
	if GlobalDataManager.UI_UPDATA_TASK_NUM == param.type then
	 	-- 任务数量
	 	local taskBtn = self:getControl(HallBottomLayer.s_controls.taskBtn );
	 	self:updateTipNum( publ_getItemFromTree(taskBtn, {"tip"} ) , tonumber(param.data))
	end
end


HallBottomLayer.updataActivityNum = function ( self,count )
    DebugLog("[HallBottomLayer]:updataActivityNum count"..tostring(count));
	if GameConstant.checkType == kCheckStatusOpen then
		self:updateAddCheckScene();
		return;
	end

    DebugLog("[HallBottomLayer]:updataActivityNum count"..tostring(count));
	-- body
	local activityBtn = self:getControl(HallBottomLayer.s_controls.activityBtn );
	self:updateTipNum( publ_getItemFromTree(activityBtn, {"tip"} ) , tonumber(count))
end

HallBottomLayer.updateAddCheckScene = function (self)
	local activityBtn = self:getControl(HallBottomLayer.s_controls.activityBtn );
	publ_getItemFromTree(activityBtn, {"tip"}):setVisible(false);
end


-- 请求强推活动
HallBottomLayer.needToPushActivity = function ( self )
	-- 玩了牌并且是主动返回大厅才弹出强推
	if GameConstant.justPlayGame and GameConstant.isBackToHallActivitely then
		if GameConstant.platformType == PlatformConfig.platformMobile then
			GameConstant.isPushRequestRss = true;
			self:reqeustActivityMobileForOrder();
		else
			GlobalDataManager.getInstance():askToshowActivityPopu();
		end
	end
	GameConstant.justPlayGame = false;
	GameConstant.isBackToHallActivitely = false;

end
HallBottomLayer.requestIsShowMobileGamer = function( self )
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_IS_SHOW_MOBILE_GAMER,nil)

end

HallBottomLayer.requestIsShowMobileGamerCallBack = function( self, isSuccess, data )
	if not isSuccess or not data then
		return;
	end

	local isShow = data.data.is_show
	if 1 == tonumber(isShow) then
		GameConstant.isShowMobileGamer = true;
	else
		GameConstant.isShowMobileGamer = false;
	end
    --recreate
	--self:updateView( HallScene.s_cmds.recreateMainView );
end


HallBottomLayer.reqeustActivityMobileForOrder = function(self)
	local param = {};
	param.mid = PlayerManager.getInstance():myself().mid;
	SocketManager.getInstance():sendPack( PHP_CMD_REQUEST_IS_SUBSCRIBE_MOBILE_GAMER, param )
end

HallBottomLayer.requestIsSubscribeMobileGamerCallBack = function ( self )
	if not isSuccess or not data or not data.data then
		return ;
	end
	print( "requestIsSubscribeMobileGamerCallBack" );
	print( GameConstant.isPushRequestRss );
	if data.status == 1 then
		if data.data.is_rss and data.data.is_rss then
			self.is_rss = tonumber(data.data.is_rss or 0);
			if GameConstant.isPushRequestRss then
				GameConstant.isPushRequestRss = false;
				GlobalDataManager.getInstance():askToshowActivityPopu( self.is_rss );
				return;
			end
			if self.isRequestActivity == 1 then
				self:requestActivityForMobile();
			else
				self:requestActivityForMobileActivity();
			end
		end

	end
end

HallBottomLayer.updateTipNum = function ( self ,tip_node, num )
	DebugLog("HallBottomLayer.updateTipNum num:" .. tostring(num))
	if not tip_node or not num then
		DebugLog("not tip_node or no num")
		return
	end

	local tipText = publ_getItemFromTree(tip_node,{"Text1"})
	if not tipText then
		DebugLog("not tipText")
		return
	end
	local inum = tonumber(num)
	tip_node:setVisible( inum > 0 and true or false)
	if inum > 99 then
		inum = 99
	end
	tipText:setText(tostring(inum))
end
HallBottomLayer.requestActivityForMobile = function(self)
	print("requestActivityForMobile");

end

HallBottomLayer.requestActivityForMobileActivity = function(self)
	print("requestActivityForMobileActivity");
	local url = "http://pcusspmj01.ifere.com/?m=activities&p=show&act_id=1286&appid=9300";
	-- http://pcusspmj01.ifere.com/?m=activities&p=show
	-- http://192.168.204.68/operating/web/index.php?m=activities&p=show
	-- local params = {}; -- TODO add params
	-- params.mid 	    = PlayerManager.getInstance():myself().mid;
	-- params.version  = GameConstant.Version;
	-- params.api 		= GameConstant.api
	-- params.sig      = "";
	-- params.isRss  	= self.is_rss or 0;
	-- params.isRefresh = 0;

	local post_data = { };
	-- 用户Key
	local player = PlayerManager.getInstance():myself();
	-- 下面3个参数用于渠道上报
	post_data.appkey = GameConstant.appkey;
	post_data.appid = GameConstant.appid;
	post_data.vkey = GameConstant.imei2;

	post_data.mid = player.mid;
	post_data.username = "user_" .. player.mid;
	post_data.time = os.time();
	-- post_data.sitemid = SystemGetSitemid();
	post_data.api = tonumber(PlatformFactory.curPlatform.api);

	-- 新接口需要
	post_data.usertype = tonumber(PlatformFactory.curPlatform.curLoginType or 1);

	post_data.langtype = 1;
	-- 1:简体 2:繁体

	post_data.version = GameConstant.Version;
	post_data.mtkey = player.mtkey;

	post_data.sid = tonumber(PlatformFactory.curPlatform.sid);
	-- Android游客:7 sina用户:2 博雅通行证:12 QQ用户:3

	if method and not string.find(method, "#") then
		post_data.method = method;
	end

	local signature = HttpModule.joins(post_data.mtkey, post_data);
	post_data.sig = string.upper(md5_string(signature));

	post_data.isRss = self.is_rss or 0;
	post_data.isRefresh = 0;

	local data = { };
	data.url = url;
	data.params = post_data;

	for k, v in pairs(post_data) do
		print(k, v);
	end
	native_to_java(kRequireMobileGamer, json.encode(data));
end

HallBottomLayer.showCheckSceneBtn = function(self)
	self:getControl(HallBottomLayer.s_controls.exchangeBtn):setVisible(false);
end

HallBottomLayer.removeCheckSceneBtn = function(self)
	self:getControl(HallBottomLayer.s_controls.exchangeBtn):setVisible(true);
end
-----------------------------------------------------------------------------------------------------------------------------------
--params = {
--				user_name_str   = "xx" ,
--			}
--[[]
HallBottomLayer.updateUserInfo = function ( self,params)
	if params and type(params) == "table" then
		--params.user_name_str   and self.m_nameText    and self.m_nameText:setText( params.user_name_str )
		--params.user_money_i    and self.m_moneyText   and self.m_moneyText:setText( tostring(params.user_money_i) )
		--params.user_photo_str  and self.m_photoImage  and self.m_photoImage:setFile( params.user_photo_str )
	end
end
]]--
-----------------------------------------------------------------------------------------------------------------------------------
--net request

--net event
HallBottomLayer.onPhpMsgResponse = function ( self, param, cmd, isSuccess, ... )
	if self.httpRequestsCallBackFuncMap[cmd] then
		self.httpRequestsCallBackFuncMap[cmd](self,isSuccess,param)
	end
end



-----------------------------------------------------------------------------------------------------------------------------------
--kFingerUp = 2  so,when button clicked up, stateTag always = 2
HallBottomLayer.onClickedMallBtn = function ( self, stateTag)
	DebugLog('Profile clicked mall start:'..os.clock(),LTMap.Profile)
	if not self.delegate:canEnterView() then
		return;
	end
	umengStatics_lua(Umeng_HallMallBtn);
	require("MahjongHall/Mall/MallWindow");

	self.delegate:playExitHallWithMoveBgAnim(-1,self,function(self )
		self.mallWindow = new(MallWindow, stateTag, self.delegate)
		self.mallWindow:set_callback_exit(self, function(self, bs)
			self.mallWindow = nil;
		end );
	end)

end

HallBottomLayer.onClickedTaskBtn = function ( self )
	DebugLog('Profile clicked task start:'..os.clock(),LTMap.Profile)
	if not self.delegate:canEnterView() then
		return;
	end

	require("MahjongHall/Task/TaskWindow");
	umengStatics_lua(Umeng_HallTaskBtn);

	self.delegate:playExitHallWithMoveBgAnim(-1,self,function(self )
		self.taskWindow = new(TaskWindow , self.delegate);
		self.taskWindow:set_callback_exit(self, function(self)
			DebugLog("HallBottomLayer callback self.taskWindow = nil")
			self.taskWindow = nil;
		end );
	end)

end

HallBottomLayer.onClickedRankBtn = function ( self )
	DebugLog('Profile clicked rank start:'..os.clock(),LTMap.Profile)
	if not self.delegate:canEnterView() then
		return;
	end
	if GameConstant.iosDeviceType>0 and GameConstant.iosPingBiFee  then
		Banner.getInstance():showMsg("暂未开放")
		return
	end
	umengStatics_lua(Umeng_HallRankBtn);
	self.delegate:playExitHallWithMoveBgAnim(-1,self,function(self )
		if PlatformConfig.platformYiXin == GameConstant.platformType then
			require("MahjongHall/Rank/YiXinRankWindow");
			self.rankWindow = new(YiXinRankWindow , self.delegate);
			self.rankWindow:set_callback_exit(self, function(self)
				self.rankWindow = nil;
			end );
		else
			require("MahjongHall/Rank/RankWindow");
			self.rankWindow = new(RankWindow , self.delegate);
			self.rankWindow:set_callback_exit(self, function(self)
				self.rankWindow = nil;
			end );
		end
	end)

end

HallBottomLayer.onClickedActivityBtn = function ( self )
	DebugLog('Profile clicked activity start:'..os.clock(),LTMap.Profile)
	if GameConstant.checkType == kCheckStatusOpen then --审核状态
		Banner.getInstance():showMsg("暂无活动")
		return
	end



	if isPlatform_Win32() then
		local activityBtn = self:getControl(HallBottomLayer.s_controls.activityBtn );
		self:updateTipNum( publ_getItemFromTree(activityBtn, {"tip"} ) , 0)
		return ;
	end

	umengStatics_lua(Umeng_HallHuoDongBtn);
    local count = GlobalDataManager.getInstance():get_activity_count();
    DebugLog("[HallBottomLayer]:onClickedActivityBtn :"..tostring(count));
    --如果活动数量<0 怎不进入活动页面
    if not count or count <= 0 then
        Banner.getInstance():showMsg("暂无活动");
        return;
    end

	showOrHide_sprite_lua(0);

	local activityBtn = self:getControl(HallBottomLayer.s_controls.activityBtn );
	self:updateTipNum( publ_getItemFromTree(activityBtn, {"tip"} ) , 0)

	self.delegate:playExitHallAnim(self,function(self)
		self:enterActivityView()
	end);
end

--without exit anim
HallBottomLayer.enterActivityView = function ( self )
	local param = { };
	param.mid = PlayerManager.getInstance():myself().mid;
	local data = { };
	data.api = HttpModule.postParam("Activity", param);
	data.activityId = 1;
	data.popuType = "0";
	data.url = PlatformConfig.ACTIVITY_URL;
	data.isRss = self.is_rss or 0;
	data.mid = param.mid;
	for k, v in pairs(data) do
		print(k, v)
	end
	native_to_java(kStartActivty, json.encode(data));
end

HallBottomLayer.onClickedExchangeBtn = function ( self,stateTag)
	DebugLog('Profile clicked exchange start:'..os.clock(),LTMap.Profile)
	if not self.delegate:canEnterView() then
		return;
	end



	umengStatics_lua(Umeng_HallMallBtn);
	require("MahjongHall/Mall/ExchangeWindow");

	self.delegate:playExitHallWithMoveBgAnim(-1,self,function(self )
		self.exchangeWindow = new(ExchangeWindow, stateTag, self.delegate);
		self.exchangeWindow:set_callback_exit(self, function(self, bs)
			self.exchangeWindow = nil;
		end );
	end)

end

--按钮事件: 好友
HallBottomLayer.onClickedFriendBtn = function ( self )
	DebugLog('Profile clicked friend start:'..os.clock(),LTMap.Profile)
	if not self.delegate:canEnterView() then
		return;
	end

    require("MahjongHall/Friend/NewFriendView")

    local obj = self.delegate;
    obj:playExitHallWithMoveBgAnim(-1,obj,function(obj )
		obj.friendView = new(NewFriendView, obj)
		obj.friendView:set_callback_exit(obj, function(obj, bs)
			obj.friendView = nil;
		    end );
    end);
end

-------------------------------------------------------------------------------------------------------------------------------------

-- 定义可操作控件的标识
HallBottomLayer.s_controls =
{
	mallBtn 			= 1,
	taskBtn 			= 2,
	rankBtn				= 3,
	activityBtn  		= 4,
	exchangeBtn  		= 5,
	forwardBtn 			= 6,
    friendBtn           = 7,
}

-- 可操作控件在布局文件中的位置
HallBottomLayer.s_controlConfig =
{
	[HallBottomLayer.s_controls.mallBtn] 			= { "hall_bottom_view", "bg", "mall_btn" },
	[HallBottomLayer.s_controls.taskBtn] 			= { "hall_bottom_view", "bg", "task_btn" },
	[HallBottomLayer.s_controls.rankBtn]			= { "hall_bottom_view", "bg", "rank_btn" },
	[HallBottomLayer.s_controls.activityBtn] 		= { "hall_bottom_view", "bg", "activity_btn" },
	[HallBottomLayer.s_controls.exchangeBtn] 		= { "hall_bottom_view", "bg", "exchange_btn"},
	[HallBottomLayer.s_controls.forwardBtn] 		= { "hall_bottom_view", "bg", "forward"},
    [HallBottomLayer.s_controls.friendBtn] 		    = { "hall_bottom_view", "bg", "btn_friend"},

}

-- 可操作控件的响应函数
HallBottomLayer.s_controlFuncMap =
{
	[HallBottomLayer.s_controls.mallBtn] 			= HallBottomLayer.onClickedMallBtn,
	[HallBottomLayer.s_controls.taskBtn] 			= HallBottomLayer.onClickedTaskBtn,
	[HallBottomLayer.s_controls.rankBtn]			= HallBottomLayer.onClickedRankBtn,
	[HallBottomLayer.s_controls.activityBtn] 		= HallBottomLayer.onClickedActivityBtn,
	[HallBottomLayer.s_controls.exchangeBtn]		= HallBottomLayer.onClickedExchangeBtn,
    [HallBottomLayer.s_controls.friendBtn]		    = HallBottomLayer.onClickedFriendBtn,

}

-- 可接受的更新界面命令
HallBottomLayer.s_cmds =
{
	--updataUserInfo = 1,

};

-- 命令响应函数
HallBottomLayer.s_cmdConfig =
{
	--[HallBottomLayer.s_cmds.updataUserInfo] = HallBottomLayer.updataUserInfo,

};

HallBottomLayer.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_REQUEST_IS_SHOW_MOBILE_GAMER] 				= HallBottomLayer.requestIsShowMobileGamerCallBack,

	[PHP_CMD_REQUEST_IS_SUBSCRIBE_MOBILE_GAMER]   		= HallBottomLayer.requestIsSubscribeMobileGamerCallBack,
	--[PHP_CMD_REQUEST_TASK_LIST]							= HallBottomLayer.requestTaskListCallback,

};
