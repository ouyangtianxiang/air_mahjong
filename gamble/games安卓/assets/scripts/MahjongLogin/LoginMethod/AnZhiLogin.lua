--[[
	className    	     :  AnZhiLogin
	Description  	     :  登录类-子类(安智登录)
	last-modified-date   :  Feb.12 2014
	create-time 	     :  Feb.12 2014
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

AnZhiLogin = class(BaseLogin);

--[[
	function name      : AnZhiLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
AnZhiLogin.ctor = function (self,data )
	self.m_loginMethod = PlatformConfig.AnZhiLogin;
end

--[[
	function name      : AnZhiLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
AnZhiLogin.dtor = function (self )
end

AnZhiLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityAnZhi;
end
AnZhiLogin.getLoginType = function(self)
	return PlatformConfig.AnZhiLogin;
end
--[[
	function name      : AnZhiLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
AnZhiLogin.login = function ( self, ... )
	umengStatics_lua(kUmengAnZhiLogin);
	self.super.login(self);
	self.m_data = k91LoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.AnZhiLogin);
	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.AnZhiLogin;
	else 
		self.m_data.loginType = PlatformConfig.AnZhiLogin;
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : AnZhiLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
AnZhiLogin.requestLoginCallBack = function (self, isSuccess, data)
	PlatformFactory.curPlatform:setAPI(PlatformConfig.AnZhiLogin);
	GameConstant.requestLogin = false;
	if isSuccess then 
		local msg;
		if kNumOne ==  GetNumFromJsonTable(data,kStatus) then
			GameConstant.isLogin = kAlreadyLogin;
			GameConstant.lastLoginType = PlatformConfig.AnZhiLogin;
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

AnZhiLogin.getLoginIdentityIcon = function(self)
	return "Login/anzhiIcon.png";
end

AnZhiLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : AnZhiLogin.loginCallback
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
AnZhiLogin.loginCallback = function(self,json_data)
	local uid = kNullStringStr;
	local sid = kNullStringStr;
	local loginName = kNullStringStr;

	if GetStrFromJsonTable(json_data,"uid") and kNullStringStr ~= GetStrFromJsonTable(json_data,"uid") then
		uid = GetStrFromJsonTable(json_data,"uid");
	end

	if GetStrFromJsonTable(json_data,"sid") and kNullStringStr ~= GetStrFromJsonTable(json_data,"sid") then
		sid = GetStrFromJsonTable(json_data,"sid");
	end

	if GetStrFromJsonTable(json_data,"login_name") and kNullStringStr ~= GetStrFromJsonTable(json_data,"login_name") then
		loginName = GetStrFromJsonTable(json_data,"login_name");
	end

	DebugLog("uid : " .. uid);
	DebugLog("sid :" .. sid);
	DebugLog("loginName :" .. loginName);
	if uid == "-1" then 
		self:logout();
		return;
	end
	
	GameConstant.uid = uid;
	GameConstant.sid = sid;
	GameConstant.loginName = loginName;

	
	--不是登出的时候
	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

AnZhiLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	
	if isPlatform_Win32() then 
    	send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
		send_data.localtoken = localtoken;

	else
		send_data.uid = GameConstant.uid;
		send_data.sid = GameConstant.sid;
		send_data.loginName = GameConstant.loginName;
		send_data.localtoken = localtoken;
		
    end
	
	return send_data;
end

--[[
	function name      : AnZhiLogin.clearGameData
	description  	   : 清除游客的信息
	param 	 	 	   : self
	last-modified-date : Feb.12 2014
	create-time		   : Feb.12 2014
]]
AnZhiLogin.clearGameData = function(self)
	GameConstant.loginName = nil;
	GameConstant.uid = nil;
	GameConstant.sid = nil;
	self.super.clearGameData( self );
end

AnZhiLogin.logout = function(self)
	--self.super.logout( self );
	self:clearGameData();
	-- SocketManager.getInstance():syncClose(); -- 关闭socket
	if HallScene_instance then
		if HallScene_instance.m_socialLayer then 
			HallScene_instance.m_socialLayer:clearViews()
		end
	end
	showOrHide_sprite_lua(0);
end

--global parameters to request the http,saving for a map.
AnZhiLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = AnZhiLogin.requestLoginCallBack,
};


