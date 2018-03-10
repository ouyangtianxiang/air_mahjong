--[[
	className    	     :  ChubaoLogin
	Description  	     :  登录类-子类(触宝登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

ChubaoLogin = class(BaseLogin);

--[[
	function name      : ChubaoLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
ChubaoLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.ChubaoLogin;
end

--[[
	function name      : ChubaoLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
ChubaoLogin.dtor = function (self )
end

ChubaoLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityChubao;
end
ChubaoLogin.getLoginType = function(self)
	return PlatformConfig.ChubaoLogin;
end
--[[
	function name      : ChubaoLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
ChubaoLogin.login = function ( self,...)
	umengStatics_lua(kUmengChubaoLogin);
	if self.isLogout then 
		self.isLogout = false
		self:logout()
	else
		self.super.login(self);
		self.m_data = {}
		PlatformFactory.curPlatform:setAPI(PlatformConfig.ChubaoLogin);
		if isPlatform_Win32() then 
			self.m_nickName = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
			self.m_sitemid = SystemGetSitemid();
			PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
			self:OnRequestLoginPHP(self:setSendLoginPHPdata());
			PlatformFactory.curPlatform.curLoginType = PlatformConfig.ChubaoLogin;
		else 
			self.m_data.loginType = PlatformConfig.ChubaoLogin;
			native_muti_login(self.m_data)
		end
	end
end

function ChubaoLogin:setLogout( flag )
	self.isLogout = flag
end

--[[
	function name      : ChubaoLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
ChubaoLogin.requestLoginCallBack = function (self, isSuccess, data)
	PlatformFactory.curPlatform:setAPI(PlatformConfig.ChubaoLogin);
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
		GameConstant.lastLoginType = PlatformConfig.ChubaoLogin;
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
end

ChubaoLogin.getLoginIdentityIcon = function(self)
	return "Login/chubaoLoginIcon.png";
end

ChubaoLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

-- --[[
-- 	function name      : ChubaoLogin.callEvent
-- 	description  	   : @Override 
-- 	param 	 	 	   : self
-- 	last-modified-date : Nov.29 2013
-- 	create-time		   : Nov.29 2013
-- ]]
ChubaoLogin.loginCallback = function(self,json_data)
	local cootek_uid = GetStrFromJsonTable(json_data,"cootek_uid", "")
	DebugLog("cootek_uid" .. cootek_uid);
	self.m_token = cootek_uid;

	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	function name      : ChubaoLogin.logout
	description  	   : 华为登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
ChubaoLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then
		self.m_data.loginType = PlatformConfig.ChubaoLogin;
		self.m_data.pluginId = PluginUtil:convertLoginId2Plugin(PlatformConfig.ChubaoLogin)
		local dataStr = json.encode(self.m_data);
		native_to_java("MutiLogout",dataStr); 
	end
end

--[[
	function name      : ChubaoLogin.clearGameData
	description  	   : 清除华为登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
ChubaoLogin.clearGameData = function(self)
	
	self.m_sitemid = nil;
	self.m_nickName = nil;
	self.m_token = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : ChubaoLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
ChubaoLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	
	if isPlatform_Win32() then 
    	send_data.nick = self.m_nickName;
		send_data.sitemid = self.m_sitemid;
		send_data.macAddress = GameConstant.macAddress;
		send_data.localtoken = localtoken;

	else
	    send_data.cootek_uid = self.m_token;
		send_data.localtoken = localtoken;
	    
    end
	return send_data;
end


