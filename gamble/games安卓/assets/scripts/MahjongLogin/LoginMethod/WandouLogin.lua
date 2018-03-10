--[[
	className    	     :  WandouLogin
	Description  	     :  登录类-子类(游客登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

WandouLogin = class(BaseLogin);

--[[
	function name      : WandouLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
WandouLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.WandouLogin;
end

--[[
	function name      : WandouLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
WandouLogin.dtor = function (self )
end

WandouLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityWanDouJia;
end
WandouLogin.getLoginType = function(self)
	return PlatformConfig.WandouLogin;
end
--[[
	function name      : WandouLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WandouLogin.login = function ( self, isQuickLogin )
	umengStatics_lua(kUmengWandouLogin);
	self.super.login(self);
	self.m_data = kWandouLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.WandouLogin);

	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.WandouLogin;
	else 
		self.m_data.loginType = PlatformConfig.WandouLogin;
		if isQuickLogin then 
			self.m_data.loginType = PlatformConfig.WandouLogin;
		end
		native_muti_login(self.m_data)
	end
end

WandouLogin.logout = function(self)
	self.super.logout(self);
	self.m_data.loginType = PlatformConfig.WandouLogin;
	local dataStr = json.encode(self.m_data);
	native_to_java(kLogoutPlatform,dataStr);
end

--[[
	function name      : WandouLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WandouLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;

	PlatformFactory.curPlatform:setAPI(PlatformConfig.WandouLogin);
	if isSuccess and data then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			GameConstant.lastLoginType = PlatformConfig.WandouLogin;
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

WandouLogin.getLoginIdentityIcon = function(self)
	return "Login/wandouIcon.png";
end

WandouLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : WandouLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WandouLogin.loginCallback = function(self,json_data)

	local wdj_uid = kNullStringStr;
	local wdj_token = kNullStringStr;
	GameConstant.isFirstPopu = 1;

	if GetStrFromJsonTable(json_data,"wdj_uid") and kNullStringStr ~= GetStrFromJsonTable(json_data,"wdj_uid") then
		wdj_uid = GetStrFromJsonTable(json_data,"wdj_uid");
	end

	if GetStrFromJsonTable(json_data,"wdj_token") and kNullStringStr ~= GetStrFromJsonTable(json_data,"wdj_token") then
		wdj_token = GetStrFromJsonTable(json_data,"wdj_token");
	end

	if wdj_uid == kNullStringStr then 
		self:logout();
		return;
	end

	GameConstant.wdj_uid = wdj_uid;
	GameConstant.wdj_token = wdj_token;

	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

WandouLogin.logout = function(self)
	--self.super.logout( self );
	self:clearGameData();
	SocketManager.getInstance():syncClose(); -- 关闭socket
	if HallScene_instance then
		if HallScene_instance.m_socialLayer then 
			HallScene_instance.m_socialLayer:clearViews()
		end
	end
	showOrHide_sprite_lua(0);
end

--[[
	function name      : WandouLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WandouLogin.clearGameData = function(self)
	GameConstant.wdj_uid = nil;
	GameConstant.wdj_token = nil;

	self.super:clearGameData();
end

--[[
	function name      : WandouLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
WandouLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	if isPlatform_Win32() then 
		send_data.localtoken = localtoken;
    	send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
	else
		send_data.uid = GameConstant.wdj_uid;
		send_data.localtoken = localtoken;
		send_data.token = GameConstant.wdj_token;
		send_data.macAddress = GameConstant.macAddress;
    end
	
	return send_data;
end

--global parameters to request the http,saving for a map.
WandouLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = WandouLogin.requestLoginCallBack,
};