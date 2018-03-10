--[[
	className    	     :  QQLogin
	Description  	     :  登录类-子类(QQ登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");
require("MahjongHttp/HttpModule");
QQLogin = class(BaseLogin);

--[[
	function name      : QQLogin.ctor
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
QQLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.QQLogin;
end


QQLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityQQ;
end

QQLogin.getLoginType = function(self)
	if not PlatformFactory.curPlatform:isLianYunNotChannel() then
		return PlatformConfig.QQLogin;
	else
		return PlatformConfig.OldQQLogin;
	end
end

--[[
	function name      : QQLogin.login
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
QQLogin.login = function ( self, ... )
	umengStatics_lua(kUmengQQLogin);
	-- params.isCallSdk
	local params = ...;
	self.m_data = kQQLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.QQLogin);
	if GameConstant.isReconnectGame or GameConstant.lastLoginType ~= PlatformConfig.QQLogin then
		self.m_sitemid = g_DiskDataMgr:getAppData(kLoginSid .. PlatformConfig.QQLogin, "");
		self.m_token = g_DiskDataMgr:getAppData(kToken .. PlatformConfig.QQLogin, "");

		if self.m_sitemid ~= "" and self.m_token ~= "" then
			self:OnRequestLoginPHP(self:setSendLoginPHPdata());
			GameConstant.isReconnectGame = false;
			return;
		end
	end

	if isPlatform_Win32() then
		self.m_sitemid = self.m_data.qqDefaultLoginOpenId;
		self.m_token = self.m_data.qqDefaultLoginToken;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else
		if not PlatformFactory.curPlatform:isLianYunNotChannel() then
			self.m_data.loginType = PlatformConfig.QQLogin;
		else
			self.m_data.loginType = PlatformConfig.OldQQLogin;
		end
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : QQLogin.loginCallback
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
QQLogin.loginCallback = function(self, json_data)
	local status = GetNumFromJsonTable(json_data, "status", 0)
	self.m_sitemid = GetStrFromJsonTable(json_data, "openid", GameConstant.imei)
	self.m_token = GetStrFromJsonTable(json_data, kToken, kNullStringStr)

	if status == 1 then
		self:OnRequestLoginPHP(self:setSendLoginPHPdata())
	else
		if HallScene_instance ~= nil then
			HallScene_instance:addLoginView()
		end
	end
end

--[[
	function name      : QQLogin.requestLoginCallBack
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]

QQLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	GameConstant.lastLoginType = PlatformConfig.QQLogin;
	if isSuccess then
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			g_DiskDataMgr:setAppData(kLoginSid .. PlatformConfig.QQLogin , self.m_sitemid);
			g_DiskDataMgr:setAppData(kToken .. PlatformConfig.QQLogin , self.m_token);
		else
			---失败清除失效token openid localtoken
			GameConstant.sitemid = "";
			GameConstant.token = "";
			g_DiskDataMgr:setAppData(kLoginSid .. PlatformConfig.QQLogin, "");
			g_DiskDataMgr:setAppData(kToken .. PlatformConfig.QQLogin, "");
			g_DiskDataMgr:setAppData(kLocalToken .. PlatformConfig.QQLogin, "");
			GameConstant.isLogin = kNoLogin;
			msg = GetStrFromJsonTable(data,kMsg);
		end
		if msg ~= nil and kNullStringStr ~= msg then
			Banner.getInstance():showMsg(msg);
		end
	end
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
end

QQLogin.getLoginIdentityIcon = function(self)
	return "Login/qqIcon.png";
end

QQLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : QQLogin.logout
	description  	   : QQ登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
QQLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then
		self.m_data.loginType = PlatformConfig.QQLogin;
		local dataStr = json.encode(self.m_data);
		native_to_java(kLogoutPlatform,dataStr);
	end
	self:login()   --重新进行登录
end

--[[
	function name      : QQLogin.setSendLoginPHPdata
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
QQLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.sitemid = self.m_sitemid
	send_data.token = self.m_token;
	send_data.vkey = GameConstant.imei;
	send_data.appid = GameConstant.appid;
	send_data.appkey = GameConstant.appkey;
	send_data.macAddress = GameConstant.macAddress;
	send_data.SIMunique = GameConstant.imei;

	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. PlatformConfig.QQLogin,"");
	send_data.localtoken = localtoken;
	return send_data;
end
