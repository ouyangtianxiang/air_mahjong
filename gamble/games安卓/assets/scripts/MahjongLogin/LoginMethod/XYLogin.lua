--[[
	className    	     :  XYLogin
	Description  	     :  登录类-子类(QQ登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");
require("MahjongHttp/HttpModule");
XYLogin = class(BaseLogin);

--[[
	function name      : XYLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
XYLogin.ctor = function (self,data )
	self.appId = PlatformFactory.curPlatform:getLoginAppId( PlatformConfig.XYLogin);
end

--[[
	function name      : XYLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
XYLogin.dtor = function (self )
end

XYLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityXYAssistant;
end

XYLogin.getLoginType = function(self)
	return PlatformConfig.XYLogin;
end

--[[
	function name      : XYLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
XYLogin.login = function ( self, ... )
	umengStatics_lua(kUmengXYLogin);
	self.super.login(self);
	self.m_data = kXYLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.XYLogin);
	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.XYLogin;

	else 
		local param = {};
		param.loginType = PlatformConfig.XYLogin;
		native_muti_login(param)
	end
end

--[[
	function name      : XYLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
XYLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.XYLogin);
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
	EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
	
end

XYLogin.getLoginIdentityIcon = function(self)
	return "Login/xyIcon.png";
end

XYLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : XYLogin.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
XYLogin.loginCallback = function(self,json_data)
	local uid = kNullStringStr;
	local token = kNullStringStr;
	GameConstant.isFirstPopu = 1;

	if GetStrFromJsonTable(json_data,"uid") and kNullStringStr ~= GetStrFromJsonTable(json_data,"uid") then
	 	uid = GetStrFromJsonTable(json_data,"uid");
	end

	if GetStrFromJsonTable(json_data,"token") and kNullStringStr ~= GetStrFromJsonTable(json_data,"token") then
		token = GetStrFromJsonTable(json_data,"token");
	end

	if PlatformFactory.curPlatform:needFirstNotDownload() then 
		if GetNumFromJsonTable(json_data,"needupdate") then 
			GameConstant.needUpdate = GetNumFromJsonTable(json_data,"needupdate");
		end
	end

	if GetNumFromJsonTable(json_data,"isFirstPopu") then 
		GameConstant.isFirstPopu = GetNumFromJsonTable(json_data,"isFirstPopu");
	end

	GameConstant.uid=uid;
	GameConstant.token=token;

	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	function name      : XYLogin.logout
	description  	   : QQ登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
XYLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then 
		self.m_data.loginType = PlatformConfig.XYLogin; 
		local dataStr = json.encode(self.m_data);
		native_to_java(kLogoutPlatform,dataStr);
	end
end

--[[
	function name      : XYLogin.clearGameData
	description  	   : 清除QQ登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
XYLogin.clearGameData = function(self)
	GameConstant.uid = nil;
	GameConstant.token = nil;
	self.super.clearGameData( self );
end

--[[
	function name      : XYLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
XYLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	send_data.uid = GameConstant.uid;
	send_data.token = GameConstant.token;

	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	send_data.localtoken = localtoken;
	return send_data;
end

--global parameters to request the http,saving for a map.
XYLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = XYLogin.requestLoginCallBack,
};

