--[[
	className    	     :  GuestLogin
	Description  	     :  登录类-子类(游客登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

NewGuestLogin = class(BaseLogin);

--[[
	function name      : GuestLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
NewGuestLogin.ctor = function (self,data )
	self.appId = PlatformFactory.curPlatform:getLoginAppId( PlatformConfig.GuestLogin );
	self.m_loginMethod = PlatformConfig.NewGuestLogin;
end

--[[
	function name      : GuestLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
NewGuestLogin.dtor = function (self )
end

NewGuestLogin.getLoginUserName = function(self)
	if PlatformConfig.platformContest == GameConstant.platformType then 
		return CreatingViewUsingData.commonData.userIdentityContest;
	else
		return CreatingViewUsingData.commonData.userIdentityGuest;
	end
end
NewGuestLogin.getLoginType = function(self)
	return PlatformConfig.NewGuestLogin;
end
--[[
	function name      : GuestLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewGuestLogin.login = function ( self, ... )
	umengStatics_lua(kUmengGuestLogin);
	self.super.login(self);
	self.m_data = kGuestLoginConfig;
	local temp = self.m_data.guestDefaultImei;
	self.m_data.guestDefaultImei = temp;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.GuestLogin);
	if isPlatform_Win32() then 
		self.m_nickName = self.m_data.guestDefaultName;
		self.m_sitemid = SystemGetSitemid();
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else 
		self.m_data.loginType = PlatformConfig.NewGuestLogin;
		--直接创建游客登录
		self.m_sitemid = GameConstant.imei
		self.m_nickName = GameConstant.model_name
		self:OnRequestLoginPHP(self:setSendLoginPHPdata())
	end
end

--[[
	function name      : NewGuestLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewGuestLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;

	PlatformFactory.curPlatform:setAPI(PlatformConfig.NewGuestLogin);
	if isSuccess and data then 
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

		if data.userinfo and data.userinfo.visitorBounded then
			self.visitorBounded = tonumber(data.userinfo.visitorBounded) == 1;
		end

		GameConstant.lastLoginType = PlatformConfig.NewGuestLogin;
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end
	EventDispatcher.getInstance():dispatch(self.loginResuleEvent,isSuccess,data);
end

NewGuestLogin.getLoginIdentityIcon = function(self)
	return "Login/guestIcon.png";
end

NewGuestLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : NewGuestLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewGuestLogin.clearGameData = function(self)
	-- GameConstant.imei = nil;
	-- GameConstant.name = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : NewGuestLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
NewGuestLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.nick = GameConstant.name;
	if DEBUGMODE == 1 then
		send_data.sitemid = self.m_sitemid..GameConstant.NewUserLoginRegTime;
		send_data.macAddress = GameConstant.macAddress..GameConstant.NewUserLoginRegTime;
	else
		send_data.macAddress = GameConstant.macAddress;
	end
	return send_data;
end


