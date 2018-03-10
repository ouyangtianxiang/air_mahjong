--[[
	className    	     :  SouGouLogin
	Description  	     :  登录类-子类(91助手登录)
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

SouGouLogin = class(BaseLogin);

--[[
	function name      : SouGouLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.ctor = function (self,data )
	self.appId = "539";
end

--[[
	function name      : SouGouLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.dtor = function (self )
end

SouGouLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentitySouGou;
end

SouGouLogin.getLoginType = function(self)
	return PlatformConfig.SouGouLogin;
end

--[[
	function name      : SouGouLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.quickLogin = function ( self, ... )
	umengStatics_lua(kUmengSouGouLogin);
	self.super.login(self);
	self.m_data = kSouGouLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.SouGouLogin);
	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.SouGouLogin;
	else 
		self.m_data.loginType = PlatformConfig.SouGouLogin; 
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : SouGouLogin.switchLogin
	description  	   : 切换账户 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.login = function ( self, ... )
	umengStatics_lua(kUmengAssistant91SwitchLogin);
	PlatformFactory.curPlatform:setAPI(PlatformConfig.SouGouLogin);
	if isPlatform_Win32() then 
		GameConstant.userId = self.m_data.userId;
		GameConstant.sessionKey = self.m_data.sessionKey;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else 
		self.m_data.loginType = PlatformConfig.SouGouLogin;
		native_to_java(kSwitchPlatform,json.encode(self.m_data));
	end
end

SouGouLogin.getLoginIdentityIcon = function(self)
	return "Login/SGIcon.png";
end

--[[
	function name      : SouGouLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.SouGouLogin);
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

SouGouLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : SouGouLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.loginCallback = function(self,json_data)
	local userId = 0;
	local sessionKey = "";

	if GetNumFromJsonTable(json_data,"userId") and kNullStringStr ~= GetNumFromJsonTable(json_data,"userId") then
	  	userId = GetNumFromJsonTable(json_data,"userId");
	end

	if GetStrFromJsonTable(json_data,"sessionKey") and kNullStringStr ~= GetStrFromJsonTable(json_data,"sessionKey") then
		sessionKey = GetStrFromJsonTable(json_data,"sessionKey");
	end


	DebugLog("userId : " .. userId);
	DebugLog("sessionKey : " .. sessionKey);
		
	if GameConstant.userId == userId and GameConstant.sessionKey == sessionKey and GameConstant.isLogin ~= kNoLogin then 
		DebugLog("已经登录了");
		return ;
	end

	if GameConstant.userId and GameConstant.sessionKey and GameConstant.userId ~= userId and GameConstant.isLogin == kAlreadyLogin then 
		self.super.logout( self );
		if HallController_instance then 
			HallController_instance.m_view:closeAllPopuWnd();
		end
	end

	GameConstant.userId=userId;
	GameConstant.sessionKey=sessionKey;


	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

SouGouLogin.logout = function (self)
	self.super.logout( self );
	if HallController_instance then
		HallController_instance.m_view:closeAllPopuWnd(); 
	end
end

--[[
	function name      : SouGouLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.clearGameData = function(self)
	GameConstant.userId = nil;
	GameConstant.sessionKey = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : SouGouLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
SouGouLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	if isPlatform_Win32() then 
		send_data.localtoken = localtoken;
    	send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
	else
		send_data.localtoken = localtoken;
		send_data.sgtoken = GameConstant.sessionKey;
		send_data.sitemid = GameConstant.userId;
	end
	return send_data;
end

--global parameters to request the http,saving for a map.
SouGouLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = SouGouLogin.requestLoginCallBack,
};

