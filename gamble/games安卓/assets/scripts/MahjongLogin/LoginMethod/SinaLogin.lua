--[[
	className    	     :  SinaLogin
	Description  	     :  登录类-子类(Sina登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

SinaLogin = class(BaseLogin);

--[[
	function name      : SinaLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20  2013
	create-time		   : Dec.20  2013
]]
SinaLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.SinaLogin;
end

SinaLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentitySina;
end
SinaLogin.getLoginType = function(self)
	return PlatformConfig.SinaLogin;
end
--[[
	function name      : SinaLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
SinaLogin.login = function ( self, ... )
	umengStatics_lua(kUmengSinaLogin);
	local params = ...;
	self.m_data = kSinaLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.SinaLogin);

	if GameConstant.lastLoginType ~= PlatformConfig.SinaLogin then 
		self.m_sitemid = g_DiskDataMgr:getAppData(kLoginSid .. PlatformConfig.SinaLogin, "");
		self.m_token = g_DiskDataMgr:getAppData(kToken .. PlatformConfig.SinaLogin, "");
		if DEBUGMODE == 1 then 
			-- Banner.getInstance():showMsg("两次值不一样 directLogin" .. self.m_sitemid .. ";" .. self.m_token );	
		end
		if self.m_sitemid ~= "" and self.m_token ~= "" then 
			GameConstant.lastLoginType = PlatformConfig.SinaLogin;
			self:OnRequestLoginPHP(self:setSendLoginPHPdata());
			return;
		end
	end

	if isPlatform_Win32() then 
		self.m_sitemid = self.m_data.sinaDefaultLoginSID;
		self.m_token = self.m_data.sinaDefaultLoginSessionKey;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else
		self.m_data.loginType = PlatformConfig.SinaLogin; 
		native_muti_login(self.m_data)
	end
end

SinaLogin.getLoginIdentityIcon = function(self)
	return "Login/sinaIcon.png";
end

--[[
	function name      : SinaLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
SinaLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.SinaLogin);
	if isSuccess then 
		local msg;
		if 1 ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			g_DiskDataMgr:setAppData(kLoginSid .. PlatformConfig.SinaLogin , self.m_sitemid);
			g_DiskDataMgr:setAppData(kToken .. PlatformConfig.SinaLogin , self.m_token);
			GameConstant.lastLoginType = PlatformConfig.SinaLogin;
		else
			GameConstant.isLogin = kNoLogin;
			GameConstant.lastLoginType = self:getLoginType();
			msg = GetStrFromJsonTable(data,kMsg);
		end
		if msg ~= nil and kNullStringStr ~= msg then 
			Banner.getInstance():showMsg(msg);
		end
	-- else
	-- 	GameConstant.isLogin = kNoLogin;
	-- 	---失败清除失效token openid localtoken
	-- 	GameConstant.sitemid = "";
	-- 	GameConstant.token = "";
	-- 	g_DiskDataMgr:setAppData(kLocalSDKOpenId .. self:getLoginType(), GameConstant.sitemid, true);
	-- 	g_DiskDataMgr:setAppData(kLocalSDKToken .. self:getLoginType(), GameConstant.token, true);
	-- 	g_DiskDataMgr:setAppData(kLocalToken .. self:getLoginType(), "", true);
	-- 	if GameConstant.isSkipSdk then
	-- 		self:login(); 
	-- 	end 
	-- 	---------------------------------------
	-- 	Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
end

--处理Java的回调接口
SinaLogin.loginCallback = function (self, json_data)
	self.m_sitemid = GetStrFromJsonTable(json_data, "uid", GameConstant.imei)
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

SinaLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : SinaLogin.logout
	description  	   : Sina登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
SinaLogin.logout = function(self)
	self.super.logout( self );
	if isPlatform_Win32() then
		self.m_data.loginType = PlatformConfig.SinaLogin; 
		local dataStr = json.encode(self.m_data); 
		native_to_java(kLogoutPlatform,dataStr);
	end
end

--[[
	function name      : SinaLogin.clearGameData
	description  	   : 清除Sina登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
SinaLogin.clearGameData = function(self)
	GameConstant.sitemid = nil;
	GameConstant.token = nil;
	self.super.clearGameData( self );
end

--[[
	function name      : SinaLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
SinaLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.sitemid = self.m_sitemid;
	send_data.token = self.m_token;
	send_data.vkey = GameConstant.imei;
	send_data.appid = GameConstant.appid;
	send_data.appkey = GameConstant.appkey;
	send_data.macAddress = GameConstant.macAddress;
	send_data.SIMunique = GameConstant.imei;
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. PlatformConfig.SinaLogin,"");
	send_data.localtoken = localtoken;
	return send_data;
end


