--[[
	className    	     :  HuaweiLogin
	Description  	     :  登录类-子类(华为登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

HuaweiLogin = class(BaseLogin);

--[[
	function name      : HuaweiLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
HuaweiLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.HuaweiLogin;
end

--[[
	function name      : HuaweiLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
HuaweiLogin.dtor = function (self )
end

HuaweiLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityHuawei;
end
HuaweiLogin.getLoginType = function(self)
	return PlatformConfig.HuaweiLogin;
end
--[[
	function name      : HuaweiLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
HuaweiLogin.login = function ( self,...)
	umengStatics_lua(kUmengHuaweiLogin);
	self.super.login(self);
	self.m_data = kHuaweiLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.HuaweiLogin);
	local dataStr = json.encode(self.m_data);
	if isPlatform_Win32() then 
		self.m_nickName = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		self.m_sitemid = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.HuaweiLogin;
	else 
		self.m_data.loginType = PlatformConfig.HuaweiLogin;
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : HuaweiLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
HuaweiLogin.requestLoginCallBack = function (self, isSuccess, data)
	PlatformFactory.curPlatform:setAPI(PlatformConfig.HuaweiLogin);
	if isSuccess then 
		local msg;
		if 1 ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
		else
			GameConstant.isLogin = kNoLogin;
			msg = GetStrFromJsonTable(data,kMsg);
		end
		if msg ~= nil and kNullStringStr ~= msg then 
			Banner.getInstance():showMsg(msg);
		end
		GameConstant.lastLoginType = PlatformConfig.HuaweiLogin;
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
end

HuaweiLogin.getLoginIdentityIcon = function(self)
	return "Login/huawei.png";
end

function HuaweiLogin:setLogout( flag )
	self.isLogout = flag
end


HuaweiLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

-- --[[
-- 	function name      : HuaweiLogin.callEvent
-- 	description  	   : @Override 
-- 	param 	 	 	   : self
-- 	last-modified-date : Nov.29 2013
-- 	create-time		   : Nov.29 2013
-- ]]
HuaweiLogin.loginCallback = function(self,json_data)
	local name 	= kNullStringStr;
	local userId = kNullStringStr;
	local accessToken = kNullStringStr;

	if GetStrFromJsonTable(json_data,"name") and kNullStringStr ~= GetStrFromJsonTable(json_data,"name") then
	  	name = GetStrFromJsonTable(json_data,"name");
	end

	if GetStrFromJsonTable(json_data,"userId") and kNullStringStr ~= GetStrFromJsonTable(json_data,"userId") then
		userId = GetStrFromJsonTable(json_data,"userId");
	end

	if GetStrFromJsonTable(json_data,"accessToken") and kNullStringStr ~= GetStrFromJsonTable(json_data,"accessToken") then
		accessToken = GetStrFromJsonTable(json_data,"accessToken");
	end
	DebugLog("name:" .. name);
	DebugLog("userId:" .. userId);
	DebugLog("accessToken" .. accessToken);

	self.m_sitemid = userId;
	self.m_nickName = name;
	self.m_token = accessToken;

	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	function name      : HuaweiLogin.logout
	description  	   : 华为登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
HuaweiLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then
		-- self.m_data.loginType = PlatformConfig.HuaweiLogin;
		-- local dataStr = json.encode(self.m_data);
		-- native_to_java(kLogoutPlatform,dataStr); 
		SocketManager.getInstance():socketCloseAndOpen()
	end
end

--[[
	function name      : HuaweiLogin.clearGameData
	description  	   : 清除华为登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
HuaweiLogin.clearGameData = function(self)
	
	self.m_sitemid = nil;
	self.m_nickName = nil;
	self.m_token = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : HuaweiLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
HuaweiLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	
	if isPlatform_Win32() then 
    	send_data.nick = self.m_nickName;
		send_data.sitemid = self.m_sitemid;
		send_data.macAddress = GameConstant.macAddress;
		send_data.localtoken = localtoken;

	else
		send_data.hw_name = self.m_nickName;
	    send_data.hw_userId = self.m_sitemid; 
	    send_data.hw_accessToken = self.m_token;
		send_data.localtoken = localtoken;
	    
    end
	return send_data;
end


