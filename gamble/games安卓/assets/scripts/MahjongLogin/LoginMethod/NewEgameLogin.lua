--[[
	className    	     :  NewEgameLogin
	Description  	     :  登录类-子类(QQ登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");
require("MahjongHttp/HttpModule");
NewEgameLogin = class(BaseLogin);

--[[
	function name      : NewEgameLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
NewEgameLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.NewEgameLogin;
end

--[[
	function name      : NewEgameLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
NewEgameLogin.dtor = function (self )
end

NewEgameLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentitynewEgame or "";
end

NewEgameLogin.getLoginType = function(self)
	return PlatformConfig.NewEgameLogin;
end

--[[
	function name      : NewEgameLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewEgameLogin.login = function ( self, ... )
	umengStatics_lua(kUmengNewEgameLogin);
	self.super.login(self);

	-- params.isCallSdk
	local params = ...;
	self.m_data = kNewEgameLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.NewEgameLogin);
	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.NewEgameLogin;
	else 
		local param = {};
		param.loginType = PlatformConfig.NewEgameLogin;
		native_muti_login(param)
	end
end

--[[
	function name      : NewEgameLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewEgameLogin.requestLoginCallBack = function (self, isSuccess, data)
		GameConstant.requestLogin = false;

	if isSuccess then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			GameConstant.lastLoginType = PlatformConfig.NewEgameLogin;
		else
			GameConstant.isLogin = kNoLogin;
			msg = GetStrFromJsonTable(data,kMsg);
		end
		if msg ~= nil and kNullStringStr ~= msg then 
			Banner.getInstance():showMsg(msg);
		end
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
	
end

NewEgameLogin.getLoginIdentityIcon = function(self)
	return "Login/egameLoginIcon.png";
end

NewEgameLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : NewEgameLogin.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewEgameLogin.loginCallback = function(self,json_data)
	if json_data.status == "LOGIN_CANCEL" or json_data.status == "LOGIN_FAILED" then 
		DebugLog("egame cancel login")
		return
	end

	local code = kNullStringStr;
	local version = kNullStringStr;

	if GetStrFromJsonTable(json_data,"code") and kNullStringStr ~= GetStrFromJsonTable(json_data,"code") then
	 	code = GetStrFromJsonTable(json_data,"code");
	end

	if GetStrFromJsonTable(json_data,"version") and kNullStringStr ~= GetStrFromJsonTable(json_data,"version") then
	 	version = GetStrFromJsonTable(json_data,"version");
	end

	GameConstant.code = code;
	GameConstant.version = version;

	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	function name      : NewEgameLogin.logout
	description  	   : QQ登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewEgameLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then 
		self.m_data.loginType = PlatformConfig.NewEgameLogin; 
		local dataStr = json.encode(self.m_data);
		native_to_java(kLogoutPlatform,dataStr);
	end
end

--[[
	function name      : NewEgameLogin.clearGameData
	description  	   : 清除QQ登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewEgameLogin.clearGameData = function(self)
	GameConstant.code = nil;
	GameConstant.version = nil;
	self.super.clearGameData( self );
end

--[[
	function name      : NewEgameLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewEgameLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	if isPlatform_Win32() then 
		send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
	else 
		send_data.code = GameConstant.code;
		send_data.version = GameConstant.version;
	end
	return send_data;
end

