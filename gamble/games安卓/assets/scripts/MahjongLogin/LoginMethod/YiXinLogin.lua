--[[
	className    	     :  YiXinLogin
	Description  	     :  登录类-子类(易信登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

YiXinLogin = class(BaseLogin);

--[[
	function name      : YiXinLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
YiXinLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.YiXinLogin;
end

--[[
	function name      : YiXinLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
YiXinLogin.dtor = function (self )
end

YiXinLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityYiXin;
end

YiXinLogin.getLoginType = function(self)
	return PlatformConfig.YiXinLogin;
end
--[[
	function name      : YiXinLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
YiXinLogin.login = function ( self, ... )
	umengStatics_lua(kUmengYiXinLogin);
	self.super.login(self);
	self.m_data = kGuestLoginConfig;
	if isPlatform_Win32() then 
		PlatformFactory.curPlatform:setAPI(PlatformConfig.GuestLogin);
		GameConstant.name = self.m_data.guestDefaultName;
		GameConstant.imei = SystemGetSitemid();
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform:setAPI(PlatformConfig.YiXinLogin);
		GameConstant.accessToken = "91e49831-4446-4618-bbfe-4cccfff34d16";
	else 
		self.m_data.loginType = PlatformConfig.YiXinLogin;
		self.m_data.loginTo2345Result = tonumber(GameConstant.tf_result);
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : YiXinLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
YiXinLogin.requestLoginCallBack = function (self, isSuccess, data)
	DebugLog("YiXinLogin.requestLoginCallBack")
	GameConstant.requestLogin = false;

	if isSuccess and data then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.lastLoginType = PlatformConfig.YiXinLogin;
			GameConstant.isLogin = kAlreadyLogin;
		else
			GameConstant.isLogin = kNoLogin;
			msg = GetStrFromJsonTable(data,kMsg);
		end
		if msg ~= nil and kNullStringStr ~= msg then 
			Banner.getInstance():showMsg(msg);
		end

		if data.userinfo and data.userinfo.visitorBounded then
			self.visitorBounded = tonumber(data.userinfo.visitorBounded) == 1;
		end
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
end

YiXinLogin.getLoginIdentityIcon = function(self)
	return "Login/yixinLoginIcon.png";
end

YiXinLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : YiXinLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
YiXinLogin.loginCallback = function(self,json_data)

	local token = kNullStringStr;
	local gameId = kNullStringStr;
	
	GameConstant.isFirstPopu = 1;

	if GetStrFromJsonTable(json_data,"token") and kNullStringStr ~= GetStrFromJsonTable(json_data,"token") then
		token = GetStrFromJsonTable(json_data,"token");
	end

	if GetStrFromJsonTable(json_data,"gameId") and kNullStringStr ~= GetStrFromJsonTable(json_data,"gameId") then
		gameId = GetStrFromJsonTable(json_data,"gameId");
	end

	if token == kNullStringStr then 
		Loading.hideLoadingAnim();
		return;
	end
	
	GameConstant.accessToken =token;
	GameConstant.yxGameId = gameId;
		
	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	function name      : YiXinLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
YiXinLogin.clearGameData = function(self)
	GameConstant.accessToken = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : YiXinLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
YiXinLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	if isPlatform_Win32() then 
		send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
	else
		send_data.accessToken = GameConstant.accessToken;
	end
	
	return send_data;
end

