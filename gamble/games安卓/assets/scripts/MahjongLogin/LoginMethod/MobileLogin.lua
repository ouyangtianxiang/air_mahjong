--[[
	className    	     :  MobileLogin
	Description  	     :  登录类-子类(移动基地登录)
	last-modified-date   :  Jan.17 2014
	create-time 	     :  Jan.17 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

MobileLogin = class(BaseLogin);

--[[
	function name      : MobileLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Jan.17 2014
	create-time		   : Jan.17 2014
]]
MobileLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.Mobile2Login;

end

--[[
	function name      : MobileLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Jan.17 2014
	create-time		   : Jan.17 2014
]]
MobileLogin.dtor = function (self )
end

MobileLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityMobile;
end
MobileLogin.getLoginType = function(self)
	return PlatformConfig.Mobile2Login;
end
--[[
	function name      : MobileLogin.login
	description  	   : @Override
	param 	 	 	   : self
	last-modified-date : Jan.17 2014
	create-time		   : Jan.17 2014
]]
MobileLogin.login = function ( self, ... )
	umengStatics_lua(kUmengMobileLogin);
	self.super.login(self);
	self.m_data = kGuestLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.Mobile2Login);
	if isPlatform_Win32() then 
		GameConstant.name = self.m_data.guestDefaultName;
		GameConstant.imei = SystemGetSitemid();
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else 
		self.m_data.loginType = PlatformConfig.Mobile2Login;
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : MobileLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Jan.17 2014
	create-time		   : Jan.17 2014
]]
MobileLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	if isSuccess then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			GameConstant.lastLoginType = PlatformConfig.Mobile2Login;
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

MobileLogin.getLoginIdentityIcon = function(self)
	return "Login/mobileIcon.png";
end

MobileLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : MobileLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Jan.17 2014
	create-time		   : Jan.17 2014
]]
MobileLogin.loginCallback = function(self,json_data)
	self.m_sitemid = GetStrFromJsonTable(json_data, "imei", GameConstant.imei)
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

--[[
	function name      : MobileLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Jan.17 2014
	create-time		   : Jan.17 2014
]]
MobileLogin.clearGameData = function(self)
	self.m_sitemid = nil;
	self.m_nickName = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : MobileLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Jan.17 2014
	create-time		   : Jan.17 2014
]]
MobileLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	send_data.localtoken = localtoken;
	send_data.nick = self.m_nickName;
	send_data.sitemid = self.m_sitemid;
	send_data.macAddress = GameConstant.macAddress;
	return send_data;
end

--global parameters to request the http,saving for a map.
MobileLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = MobileLogin.requestLoginCallBack,
};

