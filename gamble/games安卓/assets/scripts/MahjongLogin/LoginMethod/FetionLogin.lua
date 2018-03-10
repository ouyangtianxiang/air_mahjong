--[[
	className    	     :  FetionLogin
	Description  	     :  登录类-子类(飞信登录)
	last-modified-date   :  Dec.23 2013
	create-time 	     :  Oct.29 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

local KEY_REFRESH_TOKEN = "REFRESH_TOKEN";

FetionLogin = class(BaseLogin);

--[[
	function name      : FetionLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
FetionLogin.ctor = function (self,data )
	self.appId = "7086";
end

--[[
	function name      : FetionLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.23  2013
	create-time		   : Dec.23  2013
]]
FetionLogin.dtor = function (self )
end

FetionLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityFETION;
end

FetionLogin.getLoginType = function(self)
	return PlatformConfig.FetionLogin;
end

--[[
	function name      : FetionLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
FetionLogin.login = function ( self, ... )
	umengStatics_lua(kUmengFetionLogin);

	Loading.showLoadingAnim(PromptMessage.loadingLogin);

	self.super.login(self);
	self.m_data = kFetionLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.FetionLogin);
	PlatformFactory.curPlatform.curLoginType = PlatformConfig.FetionLogin;
	if isPlatform_Win32() then
		self:loginOnPHP(self.m_data.fetionDefaultLoginToken);
	else 
		self:fetionLogin();
	end
end

FetionLogin.fetionLogin = function ( self )
	-- body
	local refressToken = self:getToken(KEY_REFRESH_TOKEN);

	self.m_data.loginType = PlatformConfig.FetionLogin;
	self.m_data.token 		= refressToken or ""; 
	native_muti_login(self.m_data)
end

--登录PHP服务器
FetionLogin.loginOnPHP 	  = function ( self, accessToken )
	-- body
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	param = {};
	param.token 			= accessToken;
    param.mobile 			= {}; --上报设备信息
	param.mobile.dtype 		= GameConstant.model_name; --手机型号
	param.mobile.pixel 		= GameConstant.rat; --机屏大小
	param.mobile.imei 		= GameConstant.imei;  --设备号
	param.mobile.os 		= GameConstant.osv;    --终端操作系统
	param.mobile.network 	= GameConstant.net; --接入方式，例如wifi
	param.mobile.operator 	= GameConstant.operator; --运营商
	param.localtoken 		= localtoken;

	HttpModule.getInstance():execute(HttpModule.s_cmds.fetionLogin,param,self.m_event);
end
--登录返回
FetionLogin.onLoginOnPHP = function (self, isSuccess, data )
	
	PlatformFactory.curPlatform:setAPI(PlatformConfig.FetionLogin);
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
		EventDispatcher.getInstance():dispatch(BaseLogin.loginResuleEvent,isSuccess,data);
	else
		GameConstant.isLogin = kNoLogin;
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
	end

	Loading.hideLoadingAnim();
end

FetionLogin.getLoginIdentityIcon = function(self)
	return "Login/fetionIcon.png";
end

FetionLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : FetionLogin.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
FetionLogin.loginCallback = function(self,json_data)
	local stat = GetStrFromJsonTable(json_data,"stat") or -1;
	local code = GetStrFromJsonTable(json_data,"code") or "";

	if PlatformFactory.curPlatform:needFirstNotDownload() then 
		if GetNumFromJsonTable(json_data,"needupdate") then 
			GameConstant.needUpdate = GetNumFromJsonTable(json_data,"needupdate");
		end
	end

	stat = tonumber(stat);

	if stat < 0 or not code then
		Banner.getInstance():showMsg(PromptMessage.loginFailed);
		Loading.hideLoadingAnim();
	else
		self:loginOnPHP(code);
		self:saveToken(KEY_REFRESH_TOKEN, code);
	end

end

--[[
	function name      : FetionLogin.logout
	description  	   : QQ登出的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
FetionLogin.logout = function(self)
	self.super.logout( self );
	if not isPlatform_Win32() then 
		self.m_data.loginType = PlatformConfig.FetionLogin; 
		local dataStr = json.encode(self.m_data);
		native_to_java(kLogoutPlatform,dataStr);
	end
end

--[[
	function name      : FetionLogin.clearGameData
	description  	   : 清除QQ登陆的信息
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
FetionLogin.clearGameData = function(self)
	self.super.clearGameData( self );
end


--保存Token信息
FetionLogin.saveToken = function ( self, key, value )
	-- body
	local file 	= new(Dict, "FetionLogin");
	file:load();
	file:setString(key, value);
	file:save();
	file:delete();
	delete(file);
	file = nil;
end

--读取Token信息
FetionLogin.getToken = function ( self, key )
	-- body
	local file 	= new(Dict, "FetionLogin");
	file:load();
	local value = file:getString(key);
	file:delete();
	delete(file);
	file = nil;
	if value and string.len(value) == 0 then
		value = nil;
	end
	return value;
end

--[[
	function name      : FetionLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]


--global parameters to request the http,saving for a map.
FetionLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.fetionLogin] 				= FetionLogin.onLoginOnPHP,
};



