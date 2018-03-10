--[[
	className    	     :  Assistant91Login
	Description  	     :  登录类-子类(91助手登录)
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

Assistant91Login = class(BaseLogin);

--[[
	function name      : Assistant91Login.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.ctor = function (self,data )
	self.appId 	= "491";
end

--[[
	function name      : Assistant91Login.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.dtor = function (self )
end

Assistant91Login.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentity91;
end
Assistant91Login.getLoginType = function(self)
	return PlatformConfig.Assistant91Login;
end
--[[
	function name      : Assistant91Login.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.login = function ( self, ... )
	umengStatics_lua(kUmengAssistant91Login);
	self.super.login(self);
	self.m_data = k91LoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.Assistant91Login);
	if isPlatform_Win32() then 
		GameConstant.name = self.m_data.guestDefaultName;
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = 1;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = 16;
	else 
		self.m_data.loginType = PlatformConfig.Assistant91Login;
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : Assistant91Login.switchLogin
	description  	   : 切换账户 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.switchLogin = function ( self, ... )
	umengStatics_lua(kUmengAssistant91SwitchLogin);
	PlatformFactory.curPlatform:setAPI(PlatformConfig.Assistant91Login);
	if isPlatform_Win32() then 
		GameConstant.name = self.m_data.guestDefaultName;
		GameConstant.imei = SystemGetSitemid();
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
	else 
		self.m_data.loginType = PlatformConfig.Assistant91Login;
		local dataStr = json.encode(self.m_data);
		native_to_java(kSwitchPlatform,dataStr);
	end
end

Assistant91Login.getLoginIdentityIcon = function(self)
	return "Login/91Icon.png";
end

--[[
	function name      : Assistant91Login.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.requestLoginCallBack = function (self, isSuccess, data)
	PlatformFactory.curPlatform:setAPI(PlatformConfig.Assistant91Login);
	GameConstant.requestLogin = false;
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

Assistant91Login.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : Assistant91Login.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.loginCallback = function(self,json_data)
	local imei = kNullStringStr;
	local name = kNullStringStr;
	local style = kNullStringStr;
	local token = kNullStringStr;
	local sid = kNullStringStr;

	if GetStrFromJsonTable(json_data,kLoginImei) and kNullStringStr ~= GetStrFromJsonTable(json_data,kLoginImei) then
	 	imei = GetStrFromJsonTable(json_data,kLoginImei);
	end

	if GetStrFromJsonTable(json_data,kLoginName) and kNullStringStr ~= GetStrFromJsonTable(json_data,kLoginName) then
		name = GetStrFromJsonTable(json_data,kLoginName);
	end

	if GetStrFromJsonTable(json_data,kLoginStyle) and kNullStringStr ~= GetStrFromJsonTable(json_data,kLoginStyle) then
		style = GetStrFromJsonTable(json_data,kLoginStyle);
	end

	if GetStrFromJsonTable(json_data,kSid) and kNullStringStr ~= GetStrFromJsonTable(json_data,kSid) then
		sid = GetStrFromJsonTable(json_data,kSid);
	end

	if GetStrFromJsonTable(json_data,kToken) and kNullStringStr ~= GetStrFromJsonTable(json_data,kToken) then
		token = GetStrFromJsonTable(json_data,kToken);
	end


	DebugLog("imei : " .. imei);
	DebugLog("name : " .. name);
	DebugLog("sid :" .. sid);
	DebugLog("token :" .. token);
	DebugLog("style :" .. style);
		
	if GameConstant.imei == imei and GameConstant.name == name and GameConstant.isLogin ~= kNoLogin then 
		return ;
	end
	if GameConstant.imei and GameConstant.name and GameConstant.imei ~= imei and GameConstant.isLogin == kAlreadyLogin then 
		self:logout();
	end

	GameConstant.imei=imei;
	GameConstant.name=name;

	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

Assistant91Login.logout = function(self)
	self.super.logout( self );
	if HallController_instance then
		HallController_instance.m_view:closeAllPopuWnd(); 
	end
end

--[[
	function name      : Assistant91Login.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.clearGameData = function(self)
	GameConstant.imei = nil;
	GameConstant.name = nil;

	self.super.clearGameData( self );
end

--[[
	function name      : Assistant91Login.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
Assistant91Login.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	send_data.localtoken = localtoken;
	send_data.nick = GameConstant.name;
	send_data.sitemid = GameConstant.imei;
	send_data.macAddress = GameConstant.macAddress;
	return send_data;
end

--global parameters to request the http,saving for a map.
Assistant91Login.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = Assistant91Login.requestLoginCallBack,
};

