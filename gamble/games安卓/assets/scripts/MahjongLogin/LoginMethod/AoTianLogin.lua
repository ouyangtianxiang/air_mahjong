--[[
	AoTianassName    	     :  AoTianLogin
	Description  	     :  登录类-子类(傲天登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");
require("MahjongHttp/HttpModule");
AoTianLogin = class(BaseLogin);

--[[
	AoTiannction name      : QQLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
AoTianLogin.ctor = function (self,data )
	self.appId = PlatformFactory.curPlatform:getLoginAppId( PlatformConfig.AoTianLogin);
end

--[[
	AoTiannction name      : QQLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
AoTianLogin.dtor = function (self )
end

AoTianLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityAoTian;
end

AoTianLogin.getLoginType = function(self)
	return PlatformConfig.AoTianLogin;
end

--[[
	AoTiannction name      : QQLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
AoTianLogin.login = function ( self, ... )
	self.super.login(self);
	
	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.AoTianLogin;
	else 
		local param = {};
		param.loginType = PlatformConfig.AoTianLogin;
		native_muti_login(param)
	end
end

--[[
	AoTiannction name      : QQLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
AoTianLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.AoTianLogin);
	if isSuccess then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
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
	EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
	
end

AoTianLogin.getLoginIdentityIcon = function(self)
	return "Login/aotianIcon.png";
end

AoTianLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	AoTiannction name      : QQLogin.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
AoTianLogin.loginCallback = function(self,json_data)
	local uid = nil;
	local token = nil;
	local userName = nil;
	GameConstant.isFirstPopu = 1;

	if GetStrFromJsonTable(json_data,"userID") and kNullStringStr ~= GetStrFromJsonTable(json_data,"userID") then
	 	uid = GetStrFromJsonTable(json_data,"userID");
	end

	if GetStrFromJsonTable(json_data,"token") and kNullStringStr ~= GetStrFromJsonTable(json_data,"token") then
		token = GetStrFromJsonTable(json_data,"token");
	end

	if GetStrFromJsonTable(json_data,"userName") and kNullStringStr ~= GetStrFromJsonTable(json_data,"userName") then
		userName = GetStrFromJsonTable(json_data,"userName");
	end


	if PlatformFactory.curPlatform:needFirstNotDownload() then 
		if GetNumFromJsonTable(json_data,"needupdate") then 
			GameConstant.needUpdate = GetNumFromJsonTable(json_data,"needupdate");
		end
	end

	if GetNumFromJsonTable(json_data,"isFirstPopu") then 
		GameConstant.isFirstPopu = GetNumFromJsonTable(json_data,"isFirstPopu");
	end

	GameConstant.openid = uid;
	GameConstant.opentoken = token;
	GameConstant.username = userName;

	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	AoTiannction name      : QQLogin.logout
	description  	   : QQ登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
AoTianLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then 
		self.m_data.loginType = PlatformConfig.AoTianLogin; 
		local dataStr = json.encode(self.m_data);
		native_to_java(kLogoutPlatform,dataStr);
	end
end

--[[
	AoTiannction name      : QQLogin.clearGameData
	description  	   : 清除QQ登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
AoTianLogin.clearGameData = function(self)
	GameConstant.openid = nil;
	GameConstant.opentoken = nil;
	GameConstant.username = nil;
	self.super.clearGameData( self );
end

--[[
	AoTiannction name      : QQLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
AoTianLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.openid = GameConstant.openid;
	send_data.opentoken = GameConstant.opentoken;
	send_data.username = GameConstant.username;

	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	send_data.localtoken = localtoken;
	return send_data;
end

--global parameters to request the http,saving for a map.
AoTianLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = AoTianLogin.requestLoginCallBack,
};


