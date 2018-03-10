--[[
	className    	     :  LenovoLogin
	Description  	     :  登录类-子类(联想登录)
	last-modified-date   :  Dec.20 2013
	create-time 	     :  Dec.18 2013
	last-modified-author :  ClarkWu
	create-author        :  ClarkWu
]]
require("MahjongLogin/LoginMethod/BaseLogin");

LenovoLogin = class(BaseLogin);

--[[
	function name      : LenovoLogin.ctor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20  2013
	create-time		   : Dec.20  2013
]]
LenovoLogin.ctor = function (self,data )
	self.appId = "562";
end

--[[
	function name      : LenovoLogin.dtor
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.20  2013
	create-time		   : Dec.20  2013
]]
LenovoLogin.dtor = function (self )
end

LenovoLogin.getLoginUserName = function(self)
	return CreatingViewUsingData.commonData.userIdentityLenovo;
end
LenovoLogin.getLoginType = function(self)
	return PlatformConfig.LenovoLogin;
end
LenovoLogin.getLoginIdentityIcon = function(self)
	return "Login/lenovoIcon.png";
end

--[[
	function name      : LenovoLogin.login
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
LenovoLogin.login = function ( self, ... )
	umengStatics_lua(kUmeng360Login);
	self.super.login(self);
	self.m_data = kLenovoLoginConfig;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.LenovoLogin);
	local dataStr = json.encode(self.m_data);
	if isPlatform_Win32() then 
		GameConstant.name = kGuestLoginConfig.guestDefaultImei or "AF3B5CECA7C8A95A43438FF35F3CA50B";
		GameConstant.imei = SystemGetSitemid();
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.GuestLogin;
		self:OnRequestLoginPHP(self:setSendLoginPHPdata());
		PlatformFactory.curPlatform.curLoginType = PlatformConfig.LenovoLogin;
	else 
		self.m_data.loginType = PlatformConfig.LenovoLogin;
		native_muti_login(self.m_data)
	end
end

--[[
	function name      : LenovoLogin.requestLoginCallBack
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
LenovoLogin.requestLoginCallBack = function (self, isSuccess, data)
	GameConstant.requestLogin = false;
	PlatformFactory.curPlatform:setAPI(PlatformConfig.LenovoLogin);
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

LenovoLogin.callEvent = function(self, key, data)
	self.super.callEvent(self, key, data);
end

--[[
	function name      : LenovoLogin.callEvent
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
LenovoLogin.loginCallback = function(self,json_data)
	local lpsust = kNullStringStr;
    local realm = kNullStringStr;

	if GetStrFromJsonTable(json_data,"lpsust") and kNullStringStr ~= GetStrFromJsonTable(json_data,"lpsust") then
		lpsust = GetStrFromJsonTable(json_data,"lpsust");
	end

	if GetStrFromJsonTable(json_data,"realm") and kNullStringStr ~= GetStrFromJsonTable(json_data,"realm") then
		realm = GetStrFromJsonTable(json_data,"realm");
	end

	DebugLog("lpsust" .. lpsust .. ";realm:" .. realm);
	GameConstant.lpsust = lpsust;
    GameConstant.realm = realm;
    	
	self:OnRequestLoginPHP(self:setSendLoginPHPdata());
end

--[[
	function name      : LenovoLogin.logout
	description  	   : 奇虎登出的信息
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
LenovoLogin.logout = function(self)
	self:clearGameData();
	self.super.logout( self );
end

--[[
	function name      : LenovoLogin.clearGameData
	description  	   : 清除奇虎登陆的信息
	param 	 	 	   : self
	last-modified-date : Dec.18  2013
	create-time		   : Dec.18  2013
]]
LenovoLogin.clearGameData = function(self)
	GameConstant.lpsust = nil;
	GameConstant.realm = nil;
	self.super.clearGameData( self );
end

--[[
	function name      : LenovoLogin.setSendLoginPHPdata
	description  	   : @Override 
	param 	 	 	   : self
	last-modified-date : Nov.29 2013
	create-time		   : Nov.29 2013
]]
LenovoLogin.setSendLoginPHPdata = function(self)
	local send_data = {};
	local localtoken = g_DiskDataMgr:getAppData(kLocalToken .. self:getLoginType(),"");
	if isPlatform_Win32() then 
		send_data.localtoken = localtoken;
    	send_data.nick = GameConstant.name;
		send_data.sitemid = GameConstant.imei;
		send_data.macAddress = GameConstant.macAddress;
	else
		send_data.localtoken = localtoken;
	    send_data.lpsust = GameConstant.lpsust;
	    send_data.realm = GameConstant.realm; 
	end
	return send_data;
end

--global parameters to request the http,saving for a map.
LenovoLogin.httpRequestsCallBackFuncMap =
{
	[HttpModule.s_cmds.requestLogin] = LenovoLogin.requestLoginCallBack,
};

