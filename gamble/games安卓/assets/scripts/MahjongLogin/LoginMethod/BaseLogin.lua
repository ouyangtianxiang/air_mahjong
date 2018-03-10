--[[
	className    	     :  BaseLogin
	Description  	     :  To wrap all the methods of login,this is an abstract class.
				    	    which duplicate this method,must implement its all methods.
	last-modified-date   :  Nov.29 2013
	create-time 	   	 :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :　jkinLiu
]]
BaseLogin = class();

--public parameter which to regist the event that http login needs.
BaseLogin.loginResuleEvent = EventDispatcher.getInstance():getUserEvent();

--[[
	function name	   : BaseLogin.ctor
	description  	   : Construct a class.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BaseLogin.ctor = function (self)
	self.m_data = {};
	self.appId = nil;
	self.m_loginMethod = nil;
	EventDispatcher.getInstance():register(NativeManager._Event, self, self.callEvent);
	self.m_event = EventDispatcher.getInstance():getUserEvent();
	EventDispatcher.getInstance():register(self.m_event, self, self.onLoginHttpRequestsListenster);

	EventDispatcher.getInstance():register(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
end

BaseLogin.getLoginUserName = function(self)
	error("Sub class must define this function :BaseLogin.getLoginUserName");
end

BaseLogin.getLoginType = function(self)
	error("Sub class must define this function :BaseLogin.getLoginType");
	return -1;
end

--[[
	function name	   : BaseLogin.dtor
	description  	   : Destructor a class.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BaseLogin.dtor = function (self)
	self.appId = nil;
	self.m_loginMethod = nil;
	self:clearGameData();
	EventDispatcher.getInstance():unregister(SocketManager.s_phpMsg, self, self.onPhpMsgResponse);
	EventDispatcher.getInstance():unregister(self.m_event, self, self.onLoginHttpRequestsListenster);
	EventDispatcher.getInstance():unregister(NativeManager._Event, self, self.callEvent);
end

--[[
	function name	   : BaseLogin.login
	description  	   : To login.For it's son class,it must duplicate this class .
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BaseLogin.login = function ( self, ... )

end

--[[
	function name	   : BaseLogin.logout
	description  	   : To logout.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BaseLogin.logout = function(self)
	self:clearGameData();
end

--[[
	function name	   : BaseLogin.clearGameData
	description  	   : To reset the data of login.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time  	   : Oct.29 2013
]]
BaseLogin.clearGameData = function(self)
	self.m_sitemid = kNullStringStr;
	self.m_nickName = kNullStringStr;
	self.m_token = kNullStringStr;

	self.m_data = {};

	GameConstant.m_leftOnlineIcon = {};
	GameConstant.oneFriendList = {};
	GameConstant.level = {};
	GameConstant.isInvited = false;

	FriendDataManager.getInstance():clearData()
	--FriendDataManager.getInstance():dtor();

	GameConstant.isLogin = kNoLogin;
	PlayerManager.getInstance():myself():resetPlayerData(); -- 清除玩家数据
	if HallScene_instance ~= nil then
		HallScene_instance.m_topLayer:updateUserInfo(self.player);
		--HallController_instance:updateView( HallScene.s_cmds.updataUserInfo, PlayerManager.getInstance():myself() );
	end
	--SocketManager.getInstance():syncClose(); -- 关闭socket
end

---------------------------------------------------------------PHP  Request--------------------------------------------------------------------------------------
--[[
	function name      : BaseLogin.setSendLoginPHPdata
	description  	   : set the data of login PHP to send.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BaseLogin.setSendLoginPHPdata = function(self)
	error("Sub class must define this function :BaseLogin.getSendPHPdata");
end

--[[
	function name      : BaseLogin.OnRequestLoginPHP
	description  	   : Login Request.
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Oct.29 2013
]]
BaseLogin.OnRequestLoginPHP = function (self,param_data)
	DebugLog("BaseLogin.OnRequestLoginPHP")
	if not param_data then
		return;
	end
--    --modify by NoahHan 防止多次login方法调用
--    if GlobalDataManager.getInstance():getPlatformLogining() == true then
--        DebugLog("BaseLogin.OnRequestLoginPHP 不能登录多次");
--        return;
--    end
--    GlobalDataManager.getInstance():setPlatformLogining(true);

    --区分手机登录，只有在手机登录的回调里才能设置为true
    -- 联运版本没有手机绑定
    if PlatformFactory.curPlatform:isLianYunNotChannel() then
    	GlobalDataManager.getInstance():setIsCellAcccountLogin(true);
    else
    	GlobalDataManager.getInstance():setIsCellAcccountLogin(false);
    end
	GameConstant.requestLogin = true;
    param_data.mobile = {}; --上报设备信息
	param_data.mobile.dtype = GameConstant.model_name; --手机型号
	param_data.mobile.pixel = GameConstant.rat; --机屏大小
	param_data.mobile.imei = GameConstant.imei;  --设备号
	DebugLog("GameConstant.osv"..GameConstant.osv);
	if GameConstant.osv ~= "" then
		if GameConstant.iosDeviceType==0 then
			GameConstant.osv = "android " .. GameConstant.osv;
		end
	end
	param_data.mobile.os = GameConstant.osv;    --终端操作系统
	if GameConstant.iosDeviceType>0 then
		param_data.mobile.os = "ios " .. GameConstant.osv;
	end
	param_data.mobile.network = GameConstant.net; --接入方式，例如wifi
	param_data.mobile.operator = GameConstant.operator or "未知"; --运营商
	param_data.mobile.imsi = getLocalImsi(); -- 手机号唯一标示符

	if GameConstant.iosDeviceType>0 then
		param_data.iosNeedMore = 1;
		param_data.openUDID = GameConstant.imei;
		param_data.nick = GameConstant.model_name;
		if DEBUGMODE == 1 then
			if param_data.fakeguest and param_data.fakeguest==1 and param_data.fakeopenUDID then
				param_data.openUDID = param_data.fakeopenUDID;
			end
		end
	end

	mahjongPrint(param_data)
	DebugLog("socket status:" .. tostring(SocketManager.m_isRoomSocketOpen))
	--Loading.showLoadingAnim(PromptMessage.loadingLogin);
	if not SocketManager.m_isRoomSocketOpen then
		SocketManager.getInstance():openSocket(self:getLoginType())
	else
		SocketManager.getInstance():sendPack(PHP_CMD_REQUEST_LOGIN,param_data)
	end
	--HttpModule.getInstance():execute(HttpModule.s_cmds.requestLogin,param_data,self.m_event);
end

BaseLogin.getLoginIdentityIcon = function(self)
	error("Sub class must define this function:BaseLogin.getLoginIdentityIcon");
end

--[[
	function name	   : BaseLogin.callEvent
	description  	   : For it's son class,it must duplicate this class .
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
BaseLogin.callEvent = function(self, param, json_data)
DebugLog("BaseLogin.callEvent, key:" .. tostring(param) .. ", data:" .. tostring(json_data))
print_string(debug.traceback())
	if param == kMutiLogin or param == kSwitchPlatform then
		if not json_data then
			DebugLog( "kLoginPlatform initResult is nil" );
			return;
		end

		local loginType = PluginUtil:convertPlugin2LoginId(GetNumFromJsonTable(json_data, "pluginId", 0))
		if GameConstant.iosDeviceType > 0 then
					loginType = json_data.loginType;
		end
		DebugLog( "self:getLoginType() = "..self:getLoginType() .. ", loginType = "..loginType );
		if self:getLoginType() == loginType then
			self:loginCallback(json_data);
		end

	elseif param == kMutiLogout then
		if not json_data then
			return;
		end

		local loginType = PluginUtil:convertPlugin2LoginId(GetNumFromJsonTable(json_data, "pluginId", 0))
		if self:getLoginType() == loginType then
			self:logoutCallback(json_data);
		end

	elseif param == "loginNotConnect" then
		Banner.getInstance():showMsg("您的网络连接异常！");
	end
end

--处理Java的回调接口
BaseLogin.loginCallback = function (self, json_data)
	self.m_sitemid = GetStrFromJsonTable(json_data, "sitemid", GameConstant.imei)
	self.m_nickName = GetStrFromJsonTable(json_data, kLoginName, kNullStringStr)
	self.m_token = GetStrFromJsonTable(json_data, kToken, kNullStringStr)
	local status = GetNumFromJsonTable(json_data, "status", 0)

	if status == 1 then
		self:OnRequestLoginPHP(self:setSendLoginPHPdata())
	else
		if HallScene_instance ~= nil then
			HallScene_instance:addLoginView()
		end
	end

end

--处理登出回调
BaseLogin.logoutCallback = function ( self, json_data )
	DebugLog("BaseLogin.logoutCallback, subclass implement according to self")
end

--[[
	function name      : BaseLogin.onLoginHttpRequestsListenster
	description  	   : To send http request.
	param 	 	 	   : self
					   : command  		 Table 	   -- PHP command which from HttpModule.
	last-modified-date : Nov.29 2013
	create-time		   : Oct.29 2013
]]
BaseLogin.onLoginHttpRequestsListenster = function(self,command,...)
	if self.httpRequestsCallBackFuncMap[command] then
     	self.httpRequestsCallBackFuncMap[command](self,...);
	end
end

BaseLogin.onPhpMsgResponse = function ( self, param, cmd, isSuccess )
--    GlobalDataManager.getInstance():setPlatformLogining(false);
	if self.m_loginMethod ~= PlatformFactory.curPlatform:getCurrentLoginType() then
		return;
	end
	if self.httpSocketRequestsCallBackFuncMap[cmd] then
		self.httpSocketRequestsCallBackFuncMap[cmd](self,isSuccess,param)
	end
end

--[[
	function name 		: BaseLogin.toGetProductAppId
	description 		: To get ProductAppId
	param 				: self
	last-modified-date 	: Aug.21 2014
	create-time 		: Aug.21 2014
]]
BaseLogin.toGetProductAppId = function(self)
	return self.appId;
end

 --[[
	function name      : BaseLogin.requestLoginCallBack
	description  	   : For it's son class,it must duplicate this class .
	param 	 	 	   : self
					   : isSuccess      Boolean   -- The value of the php return,if Success returns true,it expresses success,and false,it express failed.
					   : data           Table     -- The data of PHP command returns.
	last-modified-date : Nov.29 2013
	create-time		   : Oct.29 2013
]]
BaseLogin.requestLoginCallBack = function (self, isSuccess, data)
	error("Sub class must define this function :BaseLogin.requestLoginCallBack");
end

BaseLogin.requestLoginPHPCallBack = function(self,isSuccess,data)

	self:requestLoginCallBack(isSuccess,data);
end

BaseLogin.httpRequestsCallBackFuncMap =
{
	[PHP_CMD_REQUEST_LOGIN] = BaseLogin.requestLoginPHPCallBack,
};

BaseLogin.httpSocketRequestsCallBackFuncMap =
{
	[PHP_CMD_REQUEST_LOGIN] = BaseLogin.requestLoginPHPCallBack,
};
